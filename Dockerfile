# Use an official Python runtime as the base image
FROM python:3.13-slim

# Set working directory
WORKDIR /app

# Copy requirements.txt first to leverage caching
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy entire repository (assuming correct structure)
COPY .. .

# Optional: Print contents of firebase directory for debugging
RUN echo "📁 Checking firebase directory..." && \
    ls -la /app/Backend/agriMartBackEnd/firebase/ || \
    echo "⚠️ Firebase key file not found!"

# Run Django development server
EXPOSE 8000

CMD ["python", "Backend/agriMartBackEnd/manage.py", "runserver", "0.0.0.0:8000"]
