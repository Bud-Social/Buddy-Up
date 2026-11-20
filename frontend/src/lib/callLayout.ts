/**
 * Which stage layout a call uses.
 *
 * Two people get the classic 1:1 stage (remote fills the screen, self in a
 * small overlay for video calls). From the third participant onwards every
 * person gets an equal tile — nobody is demoted to a picture-in-picture.
 */
export type CallLayout = 'group-grid' | 'voice' | 'video';

export function callLayout(participantCount: number, callType: 'audio' | 'video'): CallLayout {
  if (participantCount >= 3) return 'group-grid';
  return callType === 'audio' ? 'voice' : 'video';
}
