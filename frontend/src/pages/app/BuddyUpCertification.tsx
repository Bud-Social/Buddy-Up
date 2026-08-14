import { useState } from 'react';
import { ShieldCheck, ArrowLeft, FileText, CheckCircle2, Building, Activity, FileCheck } from 'lucide-react';
import { Card } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';
import { Badge } from '@/components/ui/Badge';
import { ImageUploadField } from '@/components/ui/ImageUploadField';

interface CertificationProps {
  shopId: string;
  shopName: string;
  onClose: () => void;
}

type ServiceType = 'nutrition' | 'fitness' | 'medical' | 'merchandise';

const SERVICE_REQUIREMENTS: Record<ServiceType, { title: string; documents: string[] }> = {
  nutrition: {
    title: 'Nutrition & Meal Plans',
    documents: ['Nutritionist Certification / License', 'Proof of ID', 'Liability Insurance (Optional)']
  },
  fitness: {
    title: 'Fitness Programmes & Events',
    documents: ['Personal Trainer Certification (e.g., ACE, NASM)', 'Proof of ID', 'First Aid / CPR Certification']
  },
  medical: {
    title: 'Medical / Physical Therapy',
    documents: ['Medical License / PT Certification', 'Proof of ID', 'Professional Liability Insurance']
  },
  merchandise: {
    title: 'Merchandise / Supplements',
    documents: ['Business Registration Document', 'Proof of ID', 'Supplier / Vendor Agreement']
  }
};

