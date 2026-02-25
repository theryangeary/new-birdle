# Stage 1: Build dependencies and collect static files
FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS build

WORKDIR /app

# Install dependencies first (layer caching)
COPY pyproject.toml .
RUN uv sync --no-dev --no-install-project

# Copy application code
COPY . .

# Collect static files (needs a SECRET_KEY but doesn't matter what value)
RUN DJANGO_SECRET_KEY=build-placeholder DATABASE_URL=sqlite:///tmp/build.db \
    uv run python manage.py collectstatic --noinput

# Stage 2: Lean runtime image
FROM python:3.13-slim-bookworm

WORKDIR /app

# Copy the virtual environment from build stage
COPY --from=build /app/.venv /app/.venv

# Copy application code and collected static files
COPY --from=build /app /app

# Put the venv on PATH
ENV PATH="/app/.venv/bin:$PATH"

# Make entrypoint executable
RUN chmod +x /app/docker-entrypoint.sh

EXPOSE 8000

ENTRYPOINT ["/app/docker-entrypoint.sh"]
