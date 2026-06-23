from celery import shared_task
from django.utils import timezone


@shared_task
def personalise_meal_plan(purchase_id: str, profile_id: str):
    from .models import MealPlanPurchase
    from apps.profiles.models import Profile

    try:
        purchase = MealPlanPurchase.objects.select_related('meal_plan', 'buyer').get(id=purchase_id)
        profile = Profile.objects.get(user_id=profile_id)
    except (MealPlanPurchase.DoesNotExist, Profile.DoesNotExist):
        return

    plan = purchase.meal_plan
    user_prefs = profile.user.preferences or {}

    # TODO: Call GPT-4o with user profile + meal plan data
    personalised = {
        'message': 'Your personalised meal plan is being generated.',
        'adjusted_portions': True,
        'substitutions': [],
        'macro_summary': {},
        'shopping_list': plan.shopping_list,
        'generated_at': timezone.now().isoformat(),
    }

    purchase.is_personalised = True
    purchase.personalised_data = personalised
    purchase.save(update_fields=['is_personalised', 'personalised_data'])

    from apps.notifications.models import Notification
    Notification.objects.create(
        recipient=purchase.buyer,
        notification_type='payment_received',
        title=f'Your personalised meal plan is ready! 🍽️',
        body=f'"{plan.title}" has been personalised based on your goals and preferences.',
        metadata={'meal_plan_id': str(plan.id), 'purchase_id': str(purchase.id)},
    )
