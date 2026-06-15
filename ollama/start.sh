#!/bin/sh
# Ollama startup for Railway.
# OLLAMA_HOST must be in host:port format — bare IP causes binding issues.
export OLLAMA_HOST="0.0.0.0:11434"
echo "Starting Ollama on $OLLAMA_HOST ..."
exec ollama serve
