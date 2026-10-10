"""Governance routes, mounted at ``/api/v1/governance/``.

Separate from ``/api/v1/portal/`` on purpose. The portal is the day-to-day read
and act surface; governance is the surface that decides who may use the portal
and records the actions too dangerous to apply in one step. Mixing them would
mean the routes that grant access sit in the same table as the routes access is
granted over.

Each decision is its own path because the envelope carries a different message
and a different set of failure modes per verb — a rejected approve and a rejected
reject are different events with different audit value.
"""
from django.urls import path

from . import views

app_name = 'governance'

urlpatterns = [
    # --- Staff roles ---
    path('staff-roles/', views.StaffRoleListCreateView.as_view(), name='staff_roles'),
    path('staff-roles/<uuid:pk>/', views.StaffRoleDetailView.as_view(),
         name='staff_role_detail'),

    # --- Two-person approvals ---
    path('approvals/', views.ApprovalListView.as_view(), name='approvals'),
    path('approvals/request/', views.ApprovalRequestCreateView.as_view(),
         name='approval_request'),
    path('approvals/<uuid:pk>/', views.ApprovalDetailView.as_view(), name='approval_detail'),
    path('approvals/<uuid:pk>/approve/', views.ApprovalApproveView.as_view(),
         name='approval_approve'),
    path('approvals/<uuid:pk>/reject/', views.ApprovalRejectView.as_view(),
         name='approval_reject'),
    path('approvals/<uuid:pk>/cancel/', views.ApprovalCancelView.as_view(),
         name='approval_cancel'),
]
