import requests
from django.conf import settings
from django.shortcuts import get_object_or_404
from django.db import models as db_models, transaction
from django.utils import timezone

from rest_framework import views, permissions, status
from rest_framework.parsers import FormParser, MultiPartParser
from rest_framework.response import Response

from common.pagination import PageNumberPagination
from .models import (
    MealPlan, MealPlanPurchase, MealPlanReview,
    TrainingProgramme, TrainingProgrammePurchase, TrainingProgrammeReview,
    Product, MarketplaceEvent, EventTicket,
)
from .serializers import (
    MealPlanSerializer, MealPlanReviewSerializer,
    TrainingProgrammeSerializer, TrainingProgrammeReviewSerializer,
    ProductSerializer, MarketplaceEventSerializer,
    EventTicketSerializer, CreateMealPlanSerializer, CreateTrainingProgrammeSerializer,
    CreateEventSerializer, PersonaliseMealPlanSerializer, ReviewInputSerializer,
)
from apps.wallet.utils import deduct_artifacts, credit_artifacts
from apps.wallet.models import ArtifactTransaction
from apps.wallet.serializers import PLATFORM_CUTS, ARTIFACT_LABELS


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

    def post(self, request):
        serializer = CreateMealPlanSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        plan = MealPlan.objects.create(
            creator=request.user.profile, **serializer.validated_data,
        )
        output = MealPlanFullSerializer(plan, context={'request': request})
        return Response({
            'success': True, 'data': output.data,
            'message': 'Meal plan created.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class MealPlanDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, plan_id):
        plan = get_object_or_404(MealPlan, id=plan_id, is_published=True)
        profile = request.user.profile
        is_owner = profile == plan.creator
        is_purchased = MealPlanPurchase.objects.filter(meal_plan=plan, buyer=profile).exists()

        if is_owner or is_purchased:
            serializer = MealPlanFullSerializer(plan, context={'request': request})
        else:
            serializer = MealPlanSerializer(plan, context={'request': request})

        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })

    def put(self, request, plan_id):
        plan = get_object_or_404(MealPlan, id=plan_id, creator=request.user.profile)
        serializer = UpdateMealPlanSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        for k, v in serializer.validated_data.items():
            setattr(plan, k, v)
        plan.save()
        output = MealPlanFullSerializer(plan, context={'request': request})
        return Response({
            'success': True, 'data': output.data,
            'message': 'Meal plan updated.',
            'errors': None, 'pagination': None,
        })

    def delete(self, request, plan_id):
        plan = get_object_or_404(MealPlan, id=plan_id, creator=request.user.profile)
        plan.delete()
        return Response({
            'success': True, 'data': None,
            'message': 'Meal plan deleted.',
            'errors': None, 'pagination': None,
        })


