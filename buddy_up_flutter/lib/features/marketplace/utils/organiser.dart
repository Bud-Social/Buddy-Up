/// Event organiser helpers, mirroring the organiser half of
/// `frontend/src/api/marketplace.ts`.
///
/// The one rule that matters: **a 403 from `events/mine/` is an expected
/// state, not a failure.** Every signed-in user is allowed to open the screen;
/// only a user who has created or hosts an event gets a list. Rendering that as
/// "you have not created any events" would be a lie for the majority who simply
/// are not organisers, so it gets its own message.
library;

import '../../../core/api/api_error.dart';

/// `EventTicket.STATUS_CHOICES`, as filter options.
///
/// The backend *validates* this filter (an unknown value is a 400 naming the
/// legal set) precisely so a dashboard whose "valid only" toggle quietly returns
/// the unfiltered list cannot happen.
const List<OrganiserStatusFilter> kOrganiserStatusFilters = [
  OrganiserStatusFilter('', 'Any status'),
  OrganiserStatusFilter('valid', 'Valid'),
  OrganiserStatusFilter('used', 'Used'),
  OrganiserStatusFilter('cancelled', 'Cancelled'),
  OrganiserStatusFilter('refunded', 'Refunded'),
];

class OrganiserStatusFilter {
  final String value;
  final String label;

  const OrganiserStatusFilter(this.value, this.label);
}

/// True when the caller is signed in but is not an event organiser.
///
/// Any 403 counts: the view returns one for "no organiser relationship", and a
/// consent gate 403 has already been intercepted by the API client.
bool isOrganiserForbidden(Object error) => apiStatusCode(error) == 403;

/// The message for a non-organiser.
///
/// The server's own wording is used when it sent one — it knows whether the
/// caller merely lacks the role — with a plain fallback that names the cause
/// rather than implying the list is empty.
String organiserForbiddenMessage(Object error) {
  final server = apiErrorMessage(error, fallback: '');
  if (server.isNotEmpty && !server.toLowerCase().contains('something went wrong')) {
    return server;
  }
  return 'Only event organisers can do this. Create an event, or ask the shop '
      'owner who hosts it to add you.';
}

/// Whether a ticket sits in an "awaiting review" state.
///
/// `submitted` and `under_review` are the staff queue states; `draft` is the
/// applicant's own draft. They are grouped so an operator sees one consistent
/// "pending" rather than three words that mean the same thing.
const List<String> kPendingStationApplicationStatuses = [
  'pending',
  'submitted',
  'under_review',
];

bool isPendingApplicationStatus(String? status) {
  if (status == null) return false;
  return kPendingStationApplicationStatuses.contains(status.trim().toLowerCase());
}

/// `pending` / `submitted` / `under_review` -> "pending"; `approved` / `rejected`
/// read as themselves.
String stationApplicationStatusLabel(String? status) {
  final value = (status ?? '').trim();
  if (value.isEmpty) return 'pending';
  if (isPendingApplicationStatus(value)) return 'pending';
  return value.replaceAll('_', ' ').toLowerCase();
}

/// The sentence explaining what a pending application means.
String stationApplicationHint({
  required String status,
  String rejectionReason = '',
}) {
  final normalised = status.trim().toLowerCase();
  if (isPendingApplicationStatus(normalised)) {
    return 'Your application is awaiting review. You can keep managing the '
        'stations you already own.';
  }
  if (normalised == 'approved') {
    return 'Approved. Add the station details to start using it.';
  }
  if (rejectionReason.trim().isNotEmpty) return rejectionReason.trim();
  return 'This application was not approved.';
}