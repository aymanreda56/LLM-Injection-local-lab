# ─── Ollama Service Dockerfile — Railway-compatible ───────────────────────────
FROM ollama/ollama:latest

EXPOSE 11434

# Use a startup script so we can correctly set OLLAMA_HOST from Railway's
# injected PORT env var (Ollama requires host:port format, not bare IP).
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]
