import { Link } from 'react-router-dom';
import LegalPage, { LegalSection } from './LegalPage';

export default function AdultContentPolicy() {
  return (
    <LegalPage
      title="Adult Content Policy"
      subtitle="This policy has been retired. Please refer to our Community Guidelines for current content standards."
      updatedAt="August 2026"
    >
      <LegalSection title="Retired Policy">
        <p>The Adult Content Policy (Mature Category) is no longer active. All content standards are now governed by the <Link to="/community-guidelines" className="text-buddy-green hover:underline">Community Guidelines</Link>.</p>
      </LegalSection>
    </LegalPage>
  );
}
