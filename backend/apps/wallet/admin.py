from django.contrib import admin

from .models import ArtifactTransaction, JournalEntry, JournalLine, LedgerAccount


@admin.register(LedgerAccount)
class LedgerAccountAdmin(admin.ModelAdmin):
    list_display = ('name', 'account_type', 'profile', 'wallet_bucket', 'artifact_type', 'is_active')
    list_filter = ('account_type', 'wallet_bucket', 'artifact_type', 'is_active')
    search_fields = ('name', 'profile__username', 'profile__user__email')
    readonly_fields = ('id', 'created_at', 'updated_at')


class JournalLineInline(admin.TabularInline):
    model = JournalLine
    extra = 0
    can_delete = False
    readonly_fields = ('account', 'direction', 'amount')

    def has_add_permission(self, request, obj=None):
        return False


@admin.register(JournalEntry)
class JournalEntryAdmin(admin.ModelAdmin):
    list_display = ('id', 'operation', 'idempotency_key', 'posted_at')
    list_filter = ('operation', 'posted_at')
    search_fields = ('idempotency_key', 'description')
    readonly_fields = (
        'id', 'operation', 'idempotency_key', 'request_hash', 'description',
        'metadata', 'posted_at', 'created_at', 'updated_at',
    )
    inlines = [JournalLineInline]

    def has_add_permission(self, request):
        return False

    def has_delete_permission(self, request, obj=None):
        return False


@admin.register(ArtifactTransaction)
class ArtifactTransactionAdmin(admin.ModelAdmin):
    list_display = ('id', 'transaction_type', 'user', 'quantity', 'artifact_type', 'status', 'created_at')
    list_filter = ('transaction_type', 'direction', 'status', 'artifact_type', 'payment_provider')
    search_fields = ('id', 'tx_ref', 'reference_id', 'user__username', 'user__user__email')
    readonly_fields = ('id', 'created_at', 'updated_at')
