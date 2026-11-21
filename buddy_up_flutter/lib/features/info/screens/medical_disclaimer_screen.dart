import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/legal_page.dart';

const _medicalSubtitle =
    'Please read this before using BuddyUp Fit\'s fitness, nutrition, meal-plan, or health-related features. This is not medical advice.';

const _body = TextStyle(
  color: BuddyColors.textSecondary,
  fontSize: 13,
  height: 1.6,
);

class MedicalDisclaimerScreen extends StatelessWidget {
  const MedicalDisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalPage(
      title: 'Medical & Wellness Disclaimer',
      subtitle: _medicalSubtitle,
      updatedAt: 'August 2026',
      sections: [
        LegalSection(
          title: '1. BuddyUp Fit Is Not a Medical Service',
          children: [
            LegalText(
              TextSpan(
                text:
                    'BuddyUp Fit is a fitness and accountability platform. It does not provide medical advice, diagnosis, treatment, or care. Nothing on the platform — including workout programmes, meal plans, coach guidance, AI-generated recommendations, health insights, or progress analysis — is a substitute for professional medical judgement.',
                style: _body,
              ),
            ),
            LegalNotice(
              text:
                  'If you have a medical condition, injury, or persistent symptoms, or if you are pregnant, nursing, or taking medication that could be affected by exercise or diet, consult a qualified healthcare professional before starting any programme.',
              tone: LegalNoticeTone.red,
            ),
          ],
        ),
        LegalSection(
          title: '2. General Wellness vs Medical Nutrition Therapy',
          children: [
            LegalText(
              TextSpan(
                text:
                    'BuddyUp Fit content is general wellness information: healthy eating patterns, activity-supportive habits, and education about food choices. It is not personalised medical nutrition therapy (MNT), which is a clinical treatment delivered by registered dietitians or other appropriately credentialed professionals to prevent, treat, or manage specific medical conditions.',
                style: _body,
              ),
            ),
            LegalText(
              TextSpan(
                text:
                    'Meal plans, recipe collections, and coaching provided on BuddyUp Fit are general wellness resources. They are not designed to diagnose, treat, cure, or manage any disease. Content that frames nutrition as managing a diagnosed condition (for example, "use this plan to control blood glucose for diabetes") is not permitted outside a verified practitioner relationship.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '3. Scope of Practice of Coaches & Trainers',
          children: [
            LegalText(
              TextSpan(
                text:
                    'Fitness coaches and personal trainers on BuddyUp Fit provide general fitness and wellness coaching within their verified scope. They are generally not licensed to:',
                style: _body,
              ),
            ),
            LegalBulletList([
              'Diagnose or treat medical conditions',
              'Prescribe personalised meal plans based on a medical diagnosis',
              'Provide medical nutrition therapy or condition-specific dietary protocols',
              'Adjust or advise on medication',
            ]),
            LegalText(
              TextSpan(
                text:
                    'Only verified practitioners — licensed clinicians, registered dietitians, and physiotherapists — may provide guidance within their licensed scope, and only when the professional relationship is established on the platform.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '4. No Guarantee of Outcomes',
          children: [
            LegalText(
              TextSpan(
                text:
                    'Fitness, weight, and health outcomes depend on many individual factors. BuddyUp Fit does not guarantee any specific result. Promises of guaranteed results, "quick fixes", or fast weight loss should be treated with caution and are not endorsed by the platform. If something sounds too good to be true, it probably is.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '5. Red Flags to Watch For',
          children: [
            LegalText(TextSpan(text: 'Be wary of content that:', style: _body)),
            LegalBulletList([
              'Claims to "cure", "treat", or "reverse" a medical condition',
              'Promises guaranteed, rapid, or extreme results',
              'Warns of severe dangers to create urgency',
              'Presents uncredentialed individuals as clinical experts',
              'Recommends unregistered supplements or medicines',
            ]),
            LegalText(
              TextSpan(
                text:
                    'You can report such content using the Report button on any post. Our moderation systems also automatically flag these patterns for human review.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '6. Mature Content & Health Claims',
          children: [
            LegalText(
              TextSpan(
                text:
                    'The Mature (18+/16+) category exists only for age-restricted fitness content. It is not a loophole for health claims. Medical claims, scope-of-practice breaches, and undisclosed sponsorship are prohibited in the Mature category exactly as they are everywhere else on the platform. Nude or suggestive content never converts wellness guidance into medical advice.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '7. Your Responsibility',
          children: [
            LegalText(
              TextSpan(
                text:
                    'You are responsible for your own health and safety decisions. Listen to your body, start gradually, and seek professional guidance when needed. Never disregard professional medical advice because of something you read on BuddyUp Fit.',
                style: _body,
              ),
            ),
          ],
        ),
        LegalSection(
          title: '8. Contact',
          children: [
            LegalText(
              TextSpan(
                text:
                    'If you have concerns about content or a safety matter, contact report@buddyup.co.ke. For medical concerns, consult a qualified healthcare professional.',
                style: _body,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
