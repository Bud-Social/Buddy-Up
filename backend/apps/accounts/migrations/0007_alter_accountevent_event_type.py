from django.db import migrations, models


class Migration(migrations.Migration):
    dependencies = [('accounts', '0006_passkey_security_state')]

    operations = [
        migrations.AlterField(
            model_name='accountevent',
            name='event_type',
            field=models.CharField(max_length=30, choices=[
                ('login', 'Login'), ('login_failed', 'Login Failed'),
                ('login_new_device', 'Login from New Device'),
                ('login_new_country', 'Login from New Country'),
                ('password_changed', 'Password Changed'), ('email_changed', 'Email Changed'),
                ('2fa_enabled', '2FA Enabled'), ('2fa_disabled', '2FA Disabled'),
                ('passkey_registered', 'Passkey Registered'), ('passkey_renamed', 'Passkey Renamed'),
                ('passkey_revoked', 'Passkey Revoked'),
                ('security_notification_sent', 'Security Notification Sent'),
                ('account_deactivated', 'Account Deactivated'), ('account_reactivated', 'Account Reactivated'),
                ('account_deleted', 'Account Deleted'), ('post_created', 'Post Created'),
                ('post_deleted', 'Post Deleted'), ('buddy_request_sent', 'Buddy Request Sent'),
                ('buddy_request_accepted', 'Buddy Request Accepted'), ('profile_updated', 'Profile Updated'),
                ('avatar_updated', 'Avatar Updated'), ('comment_added', 'Comment Added'),
                ('reaction_added', 'Reaction Added'), ('live_started', 'Live Started'),
                ('session_booked', 'Session Booked'), ('marketplace_purchase', 'Marketplace Purchase'),
                ('wallet_transaction', 'Wallet Transaction'),
            ]),
        ),
    ]
