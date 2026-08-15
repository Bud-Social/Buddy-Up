import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/theme/app_theme.dart';

class LocationResult {
  final String label;
  final double? lat;
  final double? lng;

  const LocationResult({required this.label, this.lat, this.lng});
}

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final dio.Dio _dio = dio.Dio(
    dio.BaseOptions(
      baseUrl: 'https://nominatim.openstreetmap.org',
      headers: {'User-Agent': 'BuddyUpApp/1.0'},
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );
  final TextEditingController _searchController = TextEditingController();

  static const LatLng _defaultCenter = LatLng(6.5244, 3.3792);

  GoogleMapController? _mapController;
  LatLng? _center;
  String _label = '';
  List<Map<String, dynamic>> _results = [];
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _center = _defaultCenter;
    _initLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initLocation() async {
    await _useMyLocation(quiet: true);
    if (mounted && _label.isEmpty) {
      await _reverseGeocode(_center!.latitude, _center!.longitude);
    }
  }

  Future<void> _moveCamera(LatLng l) async {
    final c = _mapController;
    if (c == null) return;
    await c.animateCamera(CameraUpdate.newLatLngZoom(l, 14));
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final res = await _dio.get('/reverse', queryParameters: {
        'format': 'json',
        'lat': lat,
        'lon': lng,
      });
      final data = res.data;
      if (data is Map && data['display_name'] is String && mounted) {
        setState(() => _label = data['display_name'] as String);
      }
    } catch (_) {}
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) return;
    try {
      final res = await _dio.get('/search', queryParameters: {
        'format': 'json',
        'q': query.trim(),
        'limit': 6,
      });
      final list = res.data;
      if (!mounted) return;
      setState(() {
        _results = list is List
            ? list
                  .whereType<Map>()
                  .map((e) => e.cast<String, dynamic>())
                  .toList()
            : [];
      });
    } catch (_) {
      if (mounted) setState(() => _results = []);
    }
  }

  void _selectResult(Map<String, dynamic> r) {
    final lat = double.tryParse('${r['lat']}');
    final lng = double.tryParse('${r['lon']}');
    if (lat == null || lng == null) return;
    setState(() {
      _center = LatLng(lat, lng);
      _label = r['display_name'] as String? ?? _label;
      _results = [];
    });
    _moveCamera(LatLng(lat, lng));
  }

  Future<void> _useMyLocation({bool quiet = false}) async {
    setState(() => _locating = true);
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) throw Exception('location service disabled');
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        throw Exception('location permission denied');
      }
      final pos = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 8),
      );
      if (!mounted) return;
      final l = LatLng(pos.latitude, pos.longitude);
      setState(() => _center = l);
      await _reverseGeocode(l.latitude, l.longitude);
      await _moveCamera(l);
    } catch (_) {
      if (!quiet && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not get your location. Search or tap the map instead.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _onMapTap(LatLng l) {
    setState(() => _center = l);
    _reverseGeocode(l.latitude, l.longitude);
  }

  void _confirm() {
    Navigator.of(context).pop(
      LocationResult(
        label: _label.isNotEmpty ? _label : 'Selected location',
        lat: _center?.latitude,
        lng: _center?.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add location'),
        actions: [
          TextButton(
            onPressed: _center == null ? null : _confirm,
            child: const Text(
              'Confirm',
              style: TextStyle(color: BuddyColors.green, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: BuddyColors.textPrimary),
              textInputAction: TextInputAction.search,
              onSubmitted: _search,
              decoration: const InputDecoration(
                hintText: 'Search for a place…',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          if (_results.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _results.length,
                itemBuilder: (_, i) {
                  final r = _results[i];
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.place_outlined, size: 18, color: BuddyColors.green),
                    title: Text(
                      r['display_name'] as String? ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 13),
                    ),
                    onTap: () => _selectResult(r),
                  );
                },
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: _center ?? _defaultCenter, zoom: 14),
                  onMapCreated: (c) => _mapController = c,
                  onTap: _onMapTap,
                  markers: {
                    if (_center != null)
                      Marker(
                        markerId: const MarkerId('selected'),
                        position: _center!,
                        draggable: true,
                        onDragEnd: (l) {
                          setState(() => _center = l);
                          _reverseGeocode(l.latitude, l.longitude);
                        },
                      ),
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'use_my_location',
                    backgroundColor: BuddyColors.surfaceRaised,
                    onPressed: _locating ? null : () => _useMyLocation(),
                    child: _locating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: BuddyColors.green),
                          )
                        : const Icon(Icons.my_location, color: BuddyColors.green),
                  ),
                ),
              ],
            ),
          ),
          if (_label.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              color: BuddyColors.black,
              child: Row(
                children: [
                  const Icon(Icons.place, color: BuddyColors.green, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: BuddyColors.textPrimary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}