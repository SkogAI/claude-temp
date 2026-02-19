import json
import subprocess
from pathlib import Path

from fastapi import FastAPI
from fastapi.responses import FileResponse

app = FastAPI()

DATA_DIR = Path(__file__).parent
DATA_FILE = DATA_DIR / "skogai-routing-data.json"
HTML_FILE = DATA_DIR / "skogai-routing-playground.html"

SKOGAI_DIR = Path.home() / ".skogai"


# --- playground ---

@app.get("/")
def playground():
    return FileResponse(HTML_FILE, media_type="text/html")


# --- routing data ---

@app.get("/api/data")
def get_data():
    return json.loads(DATA_FILE.read_text())


@app.put("/api/data")
def save_data(data: dict):
    DATA_FILE.write_text(json.dumps(data, indent=2))
    return {"ok": True}


SKOGCLI = "/home/skogix/.local/bin/skogcli"


def _run(cmd: list[str]) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, capture_output=True, text=True)


# --- agents ---

@app.get("/api/agents")
def list_agents():
    result = _run([SKOGCLI, "agent", "list"])
    agents = []
    for line in result.stdout.strip().splitlines():
        line = line.strip()
        if line and not line.startswith("Available") and not line.startswith("Model:"):
            agents.append(line)
    return agents


@app.get("/api/agents/{name}")
def get_agent(name: str):
    result = _run([SKOGCLI, "agent", "read", "--agent", name, "--json"])
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError:
        return {"agent": name, "raw": result.stdout.strip()}


# --- skogai structure ---

@app.get("/api/skogai")
def skogai_tree():
    if not SKOGAI_DIR.is_dir():
        return {"error": ".skogai not found"}
    return {
        "path": str(SKOGAI_DIR),
        "dirs": sorted(d.name for d in SKOGAI_DIR.iterdir() if d.is_dir() and not d.name.startswith(".")),
        "files": sorted(f.name for f in SKOGAI_DIR.iterdir() if f.is_file() and not f.name.startswith(".")),
    }


@app.get("/api/skogai/{subdir}")
def skogai_subdir(subdir: str):
    target = SKOGAI_DIR / subdir
    if not target.is_dir():
        return {"error": "not found"}
    return {
        "path": str(target),
        "entries": sorted(e.name for e in target.iterdir() if not e.name.startswith(".")),
    }


# --- config ---

@app.get("/api/config")
def config_list():
    result = _run([SKOGCLI, "config", "list"])
    entries = {}
    for line in result.stdout.strip().splitlines():
        if "=" in line:
            key, _, val = line.strip().partition(" = ")
            entries[key] = val
    return entries


@app.get("/api/config/{key:path}")
def config_get(key: str):
    result = _run([SKOGCLI, "config", "get", key])
    return {"key": key, "value": result.stdout.strip()}


# --- scripts ---

@app.get("/api/scripts")
def script_list():
    result = _run([SKOGCLI, "script", "list"])
    scripts = []
    for line in result.stdout.strip().splitlines():
        if " - " in line:
            name, _, desc = line.strip().partition(" - ")
            scripts.append({"name": name, "description": desc})
    return scripts


@app.get("/api/scripts/{name}")
def script_info(name: str):
    result = _run([SKOGCLI, "script", "info", name])
    return {"name": name, "info": result.stdout.strip()}


# --- skogparse ---

@app.get("/api/parse")
def parse(expr: str):
    result = subprocess.run(["/home/skogix/.local/bin/skogparse-bin"], input=expr, capture_output=True, text=True)
    try:
        return {"expr": expr, "ast": json.loads(result.stdout)}
    except json.JSONDecodeError:
        return {"expr": expr, "raw": result.stdout.strip()}


@app.get("/api/resolve")
def resolve(expr: str):
    result = subprocess.run(["/home/skogix/.local/bin/skogparse"], input=expr, capture_output=True, text=True)
    return {"expr": expr, "result": result.stdout.strip()}


# --- services ---

@app.get("/api/services")
def list_services():
    result = subprocess.run(
        ["systemctl", "--user", "list-units", "--type=service", "--no-pager", "--plain"],
        capture_output=True, text=True,
    )
    services = []
    for line in result.stdout.strip().splitlines()[1:]:
        parts = line.split(None, 4)
        if len(parts) >= 4 and "skogai" in parts[0]:
            services.append({
                "unit": parts[0],
                "active": parts[2],
                "sub": parts[3],
                "description": parts[4] if len(parts) > 4 else "",
            })
    return services


# --- health ---

@app.get("/api/health")
def health():
    return {"status": "ok"}
