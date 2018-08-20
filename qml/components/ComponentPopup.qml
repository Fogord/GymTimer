import QtQuick 2.9
import QtQuick.Controls 2.2

Popup {
    id: popup
    clip: true

    y: (parent.height - popup.implicitHeight)/2
    x: (parent.width - popup.implicitWidth)/2

    contentWidth: popupLabel.implicitWidth
    contentHeight: popupLabel.implicitHeight

    property alias popupText: popupLabel.text

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

//    background: Rectangle{
//        border.color: "#808080"
//        gradient: Gradient {
//            GradientStop { position: 0.0; color: "white"  }
//            GradientStop { position: 0.1; color: "white" }
//            GradientStop { position: 1.0; color: "lightblue"}
//        }
//    }

    Label {
        id: popupLabel
        font.pixelSize: 16
        anchors.centerIn: parent
    }
}
