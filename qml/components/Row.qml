import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ScarletLauncher 1.0

RowLayout {
    property var gameData: model
    property int index

    signal removeRequested(int index)

    anchors.fill: parent
    height: 30

    function convertFriendlyName(name) {
        if (!name) return "Unknown Game";
        
        // Extract th## pattern from anywhere in the string
        var match = name.match(/th(\d{2})/i);
        if (match) {
            var gameId = "th" + match[1];
            return getTouhouName(gameId, name);
        }
        
        return name; // Return original if no th## found
    }

    function getTouhouName(gameId, originalName) {
        var gameNames = {
            "th06": "Touhou 6: The Embodiment of Scarlet Devil",
            "th07": "Touhou 7: Perfect Cherry Blossom", // Fixed this one
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
            friendlyName += " (EN)";
        }
        
        return friendlyName;
    }

    Image { 
        source: "image://icons/" + model.path
        width: 24
        height: 24
    }

    Text {
        text: convertFriendlyName(model.name) || "Unknown Game"
        color: "white"
        Layout.fillWidth: true
    }
    Button {
        icon.name: "edit-delete"
        icon.color: "red"
        Layout.fillHeight: true
        Layout.preferredWidth: height

        onClicked: removeRequested(index)

        background: Rectangle {
            color: Theme.backgroundColor.darker(1.2)
            height: parent.height
        }
    }
}