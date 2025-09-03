import QtQuick
import QtQuick.Controls

import ScarletLauncher 1.0

Button {
    property string iconName: ""

    property bool primaryAction: false
    property bool hasIcon: iconName && iconName !== ""

    function getIconSource() {
        if (hasIcon) {
            return "image://theme_icon/" + iconName
        }
        return ""
    }

    padding: 5

    background: Rectangle {
        color: primaryAction ? Theme.primaryColor.darker(1.25) : Theme.backgroundColor.darker(1.25)
        radius: Theme.buttonRadius
    }

    contentItem: Row {
        spacing: parent.iconName === "" ? 0 : 4

        Image {
            visible: hasIcon
            source: getIconSource()
            width: hasIcon ? 16 : 0
            height: 16
            fillMode: Image.PreserveAspectFit
        }

        Text {
            text: qsTr(parent.parent.text)
            color: Theme.textColor
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }

    hoverEnabled: true

    onHoveredChanged: {
        if (primaryAction) {
            background.color = hovered ? Theme.primaryColor.lighter(1.2) : Theme.primaryColor.darker(1.25)
        } else {
            background.color = hovered ? Theme.backgroundColor.lighter(1.2) : Theme.backgroundColor.darker(1.25)
        }
    }

    onPressedChanged: {
        if (primaryAction) {
            background.color = pressed ? Theme.primaryColor.lighter(1.2) : Theme.primaryColor.darker(1.25)
        } else {
            background.color = pressed ? Theme.backgroundColor.lighter(1.2) : Theme.backgroundColor.darker(1.25)
        }
    }
}