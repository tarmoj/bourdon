import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtCore



ApplicationWindow {
    id: app
    width: 520
    height: 720
    minimumWidth: 350
    visible: true
    property string version: "0.7.0-alpha"
    title: qsTr("Bourdon app "+ version)

    property color backgroundColor: Material.background // expose to C++
    property alias presetModel: presetModel // expose it to PresetForm


    // sandBox is sort of preset 0, for tryout, it is not used in next/previous preset
    property var sandBoxData: {"tuning": "EQ", "sound": 2, "notes":""}

    property var bourdonNotes: ["G", "A", "c", "d", "e", "f", "fis", "g", "a", "h", "c1", "d1", "e1", "f1", "fis1", "g1", "a1", "h1"] // make sure the notes are loaded to tables in Csound with according numbers (index+1)
    property double lastPressTime: 0
    property var tunings: ["EQ","G", "D", "A", "C"] // make sure that this is aligned with the widget and the logic in Csound
    property var soundTypes: ["sample", "saw", "synthesized"] // same - check the widget and Csound, when changed


    ListModel {
        id: presetModel
        ListElement { tuning: "G"; sound: 0; notes: "G,g,c1"; volumeCorrection: 0 }
        ListElement { tuning: "C"; sound: 1; notes: "c,e,g"; volumeCorrection: 0 }
    }

    //onWidthChanged: console.log("window width: ", width)


    Settings {
        id: appSettings
        property string presetsArray: ""
    }


    Timer {
        id: singlePressTimer
        interval: 350 // Set the interval in milliseconds (adjust as needed)
        onTriggered: {
            //console.log("Single press detected!")
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


    function loadPresets() {
      if (appSettings.presetsArray) {
        var arr = JSON.parse(appSettings.presetsArray);
        presetModel.clear();
        for (var i = 0; i < arr.length; i++) {
          var preset = arr[i];

          // ✅ Convert notes array to a comma-separated string if needed
          if (Array.isArray(preset.notes)) {
            preset.notes = preset.notes;
          }
          presetModel.append(preset);  // Restore from array
        }
      }
    }

    function removePreset(index) {
        if (index >= 0 && index < presetModel.count) {
            presetModel.remove(index);
            savePresets();
        }
    }

    function updatePresetModel(index, preset) {
      console.log("insert to preset model: ", preset.tuning, preset.sound, preset.notes, index)
      presetModel.set(index, {
                           tuning: preset.tuning,
                           sound: preset.sound,
                           notes: preset.notes
                         })
      savePresets()
    }

    function addToPresetModel(preset) {
        console.log("Add to preset model: ", preset)
        presetModel.append({
            tuning: preset.tuning,
            sound: preset.sound,
            notes: preset.notes
        })
      savePresets()
    }

    function savePresets() {
        console.log("Saving presets to appSettings");
        var arr = [];
        for (var i = 0; i < presetModel.count; i++) {
            arr.push(presetModel.get(i));  // Convert ListModel to array
        }
        appSettings.presetsArray = JSON.stringify(arr);
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
      if (appSettings.presetsArray) {
        loadPresets();
      }
    }


    SwipeView {
        id: mainView
        anchors.fill: parent

        Page {

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("BourdonForm later here")
                font.pointSize: 16
                font.bold: true
            }

        }

        MixerForm {

        }

    }

    FocusScope { // for catching Bluehtooth media keys
        anchors.fill: parent
        focus: true
        visible: false

        Keys.onPressed: (event) => {
                          //console.log("Key pressed:", event.key)

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
            property int currentPreset: -1 // -1 for Sandbox
            property bool editMode: false

            property var bourdonButtons: []

            signal sandboxChanged;
            signal presetChanged;


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
                    sound: soundTypeCombobox.currentIndex, //soundTypes[soundTypeCombobox.currentIndex],
                    notes: "" // store as comma separated string
                };
                const noteArray = [];
                for (let i=0; i<bourdonButtons.length; i++) {
                    const b = bourdonButtons[i];
                    if (b.checked) {
                        noteArray.push(b.text)
                    }
                }
                preset.notes = noteArray.join(",")
                console.log("Preset from buttons: ", preset.notes)

                return preset;
            }


            function playFromPreset(preset) { // preset is an array of the notest to be played like [G,d,e]
                const tuning = preset.tuning
                const sound = preset.sound
                const notes = preset.notes.split(",")
                console.log("Play from preset:", tuning, sound, notes)

                if (notes.length===0) {
                    console.log("No notes in preset", preset)
                    return
                }
                for  (let note of notes) {
                    const index = app.bourdonNotes.indexOf(note);
                    if (index>=0) {
                        const b = bourdonButtons[index];
                        b.checked = true;
                    }
                }
            }

            onPresetChanged: {
              const preset = getPresetFromButtons();
              console.log("Notes in preset now: ", preset.notes, currentPreset)
              updatePresetModel(currentPreset, preset)
              updatePresetLabelText()
            }



            soundTypeCombobox.onCurrentIndexChanged: {
              csound.setChannel("type", soundTypeCombobox.currentIndex)
              //TODO: change it in the model, too
              if (currentPreset>=0) {
                presetModel.set(currentPreset, { "sound": soundTypeCombobox.currentIndex })
                savePresets()
              }
            }


            tuningCombobox.onCurrentIndexChanged: {
              csound.setChannel("tuning", tuningCombobox.currentIndex)
              if (currentPreset>=0) {
                // TODO: bind loop: this sets model, model triggers currentIndexChane in presetForm and that this one...
                presetModel.set(currentPreset, { "tuning": app.tunings[tuningCombobox.currentIndex] })
                savePresets()

              }
            }

            function getPresetData() {
                if (currentPreset===-1) {
                    console.log("Sandbox ")
                    return sandBoxData
                } else {
                  return presetModel.get(currentPreset);
                }
            }

            function updatePresetLabelText() {
              var preset = getPresetData();
              if (currentPreset===-1) {
                presetLabel.text = qsTr("Sandbox")
              } else {
                // maybe this is not needed any more soon, get rid of presetLabel
                presetLabel.text = qsTr("Preset") + " " + currentPreset.toString()
                presetLabel.text = (currentPreset+1).toString() + " " + preset.tuning + " " + soundTypes[preset.sound]
              }
              presetLabel.text += " " + preset.notes;

            }

            function updateComboBoxes() {
                var preset = getPresetData();
                console.log("Update comboboxes: ", preset.tuning, preset.sound)
                tuningCombobox.currentIndex = tunings.indexOf(preset.tuning)
                soundTypeCombobox.currentIndex = parseInt(preset.sound) //soundTypes.indexOf(preset.sound)
            }

            onSandboxChanged: {
              currentPreset = -1 ; // is it needed?
              updatePresetLabelText()
            }

            sandBoxButton.onClicked:  {
                currentPreset = -1
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
                    playFromPreset(getPresetData())
                }
                presetForm.presetList.selectedIndex = currentPreset
            }

            a4SpinBox.onValueChanged: {
                console.log("A4: ", a4SpinBox.value )
                //app.setChannel("a4", a4SpinBox.value)
                csound.setChannel("a4", a4SpinBox.value);
            }

            function advancePreset(advance=1) { // either +1 or -1
                let newPreset = currentPreset + advance
                if (newPreset >= presetModel.count ) { // TODO: replace with model
                    currentPreset = 0 ;
                } else if (newPreset<0) {
                    currentPreset = presetModel.count-1;
                } else {
                    currentPreset = newPreset
                }

                console.log("New preset: ", currentPreset)
            }

            nextButton.onClicked: {
                //advancePreset(1);
                checkDoublePress()
            }

            stopButton.onClicked: stopAll()

            addButton.onClicked: {
              const preset = getPresetFromButtons()
              if (preset.notes.length>0) {
                addToPresetModel(preset)
                savePresets();

              } else {
                console.log("No playing buttons")
              }
            }

            playButton.onCheckedChanged:  {

                // console.log("Playbutton checked: ", playButton.checked, bourdonForm.isPlaying() )

                if ( bourdonForm.isPlaying() ) {
                    playButton.checked = false; // stop will happen below
                }

                if (playButton.checked) {
                    var preset = getPresetData()
                    if (preset.length>0) {
                        // console.log("Starting: ", currentPreset, )
                        stopAll();
                    } else {
                        playButton.checked = false;
                    }

                    playFromPreset(preset );
                } else {
                    stopAll();
                }

            }

        }

    }


}
