import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

Item{
    id: inputItem

    objectName: "Input"

    anchors.left: parent.left
    anchors.right: parent.right

    signal changed
    signal add

    property alias implicitWidth: input.implicitWidth
    property alias implicitHeight: input.implicitHeight
    property alias textInput:  input.text
    property alias btnVisible: btn.visible
    property alias btnText:    btn.text
    property alias inputFocus: input.focus
    property alias placeholderTextInput: input.placeholderText

    onVisibleChanged: {
        textInput = ""
    }

    TextField {
        id: input
        font.pixelSize: 16
        anchors.left: parent.left
        anchors.right: btn.left

        Material.accent: Material.color(Material.Orange, Material.ShadeA400)

        onTextChanged: {
            changed();
        }
        onAccepted: {
            add();
        }
    }

    ComponentButton{
        id: btn
        width: font.pixelSize * text.length
        anchors.right: parent.right
        onClicked: {
            add();
        }
    }
}