class PurchaseMealPlanView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, plan_id):
        plan = get_object_or_404(MealPlan, id=plan_id, is_published=True)
        buyer = request.user.profile

        if plan.creator == buyer:
            return Response({
                'success': False, 'data': None,
                'message': 'You cannot purchase your own meal plan.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        purchase, created = MealPlanPurchase.objects.get_or_create(
            meal_plan=plan, buyer=buyer,
        )
        if not created:
            return Response({
                'success': False, 'data': None,
                'message': 'You already purchased this meal plan.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if plan.price_artifacts:
            platform_cut_rate = PLATFORM_CUTS.get('marketplace', 0.15)
            with transaction.atomic():
                for at, qty in plan.price_artifacts.items():
                    if not deduct_artifacts(buyer, at, qty):
                        purchase.delete()
                        return Response({
                            'success': False, 'data': None,
                            'message': f'Insufficient {at} tokens.',
                            'errors': None, 'pagination': None,
                        }, status=status.HTTP_400_BAD_REQUEST)

                    cut_qty = max(1, int(qty * platform_cut_rate))
                    creator_qty = qty - cut_qty
                    if creator_qty > 0:
                        credit_artifacts(plan.creator, at, creator_qty)

                    ArtifactTransaction.objects.create(
                        user=buyer, transaction_type='marketplace',
                        artifact_type=at, quantity=qty, direction='debit',
                        counterparty=plan.creator, status='completed',
                        reference_id=f'mp_mp_{plan.id}',
                    )
                    if creator_qty > 0:
                        ArtifactTransaction.objects.create(
                            user=plan.creator, transaction_type='marketplace',
                            artifact_type=at, quantity=creator_qty, direction='credit',
                            counterparty=buyer, status='completed',
                            reference_id=f'mp_mp_{plan.id}',
                        )
                    if cut_qty > 0:
                        ArtifactTransaction.objects.create(
                            user=plan.creator, transaction_type='platform_cut',
                            artifact_type=at, quantity=cut_qty, direction='debit',
                            status='completed',
                            description=f'Platform fee ({int(platform_cut_rate * 100)}%)',
                        )

                first_tx = ArtifactTransaction.objects.filter(
                    user=buyer, transaction_type='marketplace',
                    reference_id=f'mp_mp_{plan.id}',
                ).first()
                if first_tx:
                    purchase.tx_id = str(first_tx.id)
                    purchase.save(update_fields=['tx_id'])

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
        get_object_or_404(MealPlan, id=plan_id)
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

        serializer = ReviewInputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        review = MealPlanReview.objects.create(
            purchase=purchase, buyer=request.user.profile,
            meal_plan=purchase.meal_plan,
            rating=serializer.validated_data['rating'],
            body=serializer.validated_data.get('body', '')[:500],
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

        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(qs.order_by('-purchase_count'), request)
        serializer = TrainingProgrammeSerializer(page, many=True, context={'request': request})
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None,
            'pagination': {'count': paginator.page.paginator.count, 'next': paginator.get_next_link(), 'previous': paginator.get_previous_link()},
        })

    def post(self, request):
        serializer = CreateTrainingProgrammeSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        programme = TrainingProgramme.objects.create(
            creator=request.user.profile, **serializer.validated_data,
        )
        output = TrainingProgrammeSerializer(programme, context={'request': request})
        return Response({
            'success': True, 'data': output.data,
            'message': 'Programme created.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class TrainingProgrammeDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, programme_id):
        programme = get_object_or_404(TrainingProgramme, id=programme_id, is_published=True)
        serializer = TrainingProgrammeSerializer(programme, context={'request': request})
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })

    def put(self, request, programme_id):
        programme = get_object_or_404(TrainingProgramme, id=programme_id, creator=request.user.profile)
        serializer = UpdateTrainingProgrammeSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        for k, v in serializer.validated_data.items():
            setattr(programme, k, v)
        programme.save()
        output = TrainingProgrammeSerializer(programme, context={'request': request})
        return Response({
            'success': True, 'data': output.data,
            'message': 'Programme updated.',
            'errors': None, 'pagination': None,
        })

    def delete(self, request, programme_id):
        programme = get_object_or_404(TrainingProgramme, id=programme_id, creator=request.user.profile)
        programme.delete()
        return Response({
            'success': True, 'data': None,
            'message': 'Programme deleted.',
            'errors': None, 'pagination': None,
        })


class PurchaseTrainingProgrammeView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, programme_id):
        programme = get_object_or_404(TrainingProgramme, id=programme_id, is_published=True)
        buyer = request.user.profile

        if programme.creator == buyer:
            return Response({
                'success': False, 'data': None,
                'message': 'You cannot purchase your own programme.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        purchase, created = TrainingProgrammePurchase.objects.get_or_create(
            programme=programme, buyer=buyer,
        )
        if not created:
            return Response({
                'success': False, 'data': None,
                'message': 'You already purchased this programme.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if programme.price_artifacts:
            platform_cut_rate = PLATFORM_CUTS.get('marketplace', 0.15)
            with transaction.atomic():
                for at, qty in programme.price_artifacts.items():
                    if not deduct_artifacts(buyer, at, qty):
                        purchase.delete()
                        return Response({
                            'success': False, 'data': None,
                            'message': f'Insufficient {at} tokens.',
                            'errors': None, 'pagination': None,
                        }, status=status.HTTP_400_BAD_REQUEST)

                    cut_qty = max(1, int(qty * platform_cut_rate))
                    creator_qty = qty - cut_qty
                    if creator_qty > 0:
                        credit_artifacts(programme.creator, at, creator_qty)

                    ArtifactTransaction.objects.create(
                        user=buyer, transaction_type='marketplace',
                        artifact_type=at, quantity=qty, direction='debit',
                        counterparty=programme.creator, status='completed',
                        reference_id=f'mp_tp_{programme.id}',
                    )
                    if creator_qty > 0:
                        ArtifactTransaction.objects.create(
                            user=programme.creator, transaction_type='marketplace',
                            artifact_type=at, quantity=creator_qty, direction='credit',
                            counterparty=buyer, status='completed',
                            reference_id=f'mp_tp_{programme.id}',
                        )
                    if cut_qty > 0:
                        ArtifactTransaction.objects.create(
                            user=programme.creator, transaction_type='platform_cut',
                            artifact_type=at, quantity=cut_qty, direction='debit',
                            status='completed',
                            description=f'Platform fee ({int(platform_cut_rate * 100)}%)',
                        )

                first_tx = ArtifactTransaction.objects.filter(
                    user=buyer, transaction_type='marketplace',
                    reference_id=f'mp_tp_{programme.id}',
                ).first()
                if first_tx:
                    purchase.tx_id = str(first_tx.id)
                    purchase.save(update_fields=['tx_id'])

        programme.purchase_count = db_models.F('purchase_count') + 1
        programme.save(update_fields=['purchase_count'])

        serializer = TrainingProgrammeSerializer(programme, context={'request': request})
        return Response({
            'success': True, 'data': serializer.data,
            'message': 'Programme purchased!',
            'errors': None, 'pagination': None,
        })


class TrainingProgrammeReviewView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, programme_id):
        get_object_or_404(TrainingProgramme, id=programme_id)
        reviews = TrainingProgrammeReview.objects.filter(programme_id=programme_id).select_related('buyer').order_by('-created_at')
        serializer = TrainingProgrammeReviewSerializer(reviews, many=True)
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })

    def post(self, request, programme_id):
        purchase = get_object_or_404(TrainingProgrammePurchase, programme_id=programme_id, buyer=request.user.profile)
        if TrainingProgrammeReview.objects.filter(purchase=purchase).exists():
            return Response({
                'success': False, 'data': None,
                'message': 'You already reviewed this programme.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        serializer = ReviewInputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        review = TrainingProgrammeReview.objects.create(
            purchase=purchase, buyer=request.user.profile,
            programme=purchase.programme,
            rating=serializer.validated_data['rating'],
            body=serializer.validated_data.get('body', '')[:500],
        )

        serializer = TrainingProgrammeReviewSerializer(review)
        return Response({
            'success': True, 'data': serializer.data,
            'message': 'Review submitted!',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class ProductListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        category = request.query_params.get('category', '')
        qs = Product.objects.filter(is_active=True).select_related('recommended_by')
        if category:
            qs = qs.filter(category=category)

        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(qs.order_by('-click_count'), request)
        serializer = ProductSerializer(page, many=True)
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None,
            'pagination': {'count': paginator.page.paginator.count, 'next': paginator.get_next_link(), 'previous': paginator.get_previous_link()},
        })

    def post(self, request):
        serializer = CreateProductSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        product = Product.objects.create(
            recommended_by=request.user.profile, **serializer.validated_data,
        )
        output = ProductSerializer(product)
        return Response({
            'success': True, 'data': output.data,
            'message': 'Product created.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class ProductDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, product_id):
        product = get_object_or_404(Product, id=product_id, is_active=True)
        serializer = ProductSerializer(product)
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })

    def put(self, request, product_id):
        product = get_object_or_404(Product, id=product_id, recommended_by=request.user.profile)
        serializer = UpdateProductSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        for k, v in serializer.validated_data.items():
            setattr(product, k, v)
        product.save()
        output = ProductSerializer(product)
        return Response({
            'success': True, 'data': output.data,
            'message': 'Product updated.',
            'errors': None, 'pagination': None,
        })

    def delete(self, request, product_id):
        product = get_object_or_404(Product, id=product_id, recommended_by=request.user.profile)
        product.delete()
        return Response({
            'success': True, 'data': None,
            'message': 'Product deleted.',
            'errors': None, 'pagination': None,
        })


class ProductClickView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, product_id):
        product = get_object_or_404(Product, id=product_id, is_active=True)
        Product.objects.filter(id=product_id).update(click_count=db_models.F('click_count') + 1)
        return Response({
            'success': True, 'data': None,
            'message': 'Click tracked.',
            'errors': None, 'pagination': None,
        })


class EventListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        qs = MarketplaceEvent.objects.filter(is_published=True, is_cancelled=False)
        category = request.query_params.get('category')
        event_type = request.query_params.get('event_type')
        gym_id = request.query_params.get('gym_id')
        upcoming_only = request.query_params.get('upcoming', 'true').lower() == 'true'
        if category:
            qs = qs.filter(category=category)
        if event_type:
            qs = qs.filter(event_type=event_type)
        if gym_id:
            qs = qs.filter(gym_id=gym_id)
        if upcoming_only:
            from django.utils import timezone as tz
            qs = qs.filter(start_datetime__gte=tz.now())
        paginator = PageNumberPagination()
        page = paginator.paginate_queryset(qs, request)
        serializer = MarketplaceEventSerializer(page, many=True, context={'request': request})
        return Response({
            'success': True,
            'data': serializer.data,
            'pagination': {
                'count': paginator.page.paginator.count,
                'next': paginator.get_next_link(),
                'previous': paginator.get_previous_link(),
            },
        })

    def post(self, request):
        ser = CreateEventSerializer(data=request.data)
        if not ser.is_valid():
            return Response({'success': False, 'errors': ser.errors}, status=400)
        data = ser.validated_data
        gym = None
        gym_id = data.pop('gym_id', None)
        if gym_id:
            try:
                from apps.gyms.models import Gym
                gym = Gym.objects.get(id=gym_id)
            except Exception:
                pass
        event = MarketplaceEvent.objects.create(
            creator=request.user.profile,
            gym=gym,
            **data
        )
        return Response({'success': True, 'data': MarketplaceEventSerializer(event, context={'request': request}).data}, status=201)


class EventDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self, event_id):
        try:
            return MarketplaceEvent.objects.get(id=event_id)
        except MarketplaceEvent.DoesNotExist:
            return None

    def get(self, request, event_id):
        event = self.get_object(event_id)
        if not event:
            return Response({'success': False, 'message': 'Event not found.'}, status=404)
        return Response({'success': True, 'data': MarketplaceEventSerializer(event, context={'request': request}).data})

    def put(self, request, event_id):
        event = self.get_object(event_id)
        if not event:
            return Response({'success': False, 'message': 'Event not found.'}, status=404)
        if event.creator != request.user.profile:
            return Response({'success': False, 'message': 'Permission denied.'}, status=403)
        updatable = ['title', 'description', 'cover_image_url', 'event_type', 'location',
                     'online_url', 'start_datetime', 'end_datetime', 'timezone', 'capacity',
                     'ticket_price_artifacts', 'is_free', 'is_published', 'tags', 'category']
        for field in updatable:
            if field in request.data:
                setattr(event, field, request.data[field])
        event.save()
        return Response({'success': True, 'data': MarketplaceEventSerializer(event, context={'request': request}).data})

    def delete(self, request, event_id):
        event = self.get_object(event_id)
        if not event:
            return Response({'success': False, 'message': 'Event not found.'}, status=404)
        if event.creator != request.user.profile:
            return Response({'success': False, 'message': 'Permission denied.'}, status=403)
        event.is_cancelled = True
        event.save()
        return Response({'success': True, 'message': 'Event cancelled.'})


