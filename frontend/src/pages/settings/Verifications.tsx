import { useState } from 'react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { AgeVerificationCard, BadgeApplicationForm } from '@/components/settings/VerificationCards';
import { IdVerificationWizard } from '@/components/verification/IdVerificationWizard';
import { SectionShell } from './SectionShell';

export default function Verifications() {
  /* The wizard is a real multipart upload with server-side face match, and it
     lived only at /verification -- unreachable from the place users actually go
     to manage verifications. It needs an onDone callback, so it is mounted
     conditionally rather than always-on. */
  const [wizardOpen, setWizardOpen] = useState(false);

  if (wizardOpen) {
    return (
      <SectionShell title="Verifications">
        <IdVerificationWizard onDone={() => setWizardOpen(false)} />
      </SectionShell>
    );
  }

  return (
    <SectionShell title="Verifications">
      <div className="space-y-4">
        <AgeVerificationCard />
        <Card className="p-4 space-y-4">
          <div>
            <p className="text-sm font-medium">Identity Verification</p>
            <p className="text-xs text-buddy-text-secondary mb-2">
              Upload a national ID, passport or driving licence, plus a selfie to confirm it is you.
            </p>
            <Button variant="outline" onClick={() => setWizardOpen(true)}>Start ID verification</Button>
          </div>
        </Card>
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
