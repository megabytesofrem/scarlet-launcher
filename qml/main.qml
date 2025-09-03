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

    // Placeholder for first time setup
    ColumnLayout {
        visible: gameModel.count === 0 && isFirstTimeSetup
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 50
        
        spacing: 10

        Text {
            text: "Scarlet is setting up a Wine prefix..."
            color: "white"
            font.pointSize: 16
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "This may take a while, so please be patient."
            wrapMode: Text.WordWrap
            color: "#aeaeae"
            font.pointSize: 10
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }
    }

    // Placeholder for empty games
    ColumnLayout {
        visible: gameModel.count === 0 && !isFirstTimeSetup
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 50
        
        spacing: 10

        Image {
            source: "qrc:/ScarletLauncher/resources/icon.png"
            sourceSize.width: 100
            sourceSize.height: 100
            fillMode: Image.PreserveAspectFit

            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "No games were found."
            color: "white"
            font.pointSize: 16
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "If you're unsure, select 'Find Steam games with THCRAP'"
            color: "#aeaeae"
            font.pointSize: 10
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        RowLayout {
            spacing: 10
            Scarlet.ThemedButton {
                id: scanButton

                property bool selected;
                background: Rectangle {
                    property real animAlpha: 1.0

                    color: Theme.backgroundColor.darker(1.25)
                    radius: Theme.buttonRadius
                    border.color: Qt.rgba(Theme.primaryColor.r, Theme.primaryColor.g, Theme.primaryColor.b, animAlpha)
                
                    SequentialAnimation on animAlpha {
                        loops: Animation.Infinite
                        running: !scanButton.selected
                        NumberAnimation { to: 0.0; duration: 500; easing.type: Easing.InOutQuad }
                        NumberAnimation { to: 1.0; duration: 500; easing.type: Easing.InOutQuad }
                    }
                
                }

                text: "Find Steam games with THCRAP"
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    appWindow.launchTHCRAP();
                }
            }

            Scarlet.ThemedButton {
                text: "Add game manually"
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    const file = appWindow.openNativeDialog("Executables (*.exe);;All files (*)")
                    if (file) {
                        appWindow.addGameFromPath(file)
                    }
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        Layout.margins: 5
        spacing: 10

        // Game list
        ListView {
            id: gameList
            interactive: false
            visible: gameModel.count > 0
            model: gameModel
            Layout.fillHeight: true
            Layout.fillWidth: true

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

                Scarlet.Row {
                    index: index
                    onRemoveRequested: function(idx) {
                        gameModel.remove(idx)
                    }
                }
            }
        }

        // Spacer to push buttons to bottom
        Item {
            Layout.fillHeight: true
        }

        // Buttons
        RowLayout {
            visible: gameModel.count > 0
            
            spacing: 10
            Layout.margins: 5

            Item { Layout.fillWidth: true }

            Scarlet.ThemedButton {
                text: "Add Game"
                onClicked: {
                    const file = appWindow.openNativeDialog("Executables (*.exe);;All files (*)")
                    if (file) {
                        appWindow.addGameFromPath(file)
                    }
                }
            }

            Scarlet.ThemedButton {
                text: "About"
                onClicked: showAbout()
            }
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