export default function BuddyUpCertification({ shopId: _shopId, shopName, onClose }: CertificationProps) {
  const [step, setStep] = useState(1);
  const [services, setServices] = useState<ServiceType[]>([]);
  const [documents, setDocuments] = useState<Record<string, string>>({});
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);

  const toggleService = (type: ServiceType) => {
    if (services.includes(type)) {
      setServices(services.filter(s => s !== type));
    } else {
      setServices([...services, type]);
    }
  };

  const getRequiredDocuments = () => {
    const docs = new Set<string>();
    services.forEach(s => {
      SERVICE_REQUIREMENTS[s].documents.forEach(d => docs.add(d));
    });
    return Array.from(docs);
  };

  const requiredDocs = getRequiredDocuments();
  const allDocsUploaded = requiredDocs.every(d => documents[d]);

  const handleSubmit = async () => {
    setSubmitting(true);
    try {
      // Simulate API call to submit verification application
      // await marketplaceApi.submitShopVerification(shopId, { services, documents });
      await new Promise(r => setTimeout(r, 1000));
      setSubmitted(true);
    } catch {
      // Handle error
    } finally {
      setSubmitting(false);
    }
  };

  if (submitted) {
    return (
      <Card className="p-8 text-center border-none shadow-xl bg-buddy-surface/50 backdrop-blur-md">
        <div className="w-16 h-16 rounded-full bg-buddy-green/20 flex items-center justify-center mx-auto mb-4">
          <ShieldCheck size={32} className="text-buddy-green" />
        </div>
        <h2 className="text-2xl font-bold mb-2">Application Submitted!</h2>
        <p className="text-sm text-buddy-text-secondary mb-6 leading-relaxed">
          Your certification application for <span className="font-bold text-buddy-text-primary">{shopName}</span> is under review. Our team will verify your documents within 3-5 business days. You will be notified of any status changes.
        </p>
        <Button className="w-full bg-buddy-electric text-buddy-black" onClick={onClose}>
          Return to Studio
        </Button>
      </Card>
    );
  }

  return (
    <div className="max-w-xl lg:max-w-3xl xl:max-w-4xl mx-auto pb-8">
      <div className="flex items-center gap-3 mb-6">
        <button onClick={onClose} className="p-2 rounded-xl bg-buddy-surface hover:bg-buddy-surface-raised transition-colors"><ArrowLeft size={20} /></button>
        <div>
          <h1 className="font-display text-2xl font-extrabold tracking-tight">Get Certified</h1>
          <p className="text-xs text-buddy-text-secondary font-medium">for {shopName}</p>
        </div>
      </div>

      <div className="flex gap-2 mb-8 px-2">
        {['Select Services', 'Upload Documents', 'Review'].map((label, idx) => (
          <div key={idx} className="flex-1 flex flex-col gap-1.5">
            <div className={`h-1.5 rounded-full transition-colors ${idx + 1 <= step ? 'bg-buddy-electric shadow-[0_0_8px_rgba(23,154,248,0.4)]' : 'bg-buddy-surface-raised'}`} />
            <span className={`text-[10px] font-semibold text-center uppercase tracking-wider ${idx + 1 <= step ? 'text-buddy-electric' : 'text-buddy-text-secondary'}`}>{label}</span>
          </div>
        ))}
      </div>

      {step === 1 && (
        <Card className="p-6 border-none shadow-xl bg-buddy-surface/50 backdrop-blur-md space-y-5 animate-in fade-in slide-in-from-right-4">
          <div className="space-y-1">
            <h2 className="text-xl font-bold flex items-center gap-2"><Activity className="text-buddy-electric" /> Offered Services</h2>
            <p className="text-sm text-buddy-text-secondary">What kind of services will {shopName} provide? Select all that apply to see required documents.</p>
          </div>

          <div className="space-y-3">
            {(Object.keys(SERVICE_REQUIREMENTS) as ServiceType[]).map(type => (
              <div 
                key={type} 
                onClick={() => toggleService(type)}
                className={`p-4 rounded-xl border-2 cursor-pointer transition-all flex items-center justify-between ${
                  services.includes(type) ? 'border-buddy-electric bg-buddy-electric/10' : 'border-buddy-surface-raised bg-buddy-black hover:border-buddy-electric/50'
                }`}
              >
                <div>
                  <h3 className="font-bold text-sm">{SERVICE_REQUIREMENTS[type].title}</h3>
                  <p className="text-xs text-buddy-text-secondary mt-1">{SERVICE_REQUIREMENTS[type].documents.length} documents required</p>
                </div>
                <div className={`w-6 h-6 rounded-full border-2 flex items-center justify-center ${
                  services.includes(type) ? 'border-buddy-electric bg-buddy-electric' : 'border-buddy-surface-raised'
                }`}>
                  {services.includes(type) && <CheckCircle2 size={16} className="text-buddy-black" />}
                </div>
              </div>
            ))}
          </div>

          <Button 
            className="w-full h-12 bg-buddy-electric text-buddy-black font-bold shadow-lg" 
            onClick={() => setStep(2)} 
            disabled={services.length === 0}
          >
            Next: Upload Documents
          </Button>
        </Card>
      )}

      {step === 2 && (
        <Card className="p-6 border-none shadow-xl bg-buddy-surface/50 backdrop-blur-md space-y-5 animate-in fade-in slide-in-from-right-4">
          <div className="space-y-1">
            <h2 className="text-xl font-bold flex items-center gap-2"><FileCheck className="text-buddy-green" /> Required Documents</h2>
            <p className="text-sm text-buddy-text-secondary">Please upload clear images or PDFs for the following required documents.</p>
          </div>

          <div className="space-y-6 max-h-[400px] overflow-y-auto pr-2 custom-scrollbar">
            {requiredDocs.map((doc, idx) => (
              <div key={idx} className="p-4 bg-buddy-black rounded-xl border border-buddy-surface-raised">
                <div className="flex items-start justify-between mb-3">
                  <div>
                    <h4 className="font-bold text-sm text-white flex items-center gap-2">
                      {documents[doc] ? <CheckCircle2 size={16} className="text-buddy-green" /> : <FileText size={16} className="text-buddy-text-secondary" />}
                      {doc}
                    </h4>
                  </div>
                  {documents[doc] && <Badge variant="green" label="Uploaded" size="sm" />}
                </div>
                
                {documents[doc] ? (
                  <div className="relative group rounded-lg overflow-hidden border border-buddy-surface">
                    <img src={documents[doc]} alt={doc} className="w-full h-32 object-cover opacity-80" />
                    <div className="absolute inset-0 bg-buddy-black/50 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                      <Button size="sm" variant="outline" onClick={() => setDocuments(d => { const nd = {...d}; delete nd[doc]; return nd; })}>Replace</Button>
                    </div>
                  </div>
                ) : (
                  <div className="bg-buddy-surface p-2 rounded-lg">
                    <ImageUploadField
                      value=""
                      onChange={(url) => setDocuments({ ...documents, [doc]: url })}
                      label={`Upload ${doc}`}
                    />
                  </div>
                )}
              </div>
            ))}
          </div>

          <div className="flex gap-3 pt-2">
            <Button variant="ghost" className="flex-1 h-12" onClick={() => setStep(1)}>Back</Button>
            <Button className="flex-1 h-12 bg-buddy-electric text-buddy-black font-bold shadow-lg" onClick={() => setStep(3)} disabled={!allDocsUploaded}>
              Next: Review
            </Button>
          </div>
        </Card>
      )}

      {step === 3 && (
        <Card className="p-6 border-none shadow-xl bg-buddy-surface/50 backdrop-blur-md space-y-5 animate-in fade-in slide-in-from-right-4">
          <div className="space-y-1">
            <h2 className="text-xl font-bold flex items-center gap-2"><ShieldCheck className="text-buddy-gold" /> Review & Submit</h2>
            <p className="text-sm text-buddy-text-secondary">Confirm your application details. Misleading information may result in account suspension.</p>
          </div>

          <div className="bg-buddy-black rounded-xl p-4 border border-buddy-surface-raised space-y-4">
            <div>
              <p className="text-xs font-semibold text-buddy-text-secondary uppercase tracking-wider mb-2">Shop Information</p>
              <div className="flex items-center gap-2">
                <Building size={16} className="text-buddy-electric" />
                <span className="font-bold text-sm">{shopName}</span>
              </div>
            </div>

            <div className="border-t border-buddy-surface-raised pt-3">
              <p className="text-xs font-semibold text-buddy-text-secondary uppercase tracking-wider mb-2">Services Applied For</p>
              <div className="flex flex-wrap gap-2">
                {services.map(s => (
                  <Badge key={s} variant="electric" label={SERVICE_REQUIREMENTS[s].title} size="sm" />
                ))}
              </div>
            </div>

            <div className="border-t border-buddy-surface-raised pt-3">
              <p className="text-xs font-semibold text-buddy-text-secondary uppercase tracking-wider mb-2">Documents Attached</p>
              <ul className="space-y-1">
                {requiredDocs.map(doc => (
                  <li key={doc} className="text-xs flex items-center gap-2">
                    <CheckCircle2 size={12} className="text-buddy-green" /> {doc}
                  </li>
                ))}
              </ul>
            </div>
          </div>

          <div className="flex gap-3 pt-2">
            <Button variant="ghost" className="flex-1 h-12" onClick={() => setStep(2)}>Back</Button>
            <Button className="flex-1 h-12 bg-gradient-to-r from-buddy-gold to-yellow-400 text-buddy-black font-bold shadow-[0_0_15px_rgba(255,215,0,0.4)]" onClick={handleSubmit} isLoading={submitting}>
              Submit Application
            </Button>
          </div>
        </Card>
      )}
    </div>
  );
}
