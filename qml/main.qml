import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import ScarletLauncher 1.0 as Scarlet

ApplicationWindow {
    id: rootWindow

    visible: true
    minimumWidth: 500
    minimumHeight: 300
    title: "Scarlet"
    color: Theme.backgroundColor

    palette.highlight: Theme.primaryColor

    property string currentStatus: "Idle"
    property string viewMode: "list"

    property bool isFirstTimeSetup: false
    property bool isWorking: false

    // Events
    Component.onCompleted: {
        appWindow.appLoaded();
    }

    // Connect to AppWindow signals
    Connections {
        target: appWindow

        onFirstTimeSetup: isFirstTimeSetup = true

        onStatusChanged: function (status) {
            currentStatus = status;
        }

        onProgressChanged: function (visible) {
            isWorking = visible;
        }

        onWineSetupFinished: function (success) {
            if (success) {
                // Wine setup completed successfully
                console.log("Wine setup completed successfully.");
                isFirstTimeSetup = false;
            } else {
                // Wine setup failed
                console.log("Wine setup failed.");
            }
        }
    }

    Scarlet.About {
        id: aboutDialog
    }

    header: ToolBar {
        visible: !isFirstTimeSetup && gameModel.count > 0
        padding: 0

        background: Rectangle {
            color: Theme.backgroundColor.darker(1.5)
            border.width: 0
        }

        contentItem: RowLayout {
            anchors.fill: parent
            spacing: 0

            ToolButton {
                id: addButton
                text: "Add Game"
                icon.name: "add"
                padding: 8
                visible: !isFirstTimeSetup

                // Layout.margins: 8

                background: Rectangle {
                    color: Theme.primaryColor.darker(1.25)
                }

                onClicked: {
                    const file = appWindow.openNativeDialog("Executables (*.exe);;All files (*)");
                    if (file) {
                        appWindow.addGameFromPath(file);
                    }
                }
            }

            ToolButton {
                id: relaunchButton
                text: "Relaunch THCRAP"
                icon.name: "wine-glass-symbolic"
                padding: 8
                visible: gameModel.count > 0 && !isFirstTimeSetup
                onClicked: {
                    appWindow.launchTHCRAP();
                }
            }

            ToolButton {
                id: viewModeButton
                icon.name: viewMode === "grid" ? "view-list-symbolic" : "view-grid-symbolic"
                padding: 8
                onClicked: {
                    viewMode = viewMode === "grid" ? "list" : "grid";
                    console.log("main.qml viewMode changed to:", viewMode);  // Add this debug
                }
            }

            Item {
                Layout.fillWidth: true
            }

            ToolButton {
                id: aboutButton
                text: "About"
                icon.name: "info-symbolic"

                padding: 8
                rightPadding: 12

                onClicked: {
                    aboutDialog.open();
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        // First time setup
        Loader {
            active: gameModel.count === 0 && isFirstTimeSetup
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: active
            sourceComponent: Scarlet.FirstTimeSetupView {}
        }

        // Empty games view
        Loader {
            active: gameModel.count === 0 && !isFirstTimeSetup
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: active
            sourceComponent: Scarlet.EmptyGamesView {}
        }

        // Content view
        Scarlet.ContentView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: gameModel.count > 0 && !isFirstTimeSetup

            modelBinding: gameModel
            viewMode: rootWindow.viewMode
        }

        // Status display
        Scarlet.StatusDisplay {
            Layout.fillWidth: true
            Layout.preferredHeight: 24
            visible: !isFirstTimeSetup && (isWorking || currentStatus !== "Idle")
            statusValue: currentStatus
            busy: true // bind later on
        }
    }

    Connections {
        target: gameModel
    }
}
