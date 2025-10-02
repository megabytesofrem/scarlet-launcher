import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ScarletLauncher 1.0 as Scarlet

RowLayout {
    id: root

    property string statusValue: ""
    property bool busy: true

    spacing: 10

    Layout.margins: 5

    Text {
        text: root.statusValue == "" ? "Status: Idle" : "Status: " + root.statusValue
        Layout.fillWidth: true
        color: "white"
    }

    ProgressBar {
        id: progress
        from: 0
        to: 1
        implicitWidth: 40
        implicitHeight: 10
        indeterminate: true

        // Override background
        background: Rectangle {
            color: Scarlet.Theme.backgroundColor
            radius: 10
        }

        // Override the “fill” for both determinate and indeterminate
        contentItem: Item {
            id: contentItem
            anchors.fill: parent

            Rectangle {
                id: chunk
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * 0.3
                x: 0
                color: Scarlet.Theme.primaryColor
                radius: 2
            }

            NumberAnimation {
                id: idleAnim
                target: chunk
                property: "x"
                from: 0
                to: contentItem.width
                duration: 1200
                loops: Animation.Infinite
                running: true
                easing.type: Easing.Linear
            }

            Component.onCompleted: {
                idleAnim.running = true;
            }
        }
    }
}
