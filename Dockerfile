# Use an official Python runtime as the base image
FROM python:3.13-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file into the container
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY .. .

# Expose the port the app runs on
EXPOSE 8000

# Command to run the application using Gunicorn (production-ready server)
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]