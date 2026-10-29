"""Django-admin surface for live sessions.

Moderation-first recording is reviewable here: the recording lifecycle columns
(``recording_status``, ``mux_status``, ...) are read-only (driven by the egress
pipeline) and filterable, so staff can triage "still recording" vs "ready" vs
"failed" without touching the console.
"""
from django.contrib import admin

from .models import BuddyLive


@admin.register(BuddyLive)
class BuddyLiveAdmin(admin.ModelAdmin):
    list_display = [
        'id', 'title', 'live_type', 'status', 'host', 'started_at', 'ended_at',
        'recording_status', 'mux_status', 'replay_saved',
    ]
    list_filter = [
        'status', 'live_type', 'recording_status', 'mux_status',
        'recording_consent', 'replay_saved', 'content_rating',
    ]
    search_fields = ['title', 'agora_channel', 'mux_asset_id', 'mux_playback_id']
    list_select_related = ['host']
    readonly_fields = [
        'id', 'status', 'started_at', 'ended_at', 'viewer_peak', 'created_at',
        'recording_status', 'mux_status', 'mux_processing_error',
        'mux_asset_id', 'mux_playback_id', 'recording_archive_key',
        'livekit_egress_id', 'replay_url', 'replay_saved',
        'transcript', 'recording_consent',
    ]
    # The live lifecycle is owned by the Start/End views; prevent the admin from
    # mutating state the pipeline drives during a recording.
    def has_add_permission(self, request):
        return False
