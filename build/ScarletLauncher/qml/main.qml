import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ScarletLauncher 1.0 as Scarlet

ApplicationWindow {
    visible: true
    width: 400
    height: 300
    title: "Scarlet"
    color: Theme.backgroundColor

    // Placeholder
    ColumnLayout {
        visible: gameModel.count === 0
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 50
        
        spacing: 10

        Text {
            text: "No games were found."
            color: "white"
            font.pointSize: 16
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "If you're unsure, select 'Launch thcrap to scan'"
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

                text: "Launch thcrap to scan"
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                }
            }

            Scarlet.ThemedButton {
                text: "Add a game to manage manually"
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    // Call your scan function here, e.g.:
                    // backend.scanForGames()
                }
            }
        }
    }

    // Dialog {
    //     id: scanDialog
    //     title: "No Games Detected"
    //     visible: gameModel.count === 0
    //     modal: true
    //     anchors.centerIn: parent
    //     spacing: 10
    //     padding: 10

    //     background: Rectangle {
    //         color: Theme.backgroundColor.darker(1.2)
    //         radius: 5
    //         border.color: Theme.primaryColor.darker(1.2)
    //         border.width: 2
    //     }

    //     standardButtons: Dialog.Ok | Dialog.Cancel

    //     onAccepted: {
    //         // Call your scan function here, e.g.:
    //         // backend.scanForGames()
    //     }
    //     onRejected: {
    //         // Dialog closes automatically
    //     }

    //     contentItem: ColumnLayout {
    //         // Change dialog background to match theme

    //         spacing: 10
    //         Text {
    //             text: "No games were found. Would you like to scan for games now?"
    //             color: "white"
    //             wrapMode: Text.WordWrap
    //         }
    //     }
    // }

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

                    color: highlighted ? Theme.backgroundColor.darker(1.5) // selected color
                                       : Theme.backgroundColor.darker(1.2) // normal color
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

            Scarlet.ThemedButton {
                text: "About"
                Layout.fillWidth: true
                onClicked: showAbout()
            }
            Scarlet.ThemedButton {
                text: "Utilities"
                Layout.fillWidth: true
                onClicked: showUtilities()
            }
        }

        // Status display
        Scarlet.StatusDisplay {
            visible: gameModel.count > 0
            busy: true // bind later on
        }
    }

    // Expose connections
    Connections {
        target: gameModel
    }
}