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


def extract_icon_from_exe(exe_path) -> QIcon:
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
