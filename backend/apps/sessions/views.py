from django.shortcuts import get_object_or_404
from django.db import models as db_models
from django.utils import timezone
from datetime import timedelta

from rest_framework import views, permissions, status
from rest_framework.response import Response

from common.pagination import CursorPagination
from .models import (
    TrainerProfile, Availability, BookingSession, Review,
    AsyncProgramme, ProgrammeWeek, ProgrammeEnrollment,
)
from .serializers import (
    TrainerProfileSerializer, AvailabilitySerializer,
    BookingSerializer, CreateBookingSerializer,
    ReviewSerializer, ProgrammeSerializer,
    ProgrammeWeekSerializer, ProgrammeEnrollmentSerializer,
    BookingActionSerializer, AvailabilityCreateSerializer, ReviewCreateSerializer,
)
from apps.profiles.models import Profile
from apps.wallet.utils import hold_artifacts, release_held_refund, release_held_to_party, platform_cut
from apps.wallet.models import ArtifactTransaction


class TrainerListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        specialty = request.query_params.get('specialty', '')
        qs = TrainerProfile.objects.filter(profile__role__in=['trainer', 'practitioner']).select_related('profile')
        qs = qs.order_by('-average_rating', '-review_count')
        if specialty:
            qs = [t for t in qs if specialty in (t.specialties or [])]

        serializer = TrainerProfileSerializer(qs, many=True)
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })


class TrainerDetailView(views.APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, username):
        profile = get_object_or_404(Profile, username=username, role__in=['trainer', 'practitioner'])
        trainer, _ = TrainerProfile.objects.get_or_create(profile=profile)
        serializer = TrainerProfileSerializer(trainer)
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })

    def patch(self, request, username):
        profile = get_object_or_404(Profile, username=username, user_id=request.user.id)
        trainer, _ = TrainerProfile.objects.get_or_create(profile=profile)
        allowed = ['specialties', 'certifications', 'languages', 'session_types', 'pricing']
        for k in allowed:
            if k in request.data:
                setattr(trainer, k, request.data[k])
        trainer.save(update_fields=[k for k in allowed if k in request.data])
        return Response({
            'success': True,
            'data': TrainerProfileSerializer(trainer).data,
            'message': 'Trainer profile updated.',
            'errors': None, 'pagination': None,
        })


