import { Navigate, useParams } from 'react-router-dom';
import { resolveSettingsSection } from './sections';
import Account from './Account';
import Verifications from './Verifications';
import Privacy from './Privacy';
import Notifications from './Notifications';
import Security from './Security';
import Blocked from './Blocked';
import Activity from './Activity';
import Content from './Content';
import Billing from './Billing';
import Appearance from './Appearance';
import Family from './Family';
import Help from './Help';
import Data from './Data';

const SECTION_COMPONENTS: Record<string, React.ComponentType> = {
  account: Account,
  verifications: Verifications,
  privacy: Privacy,
  notifications: Notifications,
  security: Security,
  blocked: Blocked,
  activity: Activity,
  content: Content,
  billing: Billing,
  appearance: Appearance,
  family: Family,
  help: Help,
  data: Data,
};

/** /settings/:section — renders the matching section page. Unknown ids are
 * redirected back to the hub so deep links can never 404. */
export default function SettingsSection() {
  const { section } = useParams<{ section: string }>();
  const meta = resolveSettingsSection(section);
  if (!meta) return <Navigate to="/settings" replace />;
  const SectionComponent = SECTION_COMPONENTS[meta.id];
  return <SectionComponent />;
}
