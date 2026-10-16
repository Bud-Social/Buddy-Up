"""Serializers for the governance API.

Three rules shape these:

* ``user`` is written as a UUID in, a ``{id, email, display_name}`` object out.
  Staff need to know *who* a row concerns, and they need it after the account is
  deleted — which is why the account action request also carries a plain
  ``requested_by_profile`` string that survives a cascade, and why every audit
  row carries an ``actor_email`` snapshot.
* No field here can write ``is_staff`` / ``is_superuser``. Granting a
  ``StaffRole`` narrows access; minting a superuser is not this API's job, and
  a compromised staff session should not be able to escalate through it.
* Nothing here is writable on an audit row or an email log. They are written by
  the code that performs the action, from the server's side. A serializer that
  accepted input for ``before`` would let a staff member forge the record of
  their own action, which is the one thing an audit trail must not be.
"""
from django.contrib.auth import get_user_model
from rest_framework import serializers


from .models import (
    ALL_SCOPES, AccountActionRequest, AdminActionLog, EmailLog, StaffInvitation, StaffRole,
)

User = get_user_model()


def display_name_of(user):
    """Best available human name for a user, or ''.

    A ``createsuperuser`` account has no Profile row, so every caller has to
    tolerate its absence. Exported because the views use it to snapshot the
    requester's name onto the approval row.
    """
    profile = getattr(user, 'profile', None)
    if profile is None:
        return getattr(user, 'email', '') or ''
    return profile.display_name or profile.username or user.email


def _user_ref(user):
    if user is None:
        return None
    return {
        'id': str(user.id),
        'email': user.email,
        'display_name': display_name_of(user),
    }


def _validate_scope_list(value):
    """Every scope in a write payload must be a scope this platform knows.

    A typo is otherwise a silent no-op: the grant saves, the operator believes
    it took, and the route 403s weeks later. Validating at write time turns that
    into a 400 naming the bad string.

    Checked against ``KNOWN_SCOPES`` (routed + declared-but-unrouted), not
    ``ALL_SCOPES`` — otherwise the inert scopes could never be pre-granted ahead
    of the routes that will read them.
    """
    from .models import KNOWN_SCOPES

    if not isinstance(value, list):
        raise serializers.ValidationError('scopes must be a list of scope strings.')

    unknown = [s for s in value if not isinstance(s, str) or s not in KNOWN_SCOPES]
    if unknown:
        raise serializers.ValidationError(
            f'Unknown scope(s): {sorted(map(str, unknown))}. '
            f'Valid scopes are: {sorted(KNOWN_SCOPES)}.'
        )

    # Deduplicate, keeping the caller's order.
    seen = set()
    return [s for s in value if not (s in seen or seen.add(s))]


class UserRefField(serializers.Field):
    """Read side: a small identity object rather than the whole user row.

    A bare ``Field`` with a ``to_representation``, *not* a
    ``PrimaryKeyRelatedField``. Two DRF optimisations get in the way otherwise:

    * When every relational field on a serializer needs only the pk, DRF swaps
      the related object for a ``PKOnlyObject`` with no ``.id``/``.email``, so a
      relational field that reads attributes raises ``AttributeError``.
    * ``SerializerMethodField.__init__`` hard-sets ``source='*'``, so the field
      is handed the whole parent row instead of the related user.

    ``Field`` does neither, so it must declare its own read side, and its
    ``source`` has to be the related attribute name rather than the field name —
    DRF asserts those differ.

    Input uses a plain UUIDField instead (see the write serializers), so nothing
    here is writable.
    """

    def __init__(self, **kwargs):
        kwargs['read_only'] = True
        super().__init__(**kwargs)

    def to_representation(self, value):
        return _user_ref(value)


# ---------------------------------------------------------------------------
# StaffRole
# ---------------------------------------------------------------------------

