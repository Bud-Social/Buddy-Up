import os
import dotenv
dotenv.load_dotenv(os.path.join(os.path.dirname(__file__), '..', '..', '.env'))

from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.production')

application = get_wsgi_application()
