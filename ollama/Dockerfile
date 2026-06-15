FROM ollama/ollama:latest

# Tell Railway the internal port this service listens on.
# Railway uses this to set up private networking — it does NOT mean
# the health checker will probe this port.
EXPOSE 11434
ENV PORT=11434

COPY start.sh /start.sh
RUN chmod +x /start.sh

ENTRYPOINT ["/start.sh"]