class StaffRoleSerializer(serializers.ModelSerializer):
    user = UserRefField()
    granted_by = UserRefField()
    role_display = serializers.CharField(source='get_role_display', read_only=True)
    default_scopes = serializers.SerializerMethodField()
    effective_scopes = serializers.SerializerMethodField()
    is_active = serializers.BooleanField(read_only=True)

    class Meta:
        model = StaffRole
        fields = [
            'id',
            'user',
            'role',
            'role_display',
            'scopes',
            'default_scopes',
            'effective_scopes',
            'granted_by',
            'granted_at',
            'notes',
            'revoked_at',
            'is_active',
            'created_at',
            'updated_at',
        ]
        read_only_fields = [
            'id', 'granted_by', 'granted_at', 'revoked_at',
            'created_at', 'updated_at',
        ]

    def get_default_scopes(self, obj):
        """The role's floor, so an operator can see what the role alone grants."""
        from .models import DEFAULT_SCOPES_BY_ROLE
        return sorted(DEFAULT_SCOPES_BY_ROLE.get(obj.role, set()))

    def get_effective_scopes(self, obj):
        """Defaults + stored extras, exactly as ``effective_scopes`` computes."""
        from .services import effective_scopes
        return sorted(effective_scopes(obj.user))

    def validate_scopes(self, value):
        return _validate_scope_list(value)


class StaffRoleWriteSerializer(serializers.Serializer):
    """Input for granting or replacing a role.

    A plain ``Serializer``, not a ``ModelSerializer``: "granting a role" is not
    "editing a row" — it sets ``granted_by`` and ``granted_at``, clears
    ``revoked_at``, and may route through approval. Encoding it as a row update
    would expose those four columns as writable.
    """

    user = serializers.UUIDField()
    role = serializers.ChoiceField(choices=StaffRole.ROLE_CHOICES)
    scopes = serializers.ListField(
        child=serializers.CharField(), required=False, allow_empty=True, default=list,
    )
    notes = serializers.CharField(required=False, allow_blank=True, default='')
    requires_second = serializers.BooleanField(required=False, default=True)

    def validate_scopes(self, value):
        return _validate_scope_list(value)

    def validate(self, attrs):
        """Cross-field rules. Self-grant is checked in the view (needs request)."""
        user = User.objects.filter(pk=attrs['user']).first()
        if user is None:
            raise serializers.ValidationError({'user': 'No such user.'})
        if not user.is_staff:
            raise serializers.ValidationError({
                'user': 'Staff roles apply to staff accounts only. This user is not is_staff.',
            })
        attrs['_user'] = user
        return attrs


class StaffRoleUpdateSerializer(serializers.Serializer):
    """Input for narrowing an existing role (PATCH)."""

    role = serializers.ChoiceField(choices=StaffRole.ROLE_CHOICES, required=False)
    scopes = serializers.ListField(
        child=serializers.CharField(), required=False, allow_empty=True,
    )
    notes = serializers.CharField(required=False, allow_blank=True)

    def validate_scopes(self, value):
        return _validate_scope_list(value)

    def validate(self, attrs):
        if not attrs:
            raise serializers.ValidationError(
                'Provide at least one of: role, scopes, notes.'
            )
        return attrs


# ---------------------------------------------------------------------------
# AccountActionRequest
# ---------------------------------------------------------------------------

class AccountActionRequestSerializer(serializers.ModelSerializer):
    target_user = UserRefField()
    requested_by = UserRefField()
    decided_by = UserRefField()
    action_display = serializers.CharField(source='get_action_display', read_only=True)
    required_scope = serializers.CharField(read_only=True)
    is_open = serializers.BooleanField(read_only=True)

    class Meta:
        model = AccountActionRequest
        fields = [
            'id',
            'action',
            'action_display',
            'required_scope',
            'target_user',
            'payload',
            'status',
            'is_open',
            'requested_by',
            'requested_by_profile',
            'decided_by',
            'decided_at',
            'decision_note',
            'requires_second',
            'applied_at',
            'created_at',
            'updated_at',
        ]
        read_only_fields = fields  # every field is server-owned; input is separate


