/// Fulfillment-aware order status machine, mirroring
/// `ORDER_TRANSITIONS_BY_FULFILLMENT` in `backend/apps/marketplace/views.py`.
///
/// The flat map that used to live in the seller screen treated every order as a
/// parcel: a `pickup` order could be marked "shipped", a `digital` one could be
/// "en route", and neither means anything. The backend now enforces the
/// fulfillment-aware table below and answers an illegal move with a 400 naming
/// the transition, so this client mirror exists to *avoid offering* a button the
/// server will reject — never to decide the outcome. When the server disagrees,
/// its message wins: surfaces call `updateOrderStatus` and render the returned
/// `message` verbatim.
library;

///   digital  : nothing is moved, so there is no transport.
///   pickup   : the buyer collects; `ready_for_pickup` / `delivered` only.
///   delivery : a courier moves it; `shipped` / `out_for_delivery` / `delivered`.
///
/// `cancelled` is legal from every non-terminal state of every type, and
/// `delivered -> completed` is the shared close-out.
const Map<String, Map<String, List<String>>>
    kOrderTransitionsByFulfillment = {
  'digital': {
    'pending': ['paid', 'cancelled'],
    'paid': ['processing', 'completed', 'cancelled'],
    'processing': ['completed', 'cancelled'],
    'completed': ['cancelled'],
  },
  'pickup': {
    'pending': ['paid', 'cancelled'],
    'paid': [
      'processing',
      'ready_for_pickup',
      'delivered',
      'completed',
      'cancelled',
    ],
    'processing': ['ready_for_pickup', 'delivered', 'completed', 'cancelled'],
    'ready_for_pickup': ['delivered', 'completed', 'cancelled'],
    'delivered': ['completed'],
  },
  'delivery': {
    'pending': ['paid', 'cancelled'],
    'paid': [
      'processing',
      'shipped',
      'out_for_delivery',
      'delivered',
      'completed',
      'cancelled',
    ],
    'processing': [
      'shipped',
      'out_for_delivery',
      'delivered',
      'completed',
      'cancelled',
    ],
    'shipped': ['out_for_delivery', 'delivered', 'cancelled'],
    'out_for_delivery': ['delivered', 'cancelled'],
    'delivered': ['completed'],
  },
};

/// Orders placed before `fulfillment_type` was meaningful default to `digital`
/// while sitting in a transport state. Those rows must still be closeable, so
/// from a *current* state the order's own fulfillment does not define, the
/// legacy transport chain is allowed too. Entering such a state from a legal one
/// is still rejected — that is the case the table exists to catch.
const List<String> _kLegacyTransportChain = [
  'out_for_delivery',
  'delivered',
  'completed',
  'cancelled',
];

/// Statuses this order may move to, given its fulfillment type.
List<String> allowedOrderTransitions(String status, String fulfillmentType) {
  final table = kOrderTransitionsByFulfillment[fulfillmentType] ??
      kOrderTransitionsByFulfillment['digital']!;
  final direct = table[status];
  if (direct != null) return List.of(direct);
  // The order sits in a state its own fulfillment does not define, so widen the
  // legacy flat map by the transport chain purely so it can still be closed.
  final flat = kLegacyFlatTransitions[status] ?? const <String>[];
  final union = <String>[...flat, ..._kLegacyTransportChain];
  final seen = <String>{};
  return union.where(seen.add).toList();
}

/// True when the fulfillment-aware machine permits [status] -> [next].
///
/// Used to annotate — never to hide — a status the server's own flat map allows
/// (the admin portal still validates against `ORDER_FORWARD_STATES`), and to
/// filter the seller bulk actions where the fulfillment-aware endpoint is what
/// will actually run.
bool isOrderTransitionAllowed(String status, String next, String fulfillmentType) =>
    allowedOrderTransitions(status, fulfillmentType).contains(next);

/// `ORDER_FORWARD_STATES` — the flat map the admin portal's
/// `PATCH /portal/orders/<id>/status/` still validates against.
const Map<String, List<String>> kLegacyFlatTransitions = {
  'pending': ['paid', 'cancelled'],
  'paid': [
    'processing',
    'shipped',
    'out_for_delivery',
    'ready_for_pickup',
    'delivered',
    'completed',
    'cancelled',
  ],
  'processing': [
    'shipped',
    'out_for_delivery',
    'ready_for_pickup',
    'delivered',
    'cancelled',
  ],
  'shipped': ['out_for_delivery', 'delivered', 'cancelled'],
  'out_for_delivery': ['delivered', 'cancelled'],
  'ready_for_pickup': ['delivered', 'cancelled'],
  'delivered': ['completed'],
};

/// Every status a seller or admin may be offered, in lifecycle order — used to
/// label chips and to render a full picker when the transition map says
/// "terminal from here".
const Map<String, String> kOrderStatusLabels = {
  'pending': 'Pending',
  'paid': 'Paid',
  'processing': 'Processing',
  'shipped': 'Shipped',
  'out_for_delivery': 'Out for Delivery',
  'ready_for_pickup': 'Ready for Pickup',
  'delivered': 'Delivered',
  'completed': 'Completed',
  'cancelled': 'Cancelled',
};

String orderStatusLabel(String status) =>
    kOrderStatusLabels[status] ??
    status.replaceAll('_', ' ').split(' ').map((w) {
      if (w.isEmpty) return w;
      return w.substring(0, 1).toUpperCase() + w.substring(1);
    }).join(' ');