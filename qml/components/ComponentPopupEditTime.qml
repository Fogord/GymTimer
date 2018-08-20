import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2

Popup {
    id: popup
    clip: true

    y: parent.height - spinner.height - input.height - 60
    height: 280

    contentWidth: parent.width
    contentHeight:spinner.height + input.height

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property bool  isEditItem:           false

    signal timeInputAccepted
    signal timeEditAccepted

    property alias textInput:            input.textInput
    property alias placeholderTextInput: input.placeholderTextInput
    property alias choosenColorName:     spinner.choosenColorName
    property alias choosenColorId:       spinner.choosenColorId
    property alias time:                 spinner.time
    property alias soundIsMuted:         sound.muted

    property var newItem:                ({})

    ComponentInput {
        id: input
        anchors.top: parent.top
        anchors.right: sound.left
        anchors.rightMargin: 10
    }

    ComponentButton{
        id: sound
        property bool muted: false
        anchors.top: input.top
        anchors.right: parent.right
        width: sound.height
        onClicked:  {
            sound.muted = !sound.muted
        }
        onMutedChanged: {
            icon.source = sound.muted?"qrc:/img/muted.png":"qrc:/img/unmuted.png"
        }

        Image {
            id: icon
            source: "qrc:/img/unmuted.png"
            anchors.centerIn: parent
            width: parent.height - 25
            fillMode: Image.PreserveAspectFit
        }
    }

    ComponentSpinner{
        id: spinner
        anchors.top: sound.bottom
        anchors.topMargin:  10
        onCansel: popup.close()
        onOk: {
            newItem = getItem()
            newItem.textInput = input.textInput;
            newItem.muted = sound.muted;

            if (isEditItem)
                timeEditAccepted()
            else
                timeInputAccepted()
        }
    }

}
