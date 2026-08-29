from django.test import SimpleTestCase
from .models import AIPredictionJob
from .serializers import AIPredictionJobSerializer


class AIPredictionMetadataTests(SimpleTestCase):
    def test_serializer_exposes_safety_and_quality_metadata(self):
        self.assertIn('safety_notice', AIPredictionJobSerializer.Meta.fields)
        self.assertIn('confidence', AIPredictionJobSerializer.Meta.fields)
        self.assertEqual(AIPredictionJob._meta.get_field('safety_notice').default, 'AI output is informational only, not medical advice.')
