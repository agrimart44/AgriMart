from pathlib import Path
from decouple import config

BASE_DIR = Path(__file__).resolve().parent.parent

STREAM_API_KEY = config('STREAM_API_KEY')
STREAM_API_SECRET = config('STREAM_API_SECRET')

SECRET_KEY = config('SECRET_KEY', default='django-insecure-x!9vfzb0a-bmyw+pxzyuk7ep-x0xgm493pb)cvk&&usw*7c+yd')

DEBUG = config('DEBUG', default=False, cast=bool)

ALLOWED_HOSTS = [
    'localhost',
    '127.0.0.1',
    '.onrender.com',
    config('ALLOWED_HOST', default=''),
]

import cloudinary
import cloudinary.uploader

cloudinary.config(
    cloud_name=config('CLOUDINARY_CLOUD_NAME', default='dkxs4ycz3'),
    api_key=config('CLOUDINARY_API_KEY', default='587471489591572'),
    api_secret=config('CLOUDINARY_API_SECRET', default='kMPAuQYbG3U4xGQgkBi5Wn6i6ag'),
)

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'whitenoise.runserver_nostatic',
    'django.contrib.staticfiles',

    'buyerview',
    'cart',
    'crops',
    'register',
    'user_details',
    'corsheaders',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'whitenoise.middleware.WhiteNoiseMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

CORS_ALLOW_ALL_ORIGINS = True

ROOT_URLCONF = 'agriMartBackEnd.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'agriMartBackEnd.wsgi.application'

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': ':memory:',
    }
}

AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator'},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

LANGUAGE_CODE = 'en-us'
TIME_ZONE = 'UTC'
USE_I18N = True
USE_TZ = True

STATIC_URL = '/static/'
STATIC_ROOT = BASE_DIR / 'staticfiles'
STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'

DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
