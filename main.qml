import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtCore
/*

  TODO:


Akna alumine serv?

NEXT Kõrvale ka Back?

min akna kõrgus?

ListView Presetide muutmiseks ? Darg&Drop nootide lisamiseks, longPress eemaldamiseks?
LongPress on temperament/sound -  context menu with dropDpwn? või lihtsalt väike DropDown


*/

ApplicationWindow {
    id: app
    width: 520
    height: 720
    minimumWidth: 350
    visible: true
    property string version: "0.6.0"
    title: qsTr("Bourdon app "+ version)

    property color backgroundColor: Material.background // expose to C++

    /*** new preset system: array of objects:
    {
         {temperament: EQ|G|A|C|D, sound:sample|saw|synthesized, notes:[] }

         when expressed as text, separated with semicolons like:
         EQ;saw;c,g,c1
    }
    ***/


    property var presetsArray: [ {tuning: "EQ", sound: "synthesized", notes:[]}, // first one keep empty, this is for preset 0
        {tuning: "G", sound: "synthesized", notes:["G","d"]},
        {tuning: "C", sound: "saw", notes:["c","g"]},
        {tuning: "D", sound: "sample", notes:["d","a", "c1"]}
    ]
    property var bourdonNotes: ["G", "A", "c", "d", "e", "f", "fis", "g", "a", "h", "c1", "d1", "e1", "f1", "fis1", "g1", "a1", "h1"] // make sure the notes are loaded to tables in Csound with according numbers (index+1)
    property double lastPressTime: 0
    property var tunings: ["EQ","G", "D", "A", "C"] // make sure that this is aligned with the widget and the logic in Csound
    property var soundTypes: ["sample", "saw", "synthesized"] // same - check the widget and Csound, when changed

    //onWidthChanged: console.log("window width: ", width)

    // TODO: vaja mingit funktsiooni, mis käiks vana preseti üle ja kui seal ei ole tuning, sound && notes, siis paneb selle.
    Settings {
        id: appSettings
        //property alias presetsArray: app.presetsArray
        property string presetsArray: ""

    }


    Timer {
        id: singlePressTimer
        interval: 350 // Set the interval in milliseconds (adjust as needed)
        onTriggered: {
            console.log("Single press detected!")
            //bourdonForm.nextButton.clicked();
            bourdonForm.advancePreset(1)
        }
        repeat: false
    }

    function checkDoublePress() {
        //console.log("for button 1", Date.now(), lastPressTime);
        if (Date.now() - lastPressTime < 300) {
            console.log("Double press detected!")
            bourdonForm.advancePreset(-1);
            singlePressTimer.stop()
        } else {
            singlePressTimer.start()
        }

        lastPressTime = Date.now()

    }








    // These are bluetooth shortcuts, Airturn Duo, mode 2 (keyboard mode)
    Shortcut {
        sequences: ["Up","PgUp"] // change preset

        onActivated: checkDoublePress()
    }

    Shortcut {
        sequences: ["PgDown", "Down" ] // play/Stop
        onActivated: {
            console.log("for button 2");
            bourdonForm.playButton.checked = !bourdonForm.playButton.checked
        }
    }


    function  setPresetsFromText(text) {
        const arr = [ { tuning: "EQ", sound: "synthesized", notes: [] } ]; // define with one empty array for 0-preset
        //TODO: rewrite to object based version

        const rows = text.split("\n");
        console.log("Rows found: ", rows.length, rows)
        for (let row of rows) {
            row = row.replace(/\s/g, ""); // remove white spaces
            const elements = row.split(";")
            console.log("Elemets in setPresetsFromText", elements)
            if (elements.length>=3) {
                const preset = { tuning:elements[0], sound:elements[1], notes:elements[2].split(",") }
                console.log("Preset as pbject: ", preset.tuning, preset.sound, preset.notes)
                if (preset.notes.length>0 && preset.notes[0] ) { // check if not empty
                    arr.push(preset)
                }
            }
            // is it necessary to check if elements are valid? Later maybe not when presetForm will not be text based. Now let's go for risk

        }

        //console.log("New array: ", arr);
        app.presetsArray = arr;
        appSettings.presetsArray = JSON.stringify(arr);

    }

    function getPresetsText() { // turns presets array to text
        let text = "";
        for (let i=1;i<presetsArray.length;i++ ) { // NB! start from 1, 0 is for non-saved temporary array
            const tuning =  "tuning" in presetsArray[i] ? presetsArray[i].tuning : "EQ";
            const sound =  "sound" in presetsArray[i] ? presetsArray[i].sound : "synthesized";
            const notes =  "notes" in presetsArray[i] ? presetsArray[i].notes : presetsArray[i]; // quite likely that it was just the old notes there from v 0.4.0

            if (! "tuning" in presetsArray[i]) { // probably in old format, replace with new one
                presetsArray[i] = {tuning:tuning, sound:sound, notes:notes}
            }

            console.log("getPresetsText: ", tuning, sound, notes);
            text  += tuning + ";" + sound + ";" + notes.join(",") + "\n"
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

    Connections {
            target: Qt.platform.os === "android" ? MediaButtonHandler : null
            function onPlay() { console.log("Play received in QML"); bourdonForm.playButton.checked = true; }
            function onPause() {
                console.log("Pause received in QML");
                bourdonForm.playButton.checked = false;
                bourdonForm.stopAll()
            }
            function onNext() {console.log("Next received in QML");  bourdonForm.advancePreset(1); }
            function onPrevious() {console.log("Previous received in QML"); bourdonForm.advancePreset(-1); }
    }


    Component.onCompleted: {
        presetsArray = JSON.parse(appSettings.presetsArray)
        //bourdonForm.presetForm.presetText.text = getPresetsText()
        // Assuming presetsArray is available in the context
        bourdonForm.presetForm.presetList.model.clear()

        for (var i = 1; i < presetsArray.length; i++) { // skip the first as this is for preset 0
            console.log("i, preset:", i, presetsArray[i].tuning, presetsArray[i].sound, presetsArray[i].notes)
            bourdonForm.presetForm.presetList.model.append({
                                        nr: i,
                                        tuning: presetsArray[i].tuning,
                                        sound: presetsArray[i].sound,
                                        notes: presetsArray[i].notes.join(","),
                                        volumeCorrection: presetsArray[i].volumeCorrection ? presetsArray[i].volumeCorrection : 0
                                    });
        }
    }


    FocusScope { // for catching Bluehtooth media keys
        anchors.fill: parent
        focus: true

        Keys.onPressed: (event) => {
                            console.log("Key pressed:", event.key)

                            if (event.key === Qt.Key_MediaPlay) {
                                console.log("MediaPlay key was pressed!")
                                bourdonForm.playButton.checked = true
                            }

                            if (event.key === 16777349) {
                                console.log("MediaStop key was pressed!")
                                bourdonForm.playButton.checked = false
                                bourdonForm.stopAll() // in case playBotton.checked was already false
                            }

                            if (event.key === Qt.Key_MediaNext) {
                                console.log("MediaNext key was pressed!")
                                bourdonForm.advancePreset(1);
                            }

                            if (event.key === Qt.Key_MediaPrevious) {
                                console.log("MediaNext key was pressed!")
                                bourdonForm.advancePreset(-1);
                            }


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
                //test:
                //getAudioDevices()
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

                const preset = {
                    tuning: tunings[tuningCombobox.currentIndex],
                    sound: soundTypes[soundTypeCombobox.currentIndex],
                    notes: []
                };
                for (let i=0; i<bourdonButtons.length; i++) {
                    const b = bourdonButtons[i];
                    if (b.checked) {
                        preset.notes.push(b.text)
                    }
                }
                console.log("Preset from buttons: ", preset)

                return preset;
            }


            function playFromPreset(preset) { // preset is an array of the notest to be played like [G,d,e]
                var tuning = preset.tuning
                var sound = preset.sound
                console.log("Play from preset:", tuning, sound, preset.notes)

                if (!preset.notes || preset.notes.length===0) {
                    console.log("No notes in preset", preset)
                    return
                }

                for  (let note of preset.notes) {
                    const index = app.bourdonNotes.indexOf(note);
                    if (index>=0) {
                        const b = bourdonButtons[index];
                        b.checked = true;
                    }
                }
            }


            soundTypeCombobox.onCurrentIndexChanged:
                csound.setChannel("type", soundTypeCombobox.currentIndex)


            tuningCombobox.onCurrentIndexChanged:
                csound.setChannel("tuning", tuningCombobox.currentIndex)

            function updatePresetLabelText() {
                presetLabel.text = currentPreset.toString() + " " + presetsArray[currentPreset].notes.join(",");

            }

            function updateComboBoxes() {
                console.log("UpdateComboboxes: ", presetsArray[currentPreset].tuning, presetsArray[currentPreset].sound )
                tuningCombobox.currentIndex = tunings.indexOf(presetsArray[currentPreset].tuning)
                soundTypeCombobox.currentIndex = soundTypes.indexOf(presetsArray[currentPreset].sound)
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
                updateComboBoxes()
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
                //advancePreset(1);
                checkDoublePress()
            }

            // TODO: implement double click also on double click
            //nextButton.onDoubleClicked: advancePreset(-1)

            stopButton.onClicked: stopAll()

            addButton.onClicked: {
                const preset = getPresetFromButtons()
                if (preset.notes.length>0) {
                    presetsArray.push(preset)
                    appSettings.presetsArray = JSON.stringify(presetsArray);
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


}
