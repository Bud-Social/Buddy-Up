import { Card } from '@/components/ui/Card';
import { AgeVerificationCard, BadgeApplicationForm } from '@/components/settings/VerificationCards';
import { SectionShell } from './SectionShell';

export default function Verifications() {
  return (
    <SectionShell title="Verifications">
      <div className="space-y-4">
        <AgeVerificationCard />
        <Card className="p-4 space-y-4">
          <div>
            <p className="text-sm font-medium">Professional Verification</p>
            <p className="text-xs text-buddy-text-secondary mb-2">Apply for a Trainer or Practitioner badge. Required for hosting paid sessions.</p>
            <BadgeApplicationForm />
          </div>
        </Card>
      </div>
    </SectionShell>
  );
}