class PurchaseEventTicketView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, event_id):
        try:
            event = MarketplaceEvent.objects.get(id=event_id)
        except MarketplaceEvent.DoesNotExist:
            return Response({'success': False, 'message': 'Event not found.'}, status=404)

        if event.is_cancelled:
            return Response({'success': False, 'message': 'This event has been cancelled.'}, status=400)

        profile = request.user.profile
        if EventTicket.objects.filter(event=event, holder=profile, status='active').exists():
            return Response({'success': False, 'message': 'You already have a ticket for this event.'}, status=400)

        if event.capacity > 0 and event.attendee_count >= event.capacity:
            return Response({'success': False, 'message': 'This event is sold out.'}, status=400)

        price_artifacts = event.ticket_price_artifacts
        if price_artifacts and not event.is_free:
            from apps.wallet.serializers import PLATFORM_CUTS
            platform_cut_rate = PLATFORM_CUTS.get('marketplace', 0.15)
            with transaction.atomic():
                for at, qty in price_artifacts.items():
                    if not deduct_artifacts(profile, at, qty):
                        return Response({
                            'success': False, 'data': None,
                            'message': f'Insufficient {at} tokens.',
                            'errors': None, 'pagination': None,
                        }, status=status.HTTP_400_BAD_REQUEST)
                    cut_qty = max(1, int(qty * platform_cut_rate))
                    creator_qty = qty - cut_qty
                    if creator_qty > 0:
                        credit_artifacts(event.creator, at, creator_qty)

        ticket = EventTicket.objects.create(
            event=event,
            holder=profile,
            price_paid_artifacts=price_artifacts if not event.is_free else {},
        )
        event.attendee_count = EventTicket.objects.filter(event=event, status='active').count()
        event.save(update_fields=['attendee_count'])
        return Response({'success': True, 'data': EventTicketSerializer(ticket, context={'request': request}).data}, status=201)


class MyEventTicketsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        tickets = EventTicket.objects.filter(
            holder=request.user.profile, status='active'
        ).select_related('event').order_by('event__start_datetime')
        return Response({'success': True, 'data': EventTicketSerializer(tickets, many=True, context={'request': request}).data})


class EventTicketDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, ticket_id):
        try:
            ticket = EventTicket.objects.get(id=ticket_id, holder=request.user.profile)
        except EventTicket.DoesNotExist:
            return Response({'success': False, 'message': 'Ticket not found.'}, status=404)
        return Response({'success': True, 'data': EventTicketSerializer(ticket, context={'request': request}).data})


class FoodRecognizeView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser]

    def post(self, request):
        file = request.FILES.get('file')
        if not file:
            return Response({
                'success': False, 'data': None,
                'message': 'No image file provided.',
                'errors': 'file field is required.', 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        if not file.content_type.startswith('image/'):
            return Response({
                'success': False, 'data': None,
                'message': 'File must be an image.',
                'errors': 'invalid content type.', 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        ai_url = f'{settings.AI_SERVICE_URL}/api/v1/food/recognize'
        try:
            resp = requests.post(
                ai_url, files={'file': (file.name, file.read(), file.content_type)},
                timeout=30,
            )
            resp.raise_for_status()
            data = resp.json()
            return Response({
                'success': True, 'data': data,
                'message': 'Food recognition complete.',
                'errors': None, 'pagination': None,
            })
        except requests.RequestException as e:
            return Response({
                'success': False, 'data': None,
                'message': 'Food recognition service unavailable.',
                'errors': str(e), 'pagination': None,
            }, status=status.HTTP_503_SERVICE_UNAVAILABLE)
