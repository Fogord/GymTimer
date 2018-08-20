import QtQuick 2.9
import QtQuick.Controls 2.2

Item {
    id: componentItem

    anchors.left: parent.left
    anchors.right: parent.right

    signal rowsIsInserted
    signal rowsIsRemoved
    signal itemChange
    signal itemDeteils
    signal itemRemove
    signal showSearchFild
    signal hiddenSearchFild

    property var algorithm: ({})

    property int currentIndexItemList: -1

//    property alias  listModel        : listModel
    property int    margin           : 4
    property string iconChangeSource : ""
    property string iconRemoveSource : ""
    property string borderColor      : "#808080"
    property bool   isEditItems      : true

    ListModel {
        id: listModel
//        dynamicRoles: true
        property string name: "listModel"
        ListElement {
            categoryName: "1"
            collapsed: true
            subItems: [
                ListElement {
                    itemName: "11"
                },
                ListElement {
                    itemName: "12"
                }
            ]
        }
        ListElement {
            categoryName: "2"
        }
        ListElement {
            categoryName: "3"
        }

        onRowsInserted: {
            rowsIsInserted();
        }
        onRowsRemoved: {
            rowsIsRemoved();
        }
    }

    ListView {
        spacing: 4
        anchors.fill: parent
        model: listModel
        delegate: categoryDelegate
    }

    Component {
        id: categoryDelegate
        Column {
            anchors.left: parent.left
            anchors.right: parent.right

            Item {
                id: categoryItem
                height: 50
                anchors.left: parent.left
                anchors.right: parent.right

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 15
                    font.pixelSize: 18
                    text: categoryName
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: listModel.setProperty(index, "collapsed", !collapsed)
                }

            }


            Loader {
                id: subItemLoader
                visible: !collapsed
                anchors.left: parent.left
                anchors.right: parent.right
                property variant subItemModel : subItems
                sourceComponent: collapsed ? null : subItemColumnDelegate
                onStatusChanged: if (status == Loader.Ready) item.model = subItemModel
            }
        }

    }

    Component {
        id: subItemColumnDelegate
        Column {
            property alias model : subItemRepeater.model
            Repeater {
                id: subItemRepeater
                delegate: Item {
                    height: 40
                    anchors.left: parent.left
                    anchors.right: parent.right

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 30
                        font.pixelSize: 18
                        text: itemName
                    }
                }
            }
        }
    }
}





