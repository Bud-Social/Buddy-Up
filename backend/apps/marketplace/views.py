from django.shortcuts import get_object_or_404
from django.db import models as db_models
from django.utils import timezone

from rest_framework import views, permissions, status
from rest_framework.response import Response

from common.pagination import PageNumberPagination
from .models import MealPlan, MealPlanPurchase, MealPlanReview, TrainingProgramme, Product
from .serializers import (
    MealPlanSerializer, MealPlanFullSerializer, MealPlanReviewSerializer,
    TrainingProgrammeSerializer, ProductSerializer, PersonaliseMealPlanSerializer,
)


class MealPlanListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        diet_type = request.query_params.get('diet_type', '')
        qs = MealPlan.objects.filter(is_published=True).select_related('creator')
        if diet_type:
            qs = qs.filter(diet_type=diet_type)
        qs = qs.order_by('-purchase_count', '-average_rating')

        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(qs, request)
        serializer = MealPlanSerializer(page, many=True, context={'request': request})

        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None,
            'pagination': {'count': paginator.page.paginator.count, 'next': paginator.get_next_link(), 'previous': paginator.get_previous_link()},
        })


class MealPlanDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, plan_id):
        plan = get_object_or_404(MealPlan, id=plan_id, is_published=True)
        is_owner = request.user.profile == plan.creator

        if is_owner:
            serializer = MealPlanFullSerializer(plan, context={'request': request})
        else:
            serializer = MealPlanSerializer(plan, context={'request': request})

        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })


class PurchaseMealPlanView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, plan_id):
        plan = get_object_or_404(MealPlan, id=plan_id, is_published=True)

        if plan.creator == request.user.profile:
            return Response({
                'success': False, 'data': None,
                'message': 'You cannot purchase your own meal plan.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        purchase, created = MealPlanPurchase.objects.get_or_create(
            meal_plan=plan, buyer=request.user.profile,
        )
        if not created:
            return Response({
                'success': False, 'data': None,
                'message': 'You already purchased this meal plan.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if plan.price_artifacts:
            from apps.wallet.views import _deduct_artifacts
            for at, qty in plan.price_artifacts.items():
                if not _deduct_artifacts(request.user.profile, at, qty):
                    purchase.delete()
                    return Response({
                        'success': False, 'data': None,
                        'message': f'Insufficient {at} tokens.',
                        'errors': None, 'pagination': None,
                    }, status=status.HTTP_400_BAD_REQUEST)
                from apps.wallet.views import _credit_artifacts
                _credit_artifacts(plan.creator, at, max(1, int(qty * 0.85)))

        plan.purchase_count = db_models.F('purchase_count') + 1
        plan.save(update_fields=['purchase_count'])

        serializer = MealPlanFullSerializer(plan, context={'request': request})
        return Response({
            'success': True, 'data': serializer.data,
            'message': 'Meal plan purchased! Enjoy your plan.',
            'errors': None, 'pagination': None,
        })


class MealPlanReviewView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, plan_id):
        reviews = MealPlanReview.objects.filter(meal_plan_id=plan_id).select_related('buyer').order_by('-created_at')
        serializer = MealPlanReviewSerializer(reviews, many=True)
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })

    def post(self, request, plan_id):
        purchase = get_object_or_404(MealPlanPurchase, meal_plan_id=plan_id, buyer=request.user.profile)
        if MealPlanReview.objects.filter(purchase=purchase).exists():
            return Response({
                'success': False, 'data': None,
                'message': 'You already reviewed this meal plan.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        rating = min(5, max(1, int(request.data.get('rating', 5))))
        review = MealPlanReview.objects.create(
            purchase=purchase, buyer=request.user.profile,
            meal_plan=purchase.meal_plan, rating=rating,
            body=request.data.get('body', '')[:500],
        )

        plan = purchase.meal_plan
        avg = MealPlanReview.objects.filter(meal_plan=plan).aggregate(avg=db_models.Avg('rating'))['avg'] or 0
        plan.average_rating = round(avg, 1)
        plan.review_count = db_models.F('review_count') + 1
        plan.save(update_fields=['average_rating', 'review_count'])

        return Response({
            'success': True,
            'data': MealPlanReviewSerializer(review).data,
            'message': 'Review submitted!',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class PersonaliseMealPlanView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, plan_id):
        plan = get_object_or_404(MealPlan, id=plan_id, is_published=True)
        purchase = get_object_or_404(MealPlanPurchase, meal_plan=plan, buyer=request.user.profile)

        from .tasks import personalise_meal_plan
        personalise_meal_plan.delay(str(purchase.id), str(request.user.profile.user_id))

        return Response({
            'success': True, 'data': {'status': 'processing'},
            'message': 'Personalising your meal plan... You\'ll be notified when it\'s ready.',
            'errors': None, 'pagination': None,
        })


class TrainingProgrammeListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        category = request.query_params.get('category', '')
        qs = TrainingProgramme.objects.filter(is_published=True).select_related('creator')
        if category:
            qs = qs.filter(category=category)
        serializer = TrainingProgrammeSerializer(qs.order_by('-purchase_count'), many=True)
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })


class ProductListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        category = request.query_params.get('category', '')
        qs = Product.objects.filter(is_active=True).select_related('recommended_by')
        if category:
            qs = qs.filter(category=category)
        serializer = ProductSerializer(qs.order_by('-click_count'), many=True)
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })
