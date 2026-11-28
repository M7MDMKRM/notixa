#!/bin/bash
set -e

echo "🚀 Preparing NEXA Backend..."

# Create Python virtual environment if not present
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python3 -m venv venv
fi

source venv/bin/activate

echo "📦 Installing requirements..."
pip install -r requirements.txt

echo "⚡ Starting NEXA Backend Server on port 8000..."
echo "📖 Swagger API Docs available at: http://localhost:8000/docs"
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
