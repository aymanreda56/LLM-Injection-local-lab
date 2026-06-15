# ─── Ollama Service Dockerfile — Railway-compatible ───────────────────────────
#
# Railway cannot run the official ollama/ollama image directly from Docker Hub
# because Railway expects a Dockerfile to build from. This thin wrapper just
# re-uses the official image and exposes the right port.
#
# The model is pulled lazily by the Flask backend's entrypoint.sh on first boot.
# If you want to pre-bake a model into this image (faster cold starts but a
# much larger image), uncomment the RUN block below.

FROM ollama/ollama:latest

# Ollama listens on 11434 by default.
# Railway will expose this port internally; the Flask service reaches it via
# the private network hostname set in OLLAMA_URL.
EXPOSE 11434

# ── Optional: pre-pull a model at image build time ────────────────────────────
# Uncomment these lines to embed the model in the image (~637 MB extra for
# tinyllama). This avoids the pull delay on every cold start, at the cost of
# a larger image and longer initial build.
#
# RUN ollama serve & \
#     sleep 5 && \
#     ollama pull tinyllama && \
#     pkill ollama

ENV OLLAMA_HOST=0.0.0.0

CMD ["serve"]
