FROM python:3.14-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY load_yellow_taxi_data.py .

CMD ["python", "load_yellow_taxi_data.py"]