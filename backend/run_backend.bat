@echo off
echo Starting NEXA Backend...

if not exist venv (
    echo Creating virtual environment...
    python -m venv venv
)

call venv\Scripts\activate.bat
echo Installing dependencies...
pip install -r requirements.txt

echo Starting server on http://localhost:8000
echo Swagger docs: http://localhost:8000/docs
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
pause
