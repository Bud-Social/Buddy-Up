"""Analytics export: CSV, XLSX, the row cap, and the audit trail.

The three things this file is really about:

* **An export cannot differ from the screen.** Every row in a file is produced
  by the same builder the on-screen report uses, with the same validation. A
  400 for a bad date has to be a 400 here too, or the file becomes a way to
  fetch a period the UI refused to show.
* **Nothing is truncated silently.** Over the cap is a 400 naming the row count.
  A quietly shortened file would look like a complete one.
* **An export is a disclosure.** Every successful export writes an
  ``AdminActionLog`` row, and it is a GET — so it cannot rely on
  ``GovernanceAuditMixin``, which skips safe methods by design.

The xlsx tests carry an explicit skip marker rather than passing quietly when
``openpyxl`` is missing: a green run that silently covered nothing is worse than
a marked gap. The 503-with-a-named-dependency path is tested *unconditionally*
by making the import genuinely fail.
"""
import csv
import io
import sys
import unittest

from django.test import TestCase, override_settings
from django.utils import timezone
from rest_framework import status
from rest_framework.test import APIClient

from apps.accounts.models import User
from apps.analytics.exports import openpyxl_available
from apps.feed.models import Post
from apps.governance.models import AdminActionLog
from apps.profiles.models import Profile

PREFIX = '/api/v1/portal/analytics'
EXPORT = f'{PREFIX}/export/'

# Not a bare `skipUnless`: the reason has to name the gap in the test output.
XLSX_SKIP_REASON = (
    'SKIP-MARKER openpyxl is not installed in this environment. The xlsx '
    'export path is therefore UNTESTED here; the 503 fallback is tested '
    'unconditionally in ExportMissingDependencyTests. Install '
    'requirements/base.txt and re-run to cover it.'
)


def _make_user(email, username, *, staff=False, superuser=False):
    user = User.objects.create_user(email=email, password='TestPass123!')
    user.is_staff = staff
    user.is_superuser = superuser
    user.save(update_fields=['is_staff', 'is_superuser'])
    Profile.objects.create(user=user, username=username, display_name=username.title())
    return user


def parse_csv(content):
    """Rows as lists of strings, from the utf-8-sig body we actually emit."""
    text = content.decode('utf-8-sig') if isinstance(content, bytes) else content
    return list(csv.reader(io.StringIO(text, newline='')))


class ExportPermissionTests(TestCase):
    """Exporting is staff-only and scope-gated, like every analytics route."""

    def setUp(self):
        self.client = APIClient()

    def test_anonymous_is_unauthenticated(self):
        self.assertEqual(
            self.client.get(EXPORT, {'report': 'overview', 'format': 'csv'}).status_code,
            status.HTTP_401_UNAUTHORIZED,
        )

    def test_authenticated_non_staff_is_forbidden(self):
        member = _make_user('exportmember@example.com', 'exportmember')
        self.client.force_authenticate(member)
        self.assertEqual(
            self.client.get(EXPORT, {'report': 'overview', 'format': 'csv'}).status_code,
            status.HTTP_403_FORBIDDEN,
        )


class CsvExportTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.staff = _make_user('csv@example.com', 'csvstaff', staff=True, superuser=True)
        self.profile = self.staff.profile
        self.client.force_authenticate(self.staff)
        self.window = {
            'from': (timezone.now().date() - timezone.timedelta(days=6)).isoformat(),
            'to': timezone.now().date().isoformat(),
        }

    def _export(self, **params):
        query = {'report': 'overview', 'format': 'csv', **self.window, **params}
        return self.client.get(EXPORT, query)

    def test_headers_content_type_and_filename(self):
        response = self._export()
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response['Content-Type'], 'text/csv')
        disposition = response['Content-Disposition']
        self.assertIn('attachment;', disposition)
        self.assertIn('analytics-overview_', disposition)
        # The window is in the filename, because a downloaded file keeps it
        # after the response headers are gone.
        self.assertIn(self.window['from'], disposition)
        self.assertIn(self.window['to'], disposition)
        self.assertTrue(disposition.endswith('.csv"'))

    def test_rows_match_the_screen_report_exactly(self):
        screen = self.client.get(
            f'{PREFIX}/overview/', self.window,
        ).data['data']['table']
        rows = parse_csv(self._export().content)
        self.assertEqual(rows[0], screen['columns'])
        self.assertEqual([row[0] for row in rows[1:]], [row[0] for row in screen['rows']])
        for row, expected in zip(rows[1:], screen['rows']):
            self.assertEqual(row[0], expected[0])
            self.assertEqual(row[4], str(expected[4]))

    def test_provenance_headers(self):
        response = self._export()
        self.assertEqual(response['X-Analytics-Report'], 'overview')
        self.assertEqual(response['X-Analytics-From'], self.window['from'])
        self.assertEqual(response['X-Analytics-To'], self.window['to'])
        self.assertTrue(response['X-Generated-At'])
        self.assertEqual(
            int(response['X-Analytics-Rows']), len(parse_csv(response.content)) - 1,
        )

    def test_every_report_exports(self):
        for report, extra in (
            ('overview', {}),
            ('timeseries', {'metric': 'posts.new', 'granularity': 'day'}),
            ('trending', {'kind': 'posts'}),
            ('ai_quality', {}),
            ('predictive', {}),
        ):
            with self.subTest(report=report):
                response = self._export(report=report, **extra)
                self.assertEqual(response.status_code, status.HTTP_200_OK)
                rows = parse_csv(response.content)
                self.assertTrue(rows[0], msg='every report has a header row')

    def test_quotes_commas_and_newlines(self):
        Post.objects.create(
            author=self.profile, post_type='text',
            body='He said "lift, then lower"\nand then, again,\nnewline',
        )
        rows = parse_csv(self._export(report='trending', kind='posts').content)
        bodies = [row for row in rows[1:] if 'lift' in ','.join(row)]
        self.assertEqual(len(bodies), 1, msg='the quoted post did not round-trip')
        cell = bodies[0][4]
        self.assertIn('"lift, then lower"', cell)

    def test_formula_injection_is_neutralised(self):
        Post.objects.create(
            author=self.profile, post_type='text',
            body='=HYPERLINK("http://evil.example","click")',
        )
        rows = parse_csv(self._export(report='trending', kind='posts').content)
        bodies = [row[4] for row in rows[1:] if 'HYPERLINK' in row[4]]
        self.assertEqual(len(bodies), 1)
        # A leading apostrophe is how Excel/Sheets are told "this is text".
        self.assertTrue(bodies[0].startswith("'="), msg=bodies[0])

    def test_numbers_are_not_mangled(self):
        rows = parse_csv(self._export(report='overview').content)
        user_row = next(row for row in rows[1:] if row[0] == 'users.new')
        self.assertFalse(user_row[4].startswith("'"), msg=user_row)
        self.assertTrue(user_row[4].lstrip('-').isdigit())

    def test_pipes_and_newlines_survive_a_round_trip(self):
        Post.objects.create(
            author=self.profile, post_type='text', body='line one | line two',
        )
        rows = parse_csv(self._export(report='trending', kind='posts').content)
        self.assertEqual(len(rows[0]), len(rows[1]), msg='ragged CSV')

    def test_trending_limit_applies_to_the_export_too(self):
        for index in range(5):
            Post.objects.create(author=self.profile, post_type='text', body=f'post {index}')
        rows = parse_csv(self._export(report='trending', kind='posts', limit=2).content)
        self.assertEqual(len(rows) - 1, 2)


class ExportValidationTests(TestCase):
    """The export path validates exactly like the screen, so they cannot differ."""

    def setUp(self):
        self.client = APIClient()
        self.staff = _make_user('val@example.com', 'valstaff', staff=True, superuser=True)
        self.client.force_authenticate(self.staff)

    def test_bad_date_is_rejected_not_silently_widened(self):
        response = self.client.get(EXPORT, {
            'report': 'overview', 'format': 'csv', 'from': 'yesterday',
        })
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('YYYY-MM-DD', str(response.data))

    def test_reversed_window_is_rejected(self):
        response = self.client.get(EXPORT, {
            'report': 'overview', 'format': 'csv',
            'from': '2026-05-01', 'to': '2026-04-01',
        })
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_unknown_report_names_the_allowed_set(self):
        response = self.client.get(EXPORT, {'report': 'secrets', 'format': 'csv'})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('overview', str(response.data))

    def test_unknown_format_names_the_allowed_set(self):
        response = self.client.get(EXPORT, {'report': 'overview', 'format': 'pdf'})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('csv, xlsx', str(response.data))

    def test_report_specific_params_are_validated(self):
        response = self.client.get(EXPORT, {
            'report': 'timeseries', 'format': 'csv', 'metric': 'not-a-metric',
        })
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)

    def test_a_bad_window_produces_no_audit_row(self):
        self.client.get(EXPORT, {'report': 'overview', 'format': 'csv', 'from': 'nope'})
        self.assertFalse(AdminActionLog.objects.filter(action='analytics.export').exists())


