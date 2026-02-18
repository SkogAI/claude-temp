import json
from pathlib import Path

from fastapi import FastAPI
from fastapi.responses import FileResponse, JSONResponse

app = FastAPI()

DATA_DIR = Path(__file__).parent
DATA_FILE = DATA_DIR / "skogai-routing-data.json"
HTML_FILE = DATA_DIR / "skogai-routing-playground.html"


@app.get("/")
def playground():
    return FileResponse(HTML_FILE, media_type="text/html")


@app.get("/api/data")
def get_data():
    return json.loads(DATA_FILE.read_text())


@app.put("/api/data")
def save_data(data: dict):
    DATA_FILE.write_text(json.dumps(data, indent=2))
    return {"ok": True}
