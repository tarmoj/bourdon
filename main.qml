import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtCore
/*

  TODO:


ikoonid > ja < asemele
Landscape layout -  vaja alt ruumi (Current preset võibolla  pedaalinuppud kõrvale? State change?



bourdonform background -  otsi õige tooni


*/

ApplicationWindow {
    id: app
    width: 720
    height: 520
    visible: true
    property string version: "0.2.1"
    title: qsTr("Bourdon app "+ version)


    property var presetsArray: [ [], ["G","d"], ["c","g"] ]
    property var bourdonNotes: ["G", "A", "c", "d", "e", "g", "a", "h", "c1", "d1", "e1", "g1", "a1", "h1"] // make sure the notes are loaded to tables in Csound with according numbers (index+1)
    property int lastPressTime: 0


    Settings {
        property alias presetsArray: app.presetsArray
    }


    Timer {
        id: singlePressTimer
        interval: 350 // Set the interval in milliseconds (adjust as needed)
        onTriggered: {
            console.log("Single press detected!")
            bourdonForm.nextButton.clicked();
        }
        repeat: false
    }


    // These are bluetooth shortcuts, Airturn Duo, mode 2 (keyboard mode)
    Shortcut {
            sequences: ["Up","PgUp"] // change preset

            onActivated: {
                console.log("for button 1");
                if (Date.now() - lastPressTime < 300) {
                    console.log("Double press detected!")
                    bourdonForm.advancePreset(-1);
                    singlePressTimer.stop()
                } else {
                    singlePressTimer.start()
                }

                lastPressTime = Date.now()
            }
        }

    Shortcut {
            sequences: ["PgDown", "Down" ]
            onActivated: {
                console.log("for button 2");
                bourdonForm.playButton.checked = !bourdonForm.playButton.checked
            }
        }


    function  setPresetsFromText(text) {
        const arr = [ [] ]; // define with one empty array for 0-preset

        const rows = text.split("\n");
        console.log("Rows found: ", rows.length)
        for (let row of rows) {
            row = row.replace(/\s/g, ""); // remove white spaces
            const preset = row.split(",")
            //console.log("Preset as array: ", preset)
            //TODO: check if only allowed elements in array
            if (preset.length>0 && preset[0] ) { // check if not empty
                arr.push(preset)
            }
        }

        //console.log("New array: ", arr);
        app.presetsArray = arr;

    }

    function getPresetsText() { // turns presets array
        let text = "";

        for (let i=1;i<presetsArray.length;i++ ) { // NB! start from 1, 0 is for non-saved temporary array
            text += presetsArray[i] .join(",") + "\n"
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
                text: swipeView.currentItem.title + "  v" + app.version
                font.pointSize: 16
                font.bold: true
                horizontalAlignment: Qt.AlignHCenter

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
                property int currentPreset: 0

                signal presetZeroChanged;


                function stopAll() {
                    for (let i=0; i<bourdonButtons.count; i++) {
                        const b = bourdonButtons.itemAt(i);
                        if (b.checked) {
                            b.checked = false
                            console.log("Stopping ", b.text)
                        }
                    }
                }

                function isPlaying() {
                    for (let i=0; i<bourdonButtons.count; i++) {
                        const b = bourdonButtons.itemAt(i);
                        if (b.checked) {
                            return true;
                        }
                    }
                    return false;
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
                        }
                    }
                }




                soundTypeCombobox.onCurrentIndexChanged: csound.setChannel("type", soundTypeCombobox.currentIndex)
                //sawWaveSwitch.onCheckedChanged: csound.setChannel("sawtooth", sawWaveSwitch.checked ? 1 : 0  )

                bourdonButtons.model: app.bourdonNotes

                bourdonButtonGrid.columns:  Math.floor(bourdonButtonGrid.width / (bourdonButtons.itemAt(0).width + 10 ) )

                bourdonArea.Layout.preferredHeight:bourdonButtonGrid.height


                function updatePresetLabelText() {
                    presetLabel.text = currentPreset.toString() + " " + presetsArray[currentPreset].join(",");

                }

                onPresetZeroChanged: updatePresetLabelText()

                presetNullButton.onClicked:  {
                    currentPreset = 0
                    if (isPlaying() || playButton.checked) {
                        stopAll()
                        playButton.checked = false
                    }
                }

                onCurrentPresetChanged: {
                    updatePresetLabelText()
                    if (isPlaying()) {
                        stopAll();
                        playFromPreset(app.presetsArray[currentPreset])
                    }
                }

                a4SpinBox.onValueChanged: {
                    console.log("A4: ", a4SpinBox.value )
                    //app.setChannel("a4", a4SpinBox.value)
                    csound.setChannel("a4", a4SpinBox.value);
                }

                function advancePreset(advance=1) { // either +1 or -1
                    let newPreset = currentPreset + advance
                    if (newPreset >= app.presetsArray.length ) {
                        currentPreset = 1 ; // should it go preset 0 that is for temporary, non saved experiments
                    } else if (newPreset<0) { // or <1?
                        currentPreset = app.presetsArray.length-1;
                    } else {
                        currentPreset = newPreset
                    }

                    console.log("New preset: ", currentPreset)
                }

                nextButton.onClicked: {
                    advancePreset(1);
                }

                // TODO: implement double click also on double click
                //nextButton.onDoubleClicked: advancePreset(-1)

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

                    console.log("Playbutton checked: ", playButton.checked, bourdonForm.isPlaying() )

                    if ( bourdonForm.isPlaying() ) {
                        playButton.checked = false; // stop will happen below
                    }

                    if (playButton.checked) {
                        if (app.presetsArray[currentPreset].length>0) {
                            console.log("Starting: ", currentPreset, app.presetsArray[currentPreset])
                            stopAll();
                        } else {
                            playButton.checked = false;
                        }

                        playFromPreset(app.presetsArray[currentPreset] );
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


}
