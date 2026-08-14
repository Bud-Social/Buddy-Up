from django.core.management.base import BaseCommand
from django.utils import timezone


class Command(BaseCommand):
    help = (
        'Export de-identified engagement + workout data for AI training '
        '(feed_ranker, workout_forecast) into backend/ai_service/data/user/.'
    )

    def handle(self, *args, **options):
        from apps.feed.models import Post, Reaction, Comment, Save
        from django.db.models import Count

        out_dir = self._out_dir()
        out_dir.mkdir(parents=True, exist_ok=True)

        cutoff = timezone.now() - timezone.timedelta(days=180)

        # De-identified engagement: reward = weighted reaction/like signal.
        reaction_rows = (
            Reaction.objects.filter(created_at__gte=cutoff)
            .values('post_id', 'author_id')
            .annotate(n=Count('pk'))
        )
        comment_rows = (
            Comment.objects.filter(created_at__gte=cutoff)
            .values('post_id', 'author_id')
            .annotate(n=Count('pk'))
        )
        save_rows = (
            Save.objects.filter(created_at__gte=cutoff)
            .values('post_id', 'user_id')
            .annotate(n=Count('pk'))
        )

        weights = {}
        for row in reaction_rows:
            weights[(row['post_id'], row['author_id'])] = 1.0 * row['n']
        for row in comment_rows:
            weights[(row['post_id'], row['author_id'])] = weights.get((row['post_id'], row['author_id']), 0) + 0.5 * row['n']
        for row in save_rows:
            weights[(row['post_id'], row['user_id'])] = weights.get((row['post_id'], row['user_id']), 0) + 1.5 * row['n']

        with open(out_dir / 'engagement.csv', 'w') as fh:
            fh.write('user_id,post_id,reward\n')
            for (post_id, user_id), reward in sorted(weights.items()):
                fh.write(f'{user_id},{post_id},{reward}\n')

        # De-identified workout logs (1RM/volume proxy per exercise).
        posts = Post.objects.filter(
            post_type='workout_log',
            workout_log_data__isnull=False,
            created_at__gte=cutoff,
        ).values('author_id', 'workout_log_data', 'created_at')

        with open(out_dir / 'workouts.csv', 'w') as fh:
            fh.write('user_id,date,exercise,weight_kg,reps,sets\n')
            for p in posts:
                data = p['workout_log_data']
                date = p['created_at'].date().isoformat()
                for ex in data.get('exercises', []) if isinstance(data, dict) else []:
                    fh.write(
                        f"{p['author_id']},{date},{ex.get('name', '')},"
                        f"{ex.get('weight', '')},{ex.get('reps', '')},{ex.get('sets', '')}\n"
                    )

        self.stdout.write(self.style.SUCCESS(
            f'Wrote {len(weights)} engagement rows + workout export to {out_dir}'
        ))

    def _out_dir(self):
        from pathlib import Path
        return Path(__file__).resolve().parent.parent.parent.parent.parent / 'ai_service' / 'data' / 'user'
