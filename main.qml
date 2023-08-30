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
    title: qsTr("Bourdon test")


    property var presets: ["G,d", "c,g", "e,g"]



    header: ToolBar {
        width: parent.width
        height: backButton.height

        background: Rectangle {color: "transparent" }

        Item {
            anchors.fill: parent
            ToolButton {
                id: backButton
                anchors.left: parent.left
                anchors.leftMargin: 5
                text: qsTr("<")
                visible: swipeView.currentIndex===1
                onClicked: swipeView.currentIndex=0
            }

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: backButton.verticalCenter
                text: swipeView.currentItem.title
                //elide: Label.ElideRight
                font.pointSize: 16
                font.bold: true
                horizontalAlignment: Qt.AlignHCenter
                //verticalAlignment: Qt.AlignVCenter
                //Layout.fillWidth: true
            }
            ToolButton {
                anchors.right: parent.right
                anchors.rightMargin: 5
                text: qsTr(">")
                visible: swipeView.currentIndex===0
                onClicked: swipeView.currentIndex=1
            }
        }
    }





        Label {
            font.pointSize: 16
            text: swipeView.currentItem.title
            horizontalAlignment: Text.AlignHCenter
        }





    Connections {
            target: Application
            function onAboutToQuit() {
                console.log("Bye!")
                csound.stop();
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
        id: swipeView
        anchors.fill: parent
        currentIndex: 1

        Page {
            id: bourdonPage
            title: qsTr("Bourdons")

            property int currentPreset: -1
            property bool isPlaying: false


            BourdonForm {

                nextButton.onClicked: {
                    if (bourdonPage.currentPreset < app.presets.length-1 ) {
                        bourdonPage.currentPreset++ ;
                    } else {
                        bourdonPage.currentPreset = 0;
                    }

                    console.log("New preset: ", bourdonPage.currentPreset)
                    presetLabel.text = bourdonPage.currentPreset+1;
                }

            }



        }

        Page {
            id: presetPage
            title: qsTr("Presets")

            function  setPresets(text) {
                console.log("presets: ", text.split("\n"));
                // TODO: trim and simplify, maybe into arrays
            }

            PresetForm {



            }

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
