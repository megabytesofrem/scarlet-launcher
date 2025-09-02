import QtQuick 2.15
import QtQuick.Controls 2.15

import ScarletLauncher 1.0

Button {
    background: Rectangle {
        color: Theme.backgroundColor.darker(1.25)
    }

    contentItem: Text {
        text: qsTr(parent.text)
        color: Theme.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    hoverEnabled: true

    onHoveredChanged: {
        background.color = hovered ? Theme.backgroundColor.lighter(1.5) : Theme.backgroundColor.darker(1.25)
    }

    onPressedChanged: {
        background.color = pressed ? Theme.backgroundColor.lighter(1.5) : Theme.backgroundColor.darker(1.25)
    }
}
