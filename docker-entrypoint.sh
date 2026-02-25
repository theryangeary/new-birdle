#!/bin/sh
set -e

echo "Running migrations up to 0010..."
python manage.py migrate birdle 0010 --noinput

echo "Seeding regions (required by migration 0011)..."
python manage.py import_regions

echo "Running remaining migrations..."
python manage.py migrate --noinput

# Skip data seeding if bird-region data already exists
DATA_EXISTS=$(python manage.py shell -c "from birdle.models import BirdRegion; print(BirdRegion.objects.exists())")

if [ "$DATA_EXISTS" = "True" ]; then
    echo "Bird data already exists, skipping import."
else
    echo "Importing bird species..."
    python manage.py import_bird_species

    # Populate bird-region associations if EBIRD_API_KEY is set
    if [ -n "$EBIRD_API_KEY" ]; then
        echo "Fetching bird-region data from eBird API..."
        python manage.py get_birdregions
    else
        echo ""
        echo "WARNING: EBIRD_API_KEY is not set."
        echo "Bird-region data is required for the game to work."
        echo "Set EBIRD_API_KEY in your .env file and run:"
        echo "  docker-compose exec web python manage.py get_birdregions"
        echo ""
    fi
fi

echo "Collecting static files..."
python manage.py collectstatic --noinput

echo "Starting gunicorn..."
exec gunicorn config.wsgi --bind 0.0.0.0:8000 --timeout 120
