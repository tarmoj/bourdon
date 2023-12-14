import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtCore
/*

  TODO:

animatsioon preset kasti muutumisel topeltklõpsuga

Akna alumine serv?

NEXT Kõrvale ka Back?

min akna kõrgus?



*/

ApplicationWindow {
    id: app
    width: 720
    height: 520
    minimumWidth: 350
    visible: true
    property string version: "0.3.0"
    title: qsTr("Bourdon app "+ version)


    property var presetsArray: [ [], ["G","d"], ["c","g"] ]
    property var bourdonNotes: ["G", "A", "c", "d", "e", "g", "a", "h", "c1", "d1", "e1", "g1", "a1", "h1"] // make sure the notes are loaded to tables in Csound with according numbers (index+1)
    property double lastPressTime: 0


    //onWidthChanged: console.log("window width: ", width)

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

        onActivated: { // TODO: the same code to onClicked of playButton
            console.log("for button 1", Date.now(), lastPressTime);
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
        height: titleLabel.height + 10

        background: Rectangle {color: "transparent" }

        Item {
            anchors.fill: parent

            Label {
                id: titleLabel
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: "Bourdon  v" + app.version
                font.pointSize: 16
                font.bold: true
                horizontalAlignment: Qt.AlignHCenter

            }
        }
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
        bourdonForm.presetForm.presetText.text = getPresetsText()
        //searchButton.clicked()
    }


    BourdonForm {
        id: bourdonForm
        anchors.fill: parent
        property int currentPreset: 0

        property var bourdonButtons: []

        signal presetZeroChanged;


        Component.onCompleted: {
            bourdonButtons = []; // get bourdonbuttons from the grid
            for (let element of bourdonButtonGrid.children) {
                if (element.hasOwnProperty("sound")) {
                    bourdonButtons.push(element);
                }
            }
        }


        function getAudioDevices() {
            var deviceList = csound.getAudioDevices();
            console.log("Device list: ", deviceList);
        }

        function stopAll() {

            for (let i=0; i<bourdonButtons.length; i++) {
                const b = bourdonButtons[i];
                if (b.checked) {
                    b.checked = false
                    console.log("Stopping ", b.text)
                }
            }
        }

        function isPlaying() {
            for (let i=0; i<bourdonButtons.length; i++) {
                const b = bourdonButtons[i];
                if (b.checked) {
                    return true;
                }
            }
            return false;
        }

        function getPresetFromButtons() {

            const preset = [];
            for (let i=0; i<bourdonButtons.length; i++) {
                const b = bourdonButtons[i];
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
                    const b = bourdonButtons[index];
                    b.checked = true;
                }
            }
        }


        soundTypeCombobox.onCurrentIndexChanged: csound.setChannel("type", soundTypeCombobox.currentIndex)


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
            } else if (newPreset<1) { // or <1?
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
                presetForm.presetText.text = getPresetsText()
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

        presetForm.updateButton.onClicked: setPresetsFromText(presetForm.presetText.text)


//        Behavior on presetArea.y {
//            NumberAnimation {
//                duration: 200
//            }
//        }

        presetMouseArea.onDoubleClicked: {

            presetArea.y = (presetArea.y===presetArea.maxY) ? presetArea.minY : presetArea.maxY;

        }


    }


}
