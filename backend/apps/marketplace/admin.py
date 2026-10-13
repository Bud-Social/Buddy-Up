from django.contrib import admin
from .models import (
    PickupStation, StationApplication, DeliveryPersonnel, DeliveryPersonnelApplication,
    PaymentIntent,
    Order, OrderCase, OrderFulfillment, Product, Shop,
    MarketplaceEvent, EventTicket,
)


# ---------------------------------------------------------------------------
# Commerce: shops, products, orders
# ---------------------------------------------------------------------------

@admin.register(Shop)
class ShopAdmin(admin.ModelAdmin):
    """Verification moves through the shop-certification review queue
    (``ShopVerificationApplication``), not by editing this row, so the
    verification columns are read-only here too."""
    list_display = ['name', 'handle', 'category', 'is_active', 'verification_status',
                    'created_at']
    list_filter = ['category', 'is_active', 'verification_status']
    search_fields = ['name', 'handle', 'contact_email']
    readonly_fields = ['verification_applied_at', 'verified_at', 'created_at', 'updated_at']


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    """Price lives in ``variants`` JSON and the marketplace is affiliate-driven,
    so nothing about a product is a price-editing surface here."""
    list_display = ['name', 'brand', 'category', 'shop', 'is_active', 'stock_quantity',
                    'click_count']
    list_filter = ['category', 'is_active', 'stock_tracking_enabled', 'shop']
    search_fields = ['name', 'brand', 'shop__handle']
    list_select_related = ['shop']
    readonly_fields = ['click_count', 'created_at', 'updated_at']


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    """Read-mostly and never deletable: an order is the evidence that a payment
    and a ledger movement happened. Status transitions belong to
    ``Order.set_status`` (and the admin portal, which enforces
    ORDER_FORWARD_STATES); typing a status here would bypass the history entry.
    """
    list_display = ['order_number', 'buyer', 'status', 'fulfillment_type',
                    'payment_method', 'payment_status', 'spent_usd', 'created_at']
    list_filter = ['status', 'fulfillment_type', 'payment_status', 'payment_method']
    search_fields = ['order_number', 'buyer__username', 'buyer__user__email']
    list_select_related = ['buyer']
    readonly_fields = ['order_number', 'status', 'status_history', 'paid_at',
                       'created_at', 'updated_at']

    def has_add_permission(self, request):
        # Orders are minted by checkout.
        return False

    def has_delete_permission(self, request, obj=None):
        return False


@admin.register(OrderFulfillment)
class OrderFulfillmentAdmin(admin.ModelAdmin):
    list_display = ['__str__', 'carrier', 'tracking_number', 'shipped_at', 'delivered_at']
    search_fields = ['tracking_number', 'order__order_number']
    list_select_related = ['order']
    readonly_fields = ['timeline', 'seller_split_artifacts', 'shipped_at',
                       'out_for_delivery_at', 'ready_for_pickup_at', 'delivered_at',
                       'created_at', 'updated_at']

    def has_add_permission(self, request):
        # Fulfillment rows are created by the seller-facing status endpoint.
        return False


@admin.register(OrderCase)
class OrderCaseAdmin(admin.ModelAdmin):
    """Approving a case here records a decision; it moves no money. Refunds have
    to run through the wallet ledger's posting path."""
    list_display = ['order', 'case_type', 'status', 'requester', 'resolved_at',
                    'created_at']
    list_filter = ['case_type', 'status']
    search_fields = ['reason', 'resolution', 'order__order_number']
    list_select_related = ['order', 'requester']
    readonly_fields = ['resolved_at', 'created_at', 'updated_at']


# ---------------------------------------------------------------------------
# Event organisers
# ---------------------------------------------------------------------------


@admin.register(MarketplaceEvent)
class MarketplaceEventAdmin(admin.ModelAdmin):
    """Staff read-only view of an event and its organiser workload.

    `attendee_count` is the counter checkout maintains and `tickets_sold` counts
    every non-cancelled, non-refunded ticket live; staff investigating "the
    organiser says the dashboard is wrong" need to see both, because those two
    numbers diverge whenever a ticket is cancelled outside checkout. The
    organiser API (``/events/mine``, ``/events/<id>/attendees``,
    ``/events/<id>/stats``) is where the writes live — capacity and ticket
    definitions stay editable here because they are set up before publication.
    """
    list_display = ['title', 'organiser', 'host_shop', 'start_datetime', 'is_published',
                    'is_cancelled', 'attendee_count', 'tickets_sold', 'checked_in']
    list_filter = ['is_published', 'is_cancelled', 'is_draft', 'is_free', 'event_type']
    search_fields = ['title', 'location', 'creator__username', 'shop__handle']
    list_select_related = ['creator', 'shop']
    date_hierarchy = 'start_datetime'

    @admin.display(description='Organiser')
    def organiser(self, obj):
        return obj.creator.username

    @admin.display(description='Shop')
    def host_shop(self, obj):
        return obj.shop.handle if obj.shop_id else '—'

    @admin.display(description='Tickets sold')
    def tickets_sold(self, obj):
        return self._sold(obj).count()

    @admin.display(description='Checked in')
    def checked_in(self, obj):
        return self._sold(obj).filter(is_checked_in=True).count()

    @staticmethod
    def _sold(obj):
        # Mirrors SOLD_TICKET_STATUSES: a cancelled/refunded ticket is not a sale.
        return obj.tickets.exclude(status__in=('cancelled', 'refunded'))


