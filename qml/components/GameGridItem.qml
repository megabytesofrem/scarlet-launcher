import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

import ScarletLauncher 1.0 as Scarlet
import "helpers.js" as Helpers

Item {
    id: root

    property var modelBinding
    property string imageUrl
    property int itemIndex

    implicitWidth: 120
    implicitHeight: 140

    Rectangle {
        id: background
        anchors {
            fill: parent
            margins: 4
        }
        color: "#602323"
        radius: 8

        Image {
            id: coverImage
            visible: false

            source: root.imageUrl
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
        }

        MultiEffect {
            anchors.fill: parent
            source: coverImage
            maskEnabled: true
            maskSource: coverMask
        }

        Item {
            id: coverMask
            width: background.width
            height: background.height
            layer.enabled: true
            visible: false

            Rectangle {
                width: background.width
                height: background.height
                radius: background.radius
                color: "white"
            }
        }

        Rectangle {
            id: titleBackground
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            height: 30
            color: '#99000000'
            radius: 0
            border.color: "black"
            border.width: 1
            antialiasing: true
        }

        Text {
            id: titleText
            width: parent.width - 10
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
                bottomMargin: 5
            }

            text: root.modelBinding ? Helpers.convertFriendlyName(root.modelBinding.name) || "Unknown Game" : "Unknown Game"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            layer.enabled: true
            color: "white"
        }

        // Menu
        Menu {
            id: contextMenu

            MenuItem {
                text: "Launch Game"
                onTriggered: {
                    if (root.modelBinding) {
                        appWindow.launchGame(root.modelBinding.path);
                    }
                }
            }

            MenuItem {
                text: "Launch Configurator"
                onTriggered: {
                    if (root.modelBinding) {
                        appWindow.launchConfigurator(root.modelBinding.path);
                    }
                }
            }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            cursorShape: Qt.PointingHandCursor
            hoverEnabled: false
            preventStealing: true

            onClicked: function (mouse) {
                if (mouse.button === Qt.RightButton) {
                    contextMenu.popup();
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("modelBinding:", modelBinding);

        if (modelBinding) {
            const friendlyName = Helpers.convertFriendlyName(modelBinding.name);
            console.log("friendlyName for index", root.itemIndex, ":", friendlyName);  // <-- Add this

            Helpers.extractGridImage(friendlyName, function (url) {
                if (url) {
                    imageUrl = url;
                    coverImage.fillMode = Image.PreserveAspectCrop;
                } else {
                    // Fallback to icon if no grid image found
                    imageUrl = "image://icons/" + root.modelBinding.path;
                    coverImage.fillMode = Image.Pad;
                }
            });
        }
    }
}
