#!/bin/sh
set -e

mkdir -p /app/server/uploads/tmp /app/server/uploads/documents

exec "$@"
