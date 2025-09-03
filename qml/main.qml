import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import ScarletLauncher 1.0 as Scarlet

ApplicationWindow {
    visible: true
    width: 400
    height: 300
    title: "Scarlet"
    color: Theme.backgroundColor

    palette.highlight: Theme.primaryColor

    property string currentStatus: "Idle"
    property bool isFirstTimeSetup: false
    property bool isWorking: false

    // Events
    Component.onCompleted: {
        appWindow.appLoaded()
    }

    // Connect to AppWindow signals    
    Connections {
        target: appWindow

        onFirstTimeSetup: isFirstTimeSetup = true

        onStatusChanged: function(status) {
            currentStatus = status
        }

        onProgressChanged: function(visible) {
            isWorking = visible
        }

        onWineSetupFinished: function(success) {
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

    Scarlet.About { id: aboutDialog }

    header: ToolBar {
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

                // Layout.margins: 8

                background: Rectangle {
                    color: Theme.primaryColor.darker(1.25)
                }

                onClicked: {
                    const file = appWindow.openNativeDialog("Executables (*.exe);;All files (*)")
                    if (file) {
                        appWindow.addGameFromPath(file)
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
                    appWindow.launchTHCRAP()
                }
            }

            Item { Layout.fillWidth: true }

            ToolButton {
                id: aboutButton
                text: "About"
                icon.name: "info-symbolic"

                padding: 8
                rightPadding: 12

                onClicked: {
                    aboutDialog.open()
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
            sourceComponent: Scarlet.FirstTimeSetupView {}
        }

        // Empty games view
        Loader {
            active: gameModel.count === 0 && !isFirstTimeSetup
            Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
            Layout.preferredWidth: active ? implicitWidth : 0
            Layout.preferredHeight: active ? implicitHeight : 0
            sourceComponent: Scarlet.EmptyGamesView {}
        }

        // Game list view

        ScrollView {
            padding: 0
            Layout.margins: 5
            Layout.fillHeight: true
            Layout.fillWidth: true

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ListView {
                id: gameList
                interactive: true
                flickableDirection: Flickable.VerticalFlick
                boundsBehavior: Flickable.StopAtBounds
                flickDeceleration: 1500    // Make flick stop quickly
                maximumFlickVelocity: 500  // Reduce flick sensitivity

                visible: gameModel.count > 0
                model: gameModel

                delegate: ItemDelegate {
                    width: parent ? parent.width : 400
                    height: 30
                    highlighted: ListView.view.currentIndex === index
                    onClicked: ListView.view.currentIndex = index

                    Rectangle {
                        anchors.fill: parent

                        color: highlighted ? Theme.primaryColor.darker(1.5) // selected color
                                           : Theme.backgroundColor.darker(1.2) // normal color

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            hoverEnabled: false
                            preventStealing: true

                            onClicked: {
                                gameList.currentIndex = index
                            }

                            onDoubleClicked: {
                                gameList.currentIndex = index
                                appWindow.launchGame(model.path)
                            }
                        }
                    }

                    Scarlet.GameListItem {
                        index: index
                        modelBinding: model
                        onRemoveRequested: function(gamePath) {
                            for (let i = 0; i < gameModel.count; i++) {
                                if (gameModel.getGamePath(i) === gamePath) {
                                    gameModel.remove(i)
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }

        // Spacer to push buttons to bottom
        Item {
            visible: gameModel.count === 0
            Layout.fillHeight: true
        }

        // Status display
        Scarlet.StatusDisplay {
            visible: isWorking || currentStatus !== "Idle"
            statusValue: currentStatus
            busy: true // bind later on
        }
    }

    Connections {
        target: gameModel
    }
}