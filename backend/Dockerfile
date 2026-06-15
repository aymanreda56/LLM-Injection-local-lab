# ─── Backend Dockerfile (single-stage) ───────────────────────────────────────
FROM python:3.12-slim

LABEL description="Prompt Injection Lab — vulnerable LLM backend (education only)"

RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Static frontend files are mounted at /app/frontend/dist via docker-compose
EXPOSE 5000
ENV PYTHONUNBUFFERED=1

ENTRYPOINT ["./entrypoint.sh"]
