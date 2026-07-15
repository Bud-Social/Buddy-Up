import logging

import requests
from celery import shared_task
from django.conf import settings
from django.utils import timezone

logger = logging.getLogger(__name__)


@shared_task(bind=True, max_retries=3, default_retry_delay=30)
def personalise_meal_plan(self, purchase_id: str, profile_id: str):
    from .models import MealPlanPurchase
    from apps.profiles.models import Profile

    try:
        purchase = MealPlanPurchase.objects.select_related('meal_plan', 'buyer').get(id=purchase_id)
        profile = Profile.objects.get(user_id=profile_id)
    except (MealPlanPurchase.DoesNotExist, Profile.DoesNotExist):
        return

    plan = purchase.meal_plan
    user_prefs = profile.user.preferences or {}

    payload = {
        'profile_summary': f'Age: {profile.user.date_of_birth}, Goals: {user_prefs.get("goals", "")}, Activity: {user_prefs.get("activity_level", "")}',
        'goals': user_prefs.get('goals', ''),
        'dietary_preferences': plan.diet_type.split(',') if plan.diet_type else [],
        'allergies': user_prefs.get('allergies', []),
        'calorie_target': user_prefs.get('calorie_target'),
        'plan_template': {
            'title': plan.title,
            'description': plan.description,
            'duration_weeks': plan.duration_weeks,
            'calorie_range': plan.calorie_range,
            'full_plan': plan.full_plan,
            'shopping_list': plan.shopping_list,
        },
    }

    try:
        resp = requests.post(
            f'{settings.AI_SERVICE_URL}/api/v1/meal-plans/personalise',
            json=payload,
            timeout=30,
        )
        resp.raise_for_status()
        ai_result = resp.json()
        personalised = {
            'adjusted_portions': ai_result.get('adjusted_portions', True),
            'substitutions': ai_result.get('substitutions', []),
            'macro_summary': ai_result.get('macro_summary', {}),
            'shopping_list': ai_result.get('shopping_list', plan.shopping_list),
            'notes': ai_result.get('notes', ''),
            'generated_at': timezone.now().isoformat(),
        }
    except requests.RequestException as exc:
        logger.warning('AI service unavailable for purchase %s: %s', purchase_id, exc)
        try:
            self.retry(exc=exc)
        except self.MaxRetriesExceededError:
            personalised = {
                'adjusted_portions': True,
                'substitutions': [],
                'macro_summary': {},
                'shopping_list': plan.shopping_list,
                'notes': 'Personalisation is temporarily unavailable. Your meal plan has been applied with default settings.',
                'generated_at': timezone.now().isoformat(),
            }

    purchase.is_personalised = True
    purchase.personalised_data = personalised
    purchase.save(update_fields=['is_personalised', 'personalised_data'])

    from apps.notifications.models import Notification
    Notification.objects.create(
        recipient=purchase.buyer,
        notification_type='payment_received',
        title='Your personalised meal plan is ready!',
        body=f'"{plan.title}" has been personalised based on your goals and preferences.',
        metadata={'meal_plan_id': str(plan.id), 'purchase_id': str(purchase.id)},
    )
