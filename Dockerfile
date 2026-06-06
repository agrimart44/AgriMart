FROM python:3.13-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN python Backend/agriMartBackEnd/manage.py collectstatic --noinput --settings=agriMartBackEnd.settings || true

EXPOSE 8000

CMD ["gunicorn", "agriMartBackEnd.wsgi:application", "--chdir", "Backend/agriMartBackEnd", "--bind", "0.0.0.0:8000", "--workers", "2"]
