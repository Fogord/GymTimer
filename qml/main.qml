import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Controls.Material 2.2
import QtQuick.LocalStorage 2.0
import QtBluetooth 5.2

import "../js/main.js" as Js
import "./components"

ApplicationWindow{
    id: root

    objectName: "Root"

    width: 320
    height: 548
    visible: true

    Material.theme: Material.Dark

    //needs for obsever
    property var algorithm: ({})

    //signal for main.js file
    signal todoListCreate
    signal timersCreate

    Component.onCompleted: {
        //start programm here
        Js.app.start();
    }
}

