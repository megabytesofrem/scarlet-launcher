import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ScarletLauncher 1.0
import "helpers.js" as Helpers

RowLayout {
    // Model binding from main.qml
    property var modelBinding
    
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
        width: 24
        height: 24
        color: "transparent"

        MouseArea {
            id: iconHoverArea
            anchors.fill: parent
            hoverEnabled: true
        }

        Image {
            anchors.fill: parent
            source: {
                if (notTouhou) {
                    return "qrc:/ScarletLauncher/resources/ui/icon_warning.png"
                }
                return "https://flagcdn.com/w20/%1.png".arg(localization)
            }
            fillMode: Image.PreserveAspectFit
        }

        // Tooltip
        ToolTip.visible: iconHoverArea.containsMouse
        ToolTip.text: notTouhou ? "This game does not appear to be a Touhou game." 
                                : localization == "jp" 
                                ? "Original localization" : "THCRAP localization (" + localization + ")"
    }

    Rectangle {
        width: 24
        height: 24
        color: "transparent"

        Image {
            anchors.fill: parent
            source: modelBinding ? "image://icons/" + modelBinding.path : ""
            fillMode: Image.PreserveAspectFit
        }
    }

    Text {
        text: modelBinding ? Helpers.convertFriendlyName(modelBinding.name) || "Unknown Game" : "Unknown Game"
        color: "white"
        Layout.fillWidth: true
    }

    RowLayout {
        spacing: 0

        Button {
            icon.name: "settings-configure"
            icon.color: "white"
            visible: rowHasConfigurator
            Layout.fillHeight: true
            Layout.preferredWidth: height

            onClicked: {
                console.log("=== BUTTON CLICK DEBUG ===");
                console.log("Row index:", index);
                console.log("Model name:", modelBinding ? modelBinding.name : "undefined");
                console.log("Model path:", modelBinding ? modelBinding.path : "undefined");
                
                if (modelBinding) {
                    appWindow.launchConfigurator(modelBinding.path)
                }
            }

            background: Rectangle {
                color: Theme.backgroundColor.darker(1.2)
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

            onClicked: removeRequested(modelBinding.path)

            background: Rectangle {
                color: Theme.backgroundColor.darker(1.2)
                height: parent.height
            }

            ToolTip.visible: hovered
            ToolTip.text: "Remove game (does not uninstall)"
        }
    }
}