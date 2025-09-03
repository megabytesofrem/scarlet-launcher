import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    spacing: 10

    Text {
        text: "Scarlet is setting up a Wine prefix..."
        color: "white"
        font.pointSize: 16
        horizontalAlignment: Text.AlignHCenter
        Layout.alignment: Layout.AlignHCenter
    }

    Text {
        text: "This may take a while, so please be patient."
        wrapMode: Text.WordWrap
        color: "#aeaeae"
        font.pointSize: 10
        horizontalAlignment: Text.AlignHCenter
        Layout.alignment: Qt.AlignHCenter
    }
}