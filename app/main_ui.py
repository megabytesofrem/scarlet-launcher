import os
from pathlib import Path
import shutil
import subprocess
import sys
import time

from PyQt6.QtCore import (
    QProcess, QProcessEnvironment, QThread, QTimer, Qt, pyqtSignal
)

from PyQt6.QtWidgets import (
    QApplication, QMainWindow, QLabel, QPushButton, QHBoxLayout, QVBoxLayout,
    QWidget, QMessageBox, QProgressBar, QListWidget, QListWidgetItem, QSizePolicy
)

from PyQt6.QtGui import QIcon, QPixmap

from app.utils import log, extract_icon_from_exe, find_patched_games, get_project_root, check_wine_installed

# Installation path to keep things tidy
installation_path = Path("~/.shrine-loader").expanduser()

# FIXME: Latest thcrap download URL, figure out how to get this automatically later
thcrap_download_url = "https://github.com/thpatch/thcrap/releases/download/2025-07-06/thcrap.zip"

# If True, place the wine prefix in the thcrap installation directory
use_selfcontained_wine_pfx = True
wine_prefix_path = installation_path / ".wine-thcrap" if use_selfcontained_wine_pfx else Path(
    "~/.wine-thcrap").expanduser()


class WinePrefixWorker(QThread):
    """
    Worker thread to setup the wine prefix and install dependencies.
    """

    # FIXME: This cannot ever be moved to another file because the signals
    # get messed up if they are not in the same file as 'MainWindow' for some reason.

    status_update = pyqtSignal(str)
    finished = pyqtSignal(object, object)

    def __init__(self, wine_prefix_path):
        super().__init__()
        self.wine_prefix_path = wine_prefix_path

    def run(self):
        env = os.environ.copy()
        env["WINEPREFIX"] = str(self.wine_prefix_path)
        env["WINEDEBUG"] = "-fixme"
        env["HOME"] = Path.home().as_posix()  # Ensure HOME is set correctly

        # Check if wine is installed before proceeding
        is_wine_present, return_message = check_wine_installed() 
        if not is_wine_present:
            self.finished.emit(False, return_message)
            return False

        try:
            subprocess.run(["mkdir", "-p", str(self.wine_prefix_path)],
                           check=True)
            
            subprocess.run(["wine", "wineboot", "--init"], check=True,
                           env=env)
        except subprocess.CalledProcessError as e:
            self.finished.emit(False, f"Failed to create Wine prefix: {e}")
            return False

        # Winetricks
        log("[bright_yellow]Installing Winetricks dependencies...[/bright_yellow]")
        self.status_update.emit("Installing Winetricks dependencies...")

        winetricks_command = ["winetricks", "--unattended", "--force", "dsound", "d3dx9_36", "dxdiag", "xact",
                              "dinput8", "vcrun2010", "vcrun2013", "corefonts", "dotnet48", "dotnet40"]

        try:
            process = subprocess.Popen(
                winetricks_command,
                env=env,
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                text=True,
                bufsize=1,
                universal_newlines=True
            )

            if process.stdout is not None:
                for line in process.stdout:
                    line = line.strip()
                    if line:
                        self.status_update.emit(line)
                        print(f"{line}")

            process.wait()
            if process.returncode != 0:

                # mypy will complain about stdout/stderr being IO[str], we don't care
                raise subprocess.CalledProcessError(
                    process.returncode, winetricks_command, 
                    output=process.stdout, # type: ignore[reportOptionalSubscript]
                    stderr=process.stderr # type: ignore[reportOptionalSubscript]
                )

            self.finished.emit(
                True, "Winetricks dependencies installed successfully.")
        except subprocess.CalledProcessError as e:
            self.finished.emit(
                False, f"Failed to install Winetricks dependencies: {e}")


def relaunch_self():
    python = sys.executable
    script = os.path.abspath(__file__)

    # Optional: print/log before restarting
    print("Relaunching...")

    # Re-executes the current script
    os.execl(python, python, "-m", "shrine_loader")


