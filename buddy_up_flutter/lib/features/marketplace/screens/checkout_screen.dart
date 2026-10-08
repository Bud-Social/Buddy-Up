import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_error.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/marketplace.dart';
import '../../../data/models/wallet.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/page_loader.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../providers/marketplace_provider.dart';
import '../utils/checkout.dart';
import '../utils/stations.dart';
import 'checkout_receipt_view.dart';
import 'checkout_widgets.dart';

/// Standalone checkout: review -> choose fulfillment -> choose payment ->
/// receipt.
///
/// This screen replaced two nested modals that used to live inside the cart, so
/// it owns the whole flow and is deep-linkable at `/marketplace/checkout`. The
/// rules that shape everything below are documented in `utils/checkout.dart`:
/// only offer a fulfillment type the cart can actually fulfill, and never
/// destroy the buyer's input on a failure.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final Map<String, String> _address = <String, String>{
    for (final field in kAddressFields) field: '',
  };
  final Set<String> _addressTouched = <String>{};

  String _fulfillmentType = 'digital';
  bool _fulfillmentTouched = false;
  bool _suggestionApplied = false;

  double? _lat;
  double? _lng;
  bool _locating = false;

  AsyncValue<List<PickupStation>>? _stations;
  bool _stationsDown = false;
  String? _stationsError;
  String? _stationId;
  String _stationQuery = '';
  String _manualPickup = '';

  /// Defaults to Artifacts the way the web checkout does, but the *effective*
  /// method is re-resolved against `methodEnabled` on every build — so a short
  /// wallet lands on null, i.e. nothing preselected, because Artifacts is then
  /// disabled. M-Pesa and Card are always offered, so a short cart never blocks
  /// the page outright.
  String? _paymentMethod = 'artifacts';
  final TextEditingController _mpesaController = TextEditingController();

  bool _attempted = false;
  bool _submitting = false;
  String? _serverError;

  CheckoutReceipt? _receipt;
  String? _placedFulfillmentType;
  Map<String, String>? _placedAddress;
  String? _placedStationName;
  String _placedManualPickup = '';

  PaymentIntentResult? _paymentIntent;
  String? _intentNote;

  Timer? _stationDebounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (ref.read(cartProvider).value == null) {
        ref.read(cartProvider.notifier).loadCart();
      }
      ref.read(balanceProvider.notifier).loadBalance();
      await _locate();
    });
  }

  @override
  void dispose() {
    _stationDebounce?.cancel();
    _mpesaController.dispose();
    super.dispose();
  }

  bool get _located => _lat != null && _lng != null;

  // ─── location ────────────────────────────────────────────────────────────

  Future<void> _locate() async {
    setState(() => _locating = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(timeLimit: Duration(seconds: 10)),
      );
      if (!mounted) return;
      setState(() {
        _lat = pos.latitude;
        _lng = pos.longitude;
      });
    } catch (_) {
      // A refused or unavailable location is not an error: the station picker
      // falls back to search.
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  // ─── station loading ──────────────────────────────────────────────────────

  /// One station query per pause in typing. The picker also filters the loaded
  /// list client-side, so the network round trip is only for widening the result
  /// set, not for every character.
  void _searchStations(String query) {
    _stationDebounce?.cancel();
    _stationDebounce = Timer(const Duration(milliseconds: 350), () {
      if (mounted) _loadStations(query);
    });
  }

  Future<void> _loadStations(String query) async {
    setState(() {
      _stations = const AsyncLoading();
      _stationsDown = false;
      _stationsError = null;
    });
    final repo = ref.read(marketplaceRepositoryProvider);
    final trimmed = query.trim();
    try {
      final raw = await repo.getStations(
        lat: _lat,
        lng: _lng,
        radiusKm: _located ? 25 : null,
        query: trimmed.isEmpty ? null : trimmed,
      );
      if (!mounted) return;
      final stations = sortStationsByDistance(stationList(raw['data']));
      setState(() {
        _stations = AsyncData(stations);
        // A station that vanished between two loads must not stay selected.
        if (_stationId != null && !stations.any((s) => s.id == _stationId)) {
          _stationId = null;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stations = const AsyncData([]);
        _stationsDown = isStationsUnavailable(e);
        _stationsError = stationsErrorMessage(
          e,
          fallback: 'Pickup stations could not be loaded.',
        );
      });
    }
  }

  /// Honour the cart endpoint's own suggestion once, and only when this cart can
  /// actually fulfill it. A buyer who has already chosen is never overridden.
  void _applySuggestedFulfillment(Cart cart) {
    if (_fulfillmentTouched || _suggestionApplied) return;
    final suggestion = cart.suggestedFulfillment;
    final suggested = suggestion?.type;
    if (suggested == null || suggested.isEmpty) return;
    _suggestionApplied = true;

    // The cart endpoint also volunteers a collection point; adopt it only while
    // the buyer has not typed one of their own.
    final pickup = suggestion?.detail['pickup_location'];
    if (pickup is String && pickup.isNotEmpty && _manualPickup.isEmpty) {
      _manualPickup = pickup;
    }

    // Only honour the suggested *type* when this cart can actually fulfill it.
    if (availableFulfillmentTypes(cart.items).contains(suggested)) {
      setState(() => _fulfillmentType = suggested);
    }
    if (_fulfillmentType == 'pickup' && _stations == null) {
      _loadStations('');
    }
  }

  void _onFulfillmentSelected(String value) {
    setState(() {
      _fulfillmentType = value;
      _fulfillmentTouched = true;
      _serverError = null;
    });
    if (value == 'pickup' && _stations == null) {
      _loadStations('');
    }
  }

  // ─── derived checkout state ───────────────────────────────────────────────

  Map<String, int> _regularBalance(BalanceResponse? balance) {
    final out = <String, int>{};
    for (final item in balance?.regularBalance ?? const <BalanceItem>[]) {
      out[item.artifactType] = item.quantity;
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: const BackButton(),
      ),
      body: cartAsync.when(
        loading: () => const PageLoader(),
        error: (e, _) => ErrorView(
          message: apiErrorMessage(e, fallback: 'We could not load your cart.'),
          onRetry: () => ref.read(cartProvider.notifier).loadCart(),
        ),
        data: (cart) {
          if (cart == null || cart.items.isEmpty) {
            return const EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'There is nothing to check out',
              subtitle: 'Add something from the marketplace first.',
            );
          }
          return _buildFlow(cart);
        },
      ),
    );
  }

  Widget _buildFlow(Cart cart) {
    final receipt = _receipt;
    if (receipt != null) {
      return CheckoutReceiptView(
        receipt: receipt,
        baseCurrency: cart.baseCurrency,
        localCurrency: cart.localCurrency,
        conversionRate: cart.conversionRate,
        paymentMethod: _paymentMethod ?? receipt.paymentMethod ?? 'artifacts',
        fulfillmentType: _placedFulfillmentType ?? receipt.fulfillmentType,
        paymentIntent: _paymentIntent,
        intentNote: _intentNote,
        stationName: _placedStationName,
        manualPickup: _placedManualPickup,
        address: _placedAddress,
        onViewOrder: () => context.push('/marketplace/orders/${receipt.orderId}'),
        onBackToMarketplace: () => context.go('/marketplace'),
      );
    }

    final cs = Theme.of(context).colorScheme;
    final items = cart.items;
    final totals = cart.totalArtifacts;
    if (!_suggestionApplied && !_fulfillmentTouched) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _applySuggestedFulfillment(cart);
      });
    }
    final payable = positiveArtifacts(totals);
    final balanceAsync = ref.watch(balanceProvider);
    final balance = balanceAsync.value;
    final balanceLoaded = balance != null;
    final regular = _regularBalance(balance);

    // Payment gate. The wallet read is the only evidence we have of what the
    // buyer holds, so a shortfall is only asserted once that read succeeded — an
    // unreadable balance is not proof of a shortage, and the server still has
    // the final say. M-Pesa and Card always work, which is why a short cart never
    // blocks the page outright.
    String? shortfallType;
    int? shortfallNeeded;
    int shortfallHave = 0;
    if (balanceLoaded) {
      for (final entry in payable.entries) {
        final have = regular[entry.key] ?? 0;
        if (have < entry.value) {
          shortfallType = entry.key;
          shortfallNeeded = entry.value;
          shortfallHave = have;
          break;
        }
      }
    }
    final methodEnabled = <String, bool>{
      'artifacts': shortfallType == null,
      'mpesa': true,
      'card': true,
    };
    final method =
        methodEnabled[_paymentMethod] == true ? _paymentMethod : null;

    final availableTypes = availableFulfillmentTypes(items);
    final fulfillment =
        availableTypes.contains(_fulfillmentType) ? _fulfillmentType : 'digital';
    final physical = hasPhysicalItem(items);
    final localTotal = cart.totalLocalCurrency > 0
        ? cart.totalLocalCurrency
        : cart.totalUsd * cart.conversionRate;

    final addressErrors = validateAddress(_address);
    String? errorFor(String field) =>
        (_attempted || _addressTouched.contains(field)) ? addressErrors[field] : null;

    final stationAsync = _stations;
    final stations = stationAsync?.value ?? const <PickupStation>[];
    final stationSelectionError = _attempted &&
            fulfillment == 'pickup' &&
            stations.isNotEmpty &&
            _stationId == null
        ? 'Choose the station you will collect from.'
        : null;
    final manualPickupError = _attempted &&
            fulfillment == 'pickup' &&
            stations.isEmpty &&
            _manualPickup.trim().isEmpty
        ? 'Enter where you will collect the order.'
        : null;
    final mpesaPhoneError = _attempted &&
            method == 'mpesa' &&
            !isValidPhone(_mpesaController.text.trim())
        ? 'Enter the M-Pesa number to charge, e.g. 0712 345 678.'
        : null;

    final selectedStation = stations
        .where((s) => s.id == _stationId)
        .firstOrNull;

    String payLabel;
    if (method == null) {
      payLabel = 'Confirm Order';
    } else if (method == 'artifacts') {
      payLabel = 'Pay ${artifactDisplay(totals)}'.trim();
    } else if (cart.conversionRate > 0) {
      payLabel = 'Pay ${cart.localCurrency} ${localTotal.toStringAsFixed(2)}';
    } else {
      payLabel = method == 'mpesa' ? 'Pay with M-Pesa' : 'Pay with Card';
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        OrderSummaryCard(cart: cart, savings: deriveSavings(items, totals)),
        const SizedBox(height: 12),
        FulfillmentCard(
          availableTypes: availableTypes,
          selected: fulfillment,
          physical: physical,
          suggestedType: cart.suggestedFulfillment?.type,
          onSelect: _onFulfillmentSelected,
          children: [
            if (fulfillment == 'delivery')
              DeliveryAddressForm(
                address: _address,
                errorFor: errorFor,
                onChanged: (field, value) {
                  setState(() => _address[field] = value);
                  _serverError = null;
                },
                onTouched: (field) => setState(() => _addressTouched.add(field)),
              ),
            if (fulfillment == 'pickup')
              StationPickerSection(
                async: stationAsync,
                located: _located,
                locating: _locating,
                unavailable: _stationsDown,
                error: _stationsError,
                query: _stationQuery,
                manualLocation: _manualPickup,
                selectedId: _stationId,
                selectionError: stationSelectionError,
                manualError: manualPickupError,
                onQueryChanged: (value) {
                  setState(() => _stationQuery = value);
                  _searchStations(value);
                },
                onManualChanged: (value) => setState(() {
                  _manualPickup = value;
                  _serverError = null;
                }),
                onSelect: (id) => setState(() {
                  _stationId = id;
                  _serverError = null;
                }),
                onUseLocation: _locate,
              ),
          ],
        ),
        const SizedBox(height: 12),
        PaymentCard(
          enabled: methodEnabled,
          selected: method,
          totals: totals,
          regular: regular,
          shortfallType: shortfallType,
          shortfallNeeded: shortfallNeeded,
          shortfallHave: shortfallHave,
          mpesaController: _mpesaController,
          mpesaError: mpesaPhoneError,
          onSelect: (value) => setState(() {
            _paymentMethod = value;
            _serverError = null;
            if (value == 'mpesa' &&
                _mpesaController.text.trim().isEmpty &&
                (_address['phone'] ?? '').trim().isNotEmpty) {
              _mpesaController.text = _address['phone']!.trim();
            }
          }),
          onPhoneChanged: () {
            _serverError = null;
            setState(() {});
          },
        ),
        if (shortfallType != null) ...[
          const SizedBox(height: 12),
          InlineNote(
            message: 'Not enough $shortfallType — this cart needs '
                '$shortfallNeeded, you have $shortfallHave. Top up in Wallet, or pay '
                'with M-Pesa or a card.',
            color: BuddyColors.red,
            borderColor: BuddyColors.red,
            icon: Icons.error_outline,
          ),
        ],
        if (_serverError != null) ...[
          const SizedBox(height: 12),
          InlineNote(
            message: _serverError!,
            color: BuddyColors.red,
            borderColor: BuddyColors.red,
            icon: Icons.error_outline,
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: BuddyButton(
                label: 'Back to Cart',
                variant: BuddyButtonVariant.outline,
                onPressed: _submitting ? null : () => context.pop(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: BuddyButton(
                label: payLabel,
                isLoading: _submitting,
                onPressed: _submitting || method == null
                    ? null
                    : () => _submit(
                          cart: cart,
                          method: method,
                          fulfillment: fulfillment,
                          addressErrors: addressErrors,
                          stations: stations,
                          selectedStation: selectedStation,
                        ),
              ),
            ),
          ],
        ),
        if (method == null) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Pick a payment method above to confirm this order.',
              style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ],
    );
  }

  // ─── submit ───────────────────────────────────────────────────────────────

  Future<void> _submit({
    required Cart cart,
    required String method,
    required String fulfillment,
    required Map<String, String> addressErrors,
    required List<PickupStation> stations,
    required PickupStation? selectedStation,
  }) async {
    setState(() {
      _attempted = true;
      _serverError = null;
    });

    // Client-side gate first: never spend a round trip on a form we know is
    // incomplete, and never clear what the buyer typed to say so.
    if (fulfillment == 'delivery' && addressErrors.isNotEmpty) {
      setState(() => _serverError =
          'Check the delivery address — a few fields still need attention.');
      return;
    }
    if (fulfillment == 'pickup') {
      if (stations.isNotEmpty && _stationId == null) {
        setState(() => _serverError = 'Choose a pickup station to continue.');
        return;
      }
      if (stations.isEmpty && _manualPickup.trim().isEmpty) {
        setState(() => _serverError = 'Enter a collection point to continue.');
        return;
      }
    }
    if (method == 'mpesa' && !isValidPhone(_mpesaController.text.trim())) {
      setState(() =>
          _serverError = 'Enter a valid M-Pesa phone number to continue.');
      return;
    }

    final payload = <String, dynamic>{
      'fulfillment_type': fulfillment,
      'payment_method': method,
    };
    if (fulfillment == 'delivery') {
      payload['delivery_address'] = addressPayload(_address);
    }
    if (fulfillment == 'pickup') {
      payload['pickup_station_id'] = selectedStation?.id;
      payload['pickup_details'] = pickupDetailsPayload(
        stationName: selectedStation?.name,
        manualLocation: _manualPickup,
        instructions: selectedStation?.instructions,
      );
    }

    setState(() => _submitting = true);
    try {
      final raw = await ref.read(marketplaceRepositoryProvider).checkoutCart(payload);
      final receipt = CheckoutReceipt.fromJson(raw['data'] as Map<String, dynamic>);
      // No order reference means we cannot prove what was charged. Failing loud
      // beats letting the buyer retry into a duplicate order.
      if (receipt.orderId.isEmpty) {
        setState(() => _serverError =
            'Checkout returned an unexpected response. Check your orders before trying again.');
        return;
      }
      if (!mounted) return;
      setState(() {
        _receipt = receipt;
        _placedFulfillmentType = fulfillment;
        _placedAddress =
            fulfillment == 'delivery' ? Map<String, String>.from(_address) : null;
        _placedStationName = selectedStation?.name;
        _placedManualPickup = _manualPickup.trim();
        _paymentIntent = null;
        _intentNote = null;
      });
      ref.read(cartProvider.notifier).loadCart();
      ref.read(balanceProvider.notifier).loadBalance();

      // Real money settles asynchronously. A missing endpoint must not cost the
      // buyer their receipt, so a failure here is noted on the receipt instead.
      if (method != 'artifacts') {
        unawaited(_startPaymentIntent(receipt, method));
      }
    } catch (e) {
      // Inline, with the server's own wording (e.g. "Insufficient dumbbell
      // tokens."), and every field left exactly where the buyer left it.
      if (mounted) {
        setState(() => _serverError = apiErrorMessage(
              e,
              fallback: 'We could not place that order.',
            ));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _startPaymentIntent(CheckoutReceipt receipt, String method) async {
    final phone = _mpesaController.text.trim();
    try {
      final raw = await ref.read(marketplaceRepositoryProvider).createPaymentIntent({
        'order_id': receipt.orderId,
        'method': method,
        if (method == 'mpesa' && phone.isNotEmpty) 'phone': phone,
      });
      if (!mounted) return;
      final message = raw['message'] as String? ?? '';
      // `rail_configured: false` is a success with a caveat: the deployment has
      // no provider keys, so the order exists and no charge was started.
      final configured = raw['data']?['rail_configured'];
      setState(() {
        _paymentIntent = PaymentIntentResult.fromJson(
          (raw['data'] ?? <String, dynamic>{}) as Map<String, dynamic>,
        );
        _intentNote = (configured == false && message.isNotEmpty)
            ? message
            : (message.isNotEmpty ? message : null);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _intentNote = stationsErrorMessage(
            e,
            fallback: 'We could not start this payment. Retry it from the order page.',
          ));
    }
  }
}
