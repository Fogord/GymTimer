import QtQuick 2.9
import QtBluetooth 5.9



ComponentItem {
    id: topItem

    property BluetoothService currentService

    BluetoothDiscoveryModel {
        id: btModel
        running: true
        discoveryMode: BluetoothDiscoveryModel.DeviceDiscovery
        onDiscoveryModeChanged: console.log("Discovery mode: " + discoveryMode)
        onServiceDiscovered: console.log("Found new service " + service.deviceAddress + " " + service.deviceName + " " + service.serviceName);
        onDeviceDiscovered: console.log("New device: ", device);
        uuidFilter: "VTV0481201"
        onErrorChanged: {
                switch (btModel.error) {
                case BluetoothDiscoveryModel.PoweredOffError:
                    console.log("Error: Bluetooth device not turned on"); break;
                case BluetoothDiscoveryModel.InputOutputError:
                    console.log("Error: Bluetooth I/O Error"); break;
                case BluetoothDiscoveryModel.InvalidBluetoothAdapterError:
                    console.log("Error: Invalid Bluetooth Adapter Error"); break;
                case BluetoothDiscoveryModel.NoError:
                    break;
                default:
                    console.log("Error: Unknown Error"); break;
                }
        }
   }

    Rectangle {
        id: busy

        width: topItem.width * 0.7;
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: topItem.topItem;
        height: textScan.height*1.2;
        radius: 5
        color: "#1c56f3"
        visible: btModel.running

        Text {
            id: textScan
            color: "#000000"
            text: "Scanning"
            font.bold: true
            font.pointSize: 20
            anchors.centerIn: parent
        }

        SequentialAnimation on color {
            id: busyThrobber
            ColorAnimation { easing.type: Easing.InOutSine; from: "#1c56f3"; to: "white"; duration: 1000; }
            ColorAnimation { easing.type: Easing.InOutSine; to: "#1c56f3"; from: "white"; duration: 1000; }
            loops: Animation.Infinite
        }
    }

    ListView {
        id: mainList
        width: topItem.width
        anchors.top: busy.bottom
        anchors.bottom: buttonGroup.topItem
        anchors.bottomMargin: 10
        anchors.topMargin: 10
        clip: true

        model: btModel
//        model: 10
        delegate: Rectangle {
            id: btDelegate
            width: parent.width
            height: column.height + 10

            property bool expended: false;
            clip: true
            Image {
                id: bticon
                source: "qrc:/img/bluetooth.png";
                width: 20;
                height: 20;
                anchors.top: parent.topItem
                anchors.left: parent.left
                anchors.margins: 5
                fillMode: Image.PreserveAspectFit
            }

            Column {
                id: column
                anchors.left: bticon.right
                anchors.leftMargin: 5
                Text {
                    id: bttext
                    text: deviceName ? deviceName : name
                    font.family: "FreeSerif"
                    font.pointSize: 16
                }

                Text {
                    id: details
                    color: "#ffffff"
                    function get_details(s) {
                        if (btModel.discoveryMode == BluetoothDiscoveryModel.DeviceDiscovery) {
                            //We are doing a device discovery
                            var str = "Address: " + remoteAddress;
                            return str;
                        } else {
                            var str = "Address: " + s.deviceAddress;
                            if (s.serviceName) { str += "<br>Service: " + s.serviceName; }
                            if (s.serviceDescription) { str += "<br>Description: " + s.serviceDescription; }
                            if (s.serviceProtocol) { str += "<br>Protocol: " + s.serviceProtocol; }
                            return str;
                        }
                    }
                    visible: opacity !== 0
                    opacity: btDelegate.expended ? 1 : 0.0
                    text: get_details(service)
                    font.family: "FreeSerif"
                    font.pointSize: 14
                    Behavior on opacity {
                        NumberAnimation { duration: 200}
                    }
                }
            }
            Behavior on height { NumberAnimation { duration: 200} }

            MouseArea {
                anchors.fill: parent
                onClicked: btDelegate.expended = !btDelegate.expended
            }
        }
        focus: true
    }

    Row {
        id: buttonGroup
        property var activeButton: devButton

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 5
        spacing: 10

        ComponentButton {
            id: fdButton
            width: topItem.width/3*0.9
            //mdButton has longest text
            height: mdButton.height
            text: "Full Discovery"
            onClicked: {btModel.discoveryMode = BluetoothDiscoveryModel.FullServiceDiscovery; btModel.running = true;}
        }
        ComponentButton {
            id: mdButton
            width: topItem.width/3*0.9
            text: "Minimal Discovery"
            onClicked: {btModel.discoveryMode = BluetoothDiscoveryModel.MinimalServiceDiscovery; btModel.running = true;}
        }
        ComponentButton {
            id: devButton
            width: topItem.width/3*0.9
            //mdButton has longest text
            height: mdButton.height
            text: "Device Discovery"
            onClicked: {btModel.discoveryMode = BluetoothDiscoveryModel.DeviceDiscovery; btModel.running = true;}
        }
    }

    BluetoothSocket{
        id: btSocked
        onConnectedChanged: {
            console.log(connected)
        }

        onErrorChanged: {
            console.log(error)
        }

        onStringDataChanged: {
            console.log(stringData)
        }
    }

}