class AccountActionRequestCreateSerializer(serializers.Serializer):
    """Input for raising a request.

    The requester must hold the action's scope. Without that check a support
    agent could raise a payout request and let a finance approver rubber-stamp
    something they were never meant to see the contents of.
    """

    action = serializers.ChoiceField(choices=AccountActionRequest.ACTION_CHOICES)
    target_user = serializers.UUIDField()
    payload = serializers.DictField(required=False, default=dict)
    notes = serializers.CharField(required=False, allow_blank=True, default='')
    requires_second = serializers.BooleanField(required=False, default=True)

    def validate(self, attrs):
        target = User.objects.filter(pk=attrs['target_user']).first()
        if target is None:
            raise serializers.ValidationError({'target_user': 'No such user.'})

        action = attrs['action']
        required = AccountActionRequest.ACTION_SCOPES.get(action)
        if required is None:
            raise serializers.ValidationError({
                'action': f'No scope is mapped to {action!r}, so it cannot be requested.',
            })

        # `reason` is what gets written to the moderation log, so an empty one
        # would produce an unusable audit row.
        payload = dict(attrs.get('payload') or {})
        if action in ('ban', 'suspension'):
            reason = str(payload.get('reason') or '').strip()
            if not reason:
                raise serializers.ValidationError({
                    'payload': 'A reason is required for ban and suspension requests.',
                })
            duration = payload.get('duration_days')
            if action == 'suspension' and duration is not None:
                try:
                    duration = int(duration)
                except (TypeError, ValueError):
                    raise serializers.ValidationError({
                        'payload': 'duration_days must be a whole number of days.',
                    })
                if duration <= 0:
                    raise serializers.ValidationError({
                        'payload': 'duration_days must be greater than zero.',
                    })
                payload['duration_days'] = duration
            else:
                payload.pop('duration_days', None)
            attrs['payload'] = payload

        if action == 'staff_role_grant':
            role = payload.get('role')
            valid = {c[0] for c in StaffRole.ROLE_CHOICES}
            if role not in valid:
                raise serializers.ValidationError({
                    'payload': f'payload.role must be one of: {sorted(valid)}.',
                })

        attrs['_target'] = target
        attrs['_required_scope'] = required
        return attrs


class DecisionSerializer(serializers.Serializer):
    """Input for approve / reject / cancel.

    ``note`` is required for reject and cancel, optional (but encouraged) for
    approve. An approval trail with no reasoning is hard to defend in an
    incident review; a rejection with none is worse.
    """

    note = serializers.CharField(required=False, allow_blank=True, default='')


# ---------------------------------------------------------------------------
# Audit trail
# ---------------------------------------------------------------------------

class AdminActionLogSerializer(serializers.ModelSerializer):
    """Read side of an audit row.

    ``before`` / ``after`` are returned in full — that is the "recall the
    details of any action" requirement — so this serializer is also what the
    CSV export is built from. Both are scrubbed at *write* time by
    :func:`apps.governance.services.record_admin_action`, not here, because a
    row written before the contract existed is already in the table and hiding
    it at read time would be a false assurance.
    """

    class Meta:
        model = AdminActionLog
        fields = [
            'id',
            'actor',
            'actor_email',
            'action',
            'target_type',
            'target_id',
            'summary',
            'before',
            'after',
            'request_id',
            'ip_address',
            'user_agent',
            'created_at',
        ]
        read_only_fields = fields


# ---------------------------------------------------------------------------
# Assistance console
# ---------------------------------------------------------------------------

