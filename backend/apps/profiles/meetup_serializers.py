"""Serializers for buddy meetups and their ratings."""

from rest_framework import serializers

from .models import BuddyMeetup, BuddyMeetupRating


class BuddyMeetupRatingSerializer(serializers.ModelSerializer):
    """One rating, as the viewer is allowed to see it.

    A rating reaches the other participant a few days after it is written.
    Until then the viewer sees that a rating is coming, but not what it
    says — and never the note.
    """

    rater_username = serializers.CharField(source='rater.username', read_only=True)
    rater_display_name = serializers.CharField(source='rater.display_name', read_only=True)
    rater_avatar_url = serializers.CharField(source='rater.avatar_url', read_only=True)
    #: False while the rating is still waiting for the other person.
    revealed = serializers.SerializerMethodField()
    visible_at = serializers.DateTimeField(read_only=True)

    class Meta:
        model = BuddyMeetupRating
        fields = [
            'id', 'rater_username', 'rater_display_name', 'rater_avatar_url',
            'score', 'note', 'rated_at', 'visible_at', 'revealed',
        ]
        read_only_fields = fields

    def get_revealed(self, obj):
        viewer = self.context.get('viewer')
        return obj.visible_to(viewer)


class BuddyMeetupSerializer(serializers.ModelSerializer):
    """A meetup, with the ratings the viewer may see.

    The average only counts the ratings that have been revealed, so a
    half-seen pair never looks like a full one.
    """

    partner_username = serializers.SerializerMethodField()
    partner_display_name = serializers.SerializerMethodField()
    partner_avatar_url = serializers.SerializerMethodField()
    ratings = serializers.SerializerMethodField()
    average_score = serializers.SerializerMethodField()
    rating_count = serializers.SerializerMethodField()
    my_rating = serializers.SerializerMethodField()
    can_rate = serializers.SerializerMethodField()

    class Meta:
        model = BuddyMeetup
        fields = [
            'id', 'state', 'scheduled_at', 'place', 'note', 'created_at',
            'met_at', 'partner_username', 'partner_display_name',
            'partner_avatar_url', 'ratings', 'average_score', 'rating_count',
            'my_rating', 'can_rate',
        ]
        read_only_fields = fields

    def _viewer(self):
        return self.context.get('viewer')

    def _partner(self, obj):
        return obj.partner_for(self._viewer())

    def get_partner_username(self, obj):
        partner = self._partner(obj)
        return partner.username if partner else None

    def get_partner_display_name(self, obj):
        partner = self._partner(obj)
        return partner.display_name if partner else None

    def get_partner_avatar_url(self, obj):
        partner = self._partner(obj)
        return partner.avatar_url if partner else None

    def get_ratings(self, obj):
        viewer = self._viewer()
        revealed = [r for r in obj.ratings.all() if r.visible_to(viewer)]
        # A rating that is still waiting is shown as pending, without its
        # score or note, so both sides can see that a rating is coming.
        pending = [
            {'id': str(r.id), 'rater_username': r.rater.username, 'pending': True}
            for r in obj.ratings.all()
            if not r.visible_to(viewer)
        ]
        return BuddyMeetupRatingSerializer(
            revealed, many=True, context={'viewer': viewer}
        ).data + pending

    def get_average_score(self, obj):
        viewer = self._viewer()
        scores = [r.score for r in obj.ratings.all() if r.visible_to(viewer)]
        if not scores:
            return None
        return round(sum(scores) / len(scores), 1)

    def get_rating_count(self, obj):
        viewer = self._viewer()
        return len([r for r in obj.ratings.all() if r.visible_to(viewer)])

    def get_my_rating(self, obj):
        viewer = self._viewer()
        if viewer is None:
            return None
        mine = next((r for r in obj.ratings.all() if r.rater_id == viewer.user_id), None)
        if mine is None:
            return None
        return BuddyMeetupRatingSerializer(
            mine, context={'viewer': viewer}
        ).data

    def get_can_rate(self, obj):
        """A meetup can be rated once it has happened, once each."""
        viewer = self._viewer()
        if viewer is None or obj.state != 'met':
            return False
        return not any(r.rater_id == viewer.user_id for r in obj.ratings.all())


class BuddyMeetupCreateSerializer(serializers.Serializer):
    """What it takes to plan a meetup."""

    username = serializers.CharField(max_length=60)
    scheduled_at = serializers.DateTimeField(required=False, allow_null=True)
    place = serializers.CharField(max_length=140, required=False, allow_blank=True)
    note = serializers.CharField(max_length=280, required=False, allow_blank=True)


class BuddyMeetupRatingInputSerializer(serializers.Serializer):
    """A rating: a score out of five, and optionally a note."""

    score = serializers.IntegerField(min_value=1, max_value=5)
    note = serializers.CharField(max_length=280, required=False, allow_blank=True)
