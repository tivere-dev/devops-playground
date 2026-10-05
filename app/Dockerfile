# 1. Start from a small official Python image
FROM python:3.12-slim

# 2. Work inside /app
WORKDIR /app

# 3. Install dependencies first (cached unless requirements.txt changes)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 4. Copy the code and tests
COPY app.py .
COPY tests/ tests/

# 5. Don't run as root
RUN useradd -m appuser
USER appuser

# 6. Defaults (override with docker run -e COLOR=green -e VERSION=v2)
ENV COLOR=blue VERSION=v1
EXPOSE 5000

# 7. Docker checks this every 10s to decide if the container is healthy
HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# 8. Start the app with gunicorn (a production web server for Python)
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "1", "--threads", "4", "--access-logfile", "-", "app:app"]
