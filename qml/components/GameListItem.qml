import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ScarletLauncher 1.0 as Scarlet
import "helpers.js" as Helpers

RowLayout {
    id: root

    // Model binding from main.qml
    property var modelBinding
    property var appWindow: appWindow

    // Localization. Default is jp, but will be changed when auto-detected
    property string localization: "jp"

    // Indicates if the game is not a Touhou game, incase the user made a mistake
    property bool notTouhou: false
    property bool rowHasConfigurator: modelBinding ? modelBinding.hasConfigurator : false
    property int index

    signal removeRequested(string gamePath)

    anchors.fill: parent
    height: 30

    // Use rectangle to force the size to 24x24
    Rectangle {
        implicitWidth: 24
        implicitHeight: 24
        color: "transparent"

        MouseArea {
            id: iconHoverArea
            anchors.fill: parent
            hoverEnabled: true
        }

        Image {
            anchors.fill: parent
            source: {
                if (Helpers.notTouhou) {
                    return "qrc:/ScarletLauncher/resources/ui/icon_warning.png";
                }
                return "https://flagcdn.com/w20/%1.png".arg(Helpers.localization);
            }
            fillMode: Image.PreserveAspectFit
        }

        // Tooltip
        ToolTip.visible: iconHoverArea.containsMouse
        ToolTip.text: Helpers.notTouhou ? "This game does not appear to be a Touhou game." : Helpers.localization == "jp" ? "Original localization" : "THCRAP localization (" + Helpers.localization + ")"
    }

    Rectangle {
        implicitWidth: 24
        implicitHeight: 24
        color: "transparent"

        Image {
            anchors.fill: parent
            source: root.modelBinding ? "image://icons/" + root.modelBinding.path : ""
            fillMode: Image.PreserveAspectFit
        }
    }

    Text {
        text: root.modelBinding ? Helpers.convertFriendlyName(root.modelBinding.name) || "Unknown Game" : "Unknown Game"
        color: "white"
        Layout.fillWidth: true
    }

    RowLayout {
        spacing: 0

        Button {
            icon.name: "settings-configure"
            icon.color: "white"
            visible: root.rowHasConfigurator
            Layout.fillHeight: true
            Layout.preferredWidth: height

            onClicked: {
                if (root.modelBinding) {
                    root.appWindow.launchConfigurator(root.modelBinding.path);
                }
            }

            background: Rectangle {
                color: Scarlet.Theme.backgroundColor.darker(1.2)
                height: parent.height
            }

            ToolTip.visible: hovered
            ToolTip.text: "Launch game configurator"
        }

        Button {
            icon.name: "list-remove-symbolic"
            icon.color: "red"
            Layout.fillHeight: true
            Layout.preferredWidth: height

            onClicked: root.removeRequested(root.modelBinding.path)

            background: Rectangle {
                color: Scarlet.Theme.backgroundColor.darker(1.2)
                height: parent.height
            }

            ToolTip.visible: hovered
            ToolTip.text: "Remove game (does not uninstall)"
        }
    }
}
