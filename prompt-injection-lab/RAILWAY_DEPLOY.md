# 🎯 Prompt Injection Lab — Railway Deployment Guide

> **Cybersecurity Training Environment — Educational use only**

---

## Project Structure

```
prompt-injection-lab/
├── backend/
│   ├── app.py              ← Flask API (the vulnerable target)
│   ├── entrypoint.sh       ← Startup: waits for Ollama, pulls model, starts gunicorn
│   ├── Dockerfile          ← Builds the Flask service (includes frontend/)
│   ├── requirements.txt
│   ├── railway.toml        ← Railway build/deploy config for this service
│   └── frontend/
│       └── index.html      ← Hacker terminal UI (bundled into the image)
├── ollama/
│   ├── Dockerfile          ← Thin wrapper around ollama/ollama:latest
│   └── railway.toml        ← Railway build/deploy config for this service
├── .env.example            ← All environment variables documented
└── RAILWAY_DEPLOY.md       ← This file
```

---

## Railway Deployment (Step-by-Step)

### Step 1 — Create a new Railway project

1. Go to [railway.app](https://railway.app) → **New Project** → **Empty Project**.

---

### Step 2 — Add the Ollama service

1. In your project, click **+ New** → **GitHub Repo** (or **Empty Service**).
2. If using GitHub: push this repo, then point Railway at the `ollama/` directory.
   - **Root Directory**: `ollama`
3. Railway will detect `railway.toml` and build the Dockerfile automatically.
4. Once deployed, note the **private hostname** Railway shows under
   **Settings → Networking → Private Domain**. It will look like:
   ```
   ollama.railway.internal
   ```
   (Railway names services after the folder/repo; rename the service if needed.)

> **Do not expose Ollama publicly.** It doesn't need a public domain — the Flask
> service reaches it over the private network.

---

### Step 3 — Add the Flask backend service

1. Click **+ New** → **GitHub Repo** → same repo, but set:
   - **Root Directory**: `backend`
2. Railway will detect `backend/railway.toml` and build the Dockerfile.

#### Set environment variables (Service → Variables):

| Variable      | Value                                         |
|---------------|-----------------------------------------------|
| `OLLAMA_URL`  | `http://ollama.railway.internal:11434`        |
| `MODEL_NAME`  | `tinyllama` (or your preferred model)         |
| `SECRET_FLAG` | `CVTRY{Pr0mpt_1nj3cti0n}` (or custom flag)  |

> `PORT` is injected automatically by Railway — do not set it yourself.

#### Generate a public domain:
- Go to **Settings → Networking → Public Domain** → **Generate Domain**
- This is the URL you give students.

---

### Step 4 — First Boot

The first deployment takes **5–10 minutes** because:
1. Docker images are built from scratch
2. The Flask entrypoint waits for Ollama to be ready
3. `entrypoint.sh` pulls the model (~637 MB for tinyllama) from Ollama's registry

You can watch progress in Railway's **Deploy Logs** for the backend service.

The health check (`/api/health`) will return `"model_ready": true` once everything
is ready. The frontend status indicator will also switch to **ORACLE READY**.

---

## Changing the Model

Set `MODEL_NAME` in the backend service variables. The model is pulled
automatically on next boot. Available models:

| Model          | Size   | Difficulty | Notes                     |
|----------------|--------|------------|---------------------------|
| `tinyllama`    | 637 MB | Easy       | Default, fast, very leaky |
| `phi3:mini`    | 2.3 GB | Medium     | Better instruction follow  |
| `llama3.2:1b`  | 1.3 GB | Medium     | Good balance              |
| `mistral`      | 4.1 GB | Hard       | Strong prompt adherence   |
| `llama3.1:8b`  | 4.7 GB | Hard       | Best quality target       |

> ⚠️ Railway's free/hobby tier has limited RAM. `tinyllama` and `llama3.2:1b`
> are the safest choices. Upgrade to a Pro plan instance with more RAM for
> larger models.

---

## Architecture on Railway

```
Student browser
      │
      ▼  HTTPS (public)
┌─────────────────────┐
│  Flask backend      │  (backend service — public domain)
│  port: $PORT        │
│  serves index.html  │
└─────────┬───────────┘
          │  HTTP (private network only)
          │  http://ollama.railway.internal:11434
          ▼
┌─────────────────────┐
│  Ollama             │  (ollama service — internal only)
│  port: 11434        │
└─────────────────────┘
```

---

## Instructor Audit Log

```bash
curl https://<your-railway-domain>/api/audit | jq .
```

---

## Local Testing (Docker Compose still works)

The original `docker-compose.yml` still works for local testing. Use Railway
only for the hosted/remote classroom version.

---

## Legal Notice

This lab is for **authorised security testing and education only**.
Do not use these techniques against systems you do not own or have explicit
permission to test.
