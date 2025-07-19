#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Shrine Loader
# Graphical Linux wrapper around the Touhou Community Reliant Automatic Patcher.

import os
import signal
import sys

from PyQt6.QtCore import QTimer
from PyQt6.QtWidgets import QApplication
from PyQt6.QtGui import QIcon

from app.main_ui import MainWindow, thcrap_download_url
from app.utils import get_project_root

if __name__ == "__main__":

    # Let Qt post a Quit event on Ctrl+C
    signal.signal(signal.SIGINT, signal.SIG_DFL)

    app = QApplication(sys.argv)

    # Set window icon
    project_root = get_project_root()
    icon_path = os.path.join(project_root, "resources", "icon.png")

    print(f"Icon path {icon_path}")
    app.setWindowIcon(QIcon(icon_path))

    app.setApplicationName("shrine-loader")
    app.setApplicationDisplayName("Shrine Loader")
    app.setOrganizationName("Rem")

    window = MainWindow()
    window.show()

    # Schedule Wine setup after the event loop starts
    QTimer.singleShot(100, window.setup_wine_environment)

    sys.exit(app.exec())