//Item {
//    id: item

//    signal getError;
//    signal getDevice;
//    signal getService;
//    signal getData;
//    signal searching;

//    property alias model:               btModel
//    property alias startSearch:         btModel.running
//    property alias discoveryMode:       btModel.discoveryMode
//    property alias uuidFilterDevice:    btModel.uuidFilter

//    property alias socket:              btSocked
//    property alias bluetoothDdata:      btSocked.stringData

//    property var serviceObj;
//    property var deviceObj;

//    BluetoothDiscoveryModel {
//        id: btModel

//        onRunningChanged: {
//            searching();
//        }

//        onServiceDiscovered: {
//            console.log(JSON.stringify(service))
//        }

//        onDeviceDiscovered: {
//            console.log("New device: ", device.deviceName, device.remoteAddress);
//        }

//        onErrorChanged: {
//            console.log(error)
//        }

//        Component.onCompleted: {
//            console.log(BluetoothDiscoveryModel.MinimalServiceDiscovery, BluetoothDiscoveryModel.FullServiceDiscovery, BluetoothDiscoveryModel.DeviceDiscovery)
//            console.log(BluetoothDiscoveryModel.NoError, BluetoothDiscoveryModel.InputOutputError, BluetoothDiscoveryModel.PoweredOffError, BluetoothDiscoveryModel.InvalidBluetoothAdapterError, BluetoothDiscoveryModel.UnknownError)
//        }
//   }

//    BluetoothSocket{
//        id: btSocked

//        onStringDataChanged: {
////            getData()
//        }
//    }
//}

//ComponentItem {
//    BluetoothDiscoveryModel {
//        id: btModel
//        running: true
//        discoveryMode: BluetoothDiscoveryModel.FullServiceDiscovery
//    }

//    //Listview to hold the discovered device name and address
//    ListView
//    {
//        id:view
//        model: btModel
//        anchors.fill: parent
//        spacing:0
//        delegate:Item
//        {
//            width:360
//            height:60

//            Rectangle
//            {
//                id:borderRect
//                color: "transparent"
//                border.color: "white"
//                border.width: 1
//                anchors.fill: parent
//            }

//            Item
//            {
//                anchors.fill: parent

//                Text {
//                    id:btdeviceName
//                    x:10
//                    y:5
//                    text: "Name : " + qsTr(deviceName)
//                    color: "white"
//                }

//                Text {
//                    id:btdeviceaddr
//                    x:10
//                    text: "Address : " + qsTr(remoteAddress)
//                    y:btdeviceName.height + 10
//                    color: "white"
//                }
//            }
//        }
//    }
//}
