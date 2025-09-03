import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

Dialog {
    id: aboutDialog
    anchors.centerIn: parent

    modal: true
    standardButtons: Dialog.Ok
    title: qsTr("About Scarlet")
    padding: 16

    contentItem: RowLayout {
        spacing: 16

        Rectangle {
            width: 48
            height: 48
            color: "transparent"

            Image {
                anchors.fill: parent
                source: "qrc:/ScarletLauncher/resources/icon.png"
                fillMode: Image.PreserveAspectFit
            }
        }

        Label {
            text: qsTr("Graphical wrapper around thcrap for Linux.")
            wrapMode: Text.WordWrap
        }
    }
}