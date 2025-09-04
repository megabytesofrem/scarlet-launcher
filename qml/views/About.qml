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

        TextArea {
            text: "THCRAP powered launcher for Touhou games for Linux<br>" +
                  "written in QT/QML and C++.<br><br>" +
                  "Scarlet is free software, but if you want to <a href=\"https://liberapay.com/megabytesofrem/donate\">support me you can</a>"
            color: "white"
            readOnly: true
            wrapMode: Text.WrapAnywhere
            textFormat: TextEdit.RichText
            onLinkActivated: Qt.openUrlExternally(link)
        }
    }
}