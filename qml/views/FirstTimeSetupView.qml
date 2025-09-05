import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// import QtQuick.Particles 2.0

Item {
    id: root
    anchors.fill: parent

    // --- BACKGROUND LAYER ---
    
    Rectangle {
        id: backgroundRect
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: setupText.y - 10 // Leave space above the setup text

        z: 0

        color: "#0a090b"

        ShaderEffect {
            anchors.fill: parent
            
            // Properties that get passed to the shaders as uniforms
            property real time: 0.0        // Time for animation
            property size resolution: Qt.size(root.width, root.height)
            
            // Load compiled shaders (.qsb files)
            vertexShader: "qrc:/shaders/qml/shader/bullet.vert.qsb"
            fragmentShader: "qrc:/shaders/qml/shader/bullet.frag.qsb"
            
            // Animation to update time property
            NumberAnimation on time {
                from: 0.0
                to: 1000.0
                duration: 1000000  // Very long duration for continuous animation
                loops: Animation.Infinite
            }
            
            // Update resolution when window size changes
            onWidthChanged: resolution = Qt.size(width, height)
            onHeightChanged: resolution = Qt.size(width, height)
        }
    }

    // --- CONTENT LAYER ---
    Item {
        id: contentLayer
        anchors.fill: parent
        z: 1

        ColumnLayout {
            anchors.fill: parent
            spacing: 10
            z: 2

            // Top spacer to vertically center content
            Item { Layout.fillHeight: true }

            Text {
                id: setupText
                text: "Scarlet is setting up a Wine prefix..."
                color: "white"
                font.pointSize: 16
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Text {
                text: "This may take a while, so please be patient."
                wrapMode: Text.WordWrap
                color: "#aeaeae"
                font.pointSize: 10
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            // Item { Layout.fillHeight: true } // bottom spacer

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
                        color: "transparent"
                        border.width: 1
                        border.color: "#434343"
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
    }
}