class StaffEmailSendSerializer(serializers.Serializer):
    """Input for the staff→user assistance console.

    The abuse controls are in the *schema*, not in the view, because a schema is
    the one thing a caller cannot negotiate with:

    * **One recipient.** ``user_id`` and ``email`` are both scalars and there is
      no list-valued field. Unknown keys are rejected outright below, so
      ``recipients``/``to``/``cc``/``bcc`` are a 400 rather than a silently
      ignored bulk send. This endpoint must never become a spam relay, and the
      cheapest way to guarantee that is for there to be nowhere to put a second
      address.
    * **A registered recipient.** ``validate`` resolves ``to_email`` against a
      real, non-deleted ``User`` and fails if there is none. An address that
      matches nobody cannot be delivered to, and accepting one would make this a
      relay for arbitrary mail.
    * **A real subject and a real body.** Bounded, because the console is not a
      newsletter tool.
    """

    MAX_SUBJECT = 300
    MAX_BODY = 5000

    user_id = serializers.UUIDField(required=False)
    email = serializers.EmailField(required=False)
    subject = serializers.CharField(max_length=MAX_SUBJECT)
    body = serializers.CharField(max_length=MAX_BODY)
    related_object_type = serializers.CharField(
        required=False, allow_blank=True, default='', max_length=50,
    )
    related_object_id = serializers.CharField(
        required=False, allow_blank=True, default='', max_length=64,
    )

    def to_internal_value(self, data):
        """Reject unknown keys instead of ignoring them.

        DRF drops undeclared fields silently, which would make
        ``{"recipients": [...]}`` a perfectly ordinary-looking 202 that quietly
        sent to one person instead. The caller must be told that this endpoint
        does not take a list, rather than discovering later that their bulk send
        went nowhere.
        """
        if isinstance(data, dict):
            known = set(self.fields)
            unknown = sorted(set(data) - known)
            if unknown:
                raise serializers.ValidationError({
                    key: [
                        'Not accepted by this endpoint. It sends to exactly one '
                        f'recipient; unexpected field(s): {unknown}.'
                    ]
                    for key in unknown
                })
        return super().to_internal_value(data)

    def validate(self, attrs):
        user_id = attrs.get('user_id')
        email = (attrs.get('email') or '').strip()

        if not user_id and not email:
            raise serializers.ValidationError({
                'user_id': 'Provide user_id or email — exactly one recipient.',
            })
        if user_id and email:
            raise serializers.ValidationError({
                'user_id': 'Provide user_id or email, not both.',
            })

        if user_id:
            recipient = User.objects.filter(pk=user_id).first()
            if recipient is None:
                raise serializers.ValidationError({'user_id': 'No such user.'})
        else:
            # The hard "registered accounts only" rule. An address with no
            # account behind it is refused outright rather than queued and
            # bounced.
            recipient = User.objects.filter(email__iexact=email).first()
            if recipient is None:
                raise serializers.ValidationError({
                    'email': (
                        'No account is registered with this address. This console '
                        'can only message users who have an account.'
                    ),
                })

        if getattr(recipient, 'deleted_at', None) is not None:
            raise serializers.ValidationError({
                'email': 'This account has been deleted and cannot be messaged.',
            })

        body = (attrs.get('body') or '').strip()
        if not body:
            raise serializers.ValidationError({'body': 'A message body is required.'})
        # Belt and braces on "one recipient": a single address field that
        # somehow carries two addresses is not one recipient.
        if ',' in email or ';' in email or ' ' in email.strip():
            raise serializers.ValidationError({
                'email': 'One recipient per message. Bulk sending is not supported.',
            })

        attrs['_recipient'] = recipient
        attrs['_to_email'] = recipient.email
        attrs['_body'] = body
        return attrs


class EmailLogSerializer(serializers.ModelSerializer):
    recipient = UserRefField(source='recipient_user')
    sender = UserRefField(source='sent_by')

    class Meta:
        model = EmailLog
        fields = [
            'id',
            'recipient_user',
            'recipient',
            'recipient_email',
            'subject',
            'body_preview',
            'template_key',
            'sent_by',
            'sender',
            'sent_by_email',
            'status',
            'error',
            'dedupe_key',
            'related_object_type',
            'related_object_id',
            'created_at',
        ]
        read_only_fields = fields


