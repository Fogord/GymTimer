import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

Popup {
    id: popup
    clip: true

    y: parent.height - popup.implicitHeight

    contentWidth: parent.width
    contentHeight:input.implicitHeight

    property alias textInput:            input.textInput
    property alias rightBtnText:         btnRight.text
    property alias inputFocus:           input.inputFocus
    property alias placeholderTextInput: input.placeholderTextInput
    property bool  isEditItem:           false

    signal textInputAccepted
    signal textEditAccepted

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

//    background: Rectangle{
//        border.color: "#808080"
//        gradient: Gradient {
//            GradientStop { position: 0.0; color: "white"  }
//            GradientStop { position: 0.1; color: "white" }
//            GradientStop { position: 1.0; color: "lightblue"}
//        }
//    }

    ComponentInput {
        id: input
        anchors.top: parent.top
        anchors.right: btnRight.left
        anchors.rightMargin: 10

        Material.accent: Material.color(Material.Orange, Material.ShadeA400)
        onAdd: {
            if (isEditItem)
                textEditAccepted()
            else
                textInputAccepted()
        }
    }

    ComponentButton {
        id: btnRight
        anchors.top: input.top
        anchors.right: parent.right
        onPressed: {
            if (isEditItem)
                textEditAccepted()
            else
                textInputAccepted()
        }
    }
}
