import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    spacing: 10
    Layout.fillWidth: true

    Item {
        Layout.preferredHeight: 32
    }

    Text {
        id: text1

        text: "Scarlet is setting up a Wine prefix..."
        color: "white"
        font.pointSize: 16
        horizontalAlignment: Text.AlignHCenter
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
    }

    Text {
        id: text2

        text: "This may take a while, so please be patient."
        wrapMode: Text.WordWrap
        color: "#aeaeae"
        font.pointSize: 10
        horizontalAlignment: Text.AlignHCenter
        Layout.alignment: Qt.AlignHCenter
        Layout.fillWidth: true
    }

    Item {
        Layout.fillHeight: true
        Layout.minimumHeight: 50
    }

    // Live log
    ScrollView {
        id: logScrollView
        Layout.fillWidth: true
        Layout.preferredHeight: parent.height * 0.25
        Layout.minimumHeight: 100

        clip: true
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

        // Throttle updates to reduce lag
        property string pendingText: ""
        property bool updateScheduled: false

        function scheduleUpdate(newText) {
            pendingText = newText
            if (!updateScheduled) {
                updateScheduled = true
                updateTimer.start()
            }
        }

        Timer {
            id: updateTimer
            interval: 100
            onTriggered: {
                logArea.text = logScrollView.pendingText
                logScrollView.updateScheduled = false

                // Auto-scroll to bottom
                Qt.callLater(function() {
                    logArea.cursorPosition = logArea.length - 1
                })
            }
        }

        TextArea {
            id: logArea
            Layout.fillWidth: true

            readOnly: true
            wrapMode: TextArea.Wrap
            selectByMouse: true
            font.family: "monospace"
            font.pointSize: 10
            color: "white"

            background: Rectangle {
                color: "black"
            }

            text: ""
        }

        Connections {
            target: appWindow

            function onLogMessageChanged() {
                logScrollView.scheduleUpdate(appWindow.logMessage || "")
            }
        }
    }
}