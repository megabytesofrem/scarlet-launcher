import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import ScarletLauncher 1.0 as Scarlet

StackView {
    id: root

    property var modelBinding
    property string viewMode: "list"

    Component.onCompleted: {
        push(viewMode === "list" ? listViewComponent : gridViewComponent);
    }

    onViewModeChanged: {
        replace(viewMode === "list" ? listViewComponent : gridViewComponent);
    }

    // List view component
    Component {
        id: listViewComponent
        ScrollView {
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: ScrollBar.AsNeeded

            ListView {
                id: gameList
                interactive: true
                flickableDirection: Flickable.VerticalFlick
                boundsBehavior: Flickable.StopAtBounds
                flickDeceleration: 1500
                maximumFlickVelocity: 500

                model: root.modelBinding // qmllint disable unqualified

                // qmllint disable unqualified
                delegate: ItemDelegate {
                    width: parent ? parent.width : 400
                    height: 30
                    highlighted: ListView.view.currentIndex === delegateIndex
                    onClicked: ListView.view.currentIndex = delegateIndex

                    property int delegateIndex: index
                    property var delegateModel: model

                    Rectangle {
                        anchors.fill: parent
                        color: highlighted ? Scarlet.Theme.primaryColor.darker(1.5) : Scarlet.Theme.backgroundColor.darker(1.2)

                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton
                            hoverEnabled: false
                            preventStealing: true

                            onClicked: {
                                gameList.currentIndex = delegateIndex;
                            }

                            onDoubleClicked: {
                                gameList.currentIndex = delegateIndex;
                                appWindow.launchGame(delegateModel.path);
                            }
                        }
                    }

                    Scarlet.GameListItem {
                        index: delegateIndex
                        modelBinding: delegateModel
                        onRemoveRequested: function (gamePath) {
                            for (let i = 0; i < root.modelBinding.count; i++) {
                                if (root.modelBinding.getGamePath(i) === gamePath) {
                                    root.modelBinding.remove(i);
                                    break;
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // Grid view component
    Component {
        id: gridViewComponent
        GridView {
            id: gameGrid
            cellWidth: 120
            cellHeight: 140
            currentIndex: -1

            model: root.modelBinding

            delegate: ItemDelegate {
                width: gameGrid.cellWidth
                height: gameGrid.cellHeight
                highlighted: gameGrid.currentIndex === delegateIndex
                onClicked: gameGrid.currentIndex = delegateIndex

                property int delegateIndex: index
                property var delegateModel: model

                Rectangle {
                    anchors.fill: parent
                    color: highlighted ? Scarlet.Theme.primaryColor.darker(1.5) : Scarlet.Theme.backgroundColor.darker(1.2)

                    MouseArea {
                        anchors.fill: parent
                        acceptedButtons: Qt.LeftButton
                        hoverEnabled: false
                        preventStealing: true

                        onClicked: {
                            gameGrid.currentIndex = delegateIndex;
                        }

                        onDoubleClicked: {
                            gameGrid.currentIndex = delegateIndex;
                            appWindow.launchGame(delegateModel.path);
                        }
                    }
                }

                Scarlet.GameGridItem {
                    itemIndex: delegateIndex
                    modelBinding: delegateModel
                }
            }
        }
    }
}
