#!/bin/sh
set -e

mkdir -p /app/server/uploads/tmp /app/server/uploads/documents

echo "Pre-seeding RAG corpus..."
node /app/rag/scripts/ingest.js && echo "Corpus ready." || echo "Corpus seeding skipped (check API keys)."

exec "$@"
