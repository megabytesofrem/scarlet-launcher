import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ScarletLauncher 1.0 as Scarlet

ColumnLayout {
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

                color: Scarlet.Theme.backgroundColor.darker(1.25)
                radius: Scarlet.Theme.buttonRadius
                border.color: Qt.rgba(Scarlet.Theme.primaryColor.r, Scarlet.Theme.primaryColor.g, Scarlet.Theme.primaryColor.b, animAlpha)

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