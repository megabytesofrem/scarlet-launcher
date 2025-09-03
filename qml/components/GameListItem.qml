import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ScarletLauncher 1.0

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

    function convertFriendlyName(name) {
        if (!name) return "Unknown Game";
        
        // Extract th## pattern from anywhere in the string
        var match = name.match(/th(\d{2})/i);
        if (match) {
            var gameId = "th" + match[1];
            notTouhou = false;
            return getTouhouName(gameId, name);
        } else {
            // Not a touhou game, mark it as such
            notTouhou = true;
        }
        
        return name;
    }

    function getTouhouName(gameId, originalName) {
        var gameNames = {
            "th06": "Touhou 6: The Embodiment of Scarlet Devil",
            "th07": "Touhou 7: Perfect Cherry Blossom",
            "th08": "Touhou 8: Imperishable Night",
            "th09": "Touhou 9: Phantasmagoria of Flower View",
            "th10": "Touhou 10: Mountain of Faith",
            "th11": "Touhou 11: Subterranean Animism",
            "th12": "Touhou 12: Undefined Fantastic Object",
            "th13": "Touhou 13: Ten Desires",
            "th14": "Touhou 14: Double Dealing Character",
            "th15": "Touhou 15: Legacy of Lunatic Kingdom",
            "th16": "Touhou 16: Hidden Star in Four Seasons",
            "th17": "Touhou 17: Wily Beast and Weakest Creature",
            "th18": "Touhou 18: Unconnected Marketeers",
            "th19": "Touhou 19: Unfinished Dream of All Living Ghost",
            "th20": "Touhou 20: Fossilized Wonders"
        };
        
        var friendlyName = gameNames[gameId] || originalName;
        
        // Add (EN) suffix if original name contains "en"
        if (originalName.toLowerCase().includes("en")) {
            localization = "en";
        }
        
        return friendlyName;
    }

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
                return "qrc:/ScarletLauncher/resources/ui/flag_" + localization + ".png"
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
        text: modelBinding ? convertFriendlyName(modelBinding.name) || "Unknown Game" : "Unknown Game"
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
        }

        Button {
            icon.name: "edit-delete"
            icon.color: "red"
            Layout.fillHeight: true
            Layout.preferredWidth: height

            onClicked: removeRequested(modelBinding.path)

            background: Rectangle {
                color: Theme.backgroundColor.darker(1.2)
                height: parent.height
            }
        }
    }
}