#!/bin/sh
# start.sh — Ollama startup for Railway
#
# Railway injects $PORT for the public-facing port, but Ollama always binds
# internally on 11434. We hardcode OLLAMA_HOST to the correct host:port format.
# The Flask service talks to us over the private network on port 11434.

export OLLAMA_HOST="0.0.0.0:11434"

echo "Starting Ollama on $OLLAMA_HOST ..."
exec ollama serve
