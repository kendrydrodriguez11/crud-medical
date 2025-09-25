#!/bin/sh
set -e  # Exit immediately if a command exits with a non-zero status
set -u  # Exit if using an undefined variable

# Configuration variables
#NAME="${PROJECT_NAME}"
#NUM_WORKERS=3
#DJANGO_WSGI_MODULE=config.wsgi
#TIMEOUT=600

# Check environment
if [ "$APP_ENV" = "local" ]; then
    echo "Running in local environment..."
    # Run Django development server
    python manage.py runserver 0.0.0.0:8000
else
    echo "Running in production environment..."
    # In production, use Gunicorn
    # Usually, you would also run collectstatic here
    # python manage.py collectstatic --noinput

#    gunicorn ${DJANGO_WSGI_MODULE}:application \
#        --name "$NAME" \
#        --workers $NUM_WORKERS \
#        --timeout $TIMEOUT \
#        --log-level=debug \
#        --bind 0.0.0.0:8000
fi