# ---------------------------------------------------------------------------
# Staff invitations (onboarding)
# ---------------------------------------------------------------------------

class StaffInvitationSerializer(serializers.ModelSerializer):
    """Read shape for an invitation.

    ``token`` is never included. Staff lists are read by people who are already
    staff, and a list that can hand out a live accept link is a list that can
    mint administrators. The accept URL is emailed to the addressee instead.
    """

    role_display = serializers.CharField(source='get_role_display', read_only=True)
    status_display = serializers.CharField(source='get_status_display', read_only=True)
    invited_by = UserRefField(read_only=True)
    accepted_by = UserRefField(read_only=True)
    is_live = serializers.BooleanField(read_only=True)
    has_account = serializers.SerializerMethodField()

    class Meta:
        model = StaffInvitation
        fields = [
            'id',
            'email',
            'role',
            'role_display',
            'scopes',
            'notes',
            'status',
            'status_display',
            'is_live',
            'has_account',
            'invited_by',
            'invited_by_email',
            'expires_at',
            'accepted_at',
            'accepted_by',
            'accepted_user_email',
            'requires_second',
            'created_at',
        ]
        read_only_fields = fields

    def get_has_account(self, obj):
        """Whether the address already has a registered account.

        The operator needs this to tell the invitee "sign in" versus "register
        first" when they phone. It is deliberately not on the public accept
        endpoint.
        """
        from apps.accounts.models import User

        return User.objects.filter(email__iexact=obj.email).exists()


class StaffInvitationCreateSerializer(serializers.Serializer):
    """Input for offering staff access to an email address."""

    email = serializers.EmailField(max_length=254)
    role = serializers.ChoiceField(choices=StaffRole.ROLE_CHOICES)
    scopes = serializers.ListField(child=serializers.CharField(), required=False, default=list)
    notes = serializers.CharField(required=False, allow_blank=True, default='', max_length=1000)
    requires_second = serializers.BooleanField(required=False, default=True)
    expires_in_days = serializers.IntegerField(required=False, default=7, min_value=1, max_value=90)

    def validate_email(self, value):
        """Refuse an offer to somebody who is already staff.

        Not a judgement about the invitee -- an existing staff member's access
        is *changed* through the staff-role endpoint, not re-offered. Silently
        creating a second live invitation would make two links both able to set
        the same role, with no record of which was the real one.
        """
        from apps.accounts.models import User

        email = value.strip().lower()
        if User.objects.filter(email__iexact=email).exists():
            user = User.objects.filter(email__iexact=email).first()
            if user.is_staff:
                raise serializers.ValidationError(
                    'This address already has a staff account. Change their role '
                    'from the staff roles list instead of inviting them again.'
                )
        return email

    def validate_scopes(self, value):
        """Only known scopes, so the row cannot promise authority it lacks."""
        unknown = [s for s in (value or []) if s not in ALL_SCOPES]
        if unknown:
            raise serializers.ValidationError(f'Unknown scopes: {sorted(unknown)}')
        return list(value or [])

    def validate(self, attrs):
        email = attrs['email']
        if StaffInvitation.objects.filter(email=email, status='pending').exists():
            raise serializers.ValidationError({
                'email': 'There is already a pending invitation for this address. '
                         'Revoke it first if it needs reissuing.',
            })
        return attrs


class StaffInvitationAcceptSerializer(serializers.Serializer):
    """Input for accepting. Deliberately empty.

    There is nothing to submit: the token in the URL identifies the offer, and
    the caller's authenticated email must match it. A form here would be one
    more place for a role to be typed, which is the mistake this whole flow
    exists to make impossible.
    """
