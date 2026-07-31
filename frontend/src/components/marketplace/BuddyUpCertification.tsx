import { useState } from 'react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';

export function BuddyUpCertification() {
  const [step, setStep] = useState(0);
  const [submitted, setSubmitted] = useState(false);

  if (submitted) {
    return (
      <Card className="p-4 bg-buddy-green/10 border-buddy-green/30">
        <h3 className="font-bold text-buddy-green mb-2 flex items-center gap-2">
          <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>
          Application Submitted
        </h3>
        <p className="text-sm text-buddy-text-secondary">We'll review your application for the BuddyUp Certification badge shortly.</p>
      </Card>
    );
  }

  return (
    <Card className="p-4 border-buddy-gold/30 bg-gradient-to-br from-buddy-gold/10 to-transparent">
      <h3 className="font-bold text-buddy-gold mb-2">Get BuddyUp Certified</h3>
      <p className="text-xs text-buddy-text-secondary mb-4">Earn trust and visibility with a verified creator badge.</p>
      
      {step === 0 && (
        <div className="space-y-3">
          <div className="flex items-start gap-3 text-sm">
            <div className="w-6 h-6 rounded-full bg-buddy-gold/20 flex items-center justify-center text-buddy-gold text-xs shrink-0">1</div>
            <p>Verify your identity via standard KYC process.</p>
          </div>
          <div className="flex items-start gap-3 text-sm">
            <div className="w-6 h-6 rounded-full bg-buddy-gold/20 flex items-center justify-center text-buddy-gold text-xs shrink-0">2</div>
            <p>Provide evidence of relevant qualifications (optional).</p>
          </div>
          <div className="flex items-start gap-3 text-sm">
            <div className="w-6 h-6 rounded-full bg-buddy-gold/20 flex items-center justify-center text-buddy-gold text-xs shrink-0">3</div>
            <p>Agree to community guidelines.</p>
          </div>
          <Button size="sm" className="w-full mt-4 bg-buddy-gold text-black hover:bg-buddy-gold/90" onClick={() => setStep(1)}>Start Certification</Button>
        </div>
      )}

      {step === 1 && (
        <div className="space-y-3 text-sm">
          <p>Please upload a valid ID and a recent photo.</p>
          <div className="p-4 border-2 border-dashed border-buddy-gold/30 rounded-xl text-center text-buddy-text-secondary">
            Drag & drop files or click to browse
          </div>
          <div className="flex gap-2">
            <Button size="sm" variant="ghost" onClick={() => setStep(0)}>Cancel</Button>
            <Button size="sm" className="flex-1 bg-buddy-gold text-black hover:bg-buddy-gold/90" onClick={() => setStep(2)}>Next</Button>
          </div>
        </div>
      )}

      {step === 2 && (
        <div className="space-y-3 text-sm">
          <p>Do you agree to maintain high quality standards for your services?</p>
          <div className="flex gap-2">
            <Button size="sm" variant="ghost" onClick={() => setStep(1)}>Back</Button>
            <Button size="sm" className="flex-1 bg-buddy-gold text-black hover:bg-buddy-gold/90" onClick={() => setSubmitted(true)}>Submit Application</Button>
          </div>
        </div>
      )}
    </Card>
  );
}
