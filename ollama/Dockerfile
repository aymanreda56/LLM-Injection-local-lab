# ─── Ollama Service Dockerfile — Railway-compatible ───────────────────────────
FROM ollama/ollama:latest

EXPOSE 11434

COPY start.sh /start.sh
RUN chmod +x /start.sh

# Override the base image's entrypoint (which is `ollama`) so our script
# runs as PID 1 and can call `ollama serve` itself.
ENTRYPOINT ["/start.sh"]
