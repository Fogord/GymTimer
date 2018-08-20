import QtQuick 2.0
import QtQuick.Controls.Material 2.2

Item {
    width: parent.width
    height: 160
    clip: false

    signal cansel;
    signal ok;

    property double             time:  0
    property color      defaultColor:  "#F44336"
    property int      choosenColorId:  0
    property string choosenColorName:  ""

    function setTime() {
        listMinutes.currentIndex = Math.floor(time/60)
        listSeconds.currentIndex = time%60
    }
    function setColor() {
        listColors.currentIndex = choosenColorId
    }

    function getItem (){
        var retObj = {}
        retObj.seconds = listMinutes.currentIndex * 60 + listSeconds.currentIndex
        retObj.color = choosenColorName
        retObj.colorId = choosenColorId
        return retObj;
    }

    onTimeChanged: {
        setTime()
    }

    onChoosenColorIdChanged: {
        setColor()
    }

    Item {
        id: minutes

        width: parent.width/3
        height: 82

        anchors.left: parent.left

        Item {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: parent.height

            ListView {
                id: listMinutes
                anchors.fill: parent
                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: height/3
                preferredHighlightEnd: height/3
                clip: true
                model: 60
                delegate: Text {
                    font.pixelSize: 18;
                    color: defaultColor
                    text: {
                        if (index/10 < 1) { "0" + index } else { index }
                    }
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: defaultColor }
                    GradientStop { position: 0.2; color: "#00000000"  }
                    GradientStop { position: 0.8; color: "#00000000"  }
                    GradientStop { position: 1.0; color: defaultColor }
                }
            }

            Text {
                id: captionMinutes
                text: "min"
                anchors.right: parent.right
                anchors.rightMargin: 2
                color: defaultColor
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Item {
        id: seconds

        width: parent.width/3
        height: parent.height - canselBtn.height - 30

        anchors.left: minutes.right

        Item {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: parent.height

            ListView {
                id: listSeconds
                anchors.fill: parent
                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: height/3
                preferredHighlightEnd: height/3
                clip: true
                model: 60
                delegate: Text {
                    font.pixelSize: 18;
                    color: defaultColor
                    text: {
                        if (index/10 < 1) { "0" + index } else { index }
                    }
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: defaultColor }
                    GradientStop { position: 0.2; color: "#00000000"  }
                    GradientStop { position: 0.8; color: "#00000000"  }
                    GradientStop { position: 1.0; color: defaultColor }
                }
            }

            Text {
                id: captionSeconds
                text: "sec"
                anchors.right: parent.right
                anchors.rightMargin: 2
                color: defaultColor
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    Item {
        id: colors

        width: parent.width/3
        height: parent.height - canselBtn.height - 30

        anchors.left: seconds.right
        anchors.rightMargin: 10

        Item {
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: parent.height

            ListView {
                id: listColors
                anchors.fill: parent
                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: height/3
                preferredHighlightEnd: height/3
                clip: true
                spacing: 5
                model: ListModel {
                    ListElement{ color: "#F44336"}
                    ListElement{ color: "#E91E63"}
                    ListElement{ color: "#9C27B0"}
                    ListElement{ color: "#673AB7"}
                    ListElement{ color: "#3F51B5"}
                    ListElement{ color: "#2196F3"}
                    ListElement{ color: "#03A9F4"}
                    ListElement{ color: "#00BCD4"}
                    ListElement{ color: "#009688"}
                    ListElement{ color: "#4CAF50"}
                    ListElement{ color: "#8BC34A"}
                    ListElement{ color: "#CDDC39"}
                    ListElement{ color: "#FFEB3B"}
                    ListElement{ color: "#FFC107"}
                    ListElement{ color: "#FF9800"}
                    ListElement{ color: "#FF5722"}
                    ListElement{ color: "#795548"}
                    ListElement{ color: "#9E9E9E"}
                    ListElement{ color: "#607D8B"}
                }

                delegate: Rectangle {
                    color: model.color
                    width: 23
                    height: width
                    radius: width/2
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                onCurrentIndexChanged: {
                    defaultColor     = listColors.model.get(currentIndex).color
                    choosenColorName = listColors.model.get(currentIndex).color
                    choosenColorId = currentIndex
                }
            }
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.0; color: defaultColor }
                    GradientStop { position: 0.2; color: "#00000000"  }
                    GradientStop { position: 0.8; color: "#00000000"  }
                    GradientStop { position: 1.0; color: defaultColor }
                }
            }

            Text {
                id: captionColors
                text: "color"
                anchors.right: parent.right
                anchors.rightMargin: 2
                color: defaultColor
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }


    ComponentButton {
        id: canselBtn
        text: "Cansel"
        anchors.leftMargin: 10
        anchors.left: parent.left
        anchors.top: minutes.bottom
        anchors.topMargin: 10
        Material.accent: Material.color(Material.Orange, Material.ShadeA400)
        onClicked: {
            cansel()
        }
    }

    ComponentButton {
        id: okBtn
        x: 288
        text: "Ok"
        anchors.rightMargin: 10
        anchors.right: parent.right
        anchors.top: canselBtn.top
        Material.accent: Material.color(Material.Orange, Material.ShadeA400)
        onClicked: {
            ok()
        }
    }
}

