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
    property alias mainView: mainView


    // sandBox is sort of preset 0, for tryout, it is not used in next/previous preset
    property var sandBoxData: {"tuning": "EQ", "sound": 2, "notes":""}

    property var bourdonNotes: ["G", "A", "c", "d", "e", "f", "fis", "g", "a", "h", "c1", "d1", "e1", "f1", "fis1", "g1", "a1", "h1"] // make sure the notes are loaded to tables in Csound with according numbers (index+1)
    property double lastPressTime: 0
    property var tunings: ["EQ","G", "D", "A", "C"] // make sure that this is aligned with the widget and the logic in Csound
    property var soundTypes: ["sample", "saw", "synthesized"] // same - check the widget and Csound, when changed
    property int volumeTable: 303 // NB! make sure that it is the same in Csound code!

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
    signal tableSet(table: int, index: int, value: double)

    Connections { // for later: you can use also onClosing if ApplicationWindow is used
        target: Application
        function onAboutToQuit() {
            console.log("Bye!")
            csound.stop();
            savePresets()
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
        //currentIndex: 1

        BourdonForm {
            id: bourdonForm
            //anchors.fill: parent

            FocusScope { // for catching Bluehtooth media keys -- not tested with Swipeview!
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

            }
        }

        MixerForm {
            id: mixerForm
        }

    }



}
