import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    color: "darkblue"
    visible: true


    title: qsTr("Bourdon test")

    Connections {
            target: Application
            function onAboutToQuit() {
                console.log("Bye!")
                csound.stop(); // still some exiting error between the threads
            }
        }

    Connections {
        target: device
        function onButtonPressed(button) {
            console.log("Button pressed in qml: ", button)
            const b = bourdonButtons.itemAt(button-1);
            b.checked = !b.checked;
            b.clicked();
        }

        function onStatusMessage(message) {
            console.log("Message in qml: ", message);
            bluetoothStatus.text = message;
        }
    }

    Component.onCompleted: searchButton.clicked()

    Row {
        id: statusRow
        x: 5; y:5
        spacing: 5

        Button { id: searchButton; text:qsTr("Scan"); onClicked: device.startDeviceDiscovery() }

        Label {color: "white"; text: qsTr("BT status")}
        Label {color: "lightgrey"; id: bluetoothStatus}
    }

    Row {
        id: centerRow
        anchors.centerIn: parent
        spacing: 5


        Repeater {
            id: bourdonButtons
            model: ["G", "d", "e"]

            BourdonButton {
                required property string modelData
                required property int index

                sound: index+1
                text: modelData
            }

        }

//        BourdonButton {
//            id: sound1
//            sound: 1
//            text: qsTr("G")
//        }

//        BourdonButton {
//            id: sound2
//            sound: 2
//            text: qsTr("d")
//        }

//        BourdonButton {
//            id: sound3
//            sound: 3
//            text: qsTr("e")
//        }

    }

//    Grid {
//        spacing: 5
//        columns: 3

//        Button {
//            text: "Start discovery"
//            onClicked: device.startDeviceDiscovery();
//        }

//        Button {
//            text: "Scan Services";
//            onClicked: device.scanServices("DB:DB:C0:4B:5C:3A"); // hex address of Airturn Duo
//        }

//        Button {
//            text: "Service characteristucs";
//            onClicked: device.connectToService(service.text); // hex address of Device info
//        }

//        Button {
//            text: "Service characteristucs";
//            onClicked: device.connectToService(service.text); // hex address of Device info
//        }

//        Label { text: "Service hex code";}


//        TextInput {
//            id: service
//            color: "white"
//            text: "34452f38-9e44-46ab-b171-0cc578feb928"
//        }

//        Button {
//            text:"Read"
//            onClicked: device.testReadValue()
//        }
//    }






}
