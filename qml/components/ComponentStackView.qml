import QtQuick 2.9
import QtQuick.Controls 2.2

StackView {
    id: stackView
    objectName: "StackView"
    property var algorithm: ({})

    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    anchors.right: parent.right
}
