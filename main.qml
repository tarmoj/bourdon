import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts


ApplicationWindow {
    id: app
    width: 640
    height: 480
    visible: true

    Material.theme: Material.Dark

    title: qsTr("Bourdon test")

    header:
        Rectangle {
            id: headerRect
            width:parent.width
            anchors.margins: 5
            color: "darkgrey"

            Label {
                id: titleLabel;
                anchors.horizontalCenter: parent.horizontalCenter
                font.pointSize: 14
                font.bold: true
                text: app.title
            }

            Button {
                text: qsTr("Presets ->");
                scale: 0.6
                anchors.right: parent.right
            }

        }

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

    //Component.onCompleted: searchButton.clicked()

    SwipeView {
            anchors.fill:parent
            //currentIndex: 1

    Page {

    }

    Page {

    }

    }

/*
    Row {
        id: statusRow
        x: 5;
        anchors.top: headerRect.bottom
        spacing: 5
        visible: false

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


    }
*/

}
