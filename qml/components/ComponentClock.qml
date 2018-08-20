import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtMultimedia 5.9

Row {
    id: parentItem

    leftPadding: 10
    topPadding: 10
    bottomPadding: 10

    anchors.left: parent.left
    anchors.right: parent.right

    property int  secondsNow       : 0
    property int  repeaterValue    : 1
    property int  repeaterValueMax : 1

    property alias playVisible     : play.visible
    property alias pauseVisible    : pause.visible
    property alias stopVisible     : stop.visible
    property alias repeaterVisible : repeater.visible
    property alias infinityVisible : infinity.visible

    property alias repeaterChecked : repeater.checked
    property alias infinityChecked : infinity.checked

    property alias startTimer      : timer.running
    property alias startLight      : lightColor.running
    property alias stopColor       : lighterGradientStop.color
    property alias fromColor       : grColor.from
    property alias toColor         : grColor.to
    property alias sound           : playSoundGo.source
    property bool  isRunning       : timer.running
    property bool  isNeedToPlay    : false

    signal palyClicked
    signal pauseClicked
    signal stopClicked
    signal repaterClicked
    signal infinityClicked
    signal timeChanged

    onIsNeedToPlayChanged: {
        if(!isNeedToPlay){
            playSoundGo.stop()
             playSoundStop.stop()
        }
    }

    Timer {
        id: timer
        interval: 1000;
        running: false;
        repeat: true;
        onTriggered: {
            if(!playSoundGo.playing) {
                playSoundGo.play()
            }
            timeChanged();
        }
    }

    SoundEffect {
        id: playSoundGo
        source: "qrc:/sound/goX2.wav"
    }

    SoundEffect {
        id: playSoundStop
        source: "qrc:/sound/stopX2.wav"
    }

    Item {
        id: clock

        width: background.width
        height: background.width

        Rectangle {
            id: lighter
            anchors.fill: background
            radius: background.width/2
            gradient: Gradient {
                GradientStop {
                    id: lighterGradientStop
                    position: 1.0
                    color: "#FFFFFF"
                    SequentialAnimation on color {
                        id: lightColor
                        running: timer.running
                        loops: Animation.Infinite
                        ColorAnimation {id: grColor; from: "#FFFFFF";  to: "#FFFFFF"; duration: 1000 }
                    }
                }
            }
        }

        Image {
            id: background;
            source: "qrc:/img/clock.png";
        }

        Image {
            x: 97.5; y: 20
            source: "qrc:/img/second.png"
            transform: Rotation {
                origin.x: 2.5
                origin.y: 80;
                angle: secondsNow * 6
                Behavior on angle {
                    SpringAnimation { spring: 2; damping: 0.2; modulus: 360 }
                }
            }
        }

        Image {
            anchors.centerIn: background
            source: "qrc:/img/center.png"
        }
    }

    Column {
        id: menuClockItem

        leftPadding: (parent.width - clock.width )/2 - play.width/2

        ComponentButton{
            id: play
            text: "play"
            onClicked: palyClicked()
        }

        ComponentButton{
            id: pause
            text: "pause"
            visible: false
            onClicked: pauseClicked()
        }

        ComponentButton{
            id: stop
            text: "stop"
            onClicked: stopClicked()
        }

        ComponentButton{
            id: repeater
            text: "x" + repeaterValue
            checked:  true
            Material.accent: Material.color(Material.Orange, Material.ShadeA400)
            onClicked: repaterClicked()
        }

        ComponentButton{
            id: infinity
            text: "∞"
            checkable: true
            Material.accent: Material.color(Material.Orange, Material.ShadeA400)
            onClicked: infinityClicked()
        }
    }
}

