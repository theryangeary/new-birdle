# Bash commands
- source .venv/bin/activate: Activate the virtual environment 
- .venv/bin/python: Location of the Python interpreter
- uv add <package>: Add a package to the project
- uv remove <package>: Remove a package from the project
- uv run ruff check: Run the linter
- uv run ruff format: Run the auto-formatter
- uvx ty check: Run the type checker

# Code style
- Use ruff for linting and formatting
- Use uv to manage dependencies
- Follow PEP 8 style guidelines

# Workflow
- This project uses uv for project, dependency, and environment management
- Be sure to typecheck when you’re done making a series of code changes
- Run the linter and auto-formatter before committing code

# Starting the Django development server
- Run the server: `python manage.py runserver 8001`
- Access the application at `http://localhost:8001/`

# Performance Optimizations

## Frontend Optimizations

### CDN Resource Hints
Add to `base.html` `<head>` to reduce DNS lookup time:
```html
<link rel="preconnect" href="https://cdn.jsdelivr.net">
<link rel="preconnect" href="https://cdnjs.cloudflare.com">
<link rel="preconnect" href="https://unpkg.com">
```

### JavaScript Loading
- Defer non-critical JS (Bootstrap, SweetAlert) with `defer` attribute
- HTMX should load normally as it's needed for page interactivity
- Consider moving inline scripts to external files for better caching

### Library Updates
- Bootstrap is on 5.3.1 (2023) - consider upgrading to 5.3.x latest
- Font Awesome is on 5.15.3 (2021) - consider upgrading to 6.x
- Keep HTMX and SweetAlert2 up to date for performance improvements

### Image Optimization
- Compress all bird images (PNG/JPG) using tools like:
  - `pillow` with quality settings during upload/processing
  - `imagemin` or `tinypng` API for batch compression
  - WebP format for modern browsers with fallbacks
- Implement lazy loading for images: `<img loading="lazy">`
- Consider responsive images with `srcset` for different screen sizes
- Serve images through CDN for faster global delivery

### Autocomplete Caching
- Cache bird species autocomplete data in browser localStorage/sessionStorage
- Implement service worker for offline autocomplete functionality
- Server-side: cache autocomplete results in Redis or Django cache
- Consider prefetching common species names on page load

## Backend Optimizations

### Database Performance
- Add indexes on frequently queried fields (species names, dates, regions)
- Use `select_related()` and `prefetch_related()` to reduce N+1 queries
- Consider database connection pooling
- Review and optimize slow queries with Django Debug Toolbar

### Caching Strategy
- Enable Django's cache framework (Redis/Memcached recommended)
- Cache daily bird selection per region
- Cache template fragments for navbar, footer, stats
- Cache autocomplete queries with short TTL
- Use `@cache_page` decorator for relatively static views

### Static Files
- Enable Django's `ManifestStaticFilesStorage` for cache-busting
- Compress CSS/JS with `django-compressor` or `whitenoise` with compression
- Serve static files through CDN in production (AWS CloudFront, Cloudflare)
- Enable gzip/brotli compression on web server

### HTTP/2 or HTTP/3
- Ensure production server supports HTTP/2 (multiplexing benefits)
- Consider HTTP/3 for even better performance

### Django Settings for Production
```python
# Cache settings
CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.redis.RedisCache',
        'LOCATION': 'redis://127.0.0.1:6379/1',
    }
}

# Static files compression
STORAGES = {
    "staticfiles": {
        "BACKEND": "whitenoise.storage.CompressedManifestStaticFilesStorage",
    },
}
```

## Monitoring
- Use Django Debug Toolbar in development to identify slow queries
- Monitor page load times with browser DevTools Network tab
- Consider Real User Monitoring (RUM) in production
- Track Core Web Vitals (LCP, FID, CLS)
