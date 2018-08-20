import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2


Item {
    id: componentRow

    objectName: "Header"

    anchors.left: parent.left
    anchors.right: parent.right

    signal pressedBack
    signal showPopupItem
    signal pressedAdd
    signal pressedSearch
    signal changeHiderText

    property var algorithm: ({})

    property alias text:           label.text
    property alias textBackBtn:    back.text
    property alias textMenuBtn:    menu.text
    property alias textAddBtn:     add.text

    property alias visibleBackBtn: back.visible
    property alias visibleAddBtn:  add.visible
    property alias visibleText:    label.visible
    property alias visibleMenuBtn: menu.visible

    property double fontPixelSize    : 18

    ComponentButton {
        id: back
        height: parent.height
        text: "<"
        width: 50
        font.pixelSize: fontPixelSize
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        onClicked: {
            pressedBack()
        }
    }

    ComponentButton {
        id: add
        height: parent.height
        text: "+"
        width: 50
        font.pixelSize: fontPixelSize
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 10
        onClicked: {
            pressedAdd();
            pressedSearch();
        }
    }

    ComponentLabel {
        id: label
        text: "Header Text"
        verticalAlignment: Text.AlignVCenter
        height: parent.height
        font.pixelSize: fontPixelSize
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignHCenter
        anchors.right: menu.left
        anchors.left: back.right
        maximumLineCount: 10

        MouseArea{
            anchors.fill: parent
            onClicked: changeHiderText()

        }
    }

    ComponentButton {
        id: menu
        text: "≡"
        height: parent.height
        width: 50
        font.pixelSize: fontPixelSize
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: 10
        onClicked: {
            showPopupItem()
        }
    }
}
