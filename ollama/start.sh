#!/bin/sh
# Railway injects $PORT for its load balancer, but Ollama must bind on 11434
# for the Flask service to reach it via private networking on that port.
# We ignore Railway's $PORT and always bind Ollama on 11434.
export OLLAMA_HOST="0.0.0.0:11434"
echo "Starting Ollama on $OLLAMA_HOST ..."
exec ollama serve
