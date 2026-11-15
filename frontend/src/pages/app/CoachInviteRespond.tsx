import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { Check, Dumbbell, X } from 'lucide-react';
import { Button } from '@/components/ui/Button';
import { Card } from '@/components/ui/Card';
import { gymsApi } from '@/api/gyms';

/**
 * The one screen a coach lands on from a "you have been invited" notification.
 *
 * Mirror of the Flutter `CoachInviteRespondScreen`. A coach who is not staff
 * on the gym would see a "not permitted" notice on the full manage console
 * and nothing else — so the route is a single-decision page: accept or
 * decline, nothing else offered.
 */
export default function CoachInviteRespond() {
  const { slug, coachId } = useParams<{ slug: string; coachId: string }>();
  const navigate = useNavigate();
  const [gymName, setGymName] = useState(slug || '');
  const [submitting, setSubmitting] = useState<'accept' | 'decline' | null>(null);
  const [done, setDone] = useState<'accepted' | 'declined' | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!slug) return;
    gymsApi.detail(slug)
      .then((gymData) => {
        const data = (gymData?.data ?? gymData) as unknown as { name?: string };
        if (data?.name) setGymName(data.name);
      })
      .catch(() => { /* fall back to slug */ });
  }, [slug]);

  const respond = async (action: 'accept' | 'decline') => {
    if (!slug || !coachId) return;
    setSubmitting(action);
    setError(null);
    try {
      await gymsApi.respondCoachInvite(slug, coachId, action);
      setDone(action === 'accept' ? 'accepted' : 'declined');
    } catch (e: unknown) {
      const data = (e as { response?: { data?: { message?: string } } })?.response?.data;
      setError(data?.message || 'Could not send your response. Check your connection.');
    } finally {
      setSubmitting(null);
    }
  };

  return (
    <div className="max-w-lg mx-auto p-4">
      <Card className="p-6 text-center space-y-4">
        {done ? (
          <>
            <Dumbbell size={40} className="mx-auto text-buddy-green" />
            <h1 className="font-display text-xl font-bold">
              {done === 'accepted' ? 'You are listed as a coach' : 'No problem'}
            </h1>
            <p className="text-buddy-text-secondary text-sm">
              {done === 'accepted'
                ? 'The gym has been notified — you will appear in the Online roster with the Coach badge on the members list.'
                : 'The gym has been notified you declined the invitation.'}
            </p>
            <Button onClick={() => navigate('/gyms')}>Back to gyms</Button>
          </>
        ) : (
          <>
            <Dumbbell size={40} className="mx-auto text-buddy-green" />
            <h1 className="font-display text-xl font-bold">Coach invitation</h1>
            <p className="text-buddy-text-secondary text-sm">
              <strong>{gymName}</strong> asked you to be listed as an online coach.
            </p>
            <p className="text-buddy-text-secondary/75 text-xs">
              Accepting makes your membership a trainer role and lists you in the
              gym's online roster with the Coach badge on the members list.
            </p>
            {error && (
              <p className="text-xs text-buddy-red bg-buddy-red/10 border border-buddy-red/20 rounded-lg px-3 py-2" role="alert">{error}</p>
            )}
            <div className="flex flex-col gap-2 pt-1">
              <Button
                size="lg"
                className="w-full"
                isLoading={submitting === 'accept'}
                disabled={submitting !== null}
                onClick={() => respond('accept')}
              >
                <Check size={16} className="mr-1.5" /> Accept invite
              </Button>
              <Button
                size="lg"
                variant="ghost"
                className="w-full text-buddy-red"
                isLoading={submitting === 'decline'}
                disabled={submitting !== null}
                onClick={() => respond('decline')}
              >
                <X size={16} className="mr-1.5" /> Decline
              </Button>
            </div>
          </>
        )}
      </Card>
    </div>
  );
}