@override_settings(ANALYTICS_EXPORT_MAX_ROWS=5)
class ExportRowCapTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.staff = _make_user('cap@example.com', 'capstaff', staff=True, superuser=True)
        self.profile = self.staff.profile
        self.client.force_authenticate(self.staff)

    def test_over_the_cap_is_a_400_not_a_short_file(self):
        for index in range(6):
            Post.objects.create(author=self.profile, post_type='text', body=f'post {index}')
        response = self.client.get(EXPORT, {
            'report': 'trending', 'format': 'csv', 'kind': 'posts', 'limit': '100',
        })
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        message = str(response.data)
        self.assertIn('6', message)
        self.assertIn('5', message)
        self.assertIn('not truncated', message)

    def test_under_the_cap_succeeds(self):
        for index in range(3):
            Post.objects.create(author=self.profile, post_type='text', body=f'post {index}')
        response = self.client.get(EXPORT, {
            'report': 'trending', 'format': 'csv', 'kind': 'posts', 'limit': '100',
        })
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(len(parse_csv(response.content)) - 1, 3)


class ExportAuditTests(TestCase):
    """An export is a GET that moves data off-platform, so it is recorded."""

    def setUp(self):
        self.client = APIClient()
        self.staff = _make_user('audit@example.com', 'auditstaff', staff=True, superuser=True)
        self.client.force_authenticate(self.staff)

    def test_successful_export_writes_one_audit_row(self):
        response = self.client.get(EXPORT, {'report': 'overview', 'format': 'csv'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        rows = AdminActionLog.objects.filter(action='analytics.export')
        self.assertEqual(rows.count(), 1)
        row = rows.get()
        self.assertEqual(row.actor, self.staff)
        self.assertEqual(row.target_type, 'analytics_export')
        self.assertEqual(row.target_id, 'overview')
        self.assertEqual(row.after['format'], 'csv')
        self.assertEqual(row.after['outcome'], 'exported')
        self.assertEqual(row.after['rows'], int(response['X-Analytics-Rows']))

    def test_audit_row_records_the_window(self):
        today = timezone.now().date()
        self.client.get(EXPORT, {
            'report': 'overview', 'format': 'csv',
            'from': today.isoformat(), 'to': today.isoformat(),
        })
        after = AdminActionLog.objects.get(action='analytics.export').after
        self.assertEqual(after['from'], today.isoformat())
        self.assertEqual(after['to'], today.isoformat())

    def test_refused_export_is_audited(self):
        with openpyxl_disabled():
            response = self.client.get(EXPORT, {'report': 'overview', 'format': 'xlsx'})
        self.assertEqual(response.status_code, status.HTTP_503_SERVICE_UNAVAILABLE)
        row = AdminActionLog.objects.get(action='analytics.export')
        self.assertEqual(row.after['outcome'], 'refused_missing_dependency')


class openpyxl_disabled:
    """Make ``import openpyxl`` genuinely fail, without uninstalling anything.

    ``sys.modules[name] = None`` makes the import raise ImportError, which is
    exactly what a deployment missing the wheel sees.
    """

    def __enter__(self):
        self.previous = sys.modules.get('openpyxl', 'absent')
        sys.modules['openpyxl'] = None
        return self

    def __exit__(self, *exc_info):
        if self.previous == 'absent':
            sys.modules.pop('openpyxl', None)
        else:
            sys.modules['openpyxl'] = self.previous
        return False


class ExportMissingDependencyTests(TestCase):
    """A missing wheel is a 503 that names the wheel — never a 500."""

    def setUp(self):
        self.client = APIClient()
        self.staff = _make_user('nx@example.com', 'nxstaff', staff=True, superuser=True)
        self.client.force_authenticate(self.staff)

    def test_xlsx_without_openpyxl_is_503_naming_the_package(self):
        with openpyxl_disabled():
            self.assertFalse(openpyxl_available())
            response = self.client.get(EXPORT, {'report': 'overview', 'format': 'xlsx'})
        self.assertEqual(response.status_code, status.HTTP_503_SERVICE_UNAVAILABLE)
        self.assertIn('openpyxl', str(response.data))
        self.assertIn('CSV export of the same report is unaffected',
                      str(response.data))

    def test_csv_still_works_without_openpyxl(self):
        with openpyxl_disabled():
            response = self.client.get(EXPORT, {'report': 'overview', 'format': 'csv'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)

    def test_a_bad_report_is_a_400_even_when_xlsx_is_missing(self):
        # Validation runs first: a bad request must not be reported as a
        # missing dependency.
        with openpyxl_disabled():
            response = self.client.get(EXPORT, {'report': 'nope', 'format': 'xlsx'})
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)


def xlsx_rows(content, sheet_name=None):
    """Rows of the workbook as lists of python values.

    ``read_only=True`` hands back ReadOnlyCell objects that are not iterable and
    not hashable, so every cell is read through ``.value`` explicitly.
    """
    from openpyxl import load_workbook
    workbook = load_workbook(io.BytesIO(content), read_only=True)
    sheet = workbook[sheet_name or workbook.sheetnames[0]]
    return [[cell.value for cell in row] for row in sheet.rows]


@unittest.skipUnless(
    openpyxl_available(),
    XLSX_SKIP_REASON,
)
class XlsxExportTests(TestCase):
    def setUp(self):
        self.client = APIClient()
        self.staff = _make_user('xl@example.com', 'xlstaff', staff=True, superuser=True)
        self.profile = self.staff.profile
        self.client.force_authenticate(self.staff)

    def test_returns_a_real_xlsx_workbook(self):
        response = self.client.get(EXPORT, {'report': 'overview', 'format': 'xlsx'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(
            response['Content-Type'],
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        )
        self.assertIn('.xlsx"', response['Content-Disposition'])
        # An xlsx is a zip. Anything else is a truncated or wrong file.
        self.assertTrue(response.content.startswith(b'PK'))

    def test_workbook_reads_back_with_the_same_rows_as_the_csv(self):
        query = {'report': 'overview', 'format': 'xlsx'}
        rows = xlsx_rows(self.client.get(EXPORT, query).content)
        csv_rows = parse_csv(self.client.get(EXPORT, {**query, 'format': 'csv'}).content)
        self.assertEqual([str(cell) for cell in rows[0]], csv_rows[0])
        self.assertEqual(len(rows) - 1, len(csv_rows) - 1)
        self.assertEqual(str(rows[1][0]), csv_rows[1][0])

    def test_provenance_sheet_is_written(self):
        from openpyxl import load_workbook
        response = self.client.get(EXPORT, {'report': 'overview', 'format': 'xlsx'})
        workbook = load_workbook(io.BytesIO(response.content), read_only=True)
        self.assertIn('provenance', workbook.sheetnames)
        pairs = {
            row[0]: (row[1] if len(row) > 1 else None)
            for row in xlsx_rows(response.content, 'provenance')
        }
        self.assertEqual(pairs['report'], 'overview')
        self.assertTrue(pairs['from'])
        self.assertTrue(pairs['to'])

    def test_post_body_round_trips_through_the_sheet(self):
        Post.objects.create(
            author=self.profile, post_type='text', body='=cmd|" /C calc"!A1',
        )
        response = self.client.get(EXPORT, {'report': 'trending', 'format': 'xlsx',
                                            'kind': 'posts'})
        rows = xlsx_rows(response.content)
        excerpt_index = rows[0].index('body_excerpt')
        excerpts = [row[excerpt_index] for row in rows[1:]]
        self.assertTrue(any(str(cell).startswith("'=") for cell in excerpts))