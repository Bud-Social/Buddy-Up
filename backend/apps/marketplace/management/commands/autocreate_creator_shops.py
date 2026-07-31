"""Management command: autocreate_creator_shops

For every Profile that has created at least one marketplace item (meal plan,
programme, event, or product) but has NO ShopMembership yet, create a default
shop and assign them as owner.  Existing items are then linked to the new shop.

Usage:
    python manage.py autocreate_creator_shops
    python manage.py autocreate_creator_shops --dry-run
"""
from django.core.management.base import BaseCommand
from django.utils.text import slugify


class Command(BaseCommand):
    help = 'Auto-create shops for existing marketplace creators who have no shop yet.'

    def add_arguments(self, parser):
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Print what would be done without making any changes.',
        )

    def handle(self, *args, **options):
        dry_run = options['dry_run']

        from apps.profiles.models import Profile
        from apps.marketplace.models import (
            Shop, ShopMembership,
            MealPlan, TrainingProgramme, Product, MarketplaceEvent,
        )

        # Collect all profiles that have created marketplace items
        creator_ids = set()
        creator_ids.update(MealPlan.objects.values_list('creator_id', flat=True))
        creator_ids.update(TrainingProgramme.objects.values_list('creator_id', flat=True))
        creator_ids.update(MarketplaceEvent.objects.values_list('creator_id', flat=True))
        creator_ids.update(
            Product.objects.filter(recommended_by__isnull=False).values_list('recommended_by_id', flat=True)
        )

        # Exclude those who already have a shop membership
        existing_owner_ids = set(ShopMembership.objects.values_list('profile_id', flat=True))
        creator_ids -= existing_owner_ids

        profiles = Profile.objects.filter(user_id__in=creator_ids).select_related('user')

        self.stdout.write(f'Found {profiles.count()} creators without a shop.')

        created_count = 0
        for profile in profiles:
            shop_name = profile.creator_display_name or profile.display_name or f"{profile.username}'s Shop"
            base_handle = slugify(profile.username)
            handle = base_handle
            suffix = 1
            while Shop.objects.filter(handle=handle).exists():
                handle = f'{base_handle}-{suffix}'
                suffix += 1

            if dry_run:
                self.stdout.write(
                    f'  [DRY RUN] Would create shop "{shop_name}" (handle: @{handle}) for @{profile.username}'
                )
                continue

            shop = Shop.objects.create(
                name=shop_name,
                handle=handle,
                description=f'Official shop for {profile.display_name}',
                category='mixed',
            )
            ShopMembership.objects.create(shop=shop, profile=profile, role='owner')

            # Link existing items to the new shop
            MealPlan.objects.filter(creator=profile, shop__isnull=True).update(shop=shop)
            TrainingProgramme.objects.filter(creator=profile, shop__isnull=True).update(shop=shop)
            MarketplaceEvent.objects.filter(creator=profile, shop__isnull=True).update(shop=shop)
            Product.objects.filter(recommended_by=profile, shop__isnull=True).update(shop=shop)

            created_count += 1
            self.stdout.write(
                self.style.SUCCESS(
                    f'  Created shop "{shop_name}" (@{handle}) for @{profile.username}'
                )
            )

        if not dry_run:
            self.stdout.write(self.style.SUCCESS(f'\nDone. Created {created_count} shops.'))
        else:
            self.stdout.write(self.style.WARNING(f'\n[DRY RUN] Would create {profiles.count()} shops.'))
