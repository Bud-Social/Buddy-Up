import os

from django.core.management.base import BaseCommand, CommandError

from apps.marketplace.models import EventMedia, MarketplaceEvent


class Command(BaseCommand):
    help = (
        'Upload local media files (images/videos) to Cloudinary and attach them '
        'to events as gallery media. Use --image/--video for files, --url for '
        'remote files, or --json to bulk-assign URL lists.'
    )

    def add_arguments(self, parser):
        parser.add_argument('--event', action='append', default=[],
                            help='Event id or slug (repeatable). If omitted, all events are processed.')
        parser.add_argument('--creator', default='',
                            help='Only process events created by this username.')
        parser.add_argument('--image', action='append', default=[],
                            help='Path to a local image file to upload (repeatable).')
        parser.add_argument('--video', action='append', default=[],
                            help='Path to a local video file to upload (repeatable).')
        parser.add_argument('--url', action='append', default=[],
                            help='Remote media URL to attach directly without upload (repeatable).')
        parser.add_argument('--promo-video', default='',
                            help='Local video file path or URL to set as promo_video_url.')
        parser.add_argument('--dry-run', action='store_true', help='Do not upload or save.')

    def handle(self, *args, **options):
        self._dry_run_flag = bool(options['dry_run'])
        events = self._resolve_events(options)
        if not events:
            raise CommandError('No events matched. Use --event <id> or --creator <username>.')

        images = options['image'] or []
        videos = options['video'] or []
        urls = options['url'] or []
        promo = options['promo_video'] or ''

        if not (images or videos or urls or promo):
            raise CommandError('Nothing to attach. Pass --image, --video, --url and/or --promo-video.')

        for event in events:
            self.stdout.write(self.style.SUCCESS(f'\n=== Event: {event.title} ({event.id}) ==='))

            sort = event.media.count()
            for path in images:
                media = self._upload_media(event, path, 'image', sort)
                if media:
                    sort += 1
            for path in videos:
                media = self._upload_media(event, path, 'video', sort)
                if media:
                    sort += 1
            for url in urls:
                media = self._attach_url(event, url, sort)
                if media:
                    sort += 1

            if promo:
                promo_url = promo if promo.startswith(('http://', 'https://')) else promo
                if not self._dry_run_flag:
                    promo_url = self._resolve_url(promo, 'video')
                    event.promo_video_url = promo_url
                    event.save(update_fields=['promo_video_url'])
                self.stdout.write(self.style.SUCCESS(f'  promo_video_url set: {promo_url}'))

            self.stdout.write(self.style.SUCCESS(f'  total media now: {event.media.count()}'))

    def _resolve_events(self, options):
        events = MarketplaceEvent.objects.all()
        if options['creator']:
            events = events.filter(creator__user__username=options['creator'])
        if options['event']:
            events = events.filter(id__in=options['event'])
        return list(events)

    def _upload_media(self, event, path, media_type, sort):
        if self._dry_run:
            self.stdout.write(self.style.WARNING(f'  [dry-run] would upload {media_type}: {path}'))
            return None
        try:
            url, thumbnail = self._upload_file(path, media_type)
        except Exception as exc:  # noqa: BLE001
            self.stderr.write(f'  !! failed to upload {path}: {exc}')
            return None

        self.stdout.write(self.style.SUCCESS(f'  + {media_type}: {url}'))

        return EventMedia.objects.create(
            event=event,
            media_type=media_type,
            url=url,
            thumbnail_url=thumbnail,
            alt_text=os.path.splitext(os.path.basename(path))[0],
            sort_order=sort,
        )

    def _attach_url(self, event, url, sort):
        media_type = 'video' if url.lower().endswith(('.mp4', '.webm', '.mov', '.m3u8')) else 'image'
        self.stdout.write(self.style.SUCCESS(f'  + {media_type} (url): {url}'))
        if self._dry_run:
            return None
        return EventMedia.objects.create(
            event=event,
            media_type=media_type,
            url=url,
            thumbnail_url=url if media_type == 'image' else '',
            alt_text='',
            sort_order=sort,
        )

    def _upload_file(self, path, media_type):
        if path.startswith(('http://', 'https://')):
            return path, (path if media_type == 'image' else '')

        if not os.path.isfile(path):
            raise FileNotFoundError(path)

        import cloudinary.uploader
        resource_type = 'image' if media_type == 'image' else 'video'
        if resource_type == 'image':
            result = cloudinary.uploader.upload(
                path,
                folder='marketplace/events/media',
                resource_type='image',
                transformation=[{'quality': 'auto', 'fetch_format': 'auto'}],
            )
            return result['secure_url'], result['secure_url']
        result = cloudinary.uploader.upload(
            path,
            folder='marketplace/events/media',
            resource_type='video',
            chunk_size=6_000_000,
        )
        thumbnail = ''
        try:
            thumb = cloudinary.uploader.upload(
                path,
                folder='marketplace/events/media',
                resource_type='video',
                transformation=[{'width': 640, 'crop': 'scale'}],
                format='jpg',
            )
            thumbnail = thumb.get('secure_url', '')
        except Exception:  # noqa: BLE001
            pass
        return result['secure_url'], thumbnail

    @property
    def _dry_run(self):
        return self._dry_run_flag

    def _resolve_url(self, path, media_type):
        if path.startswith(('http://', 'https://')):
            return path
        url, _ = self._upload_file(path, media_type)
        return url
