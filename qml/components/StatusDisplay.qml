import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ScarletLauncher 1.0

RowLayout {
    property string statusValue: ""
    property bool busy: true

    spacing: 10

    Layout.margins: 5

    Text {
        text: statusValue == "" ? "Status: Idle" : "Status: " + statusValue
        Layout.fillWidth: true
        color: "white"
    }

    ProgressBar {
        id: progress
        from: 0
        to: 1
        width: 40
        height: 10
        indeterminate: true

        // Override background
        background: Rectangle {
            color: Theme.backgroundColor
            radius: 10
        }

        // Override the “fill” for both determinate and indeterminate
        contentItem: Item {
            anchors.fill: parent

            Rectangle {
                id: chunk
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: parent.width * 0.3
                x: 0
                color: Theme.primaryColor
                radius: 2
            }

            NumberAnimation {
                id: idleAnim
                target: chunk
                property: "x"
                from: 0
                to: parent.width
                duration: 1200
                loops: Animation.Infinite
                running: true
                easing.type: Easing.Linear
            }

            Component.onCompleted: {
                idleAnim.running = true
            }
        }
    }
}
