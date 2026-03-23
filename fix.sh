#!/bin/bash
echo "======================================"
echo "   Journal API - FIX ALL SCRIPT"
echo "======================================"

cd ~/journal-api

echo "→ Stoppe API..."
pkill -f uvicorn 2>/dev/null
sleep 2

echo "→ PostgreSQL sicher starten..."
docker start postgres 2>/dev/null || docker run -d \
  --name postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=career_journal \
  -p 5432:5432 \
  postgres:15

sleep 5

echo "→ Datenbank fixen..."
docker exec -i postgres psql -U postgres -d career_journal << 'SQL'
DROP TABLE IF EXISTS entries;

CREATE TABLE entries (
    id UUID PRIMARY KEY,
    data JSONB,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

SELECT 'OK' as status;
SQL

echo "→ API starten..."
uv run uvicorn api.main:app --host 0.0.0.0 --port 8000