class AvailabilityView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, username):
        profile = get_object_or_404(Profile, username=username, role__in=['trainer', 'practitioner'])
        trainer = get_object_or_404(TrainerProfile, profile=profile)
        slots = Availability.objects.filter(trainer=trainer, is_active=True).order_by('day_of_week', 'start_time')
        return Response({
            'success': True, 'data': AvailabilitySerializer(slots, many=True).data,
            'message': 'OK', 'errors': None, 'pagination': None,
        })

    def post(self, request):
        trainer = get_object_or_404(TrainerProfile, profile=request.user.profile)
        serializer = AvailabilityCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        slot = Availability.objects.create(
            trainer=trainer,
            **serializer.validated_data,
        )
        return Response({
            'success': True,
            'data': AvailabilitySerializer(slot).data,
            'message': 'Availability added.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class BookingCreateView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, username):
        trainer_profile = get_object_or_404(Profile, username=username, role__in=['trainer', 'practitioner'])
        serializer = CreateBookingSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data

        trainer, _ = TrainerProfile.objects.get_or_create(profile=trainer_profile)
        pricing = trainer.pricing or {}
        session_key = f"{data['session_type']}_{data['duration_minutes']}"
        fee = pricing.get(session_key, {'dumbbell': 2})

        booking = BookingSession.objects.create(
            client=request.user.profile,
            trainer=trainer_profile,
            session_type=data['session_type'],
            scheduled_at=data['scheduled_at'],
            duration_minutes=data['duration_minutes'],
            artifact_fee=fee,
            notes=data.get('notes', ''),
            status='pending',
        )

        tx_ids = []
        for at, qty in fee.items():
            tx = hold_artifacts(
                profile=request.user.profile,
                artifact_type=at,
                quantity=qty,
                counterparty=trainer_profile,
                reference_id=str(booking.id),
            )
            if tx is None:
                booking.delete()
                for tid in tx_ids:
                    ArtifactTransaction.objects.filter(id=tid).delete()
                return Response({
                    'success': False, 'data': None,
                    'message': f'Insufficient {at} balance.',
                    'errors': None, 'pagination': None,
                }, status=status.HTTP_402_PAYMENT_REQUIRED)
            tx_ids.append(str(tx.id))

        booking.escrow_tx_id = ','.join(tx_ids)
        booking.status = 'confirmed'
        booking.save(update_fields=['status', 'escrow_tx_id'])

        from apps.notifications.tasks import create_notification
        create_notification.delay(
            recipient_id=trainer_profile.user_id,
            notification_type='session_booked',
            title='New Session Booked',
            body=f'{request.user.profile.display_name} booked a {data["session_type"]} session.',
            metadata={'booking_id': str(booking.id)},
        )

        return Response({
            'success': True,
            'data': BookingSerializer(booking).data,
            'message': 'Session booked!',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class MyBookingsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        role = request.query_params.get('role', 'client')
        if role == 'trainer':
            qs = BookingSession.objects.filter(trainer=request.user.profile)
        else:
            qs = BookingSession.objects.filter(client=request.user.profile)

        filter_status = request.query_params.get('status')
        if filter_status:
            qs = qs.filter(status=filter_status)

        qs = qs.order_by('-scheduled_at').select_related('client', 'trainer')
        count = qs.count()

        paginator = CursorPagination()
        page = paginator.paginate_queryset(qs, request)
        serializer = BookingSerializer(page, many=True)

        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None,
            'pagination': {
                'count': count,
                'next': paginator.get_next_link(),
                'previous': paginator.get_previous_link(),
            },
        })


class BookingDetailView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, booking_id):
        booking = get_object_or_404(BookingSession, id=booking_id)
        if request.user.profile not in (booking.client, booking.trainer):
            return Response(status=status.HTTP_403_FORBIDDEN)

        return Response({
            'success': True,
            'data': BookingSerializer(booking).data,
            'message': 'OK', 'errors': None, 'pagination': None,
        })

    def post(self, request, booking_id):
        booking = get_object_or_404(BookingSession, id=booking_id)
        serializer = BookingActionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        action = serializer.validated_data['action']

        if action == 'start':
            if request.user.profile == booking.trainer and booking.status == 'confirmed':
                booking.status = 'in_progress'
                booking.save(update_fields=['status'])
                return Response({
                    'success': True, 'data': None,
                    'message': 'Session started.',
                    'errors': None, 'pagination': None,
                })

        if action == 'complete':
            if request.user.profile == booking.trainer and booking.status == 'in_progress':
                booking.status = 'completed'
                booking.completed_at = timezone.now()
                booking.save(update_fields=['status', 'completed_at'])
                from .tasks import process_escrow_release
                process_escrow_release.delay(str(booking.id))
                return Response({
                    'success': True, 'data': None,
                    'message': 'Session marked as completed.',
                    'errors': None, 'pagination': None,
                })

        if action == 'cancel':
            if request.user.profile == booking.client:
                diff = booking.scheduled_at - timezone.now()
                refund_pct = 1.0 if diff > timedelta(hours=24) else 0.5
                tx_ids = [t for t in booking.escrow_tx_id.split(',') if t]
                for tx_id in tx_ids:
                    try:
                        tx = ArtifactTransaction.objects.get(id=tx_id, status='held')
                    except ArtifactTransaction.DoesNotExist:
                        continue
                    refund_qty = max(1, int(tx.quantity * refund_pct))
                    trainer_qty = tx.quantity - refund_qty
                    if refund_qty > 0:
                        release_held_refund(booking.client, tx.artifact_type, refund_qty)
                    if trainer_qty > 0:
                        release_held_to_party(booking.client, booking.trainer, tx.artifact_type, trainer_qty)
                    tx.status = 'refunded'
                    tx.description = f'Client cancelled. Refund {refund_qty}/{tx.quantity}'
                    tx.save(update_fields=['status', 'description'])
                booking.status = 'cancelled_by_client'
                booking.cancelled_at = timezone.now()
                booking.save(update_fields=['status', 'cancelled_at'])
                return Response({
                    'success': True, 'data': {'refund_pct': refund_pct},
                    'message': f'Session cancelled. {int(refund_pct * 100)}% refunded.',
                    'errors': None, 'pagination': None,
                })
            elif request.user.profile == booking.trainer:
                tx_ids = [t for t in booking.escrow_tx_id.split(',') if t]
                for tx_id in tx_ids:
                    try:
                        tx = ArtifactTransaction.objects.get(id=tx_id, status='held')
                    except ArtifactTransaction.DoesNotExist:
                        continue
                    release_held_refund(booking.client, tx.artifact_type, tx.quantity)
                    tx.status = 'refunded'
                    tx.description = f'Trainer cancelled. Full refund.'
                    tx.save(update_fields=['status', 'description'])
                booking.status = 'cancelled_by_trainer'
                booking.cancelled_at = timezone.now()
                booking.save(update_fields=['status', 'cancelled_at'])
                return Response({
                    'success': True, 'data': None,
                    'message': 'Session cancelled. Full refund issued.',
                    'errors': None, 'pagination': None,
                })

        return Response({
            'success': False, 'data': None,
            'message': 'Invalid action or not permitted.',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_400_BAD_REQUEST)


class ReviewView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, booking_id):
        booking = get_object_or_404(BookingSession, id=booking_id, client=request.user.profile, status='completed')
        if Review.objects.filter(session=booking).exists():
            return Response({
                'success': False, 'data': None,
                'message': 'You already reviewed this session.',
                'errors': None, 'pagination': None,
            }, status=status.HTTP_400_BAD_REQUEST)

        serializer = ReviewCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        review = Review.objects.create(
            session=booking, client=request.user.profile,
            trainer=booking.trainer,
            rating=serializer.validated_data['rating'],
            body=serializer.validated_data.get('body', '')[:500],
        )

        trainer, _ = TrainerProfile.objects.get_or_create(profile=booking.trainer)
        avg = Review.objects.filter(trainer=booking.trainer).aggregate(avg=db_models.Avg('rating'))['avg'] or 0
        trainer.average_rating = round(avg, 1)
        trainer.review_count = db_models.F('review_count') + 1
        trainer.save(update_fields=['average_rating', 'review_count'])

        return Response({
            'success': True,
            'data': ReviewSerializer(review).data,
            'message': 'Review submitted!',
            'errors': None, 'pagination': None,
        }, status=status.HTTP_201_CREATED)


class TrainerReviewsView(views.APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request, username):
        profile = get_object_or_404(Profile, username=username)
        reviews = Review.objects.filter(trainer=profile).order_by('-created_at').select_related('session', 'client')
        serializer = ReviewSerializer(reviews, many=True)
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })


class ProgrammeListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        qs = AsyncProgramme.objects.filter(is_active=True).select_related('trainer')
        trainer = request.query_params.get('trainer')
        if trainer:
            qs = qs.filter(trainer__username=trainer)
        serializer = ProgrammeSerializer(qs.order_by('-created_at'), many=True)
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })


class ProgrammeEnrollmentView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, programme_id):
        programme = get_object_or_404(AsyncProgramme, id=programme_id, is_active=True)
        enrollment, created = ProgrammeEnrollment.objects.get_or_create(
            client=request.user.profile, programme=programme,
        )
        if created:
            programme.enrolled_count = db_models.F('enrolled_count') + 1
            programme.save(update_fields=['enrolled_count'])

        return Response({
            'success': True,
            'data': {'enrolled': created},
            'message': 'Enrolled!' if created else 'Already enrolled.',
            'errors': None, 'pagination': None,
        })


class ProgrammeWeekListView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, programme_id):
        programme = get_object_or_404(AsyncProgramme, id=programme_id, is_active=True)
        weeks = programme.weeks.all().order_by('week_number')
        serializer = ProgrammeWeekSerializer(weeks, many=True)
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })


class ProgrammeWeekCompleteView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, programme_id, week_number):
        programme = get_object_or_404(AsyncProgramme, id=programme_id, is_active=True)
        week = get_object_or_404(ProgrammeWeek, programme=programme, week_number=week_number)
        enrollment = get_object_or_404(ProgrammeEnrollment, client=request.user.profile, programme=programme)

        completed = enrollment.completed_weeks or []
        if week_number not in completed:
            completed.append(week_number)
            enrollment.completed_weeks = completed
            duration = programme.duration_weeks or 1
            enrollment.progress_pct = int(len(completed) / duration * 100)
            enrollment.save(update_fields=['completed_weeks', 'progress_pct'])

        return Response({
            'success': True,
            'data': {'completed_weeks': completed, 'progress_pct': enrollment.progress_pct},
            'message': 'Week completed!' if week_number not in completed else 'Already completed.',
            'errors': None, 'pagination': None,
        })


class MyEnrolmentsView(views.APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        enrollments = ProgrammeEnrollment.objects.filter(
            client=request.user.profile
        ).select_related('programme').order_by('-created_at')
        serializer = ProgrammeEnrollmentSerializer(enrollments, many=True)
        return Response({
            'success': True, 'data': serializer.data, 'message': 'OK',
            'errors': None, 'pagination': None,
        })
