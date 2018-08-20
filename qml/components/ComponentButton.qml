import QtQuick 2.9
import QtQuick.Controls 2.2

Button {
    id: button
    font.pixelSize: 16

    property var algorithm: ({})

    property bool free: false

    property bool anchorsRight: false
    property real anchorsRightMargin: 0
    property bool anchorsLeft:  false
    property real anchorsLeftMargin:  0
    property bool anchorsTop:   false
    property real anchorsTopMargin:   0
    property bool anchorsBottom:false
    property real anchorsBottomMargin:0

    onAnchorsRightChanged: {
        if(anchorsRight)
            button.anchors.right = parent.right
    }

    onAnchorsRightMarginChanged: {
        button.anchors.rightMargin = anchorsRightMargin
    }

    onAnchorsLeftChanged: {
        if(anchorsLeft)
            button.anchors.left = parent.left
    }

    onAnchorsLeftMarginChanged: {
        button.anchors.leftMargin = anchorsLeftMargin
    }

    onAnchorsTopChanged: {
        if(anchorsTop)
            button.anchors.top = parent.top
    }

    onAnchorsTopMarginChanged: {
         button.anchors.topMargin = anchorsTopMargin
    }

    onAnchorsBottomChanged: {
        if(anchorsBottom)
            button.anchors.bottom = parent.bottom
    }

    onAnchorsBottomMarginChanged: {
         button.anchors.bottomMargin = anchorsBottomMargin
    }
}
