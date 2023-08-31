import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtCore
/*

  TODO:


BourdonForm -  lisa ülesse spacer, Grid -  arvuta nuppude arv koos spacing
Mõtle Stop ja Add nupu peale pigem norm nupud ikoonidega, spacing väiksemaks (5)
ikoonid > ja < asemele
Landscape layout -  vaja alt ruumi (Current preset võibolla  pedaalinuppud kõrvale? State change?
Android - ümberhäälestamine -  mingi jama, ei ole stabiilne....
SpinBox - editable

ikoon


bourdonform background -  otsi õige tooni

BourdonButton view, background (FoxButton)


*/

ApplicationWindow {
    id: app
    width: 640
    height: 480
    visible: true
    title: qsTr("Bourdon test")


    property var presetsArray: [ ["G","d"], ["c","g"] ]
    property var bourdonNotes: ["G", "c", "d", "e", "g", "a", "h", "c1", "d1", "e1", "g1", "a1", "h1"] // make sure the notes are loaded to tables in Csound with according numbers (index+1)

    Settings {
        property alias presetsArray: app.presetsArray
    }


    function  setPresetsFromText(text) {
        const arr = []
        const rows = text.split("\n");
        console.log("Rows found: ", rows.length)
        for (let row of rows) {
            row = row.replace(/\s/g, ""); // remove white spaces
            const preset = row.split(",")
            console.log("Preset as array: ", preset)
            //TODO: check if only allowed elements in array
            if (preset.length>0 && preset[0] ) { // check if not empty
                arr.push(preset)
            }
        }

        console.log("New array: ", arr);
        app.presetsArray = arr;

    }

    function getPresetsText() { // turns presets array
        let text = "";

        for (let p of presetsArray ) {
            text += p.join(",") + "\n"
        }
        console.log("presets as text: ", text)
        return text
    }

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
                onClicked:  {
                    setPresetsFromText(presetForm.presetArea.text) // update if there has been change
                    swipeView.currentIndex=0
                }
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
                onClicked: {
                    swipeView.currentIndex=1
                }
            }
        }
    }

        Label {
            font.pointSize: 16
            text: swipeView.currentItem.title
            horizontalAlignment: Text.AlignHCenter
        }


    signal setChannel(channel: string, value: double)
    signal readScore(scoreLine: string)


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

    Component.onCompleted: {
        presetForm.presetArea.text = getPresetsText()
        //searchButton.clicked()
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        //currentIndex: 1

        Page {
            id: bourdonPage
            title: qsTr("Bourdons")



            BourdonForm {
                id: bourdonForm
                property int currentPreset: -1
                property bool isPlaying: false

                function stopAll() {
                    for (let i=0; i<bourdonButtons.count; i++) {
                        const b = bourdonButtons.itemAt(i);
                        if (b.checked) {
                            b.checked = false
                            b.clicked();
                            console.log("Stopping ", b.text)
                        }
                    }
                }

                function getPresetFromButtons() {

                    const preset = [];
                    for (let i=0; i<bourdonButtons.count; i++) {
                        const b = bourdonButtons.itemAt(i);
                        if (b.checked) {
                            preset.push(b.text)
                        }
                    }
                    console.log("Preset: ", preset)

                    return preset;
                }


                function playFromPreset(preset) { // preset is an array of the notest to be played like [G,d,e]
                    for  (let note of preset) {
                        const index = app.bourdonNotes.indexOf(note);
                        if (index>=0) {
                            const b = bourdonButtons.itemAt(index);
                            b.checked = true;
                            b.clicked();
                        }
                    }
                }


                // These are bluetooth shortcuts, Airturn Duo, mode 2 (keyboard mode)
                Shortcut {
                        sequence: "Up"
                        onActivated: {
                            console.log("for button 1");
                            bourdonForm.nextButton.clicked();
                        }
                    }

                Shortcut {
                        sequence: "Down"
                        onActivated: {
                            console.log("for button 2");
                            bourdonForm.playButton.checked = !bourdonForm.playButton.checked
                        }
                    }


                bourdonButtons.model: app.bourdonNotes

                bourdonButtonGrid.columns:  Math.floor(bourdonButtonGrid.width / bourdonButtons.itemAt(0).width)

                bourdonArea.Layout.preferredHeight:bourdonButtonGrid.height

                onCurrentPresetChanged: {
                    if (currentPreset>=0) {
                        presetLabel.text = (currentPreset+1).toString() + " " + presetsArray[currentPreset].join(",");
                        if (playButton.checked) {
                            stopAll();
                            playFromPreset(app.presetsArray[currentPreset])
                        }
                    }
                }

                a4SpinBox.onValueChanged: {
                    console.log("A4: ", a4SpinBox.value )
                    app.setChannel("a4", a4SpinBox.value)
                    //csound.setChannel("a4", a4SpinBox.value);
                }

                nextButton.onClicked: {
                    if (currentPreset < app.presetsArray.length-1 ) {
                        currentPreset++ ;
                    } else {
                        currentPreset = 0;
                    }
                    console.log("New preset: ", currentPreset)
                }

                stopButton.onClicked: stopAll()

                addButton.onClicked: {
                    const preset = getPresetFromButtons()
                    if (preset.length>0) {
                        presetsArray.push(preset)
                        presetForm.presetArea.text = getPresetsText()
                        swipeView.currentIndex = 1
                    } else {
                        console.log("No playing buttons")
                    }

                }

                playButton.onCheckedChanged:  {

                    console.log("Playbutton checked: ", playButton.checked)

                    if (playButton.checked) {
                        stopAll();
                        if (currentPreset<0 ) {
                            currentPreset = 0; // changing preset triggers also playback
                        } else {
                            playFromPreset(app.presetsArray[currentPreset] );
                        }

                    } else {
                        stopAll();
                    }

                }

            }



        }

        Page {
            id: presetPage
            title: qsTr("Presets")


            PresetForm { id:presetForm }

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
