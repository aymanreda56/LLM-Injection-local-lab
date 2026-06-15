#!/bin/bash
# entrypoint.sh
# The backend container already depends_on ollama:healthy via compose,
# so Ollama is guaranteed reachable when this runs. We just do a quick
# confirmation poll (belt-and-suspenders), then start gunicorn.

set -e

OLLAMA_URL="${OLLAMA_URL:-http://ollama:11434}"
MODEL="${MODEL_NAME:-tinyllama}"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Prompt Injection Lab — Backend Starting"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Ollama URL : $OLLAMA_URL"
echo "  Model      : $MODEL"
echo ""

# Brief confirmation that Ollama is still up (compose already waited,
# but a safety net in case of race conditions on slower machines)
MAX_WAIT=60
ELAPSED=0
echo "Confirming Ollama is reachable..."
until curl -sf "$OLLAMA_URL/api/tags" > /dev/null 2>&1; do
    if [ $ELAPSED -ge $MAX_WAIT ]; then
        echo "ERROR: Ollama not reachable after ${MAX_WAIT}s — starting anyway"
        break
    fi
    sleep 2
    ELAPSED=$((ELAPSED + 2))
    echo "  ...waiting (${ELAPSED}s / ${MAX_WAIT}s)"
done
echo "Ollama is reachable."

# Show which models are available
echo "Available models:"
curl -sf "$OLLAMA_URL/api/tags" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    models = [m['name'] for m in data.get('models', [])]
    if models:
        for m in models:
            print(f'  - {m}')
    else:
        print('  (none yet — model-loader container will pull the model)')
except:
    print('  (could not parse response)')
" 2>/dev/null || true

echo ""
echo "Starting Flask backend on 0.0.0.0:5000 ..."
exec gunicorn \
    --bind 0.0.0.0:5000 \
    --workers 2 \
    --timeout 180 \
    --log-level info \
    app:app
