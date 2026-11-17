import 'package:flutter/material.dart';

/// Identity for the gym the console is acting as, threaded from the manage
/// screens down to the card chrome (repost ribbon) and bylines.
@immutable
class GymActorIdentity {
  final String name;
  final String logoUrl;
  final bool isVerified;
  final String tier;

  const GymActorIdentity({
    required this.name,
    this.logoUrl = '',
    required this.isVerified,
    this.tier = 'regular',
  });
}
