FROM ollama/ollama:latest

EXPOSE 11434
ENV PORT=11434

# Cap context length at the server level so Ollama never allocates a
# giant KV cache regardless of what the client requests.
# llama3.2:1b's default of 131072 requires ~16 GB RAM — Railway instances
# have 8 GB max on the Pro plan. 2048 is plenty for this CTF lab.
ENV OLLAMA_CONTEXT_LENGTH=2048

# Limit to 1 model loaded at a time to conserve RAM.
ENV OLLAMA_MAX_LOADED_MODELS=1

# Disable Ollama's flash attention (not available on CPU, wastes cycles trying).
ENV OLLAMA_FLASH_ATTENTION=0

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