@admin.register(EventTicket)
class EventTicketAdmin(admin.ModelAdmin):
    """The door list, for when an organiser phones support mid-event.

    ``is_checked_in`` / ``checked_in_at`` are written by the organiser's
    check-in and check-out endpoints and are read-only here so a staff fix
    cannot invent a check-in that no scan recorded (and so it cannot leave
    ``checked_in_at`` set on a ticket that is not checked in).
    """
    list_display = ['ticket_code', 'event', 'holder', 'tier', 'status',
                    'is_checked_in', 'checked_in_at', 'price_paid_artifacts']
    list_filter = ['status', 'is_checked_in', 'tier', 'event']
    search_fields = ['ticket_code', 'holder__username', 'holder__display_name', 'event__title']
    list_select_related = ['event', 'holder']
    readonly_fields = ['is_checked_in', 'checked_in_at', 'price_paid_artifacts',
                       'created_at', 'updated_at']

    def has_add_permission(self, request):
        # Tickets are minted by checkout, never typed in by hand.
        return False


# ---------------------------------------------------------------------------
# Fulfillment logistics (added in migration 0016)
# ---------------------------------------------------------------------------


@admin.register(PickupStation)
class PickupStationAdmin(admin.ModelAdmin):
    """Read-mostly. Collection points are created by the owning shop/gym through
    the API, and ``name`` is intentionally not unique so staff cannot silently
    merge two stations that share a building name."""
    list_display = ['name', 'owner_type', 'owner', 'city', 'is_active', 'is_primary']
    list_filter = ['owner_type', 'is_active', 'is_primary', 'city']
    search_fields = ['name', 'address', 'city']
    list_select_related = ['shop', 'gym']
    readonly_fields = ['created_at', 'updated_at']

    @admin.display(description='Owner')
    def owner(self, obj):
        return obj.shop.name if obj.shop_id else (obj.gym.name if obj.gym_id else '—')


@admin.register(StationApplication)
class StationApplicationAdmin(admin.ModelAdmin):
    """Read-mostly: applications move through ApplicationReviewSerializer in the
    API so the audit trail (reviewed_by / reviewed_at) is always written."""
    list_display = ['__str__', 'submitted_by', 'status', 'city', 'created_at']
    list_filter = ['status']
    search_fields = ['business_registration_number', 'contact_phone', 'city']
    list_select_related = ['shop', 'gym', 'submitted_by', 'reviewed_by']
    readonly_fields = ['status', 'reviewed_by', 'reviewed_at', 'reviewer_notes',
                       'rejection_reason', 'created_at', 'updated_at']


@admin.register(DeliveryPersonnel)
class DeliveryPersonnelAdmin(admin.ModelAdmin):
    """``commission_rate`` is editable here and nowhere else: it is a negotiated
    commercial term between the platform and the courier, so no client endpoint
    may write it (the courier self-service POST filters to vehicle/zones/active
    /bio). The 0..1 bound is a database CHECK, so a hand-typed 99.99 fails at
    the database rather than silently becoming a rate."""
    list_display = ['profile', 'vehicle_type', 'is_active', 'rating',
                    'commission_rate', 'service_zones']
    list_filter = ['vehicle_type', 'is_active']
    search_fields = ['profile__username', 'profile__display_name']
    list_select_related = ['profile']
    readonly_fields = ['rating', 'created_at', 'updated_at']


@admin.register(DeliveryPersonnelApplication)
class DeliveryPersonnelApplicationAdmin(admin.ModelAdmin):
    list_display = ['profile', 'vehicle_type', 'status', 'created_at']
    list_filter = ['status', 'vehicle_type']
    search_fields = ['profile__username', 'profile__display_name', 'phone']
    list_select_related = ['profile', 'reviewed_by']
    readonly_fields = ['status', 'reviewed_by', 'reviewed_at', 'reviewer_notes',
                       'rejection_reason', 'created_at', 'updated_at']


@admin.register(PaymentIntent)
class PaymentIntentAdmin(admin.ModelAdmin):
    """Read-mostly and deliberately not editable by hand: a payment row is
    evidence. Status transitions come from the provider callback keyed on
    ``provider_reference``."""
    list_display = ['id', 'order', 'method', 'amount', 'currency', 'status',
                    'provider_reference', 'created_at']
    list_filter = ['status', 'method', 'provider']
    search_fields = ['provider_reference', 'order__order_number']
    list_select_related = ['order', 'created_by']
    readonly_fields = ['provider', 'provider_reference', 'status', 'raw_response',
                       'created_at', 'updated_at']

    def has_add_permission(self, request):
        # Intents are minted by checkout, never typed in by hand.
        return False