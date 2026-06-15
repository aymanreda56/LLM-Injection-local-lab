#!/bin/bash
# entrypoint.sh — Railway-compatible startup script
# 1. Waits for Ollama to be reachable (via OLLAMA_URL)
# 2. Pulls the model if not already present
# 3. Starts gunicorn on the PORT Railway injects

set -e

OLLAMA_URL="${OLLAMA_URL:-http://localhost:11434}"
MODEL="${MODEL_NAME:-tinyllama}"
PORT="${PORT:-5000}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Prompt Injection Lab — Backend Starting"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Ollama URL : $OLLAMA_URL"
echo "  Model      : $MODEL"
echo "  Port       : $PORT"
echo ""

# ── 1. Wait for Ollama ────────────────────────────────────────────────────────
MAX_WAIT=120
ELAPSED=0
echo "Waiting for Ollama to become reachable..."
until curl -sf "$OLLAMA_URL/api/tags" > /dev/null 2>&1; do
    if [ $ELAPSED -ge $MAX_WAIT ]; then
        echo "ERROR: Ollama not reachable after ${MAX_WAIT}s — starting Flask anyway"
        break
    fi
    sleep 3
    ELAPSED=$((ELAPSED + 3))
    echo "  ...waiting (${ELAPSED}s / ${MAX_WAIT}s)"
done
echo "Ollama is reachable."

# ── 2. Pull model if not already available ────────────────────────────────────
echo ""
echo "Checking if model '$MODEL' is already pulled..."
MODELS_JSON=$(curl -sf "$OLLAMA_URL/api/tags" 2>/dev/null || echo '{"models":[]}')
if echo "$MODELS_JSON" | python3 -c "
import sys, json
data = json.load(sys.stdin)
names = [m['name'] for m in data.get('models', [])]
print('\n'.join(names))
" 2>/dev/null | grep -q "$MODEL"; then
    echo "Model '$MODEL' already present — skipping pull."
else
    echo "Pulling model '$MODEL' from Ollama registry (this can take several minutes on first boot)..."
    curl -sf -X POST "$OLLAMA_URL/api/pull" \
        -H "Content-Type: application/json" \
        -d "{\"name\": \"$MODEL\"}" \
        --max-time 900 \
        --no-buffer \
        -o /dev/null \
        && echo "Model '$MODEL' pulled successfully." \
        || echo "WARNING: model pull may have failed — Flask will start anyway."
fi

# ── 3. Start Flask via gunicorn ───────────────────────────────────────────────
echo ""
echo "Starting Flask on 0.0.0.0:$PORT ..."
exec gunicorn \
    --bind "0.0.0.0:$PORT" \
    --workers 2 \
    --timeout 180 \
    --log-level info \
    app:app
