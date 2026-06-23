export function calculateAge(dob: Date): number {
  const today = new Date();
  let age = today.getFullYear() - dob.getFullYear();
  const m = today.getMonth() - dob.getMonth();
  if (m < 0 || (m === 0 && today.getDate() < dob.getDate())) age--;
  return age;
}

export function isUserAdult(dob: Date): boolean {
  return calculateAge(dob) >= 18;
}

export function isUser16Plus(dob: Date): boolean {
  return calculateAge(dob) >= 16;
}