class MainWindow(QMainWindow):
    global installation_path, thcrap_download_url, use_selfcontained_wine_pfx, wine_prefix_path
    global log

    def __init__(self):
        super().__init__()
        self.setWindowTitle("Shrine Loader")
        self.setGeometry(100, 100, 400, 200)

        # Set window icon
        project_root = get_project_root()
        icon_path = os.path.join(project_root, "resources", "icon.png")

        print(f"Icon path {icon_path}")

        self.setWindowIcon(QIcon(icon_path))

        # Create a central widget
        central_widget = QWidget()
        self.setCentralWidget(central_widget)

        # Create a vertical layout
        self.layout: QVBoxLayout = QVBoxLayout()

        # List of games to launch
        self.view_container = QVBoxLayout()
        self.view_container.setContentsMargins(0, 0, 0, 0)

        self.list_widget = QListWidget()
        self.list_widget.setSelectionMode(
            QListWidget.SelectionMode.SingleSelection)
        self.list_widget.itemDoubleClicked.connect(self.launch_game)

        central_widget.setLayout(self.layout)

        # Find patched games and populate the list
        self.populate_game_list()

        self.layout.addWidget(customize_button := QPushButton(
            "Customize thcrap installation", self))

        self.layout.addWidget(about_button := QPushButton(
            "About Shrine Loader", self))

        customize_button.clicked.connect(self.launch_thcrap_customizer)
        about_button.clicked.connect(self.show_about)

        # Status progress
        self.status_container = QHBoxLayout()
        self.status_container.setContentsMargins(0, 0, 0, 0)
        self.status_container.setSpacing(10)

        self.status_label = QLabel("Waiting for user action", self)
        self.status_label.setAlignment(Qt.AlignmentFlag.AlignLeft)

        self.status_label.setSizePolicy(
            QSizePolicy.Policy.Expanding, QSizePolicy.Policy.Preferred)
        self.status_label.setMaximumWidth(400)

        self.status_bar = QProgressBar(self)
        self.status_bar.setFixedWidth(40)
        self.status_bar.setRange(0, 0)  # Indeterminate mode
        self.status_bar.setTextVisible(False)

        self.status_container.addWidget(self.status_label)
        self.status_container.addStretch(1)
        self.status_container.addWidget(self.status_bar)

        # Maybe it wasnt initlized before?
        self.wine_worker = None

        self.layout.addLayout(self.status_container)

    def show_dialog(self, title, message, icon=QMessageBox.Icon.Information):
        # Show a simple dialog with the message
        dialog = QMessageBox(self)
        dialog.setWindowTitle(title)
        dialog.setText(message)
        dialog.setIcon(icon)

        return dialog

    def show_about(self):
        about = QMessageBox(self)
        about.setWindowTitle("About Shrine Loader")

        # Set the text in rich HTML format (like Qt About dialogs)
        about.setText(
            "<h2>Shrine Loader</h2>"
            "<p>Graphical wrapper around thcrap for Linux.</p>"
            "<p>Version 1.0.0</p>"
            "<p>© 2025 Charlotte (Rem)</p>"
        )

        project_root = get_project_root()
        icon_path = os.path.join(project_root, "resources", "icon.png")

        pixmap = QPixmap(icon_path)
        about.setIconPixmap(pixmap.scaled(64, 64))  # scale if needed

        # Add only the OK button like standard About dialogs
        about.setStandardButtons(QMessageBox.StandardButton.Ok)

        about.exec()

    def symlink_steam_dir(self):
        steamapps_path = Path(
            "~/.local/share/Steam/steamapps/").expanduser().resolve()
        target = wine_prefix_path / "dosdevices" / "t:"

        if not target.exists():
            try:
                target.symlink_to(steamapps_path, target_is_directory=True)
                log(
                    f"[bright_green]Symlink created: {target} -> {steamapps_path}[/bright_green]")
            except Exception as e:
                log(f"[bright_red]Failed to create symlink: {e}[/bright_red]")
                self.show_dialog("Error",
                                 f"Failed to create symlink: {e}", icon=QMessageBox.Icon.Critical).exec()

    def extract_thcrap_files(self):
        try:
            shutil.unpack_archive(
                installation_path / "thcrap.zip", installation_path / "thcrap")

            self.status_label.setText("thcrap extracted successfully.")
            self.status_bar.setRange(0, 1)  # Set to determinate mode
            self.status_bar.setValue(1)
        except Exception as e:
            self.show_dialog("Error",
                             f"Failed to extract thcrap: {e}", icon=QMessageBox.Icon.Critical).exec()
            return False

    def setup_wine_environment(self):
        if not wine_prefix_path.exists():
            self.create_wine_prefix()

    def create_wine_prefix(self):
        self.status_label.setText("Creating Wine prefix...")
        self.status_bar.setRange(0, 0)  # Set to indeterminate mode
        self.status_bar.setValue(0)
        self.wine_worker = WinePrefixWorker(wine_prefix_path)
        self.wine_worker.finished.connect(self.after_wine_ready)
        self.wine_worker.status_update.connect(self.on_wine_status_update)

        # Check if wine is installed before starting the worker
        is_wine_present, return_message = check_wine_installed() 
        if not is_wine_present:
            self.show_dialog("Error", return_message,
                             icon=QMessageBox.Icon.Critical).exec()

            return
        else:
            self.wine_worker.start()

    def on_wine_status_update(self, line):
        # Update the status label with the message from the worker
        if "Installing" in line or "Executing" in line or "Using" in line or "Running" in line:
            self.status_label.setText(line)
            self.status_bar.setRange(0, 0)  # Set to indeterminate mode
            self.status_bar.setValue(0)

    def after_wine_ready(self, success, message):
        self.status_bar.setRange(0, 1)  # Set to determinate mode
        self.status_bar.setValue(1)
        self.status_label.setText(message)

        if success:
            log("[bright_green]Wine prefix created successfully.[/bright_green]")
        else:
            log(
                f"[bright_red]Failed to create Wine prefix: {message}[/bright_red]")
            self.show_dialog("Error", message,
                             icon=QMessageBox.Icon.Critical).exec()

        # Symlink steamapps for later on (T: drive)
        self.symlink_steam_dir()

        # Extract thcrap if it doesn't exist, and then launch the customizer for first time setup
        if not Path(installation_path / "thcrap").exists():
            self.download_extract_thcrap(
                callback=self.launch_thcrap_customizer)

    def download_extract_thcrap(self, callback=None):
        log("[bright_yellow]Downloading thcrap (The Touhou Community Reliant Automatic Patcher)...[/bright_yellow]")

        # Download thcrap
        progress = subprocess.run(["wget", thcrap_download_url, "-O", str(
            installation_path / "thcrap.zip")], capture_output=True)
        self.status_label.setText("Downloading thcrap...")
        self.status_bar.setRange(0, 0)  # Set to indeterminate mode
        self.status_bar.setValue(0)
        QApplication.processEvents()

        if progress.returncode != 0:
            self.show_dialog("Error", "Failed to download thcrap. Please check your internet connection.",
                             icon=QMessageBox.Icon.Critical).exec()
            return False

        log("[bright_green]Download complete. Extracting files...[/bright_green]")
        # Extract thcrap
        self.status_label.setText("Extracting thcrap...")
        self.status_bar.setRange(0, 0)  # Set to indeterminate mode
        self.status_bar.setValue(0)
        QApplication.processEvents()

        QTimer.singleShot(100, self.extract_thcrap_files)

        if callback:
            callback()

    def populate_game_list(self):
        patched_games = find_patched_games(installation_path=installation_path)
        for game in patched_games:
            try:
                icon = extract_icon_from_exe(
                    Path(installation_path / "thcrap") / game)
            except:
                icon = QIcon()  # Fallback to default icon if extraction fails

            item = QListWidgetItem(game)

            if "custom" in item.text():
                item.setForeground(Qt.GlobalColor.red)
                item.setToolTip(
                    f"Launch the customizer for {item.text().replace('custom_', '')}")
            else:
                item.setToolTip(f"Launch {item.text()}")

            item.setIcon(icon)
            self.list_widget.addItem(item)

        if len(patched_games) > 0:
            self.view_container.addWidget(
                label := QLabel("Select a game to launch", self))
            
            label.setAlignment(Qt.AlignmentFlag.AlignCenter)
            self.view_container.addWidget(self.list_widget)
        else:
            self.view_container.addWidget(label := QLabel("No patched games found.", self))
            label.setAlignment(Qt.AlignmentFlag.AlignCenter)

            self.view_container.addWidget(label := QLabel("If this is first time setup, please disregard and let the script run.", self))
            label.setAlignment(Qt.AlignmentFlag.AlignCenter)

            log("[bright_red]No patched games found. Please launch thcrap first and perform initial setup.[/bright_red]")

        # Add the view container to the main layout
        self.layout.addLayout(self.view_container)

    def launch_thcrap_customizer(self):
        env = os.environ.copy()
        env["WINEPREFIX"] = str(wine_prefix_path)
        env["HOME"] = Path.home().as_posix()  # Ensure HOME is set correctly

        thcrap_process = None

        try:
            thcrap_process = subprocess.Popen(
                ["wine", str(installation_path / "thcrap" / "thcrap.exe")], env=env)
            log("[bright_yellow]Launching thcrap customizer...[/bright_yellow]")

            self.show_dialog("Important", "It is very important that you make sure to select 'thcrap' as the installation path!",
                             icon=QMessageBox.Icon.Critical).exec()

        except subprocess.CalledProcessError as e:
            log(
                f"[bright_red]Failed to launch thcrap customizer: {e}[/bright_red]")
            self.show_dialog("Error",
                             "Failed to launch thcrap customizer. Please check your installation.",
                             icon=QMessageBox.Icon.Critical).exec()

            self.status_label.setText("Failed to launch thcrap customizer.")
            self.status_bar.setRange(0, 1)  # Set to determinate mode
            self.status_bar.setValue(1)

        # Wait for the process to finish
        if thcrap_process:
            thcrap_process.wait()
            if thcrap_process.returncode == 0:
                # Relaunch ourself to refresh the game list
                log("[bright_green]thcrap customizer finished successfully.[/bright_green]")
                self.status_label.setText(
                    "thcrap customizer finished successfully.")
                self.status_bar.setRange(0, 1)  # Set to determinate mode
                self.status_bar.setValue(1)

                time.sleep(1)  # Give some time for the process to finish
                relaunch_self()

    def launch_game(self, item):
        game_path = installation_path / "thcrap" / item.text()

        env = QProcessEnvironment.systemEnvironment()
        env.insert("WINEPREFIX", str(wine_prefix_path))
        # Ensure HOME is set correctly
        env.insert("HOME", Path.home().as_posix())
        env.insert("WINEDEBUG", "-fixme")

        try:
            self.status_label.setText(f"Launching {item.text()}...")

            process = QProcess(self)
            process.setProcessEnvironment(env)
            process.finished.connect(lambda exit_code, _: self.status_label.setText(
                f"Game launched with exit code {exit_code}."))
            process.start("wine", [str(game_path)])
            log(
                f"[bright_yellow]Launching [reset]{item.text()}[/reset][bright_yellow]...[reset][/reset]")
        except Exception as e:
            self.status_label.setText(f"Failed to launch {item.text()}.")
            log(f"[bright_red]Failed to launch game: {e}[/bright_red]")
