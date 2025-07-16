#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Shrine Loader
# Graphical Linux wrapper around the Touhou Community Reliant Automatic Patcher.

import os
import sys

from PyQt6.QtCore import QTimer
from PyQt6.QtWidgets import QApplication
from PyQt6.QtGui import QIcon

from app.main_ui import MainWindow

if __name__ == "__main__":
    app = QApplication(sys.argv)

    # Set window icon
    # FIXME: Icon is reset to the default icon on startup when using Wayland
    icon_path = os.path.join(os.path.dirname(
        __file__), "resources/icon.png")
    app.setWindowIcon(QIcon(icon_path))

    app.setApplicationName("shrine-loader")
    app.setApplicationDisplayName("Shrine Loader")
    app.setOrganizationName("Rem")

    window = MainWindow()
    window.show()

    # Schedule Wine setup after the event loop starts
    QTimer.singleShot(100, window.setup_wine_environment)

    sys.exit(app.exec())
