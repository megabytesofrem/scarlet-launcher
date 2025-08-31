import os
from PyQt6.QtGui import QIcon, QPixmap
from PyQt6.QtCore import QByteArray, QBuffer, QBuffer

import subprocess
import tempfile
from pathlib import Path

try:
    from rich import print
except ImportError:
    pass  # rich is optional but recommended, fallback to print


def log(message):
    print(message)  # Placeholder for logging functionality


def get_project_root():
    path = os.path.abspath(__file__)
    # assuming your structure is /path/to/shrine-loader/app/main_ui.py
    # move up one directory from app/
    root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    return root

def get_latest_github_release(repo: str) -> str:
    try:
        import requests
    except ImportError:
        log("[bright_red]requests module is not installed. Please install it to fetch the latest release.[/bright_red]")
        return "Error: requests module not installed"

    url = f"https://api.github.com/repos/{repo}/releases/latest"
    try:
        response = requests.get(url)
        response.raise_for_status()
        return response.json().get("name", "No release found")
    except requests.RequestException as e:
        return f"Error fetching latest release: {e}"
    

def detect_steam_games() -> list[str]:
    steam_games = []
    # Logic to detect Steam games goes here
    return steam_games


def check_wine_installed() -> tuple[bool, str]:
    from shutil import which
    wine_tools = ["wine", "wrestool", "winetricks"]

    for tool in wine_tools:
        if which(tool) is None:
            log(f"[bright_red]'{tool}' is not installed.[/bright_red]")
            return False, f"'{tool}' is not installed or not found in PATH."
        
    log("[bright_green]Wine and required tools are installed.[/bright_green]")
    return True, "Wine and required tools are installed."


def extract_icon_from_exe(exe_path: Path) -> QIcon:
    with tempfile.NamedTemporaryFile(suffix=".ico", delete=False) as tmp:
        tmp_path = tmp.name

    try:
        # Extract using wrestool (part of the wine tools)
        subprocess.run(
            ["wrestool", "-x", "-t14", "-o", tmp_path, str(exe_path)],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL
        )

        with open(tmp_path, "rb") as f:
            icon_bytes = f.read()
    finally:
        Path(tmp_path).unlink(missing_ok=True)

    # Convert bytes to a QIcon
    byte_array = QByteArray(icon_bytes)
    buffer = QBuffer(byte_array)
    buffer.open(QBuffer.OpenModeFlag.ReadOnly)
    pixmap = QPixmap()
    pixmap.loadFromData(buffer.data(), "ICO")
    buffer.close()
    return QIcon(pixmap)


def find_patched_games(installation_path: Path) -> list[str]:
    # Find patched games in the thcrap installation directory
    if not Path(installation_path / "thcrap").exists():
        log("[bright_red]thcrap installation path does not exist.[/bright_red]")
        return []

    patched_games = []

    games = Path(installation_path / "thcrap").glob("th* (en).exe")
    for game in games:
        log(
            f"[bright_green]Found patched game: [reset]{game.name}[/reset]")
        patched_games.append(game.name)

    return patched_games
