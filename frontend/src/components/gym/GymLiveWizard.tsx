import { useMemo, useState } from 'react';
import { Radio, Users, Zap, X, ShieldCheck, CalendarClock } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';
import { artifactLabel, artifactIcon, ARTIFACT_TYPES } from '@/lib/artifactCalc';
import { livesApi } from '@/api';
import type { Gym } from '@/types';

interface GymLiveWizardProps {
  gym: Gym;
  onClose: () => void;
  onScheduled: () => void;
}

type Step = 'basics' | 'fees' | 'review';
const STEPS: Step[] = ['basics', 'fees', 'review'];
const STEP_LABEL: Record<Step, string> = {
  basics: 'Basics',
  fees: 'Access & fees',
  review: 'Review',
};

const CATEGORY_OPTIONS = [
  'strength', 'cardio_running', 'yoga_wellness', 'sport_specific', 'mixed', 'other',
];

const ACCESS_OPTIONS: Array<{ value: 'public' | 'gym_members' | 'private'; label: string; hint: string }> = [
  { value: 'public', label: 'Public', hint: 'Anyone can RSVP; members and non-members' },
  { value: 'gym_members', label: 'Gym members only', hint: 'Free for members; non-members get error on RSVP' },
  { value: 'private', label: 'Only me', hint: 'No RSVP prompt; you stream to an empty room' },
];

interface FeeDraft {
  artifactType: string | null;
  qty: number;
}
const emptyFee = (): FeeDraft => ({ artifactType: null, qty: 1 });

/**
 * Multistep schedule-a-gym-live wizard.
 *
 * Replaces the single-field "Go Live" modal: schedules a live under the gym
 * identity instead of a personal one. Fees are per membership tier
 * (member vs non-member artifacts) and flow into the gym's artifact purse on
 * every paid RSVP.
 */
