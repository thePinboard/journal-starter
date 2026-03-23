#!/bin/bash
echo "======================================"
echo "   Journal API - Full Auto Fix Script"
echo "======================================"

# Pfad zum Projekt
PROJECT_DIR=~/journal-api
cd $PROJECT_DIR || exit

# 1️⃣ Stoppe alte API-Prozesse
echo "→ Stoppe alte API-Prozesse..."
pkill -f uvicorn 2>/dev/null || true
sleep 2

# 2️⃣ PostgreSQL Container starten oder erstellen
echo "→ Starte PostgreSQL Container..."
docker start postgres 2>/dev/null || docker run -d \
  --name postgres \
  -e POSTGRES_USER=postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=career_journal \
  -p 5432:5432 \
  postgres:15
sleep 5

# 3️⃣ Tabelle neu erstellen
echo "→ Tabelle 'entries' neu erstellen..."
docker exec -i postgres psql -U postgres -d career_journal <<'SQL'
DROP TABLE IF EXISTS entries;

CREATE TABLE entries (
    id SERIAL PRIMARY KEY,
    work TEXT NOT NULL,
    struggle TEXT NOT NULL,
    intention TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

SELECT '✅ Tabelle "entries" erstellt!' as status;
SQL

# 4️⃣ Virtuelle Umgebung prüfen
if [ ! -d ".venv" ]; then
    echo "→ Erstelle virtuelle Umgebung..."
    python3 -m venv .venv
    source .venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
else
    source .venv/bin/activate
fi

# 5️⃣ API starten
echo "→ Starte Journal API..."
uv run uvicorn api.main:app --host 0.0.0.0 --port 8000 > api.log 2>&1 &

sleep 3
echo ""
echo "🚀 API läuft jetzt unter: http://localhost:8000"
echo "Logs anzeigen: tail -f api.log"
