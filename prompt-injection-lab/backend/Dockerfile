# ─── Backend Dockerfile — Railway-compatible ──────────────────────────────────
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

# Bundle the frontend directly into the image.
# On Railway there are no bind mounts, so we COPY instead.
COPY frontend/ /app/frontend/

# Railway injects PORT at runtime; gunicorn reads it from entrypoint.sh.
# We declare 5000 as a hint but the actual port is dynamic.
EXPOSE 5000

ENV PYTHONUNBUFFERED=1

ENTRYPOINT ["./entrypoint.sh"]
