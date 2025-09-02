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

    // Image { source: model.icon; width: 24; height: 24 }
    Text {
        text: gameData.name || "Unknown Game"
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