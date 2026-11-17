import 'package:flutter/material.dart';

/// One source of truth for verified-account colours on Flutter surfaces.
/// Mirrors `frontend/src/lib/verificationBadge.ts` — keep the two in sync.
/// Keys are the `Profile.verification_status` values written by
/// `apps.verification` on approval.
const _kBadgeColours = <String, Color>{
  'id': Color(0xFF3B82F6), // blue — verified person
  'email': Color(0xFF3B82F6),
  'trainer': Color(0xFF4ADE80), // green — coach
  'practitioner': Color(0xFFEAB308), // gold — health practitioner
  'distributor': Color(0xFFFB923C), // orange — distributor
  'shop': Color(0xFF22D3EE), // cyan — shop
  'shop_owner': Color(0xFF22D3EE),
  'gym': Color(0xFF4ADE80), // green — gym
  'gym_owner': Color(0xFF4ADE80),
  'delivery_partner': Color(0xFFEAB308), // gold — delivery
};

const _kBadgeLabels = <String, String>{
  'id': 'Verified',
  'email': 'Verified',
  'trainer': 'Trainer',
  'practitioner': 'Practitioner',
  'distributor': 'Distributor',
  'shop': 'Shop',
  'shop_owner': 'Shop',
  'gym': 'Gym',
  'gym_owner': 'Gym',
  'delivery_partner': 'Delivery',
};

/// Colour for the verified glyph; falls back to brand green.
Color verificationBadgeColor(String? status) =>
    _kBadgeColours[status] ?? const Color(0xFF4ADE80);

/// Short label for a chip ('Gym', 'Trainer', …); null when not verified.
String? verificationBadgeLabel(String? status) => _kBadgeLabels[status];

/// True when any verified status is present.
bool isVerifiedStatus(String? status) =>
    status != null && status != 'none' && _kBadgeLabels.containsKey(status);
