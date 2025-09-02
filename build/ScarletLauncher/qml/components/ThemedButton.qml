import QtQuick
import QtQuick.Controls

import ScarletLauncher 1.0

Button {
    background: Rectangle {
        color: Theme.backgroundColor.darker(1.25)
        radius: Theme.buttonRadius
    }

    contentItem: Text {
        text: qsTr(parent.text)
        color: Theme.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    hoverEnabled: true

    onHoveredChanged: {
        background.color = hovered ? Theme.backgroundColor.lighter(1.2) : Theme.backgroundColor.darker(1.25)
    }

    onPressedChanged: {
        background.color = pressed ? Theme.backgroundColor.lighter(1.2) : Theme.backgroundColor.darker(1.25)
    }
}