export function GymLiveWizard({ gym, onClose, onScheduled }: GymLiveWizardProps) {
  const [step, setStep] = useState<Step>('basics');
  const [title, setTitle] = useState('');
  const [category, setCategory] = useState('strength');
  const [access, setAccess] = useState<'public' | 'gym_members' | 'private'>('public');
  const [date, setDate] = useState('');
  const [time, setTime] = useState('18:00');
  const [memberFee, setMemberFee] = useState<FeeDraft>(emptyFee());
  const [nonMemberFee, setNonMemberFee] = useState<FeeDraft>(emptyFee());
  const [reminderMinutes, setReminderMinutes] = useState(30);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');

  const stepIndex = STEPS.indexOf(step);
  const canBasics = title.trim().length >= 3 && date.trim() && time.trim();

  const feePayload = (draft: FeeDraft): Record<string, number> | undefined =>
    draft.artifactType ? { [draft.artifactType]: Math.max(1, draft.qty) } : undefined;

  const memberFeeDict = feePayload(memberFee);
  const nonMemberFeeDict = feePayload(nonMemberFee);

  const busyLabel = submitting ? 'Scheduling…' : 'Schedule live';

  const scheduledForIso = useMemo(() => {
    if (!date || !time) return null;
    const dt = new Date(`${date}T${time}:00`);
    return Number.isNaN(dt.getTime()) ? null : dt.toISOString();
  }, [date, time]);

  const schedule = async () => {
    if (!scheduledForIso) return;
    setSubmitting(true);
    setError('');
    try {
      await livesApi.startLive({
        title: title.trim(),
        live_type: 'gym_live',
        category,
        access,
        gym_id: gym.id,
        scheduled_for: scheduledForIso,
        member_fee_artifacts: memberFeeDict,
        non_member_fee_artifacts: nonMemberFeeDict,
      });
      onScheduled();
      onClose();
    } catch (err: unknown) {
      const data = (err as { response?: { data?: { message?: string } } })?.response?.data;
      setError(data?.message || 'Could not schedule the live.');
    } finally {
      setSubmitting(false);
    }
  };

  const renderFeePicker = (which: 'member' | 'non_member') => {
    const value = which === 'member' ? memberFee : nonMemberFee;
    const setValue = which === 'member' ? setMemberFee : setNonMemberFee;
    const label = which === 'member' ? 'Members pay' : 'Non-members pay';
    return (
      <div>
        <p className="text-[11px] font-semibold uppercase tracking-wide text-buddy-text-secondary mb-1.5">{label}</p>
        <div className="flex flex-wrap gap-1.5 mb-1.5">
          <button
            type="button"
            onClick={() => setValue({ ...value, artifactType: null })}
            className={`px-2.5 py-1 rounded-full text-[11px] border transition-colors ${value.artifactType === null ? 'border-buddy-green bg-buddy-green/10 text-buddy-green' : 'border-buddy-surface-raised text-buddy-text-secondary'}`}
          >
            Free
          </button>
          {ATRIFACTS.map((a) => (
            <button
              key={a}
              type="button"
              onClick={() => setValue({ ...value, artifactType: a })}
              className={`px-2.5 py-1 rounded-full text-[11px] border transition-colors ${value.artifactType === a ? 'border-buddy-green bg-buddy-green/10 text-buddy-green' : 'border-buddy-surface-raised text-buddy-text-secondary'}`}
            >
              {artifactIcon(a)} {artifactLabel(a)}
            </button>
          ))}
        </div>
        {value.artifactType && (
          <div className="flex items-center gap-2">
            <span className="text-xs text-buddy-text-secondary">Qty</span>
            <div className="flex items-center gap-1">
              <button type="button" className="w-7 h-7 rounded bg-buddy-surface text-xs" onClick={() => setValue({ ...value, qty: Math.max(1, value.qty - 1) })}>−</button>
              <span className="w-8 text-center text-sm">{value.qty}</span>
              <button type="button" className="w-7 h-7 rounded bg-buddy-surface text-xs" onClick={() => setValue({ ...value, qty: value.qty + 1 })}>+</button>
            </div>
          </div>
        )}
      </div>
    );
  };

  return (
    <div className="fixed inset-0 z-50 bg-buddy-black/80 flex items-center justify-center p-4" onClick={onClose}>
      <div className="bg-buddy-surface rounded-3xl w-full max-w-md max-h-[90vh] overflow-y-auto" onClick={(e) => e.stopPropagation()}>
        <div className="flex items-center justify-between px-5 pt-5">
          <div className="flex items-center gap-2">
            <Radio size={18} className="text-buddy-green" />
            <h2 className="font-heading font-semibold text-base">Schedule a gym live</h2>
          </div>
          <button onClick={onClose} className="p-2 text-buddy-text-secondary hover:text-buddy-text-primary"><X size={18} /></button>
        </div>

        <div className="flex items-center gap-1 px-5 pt-3">
          {STEPS.map((s, i) => (
            <div key={s} className="flex items-center gap-1 flex-1">
              <div className={`h-1 flex-1 rounded-full ${i <= stepIndex ? 'bg-buddy-green' : 'bg-buddy-surface-raised'}`} />
              <span className={`text-[9px] uppercase tracking-wider ${i <= stepIndex ? 'text-buddy-green' : 'text-buddy-text-secondary/60'}`}>{STEP_LABEL[s]}</span>
            </div>
          ))}
        </div>

        {error && <p className="mx-5 mt-3 text-xs text-buddy-red bg-buddy-red/10 border border-buddy-red/20 rounded-lg px-3 py-2" role="alert">{error}</p>}

        {step === 'basics' && (
          <div className="p-5 space-y-4">
            <Input label="Live title" value={title} onChange={(e) => setTitle(e.target.value)} placeholder="e.g. Monday technique fix" maxLength={80} autoFocus />
            <div>
              <label className="text-xs font-medium text-buddy-text-secondary mb-1 block">Category</label>
              <div className="flex flex-wrap gap-1.5">
                {CATEGORY_OPTIONS.map((c) => (
                  <button key={c} type="button" onClick={() => setCategory(c)}
                    className={`px-2.5 py-1 rounded-full text-[11px] border capitalize transition-colors ${category === c ? 'border-buddy-green bg-buddy-green/10 text-buddy-green' : 'border-buddy-surface-raised text-buddy-text-secondary'}`}>
                    {c.replace('_', ' ')}
                  </button>
                ))}
              </div>
            </div>
            <div className="grid grid-cols-2 gap-3">
              <Input label="Date" type="date" value={date} min={new Date().toISOString().slice(0, 10)} onChange={(e) => setDate(e.target.value)} />
              <Input label="Time" type="time" value={time} onChange={(e) => setTime(e.target.value)} />
            </div>
            <div>
              <label className="text-xs font-medium text-buddy-text-secondary mb-1 block">Access</label>
              <div className="space-y-1.5">
                {ACCESS_OPTIONS.map((opt) => (
                  <button key={opt.value} type="button" onClick={() => setAccess(opt.value)}
                    aria-pressed={access === opt.value}
                    className={`w-full text-left px-3 py-2 rounded-xl border text-xs transition-colors ${access === opt.value ? 'border-buddy-green bg-buddy-green/5' : 'border-buddy-surface-raised'}`}>
                    <span className="font-semibold flex items-center gap-1.5">{opt.value === 'gym_members' ? <ShieldCheck size={12} /> : <Users size={12} />} {opt.label}</span>
                    <span className="text-[10px] text-buddy-text-secondary">{opt.hint}</span>
                  </button>
                ))}
              </div>
            </div>
            <div className="flex gap-3 pt-1">
              <Button variant="ghost" className="flex-1" onClick={onClose}>Cancel</Button>
              <Button className="flex-1" disabled={!canBasics} onClick={() => setStep('fees')}>Next</Button>
            </div>
          </div>
        )}

        {step === 'fees' && (
          <div className="p-5 space-y-4">
            <p className="text-xs text-buddy-text-secondary">
              Charge gym members, non-members, or both. Revenue goes to the gym's artifact wallet
              and is analysed on the Revenue tab.
            </p>
            {renderFeePicker('member')}
            <div className="border-t border-buddy-surface-raised pt-4" />
            {renderFeePicker('non_member')}
            <div>
              <span className="text-xs font-medium text-buddy-text-secondary block mb-1">Reminder default</span>
              <div className="flex flex-wrap gap-1.5">
                {[0, 15, 30, 60, 120].map((m) => (
                  <button key={m} type="button" onClick={() => setReminderMinutes(m)}
                    className={`px-2.5 py-1 rounded-full text-[11px] border ${reminderMinutes === m ? 'border-buddy-green bg-buddy-green/10 text-buddy-green' : 'border-buddy-surface-raised text-buddy-text-secondary'}`}>
                    {m === 0 ? 'No reminder' : `${m} min before`}
                  </button>
                ))}
              </div>
            </div>
            <div className="flex gap-3 pt-1">
              <Button variant="ghost" className="flex-1" onClick={() => setStep('basics')}>Back</Button>
              <Button className="flex-1" onClick={() => setStep('review')}>Next</Button>
            </div>
          </div>
        )}

        {step === 'review' && (
          <div className="p-5 space-y-4">
            <div className="rounded-2xl bg-buddy-surface-raised p-4 space-y-2 text-xs">
              <div className="flex items-center gap-2 font-semibold text-sm"><Zap size={14} className="text-buddy-green" /> {title.trim()}</div>
              <p className="text-buddy-text-secondary">{new Date(scheduledForIso || '').toLocaleString()}</p>
              <p className="text-buddy-text-secondary capitalize">{category.replace('_', ' ')} · {access.replace('_', ' ')}</p>
              <div className="grid grid-cols-2 gap-2 pt-1">
                <div className="rounded-xl bg-buddy-surface p-2 text-center">
                  <p className="text-[10px] text-buddy-text-secondary">Members pay</p>
                  <p className="text-xs font-semibold">
                    {memberFeeDict ? Object.entries(memberFeeDict).map(([t, q]) => `${q} ${artifactLabel(t)}`).join(' + ') : 'Free'}
                  </p>
                </div>
                <div className="rounded-xl bg-buddy-surface p-2 text-center">
                  <p className="text-[10px] text-buddy-text-secondary">Non-members pay</p>
                  <p className="text-xs font-semibold">
                    {nonMemberFeeDict ? Object.entries(nonMemberFeeDict).map(([t, q]) => `${q} ${artifactLabel(t)}`).join(' + ') : 'Free'}
                  </p>
                </div>
              </div>
              {gym.is_verified && <p className="text-[10px] text-buddy-text-secondary flex items-center gap-1"><CalendarClock size={11} /> Being hosted by a verified gym</p>}
            </div>
            <div className="flex gap-3">
              <Button variant="ghost" className="flex-1" onClick={() => setStep('fees')}>Back</Button>
              <Button className="flex-1" isLoading={submitting} onClick={schedule}>{busyLabel}</Button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}

const ATRIFACTS = ARTIFACT_TYPES;

export default GymLiveWizard;
