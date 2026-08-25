from django.urls import path
from . import views
from apps.profiles import views as profiles_views

app_name = 'accounts'
urlpatterns = [
    path('register/', views.RegisterView.as_view(), name='register'),
    path('verify-registration-otp/', views.VerifyRegistrationOTPView.as_view(), name='verify_registration_otp'),
    path('login/', views.LoginView.as_view(), name='login'),
    path('google/', views.GoogleLoginView.as_view(), name='google_login'),
    path('apple/', views.AppleLoginView.as_view(), name='apple_login'),
    path('verify-login-otp/', views.VerifyLoginOTPView.as_view(), name='verify_login_otp'),
    path('logout/', views.LogoutView.as_view(), name='logout'),
    path('token/refresh/', views.TokenRefreshView.as_view(), name='token_refresh'),
    path('verify-otp/', views.VerifyOTPView.as_view(), name='verify_otp'),
    path('resend-otp/', views.ResendOTPView.as_view(), name='resend_otp'),
    path('resend-registration-otp/', views.ResendRegistrationOTPView.as_view(), name='resend_registration_otp'),
    path('forgot-password/', views.PasswordResetRequestView.as_view(), name='forgot_password'),
    path('reset-password/', views.PasswordResetConfirmView.as_view(), name='reset_password'),
    path('change-password/', views.ChangePasswordView.as_view(), name='change_password'),
    path('totp/setup/', views.TOTPSetupView.as_view(), name='totp_setup'),
    path('totp/verify/', views.TOTPVerifyView.as_view(), name='totp_verify'),
    path('totp/disable/', views.TOTPDisableView.as_view(), name='totp_disable'),
    path('totp/challenge/', views.TOTPChallengeView.as_view(), name='totp_challenge'),
    path('deactivate/', views.DeactivateAccountView.as_view(), name='deactivate'),
    path('delete/', views.DeleteAccountView.as_view(), name='delete'),
    path('export-data/', views.ExportUserDataView.as_view(), name='export_data'),
    path('sessions/', views.DeviceSessionsListView.as_view(), name='device_sessions'),
    path('logout-all/', views.LogoutAllSessionsView.as_view(), name='logout_all'),
    path('activity-log/', views.ActivityLogView.as_view(), name='activity_log'),
    path('verify-age/', views.VerifyAgeView.as_view(), name='verify_age'),
    # Alias: the web client posts the onboarding payload here.
    path('onboarding/', profiles_views.OnboardingView.as_view(), name='onboarding_alias'),
    path('social/age-setup/', views.SocialAgeSetupView.as_view(), name='social_age_setup'),
    path('recovery-codes/regenerate/', views.RecoveryCodesRegenerateView.as_view(), name='recovery_codes_regenerate'),
    path('passkeys/register/begin/', views.PasskeyRegisterBeginView.as_view(), name='passkey_register_begin'),
    path('passkeys/register/finish/', views.PasskeyRegisterFinishView.as_view(), name='passkey_register_finish'),
    path('passkeys/login/begin/', views.PasskeyLoginBeginView.as_view(), name='passkey_login_begin'),
    path('passkeys/login/finish/', views.PasskeyLoginFinishView.as_view(), name='passkey_login_finish'),
    path('policies/', views.PolicyVersionsView.as_view(), name='policy_versions'),
    path('consent-status/', views.ConsentStatusView.as_view(), name='consent_status'),
]
