import QtQuick
import QtQuick.Window
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import QtQuick.Dialogs
//import Qt.labs.platform
import QtCore
import MyApp.FileIO 1.0 // for loading/saving files


// TODO: examine  switching   between presets (and sanbox)
// -  change the soundType after fadeout, otherwise might cause a jump in the spectrum

ApplicationWindow {
    id: app
    width: 520
    height: 720
    minimumWidth: 350
    visible: true
    property string version: "0.9.5"
    title: qsTr("Bourdon Player "+ version)

    color: Material.background

    flags: Qt.ExpandedClientAreaHint | Qt.NoTitleBarBackgroundHint

    property color backgroundColor: Material.background // expose to C++
    property alias presetModel: presetModel // expose it to PresetForm
    property alias mainView: mainView


    // sandBox is sort of preset 0, for tryout, it is not used in next/previous preset
    property var sandBoxData: {"tuning": "EQ", "sound": 1, "notes":""}

    property var bourdonNotes: ["G", "A", "c", "d", "e", "f", "fis", "g", "a", "h", "c1", "d1", "e1", "f1", "fis1", "g1", "a1", "h1"] // make sure the notes are loaded to tables in Csound with according numbers (index+1)
    property double lastPressTime: 0
    property var tunings: ["EQ","G", "D", "A", "C", "E", "?!"] // make sure that this is aligned with the widget and the logic in Csound
    property var soundTypes: [ "saw", "synthesized", "custom"] // same - check the widget and Csound, when changed
    property int volumeTable: 303 // NB! make sure that it is the same in Csound code!


    property double slowFadeTime: 2  // this is set to true when a slow fade-in/fade-out is needed, for example when BT play/stop is pessed

    property double fadeTime: 0.1  // fade time for sound envelope, used when stopping Csound

    // property bool useSamples: false // enable samples in sound comboboxes



    ListModel {
        id: presetModel
        ListElement { tuning: "G"; sound: 0; notes: "G,g,d1";  }
    }

    //onWidthChanged: console.log("window width: ", width)


    Settings {
        id: appSettings
        property string presetsArray: ""
        property int a4: 440
        property string language: "ENG"
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


    Timer {
        id: btSoundsOffTimer

        onTriggered: {
            console.log("Turning faded out notes off")
            bourdonForm.stopAll()
            bourdonForm.playButton.checked = false;
            csound.readScore(`i "RestoreFadeLevel" 0.25 0`)
        }
        running: false
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

          // Convert notes array to a comma-separated string if needed
          if (Array.isArray(preset.notes)) {
            preset.notes = preset.notes.join(",");
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
      if (index < 0 || index >= presetModel.count) {
          console.warn("updatePresetModel: Invalid index", index, "model count:", presetModel.count)
          return
      }
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


    function savePresetsToFile(fileUrl) {
        savePresets();  // make sure appSettings.presetsArray is up to date

        const json = appSettings.presetsArray;
        const path = fileUrl.toString().replace("file://", "");  // still needed!
        console.log("Trying to save contents to: ", fileUrl, path)
        const ok = fileio.writeFile(path, json);
        if (!ok) console.error("Failed to save file");
    }

    function loadPresetsFromFile(fileUrl) {
        const path = fileUrl.toString().replace("file://", "");
        console.log("Read from file: ", fileUrl, path)
        const data = fileio.readFile(path);
        if (data) {
            appSettings.presetsArray = data;
            loadPresets();
        } else {
            console.error("Failed to load file");
        }
    }

    function fadeStart() {
        console.log("FADE START");
        // NO slow fade in for now
        //csound.readScore(`i "SlowFade" 0 ${slowFadeTime} 0`)
        bourdonForm.playButton.checked = true;
    }

    function fadeStop() {
        console.log("FADE STOP");
        // NO slow fade for now, just stop immediately
        //csound.readScore(`i "SlowFade" 0 ${slowFadeTime} 1`)
        //btSoundsOffTimer.start()
        bourdonForm.stopAll()
        bourdonForm.playButton.checked = false;
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
        id: toolBar
        width: parent.width
        // height: titleLabel.height + 20
        visible: mainView.currentIndex !== 0 // hide when LockForm is visible
        implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding

        background: Rectangle {color: "transparent" }

        topPadding: parent.SafeArea ? parent.SafeArea.margins.top : 10
        bottomPadding: 10

        contentItem:  Item {
            //anchors.fill: parent
            anchors.topMargin: 10
            implicitHeight: titleLabel.implicitHeight + 10

            //Rectangle {color: "green"; anchors.fill: parent; visible: true}

            Label {
                id: titleLabel
                anchors.centerIn: parent
                //anchors.verticalCenter: parent.verticalCenter
                text: "Bourdon  v" + app.version
                font.pointSize: 16
                font.bold: true
                horizontalAlignment: Qt.AlignHCenter

            }

            ToolButton {
                id: menuButton

                anchors.left: parent.left
                anchors.leftMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                icon.source: "qrc:/images/menu.svg"
                onClicked: drawer.opened ? drawer.close() : drawer.open()
            }
        }
    }

    MessageDialog { // maybe replace with normal Dialog later
            id: helpDialog
            buttons: MessageDialog.Ok

            text: qsTr(`Bourdon Player

is an app for bagpipe players (or why not other musicians) who want to play against long drone notes.

Build your chords from given bourdon notes, set the tuning, temperement and sound type.
You can set the relative volume of each preset, also the individual volumes of the bourdon notes.
You can start/stop the sound from bluetooth speaker or pedal.

Built using Csound sound engine and Qt framework.

(c) Tarmo Johannes trmjhnns@gmail.com`)

            onButtonClicked: function (button, role) { // does not close on Android otherwise
                switch (button) {
                case MessageDialog.Ok:
                    helpDialog.close()
                }
            }
    }

    Drawer {
        id: drawer
        //width is automatic
        height: app.height - toolBar.height
        y: toolBar.height
        property int marginLeft: 20

        background: Rectangle {anchors.fill:parent; color: Material.backgroundColor.lighter()}


        ColumnLayout {
            anchors.fill: parent
            spacing: 5
            visible: true


            ComboBox {
                id: languageComboBox
                visible: true

                Layout.leftMargin: drawer.marginLeft

                model: ["ENG", "EST", "SCO", "IRE"]

                onActivated: {
                    console.log("Language: ", currentText)
                    languageManager.switchLanguage(currentText)
                    appSettings.language = currentText
                }
            }

            MenuItem {
                text: qsTr("Load Presets")
                icon.source: "qrc:/images/open.svg"
                onTriggered: {
                    drawer.close()
                    loadDialogMobile.open()
                    if (Qt.platform.os === "ios" || Qt.platform.os === "android")  {
                        loadDialogMobile.open()
                    } else {
                        loadDialog.open();
                    }
                }
            }

            MenuItem {
                text: qsTr("Save Presets")
                icon.source: "qrc:/images/save.svg"
                onTriggered: {
                    drawer.close()
                    savePresetDialogMobile.open()
                    if (Qt.platform.os === "ios" || Qt.platform.os === "android")  {
                        savePresetDialogMobile.open()
                    } else {
                        saveDialog.open();
                    }
                }
            }

            // MenuItem {
            //     text: qsTr("Restart Sound Engine")
            //     icon.source: "qrc:/images/restart.svg"  // Using existing icon for now
            //     onTriggered: {
            //         drawer.close()
            //         csound.restartCsound()
            //     }
            // }

            // MenuItem {
            //     id: buyMeACoffeeItem
            //     icon.source: "qrc:/images/bmc-logo.svg"
            //     text: qsTr("Buy me a coffee")
            //     onTriggered: Qt.openUrlExternally("https://ko-fi.com/tarmojohannes")
            // }

            MenuItem {
                text: qsTr("Info")
                icon.source: "qrc:/images/info.svg"
                onTriggered: {
                    drawer.close()
                    helpDialog.open()
                }
            }


            // MenuItem {
            //     text: qsTr("TEST PLAY")
            //     onTriggered: {
            //         drawer.close()
            //         fadeStart()
            //     }
            // }

            // MenuItem {
            //     text: qsTr("TEST STOP")
            //     onTriggered: {
            //         drawer.close()
            //         fadeStop()
            //     }
            // }

            Item {Layout.fillHeight: true}

        }


    }

    FileIO {
        id: fileio
    }


    FileDialog {
        id: saveDialog
        title: qsTr("Save Presets to File")
        fileMode: FileDialog.SaveFile
        //currentFolder: StandardPaths.writableLocation(StandardPaths.MusicLocation) + "/Bourdon"
        currentFolder: StandardPaths.writableLocation(StandardPaths.DocumentsLocation)

        nameFilters: ["JSON files (*.json)", "All files (*)"]
        onAccepted: {
            let path = selectedFile.toString();
            // if (!path.endsWith(".json")) {
            //     path += ".json";
            // }
            savePresetsToFile(path)
        }
    }

    FileDialog {
        id: loadDialog
        title: qsTr("Load Presets from File")
        fileMode: FileDialog.OpenFile
        nameFilters: ["All files (*)"]
        onAccepted: {
            loadPresetsFromFile(selectedFile)
        }
    }

    // for iOS
    FileDialogMobile {
        id: loadDialogMobile


        fileMode: "open"

        onFileSelected: function(fileUrl) {
            console.log("Load from: ", fileUrl)
            loadPresetsFromFile(fileUrl)
        }

    }

    FileDialogMobile {
        id: savePresetDialogMobile
        fileMode: "save"

        onFileSelected: function(fileUrl) {
            console.log("Saving to", fileUrl)
            savePresetsToFile(fileUrl)
        }

    }




    Connections { // for later: you can use also onClosing if ApplicationWindow is used
        target: Application
        function onAboutToQuit() {
            console.log("Bye!")
            csound.stop();
            savePresets()
        }
    }

    Connections {
            target: Qt.platform.os === "android" || Qt.platform.os === "ios" ? MediaButtonHandler : null
            function onPlay() {
                console.log("Play received in QML");
                fadeStart()
            }
            function onPause() {
                console.log("Pause received in QML"); // acts as toggle pause
                if (bourdonForm.isPlaying()) {
                    fadeStop()
                } else {
                    fadeStart()
                }
            }

            function onStop() {
                console.log("Stop received in QML");
                fadeStop()

            }
            function onNext() {console.log("Next received in QML");  bourdonForm.advancePreset(1); }
            function onPrevious() {console.log("Previous received in QML"); bourdonForm.advancePreset(-1); }
    }


    Component.onCompleted: {
      if (appSettings.presetsArray) {
        loadPresets();
      }
      if (appSettings.language) {
        languageComboBox.currentIndex = languageComboBox.model.indexOf(appSettings.language)
        languageManager.switchLanguage(appSettings.language)
      } else {
        languageComboBox.currentIndex = 0
        languageManager.switchLanguage("EN")
      }
    }


    SwipeView {
        id: mainView
        anchors.fill: parent
        anchors.topMargin:10
        currentIndex: 1
        property bool disableFirst: true

        onCurrentIndexChanged: {
            if (disableFirst && currentIndex === 0)
                currentIndex = 1
        }

        LockForm {
        }

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
                                    fadeStart()
                                  }

                                  if (event.key === 16777349) {
                                    console.log("MediaStop key was pressed!")

                                    fadeStop()
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
