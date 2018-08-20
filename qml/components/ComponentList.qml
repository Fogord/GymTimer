import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

ListView {
    id: view

    anchors.left: parent.left
    anchors.right: parent.right

    contentWidth: root.width - margin
    flickableDirection: Flickable.VerticalFlick

    leftMargin:  margin/2
    rightMargin: margin/2
    spacing:     margin/2

    signal rowsIsInserted
    signal rowsIsRemoved
    signal itemChanging
    signal itemDeteils
    signal itemRemove
    signal showSearchFild
    signal hiddenSearchFild
    signal addItem
    signal changeMutedStatus

    property var algorithm: ({})

    property int currentIndexItemList: -1

    property alias  listModel        : listModel
    property int    margin           : 4
    property string iconChangeSource : ""
    property string iconRemoveSource : ""
    property bool   isEditItems      : true

    property double fontPixelSize    : 18


    ListModel {
        id: listModel
        dynamicRoles: true
        property string name: "listModel"
        onRowsInserted: {
            rowsIsInserted();
        }
        onRowsRemoved: {
            rowsIsRemoved();
        }
    }

//    highlight: Rectangle {
//        color: "#808080";
//    }


    model: listModel
    focus: true

    onAtYBeginningChanged: {
        if(atYBeginning && !atYEnd && isEditItems) {
            showSearchFild();
        }
    }

    onAtYEndChanged: {
        if(!atYBeginning && atYEnd && isEditItems) {
            hiddenSearchFild();
        }
    }

    onCurrentItemChanged: {
        currentIndexItemList = view.currentIndex
    }

    delegate:
        Flickable {

            id: flickItem
            width: parent.width
            height: 40

            onVisibleChanged: {
                if (!visible){
                    hiddenSearchFild();
                    remove.width = change.width = content.x = 0
                }
            }

            flickableDirection: Flickable.HorizontalFlick

            Item {
                id: row
                width: parent.width
                height: parent.height

                Item{
                    id: content
                    width: parent.width
                    height: parent.height

                    Label {
                        id: index
                        width: parent.width * 0.05
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: fontPixelSize
                        text: (model.index + 1)
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        color: Material.color(Material.Orange)
                    }

                    Label {
                        width: parent.width * 0.86
                        height: parent.height
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: fontPixelSize
                        text: model.name
                        anchors.left: index.right
                        anchors.leftMargin: 5
                        anchors.verticalCenter: parent.verticalCenter
//                        color: flickItem.ListView.isCurrentItem? Material.color(Material.Orange): "white"

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                view.currentIndex = model.index
                                remove.width = change.width = content.x = 0
                                hiddenSearchFild();
                                itemDeteils()
                            }
                        }
                    }

                    Image{
                        id: sound
                        anchors.right: time.left
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        source: model.muted?"qrc:/img/muted.png":"qrc:/img/unmuted.png"
                        width: parent.height - 10
                        visible: (model.muted !== undefined)
                        fillMode: Image.PreserveAspectFit
                        MouseArea {
                            anchors.fill: sound
                            onClicked: {
                                view.currentIndex = model.index
                                changeMutedStatus()
                            }
                        }
                    }

                    Label {
                        id: time
                        width: parent.width * 0.14
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: fontPixelSize
                        text: {
                            if(model.seconds >= 0)
                                Math.floor(model.seconds/60) + "." + ((model.seconds%60/10 < 1) ? "0" + model.seconds%60 :  model.seconds%60 )
                            else
                                ""
                        }
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        color: model.color || "black"
                        visible: (model.seconds >= 0)
                    }

                    Rectangle{
                        id: borderBottom
                        color: Material.color(Material.Orange)
                        width: parent.width
                        anchors.bottom: parent.bottom
                        height: 1
                    }
                }

                Rectangle{
                    id: change
                    height: content.height
                    anchors.left: parent.left
                    color: Material.color(Material.Orange)

                    Image {
                        id: iconChange
                        width: parent.width/2
                        height: parent.height/2
                        anchors.centerIn: parent
                        source: iconChangeSource
                    }

                    Rectangle{
                        id: changeRightBorder
                        height: row.height
                        width: 1
                        color: Material.color(Material.Orange)
                        anchors.right: change.right
                        visible: change.width
                    }

                    MouseArea{
                        anchors.fill: change
                        onClicked: function() {
                            view.currentIndex = model.index
                            remove.width = change.width = content.x = 0
                            hiddenSearchFild();
                            itemChanging()
                        }
                    }
                }

                Rectangle{
                    id: remove
                    height: content.height
                    anchors.right: parent.right
                    color: Material.color(Material.Red)

                    Image {
                        id: iconRemove
                        width: parent.width/2
                        height: parent.height/2
                        anchors.centerIn: parent
                        source: iconRemoveSource
                    }

                    Rectangle{
                        id: removeLeftBorder
                        height: row.height
                        width: 1
                        color: Material.color(Material.Red)
                        anchors.left: remove.left
                        visible: remove.width
                    }

                    MouseArea{
                        anchors.fill: remove
                        onClicked: function() {
                            view.currentIndex = model.index
                            remove.width = change.width = content.x = 0
                            hiddenSearchFild();
                            itemRemove();
                        }
                    }
                }


            }

            onAtXBeginningChanged: {
                if(atXBeginning && !atXEnd) {
                    remove.width = content.x = 0;
                    change.width = row.height;
                    content.x    = row.height;
                }
            }

            onAtXEndChanged: {
                if(!atXBeginning && atXEnd) {
                    change.width = content.x = 0;
                    remove.width = row.height;
                    content.x    = -row.height;
                }
            }
    }
}





