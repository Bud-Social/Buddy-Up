"""Create a GymWallet for every existing gym.

Gym creation makes a wallet going forward (see ``CreateGymView``), so this
backfill covers the gyms that already existed when the wallet landed.
Old ``Gym.wallet_balance`` artifacts are folded into the wallet balance so
the legacy join/subscription fees are not lost from view.
"""

from django.db import migrations


def create_wallets(apps, schema_editor):
    Gym = apps.get_model('gyms', 'Gym')
    GymWallet = apps.get_model('gyms', 'GymWallet')

    for gym in Gym.objects.all().only('id', 'wallet_balance'):
        GymWallet.objects.get_or_create(
            gym_id=gym.id,
            defaults={'balance': dict(gym.wallet_balance or {})},
        )


class Migration(migrations.Migration):

    dependencies = [
        ('gyms', '0015_venuelocation_building_name_venuelocation_floor_and_more'),
    ]

    operations = [
        migrations.RunPython(create_wallets, migrations.RunPython.noop),
    ]
