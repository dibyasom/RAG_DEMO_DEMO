# Use Python 3.12 Alpine as base image for minimal size
FROM python:3.12-alpine

# Set working directory
WORKDIR /app

# Install build dependencies for Python packages that need compilation
# Remove them after pip install to keep image lean
RUN apk add --no-cache \
    gcc \
    musl-dev \
    libffi-dev \
    && rm -rf /var/cache/apk/*

# Copy requirements first for better layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Remove build dependencies to reduce image size
RUN apk del gcc musl-dev libffi-dev

# Copy application files
COPY app.py .
COPY templates/ ./templates/
COPY static/ ./static/

# Expose port 8000
EXPOSE 8000

# Set environment variables
ENV FLASK_APP=app.py
ENV PYTHONUNBUFFERED=1

# Run Flask app on port 8000
CMD ["python", "-m", "flask", "run", "--host=0.0.0.0", "--port=8000"]

