import LegalPage, { LegalSection, LegalNotice } from './LegalPage';

export default function MedicalDisclaimer() {
  return (
    <LegalPage
      title="Medical & Wellness Disclaimer"
      subtitle="Please read this before using BuddyUp's fitness, nutrition, meal-plan, or health-related features. This is not medical advice."
      updatedAt="August 2026"
    >
      <LegalSection title="1. BuddyUp Is Not a Medical Service">
        <p>BuddyUp is a fitness and accountability platform. It does not provide medical advice, diagnosis, treatment, or care. Nothing on the platform — including workout programmes, meal plans, coach guidance, AI-generated recommendations, health insights, or progress analysis — is a substitute for professional medical judgement.</p>
        <LegalNotice tone="red">
          If you have a medical condition, injury, or persistent symptoms, or if you are pregnant, nursing, or taking medication that could be affected by exercise or diet, consult a qualified healthcare professional before starting any programme.
        </LegalNotice>
      </LegalSection>

      <LegalSection title="2. General Wellness vs Medical Nutrition Therapy">
        <p>BuddyUp content is general wellness information: healthy eating patterns, activity-supportive habits, and education about food choices. It is not personalised medical nutrition therapy (MNT), which is a clinical treatment delivered by registered dietitians or other appropriately credentialed professionals to prevent, treat, or manage specific medical conditions.</p>
        <p className="mt-2">Meal plans, recipe collections, and coaching provided on BuddyUp are general wellness resources. They are not designed to diagnose, treat, cure, or manage any disease. Content that frames nutrition as managing a diagnosed condition (for example, "use this plan to control blood glucose for diabetes") is not permitted outside a verified practitioner relationship.</p>
      </LegalSection>

      <LegalSection title="3. Scope of Practice of Coaches & Trainers">
        <p>Fitness coaches and personal trainers on BuddyUp provide general fitness and wellness coaching within their verified scope. They are generally not licensed to:</p>
        <ul className="list-disc list-inside space-y-1">
          <li>Diagnose or treat medical conditions</li>
          <li>Prescribe personalised meal plans based on a medical diagnosis</li>
          <li>Provide medical nutrition therapy or condition-specific dietary protocols</li>
          <li>Adjust or advise on medication</li>
        </ul>
        <p className="mt-2">Only verified practitioners — licensed clinicians, registered dietitians, and physiotherapists — may provide guidance within their licensed scope, and only when the professional relationship is established on the platform.</p>
      </LegalSection>

      <LegalSection title="4. No Guarantee of Outcomes">
        <p>Fitness, weight, and health outcomes depend on many individual factors. BuddyUp does not guarantee any specific result. Promises of guaranteed results, "quick fixes", or fast weight loss should be treated with caution and are not endorsed by the platform. If something sounds too good to be true, it probably is.</p>
      </LegalSection>

      <LegalSection title="5. Red Flags to Watch For">
        <p>Be wary of content that:</p>
        <ul className="list-disc list-inside space-y-1">
          <li>Claims to "cure", "treat", or "reverse" a medical condition</li>
          <li>Promises guaranteed, rapid, or extreme results</li>
          <li>Warns of severe dangers to create urgency</li>
          <li>Presents uncredentialed individuals as clinical experts</li>
          <li>Recommends unregistered supplements or medicines</li>
        </ul>
        <p className="mt-2">You can report such content using the Report button on any post. Our moderation systems also automatically flag these patterns for human review.</p>
      </LegalSection>

      <LegalSection title="6. Mature Content &amp; Health Claims">
        <p>The Mature (18+/16+) category exists only for age-restricted fitness content. It is <strong>not</strong> a loophole for health claims. Medical claims, scope-of-practice breaches, and undisclosed sponsorship are prohibited in the Mature category exactly as they are everywhere else on the platform. Nude or suggestive content never converts wellness guidance into medical advice.</p>
      </LegalSection>

      <LegalSection title="7. Your Responsibility">
        <p>You are responsible for your own health and safety decisions. Listen to your body, start gradually, and seek professional guidance when needed. Never disregard professional medical advice because of something you read on BuddyUp.</p>
      </LegalSection>

      <LegalSection title="8. Contact">
        <p>If you have concerns about content or a safety matter, contact <strong>safety@buddyup.app</strong>. For medical concerns, consult a qualified healthcare professional.</p>
      </LegalSection>
    </LegalPage>
  );
}
