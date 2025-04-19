import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Item {

    width: 300
    height: 600
    //anchors.fill: parent


    property alias soundTypeCombobox: soundTypeCombobox // to expose it to presetForm
    property alias tuningCombobox: tuningCombobox
    property alias sandBoxButton: sandBoxButton

    property int roundedScale: Material.ExtraSmallScale


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


    function playFromPreset(preset) {
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

    function getPresetData() {
        if (currentPreset===-1) {
            console.log("Sandbox ")
            return app.sandBoxData
        } else {
          return presetModel.get(currentPreset);
        }
    }


    function updateComboBoxes() {
        var preset = getPresetData();
        console.log("Update comboboxes: ", preset.tuning, preset.sound)
        tuningCombobox.currentIndex = tunings.indexOf(preset.tuning)
        soundTypeCombobox.currentIndex = parseInt(preset.sound) //soundTypes.indexOf(preset.sound)
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


    onPresetChanged: {
      const preset = getPresetFromButtons();
      console.log("Notes in preset now: ", preset.notes, currentPreset)
      updatePresetModel(currentPreset, preset)
    }

    onSandboxChanged: {
      currentPreset = -1 ; // is it needed?
      sandboxNotesRepeater.model = app.sandBoxData.notes ? app.sandBoxData.notes.split(",") : []
    }

    onCurrentPresetChanged: {
        updateComboBoxes()
        if (isPlaying()) {
            stopAll();
            playFromPreset(getPresetData())
        }
        presetForm.presetList.selectedIndex = currentPreset
    }



    Rectangle {
        id: background
        anchors.fill: parent
        color: Material.backgroundColor

        gradient: Gradient {
            GradientStop {
                position: 0
                color: Material.backgroundColor
            }
            GradientStop {
                position: 0.5
                color: "#3c243d"
            }

            GradientStop {
                position: 1.00
                color: "#a8549d"
            }
        }


        Column {
            id: bourdonFormColumn
            width: parent.width-20
            anchors.horizontalCenter: parent.horizontalCenter
            //height: a4SpinBox.height + 4
            anchors.top: parent.top
            //anchors.leftMargin: 10
            //anchors.rightMargin: 10

            spacing: 5

            RowLayout {
                width: parent.width

                ComboBox {
                    id: soundTypeCombobox
                    currentIndex: 2
                    Layout.preferredWidth: 150
                    model: [qsTr("Sample"), qsTr("Saw wave"), qsTr("Synthesized") ]

                    onCurrentIndexChanged: {
                      csound.setChannel("type", currentIndex)
                      if (currentPreset>=0) {
                        presetModel.set(currentPreset, { "sound": currentIndex })
                        savePresets()
                      }
                    }
                }


                Item {
                    Layout.fillWidth: true
                }

                Label {
                    text: "A4:"
                }


                SpinBox {
                    id: a4SpinBox
                    scale: 0.75
                    from: 430
                    to: 450
                    editable: true
                    stepSize: 1
                    value: 440

                    onValueChanged: {
                        console.log("A4: ", value )
                        csound.setChannel("a4", value);
                    }
                }
            }

            RowLayout {
                id: stopAndAddRow
                width: parent.width
                spacing: 10


                ComboBox {
                    id: tuningCombobox
                    enabled: soundTypeCombobox.currentIndex>0 // only when not samples
                    currentIndex: 0
                    Layout.preferredWidth: 150
                    model: [qsTr("Equal temp."), qsTr("Natural G"), qsTr("Natural D"), qsTr("Natural A"), qsTr("Natural C")]

                    onCurrentIndexChanged: {
                      csound.setChannel("tuning", currentIndex)
                      if (currentPreset>=0) {
                        // TODO: bind loop: this sets model, model triggers currentIndexChane in presetForm and that this one...
                        presetModel.set(currentPreset, { "tuning": app.tunings[currentIndex] })
                        savePresets()
                      }
                    }
                }


                Item {
                    Layout.fillWidth: true
                }


                ToolButton {
                    id: mixerViewButton
                    icon.source: "qrc:/images/dj-mixer.png"
                    onClicked: {
                        app.mainView.currentIndex = 1
                    }
                }
            }



            RowLayout {
                width: parent.width
                spacing: 10

                ToolButton {
                    id: sandBoxButton
                    text: qsTr("Sandbox")

                    onClicked:  {
                        currentPreset = -1
                        if (isPlaying() || playButton.checked) {
                            stopAll()
                            playButton.checked = false
                        }
                    }
                }

                Repeater {
                    id: sandboxNotesRepeater
                    model: app.sandBoxData.notes ? app.sandBoxData.notes.split(",") : []

                    Rectangle {
                        Layout.alignment:  Qt.AlignVCenter
                        width: textItem.implicitWidth + 10
                        height: textItem.implicitHeight + 5
                        border.color: Material.frameColor
                        radius: 4
                        color: "transparent"

                        Label {
                            id: textItem
                            text: modelData
                            anchors.centerIn: parent
                        }
                    }
                }

                ToolButton {
                    icon.source: "qrc:/images/clear.png"
                    //icon.name: "delete"
                    visible: sandboxNotesRepeater.model.length>0
                    onClicked:  {
                        stopAll()
                        app.sandBoxData.notes = ""
                        sandboxNotesRepeater.model = app.sandBoxData.notes ? app.sandBoxData.notes.split(",") : []
                    }
                }




                ToolButton {
                    id: addButton
                    //icon.source: "qrc:/images/add.png"
                    text: qsTr("Add to presets")
                    //Material.roundedScale: roundedScale

                    onClicked: {
                      const preset = getPresetFromButtons()
                      if (preset.notes.length>0) {
                        addToPresetModel(preset)
                        savePresets();
                      } else {
                        console.log("No playing buttons")
                      }
                    }
                }

                Item {Layout.fillWidth: true}


            }
        }


        Column {
            id: bourdonButtonColumn

            width: bourdonFormColumn.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: bourdonFormColumn.bottom

            GridLayout {
                id: bourdonButtonGrid
                visible: true
                width: parent.width * 0.95
                columns: 8 //width / bourdonButtons.itemAt(0).width
                //

                anchors.horizontalCenter: parent.horizontalCenter

                BourdonButton {
                    Layout.row: 0
                    Layout.column: 5
                    Layout.fillWidth: true
                    sound: 1
                    text: "G"
                    Material.roundedScale: roundedScale
                }

                BourdonButton {
                    Layout.row: 0
                    Layout.column: 6
                    Layout.fillWidth: true

                    sound: 2
                    text: "A"
                    Material.roundedScale: roundedScale
                }

                Item {}

                Repeater {
                    model: ["c", "d", "e", "f", "fis", "g", "a", "h",
                            "c1", "d1", "e1", "f1", "fis1", "g1", "a1", "h1"]


                    BourdonButton {
                        Layout.fillWidth: true

                        required property int index
                        required property string modelData
                        sound: 2 + index + 1
                        text: modelData
                        Material.roundedScale: roundedScale
                    }
                }
            }
        }

        ColumnLayout {
            id: controlArea

            width: parent.width-20
            anchors.top: bourdonButtonColumn.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            //Rectangle {anchors.fill: parent; color: "darkblue"}

            RowLayout {
                id: mainButtonRow
                width: parent.width
                Layout.alignment: Qt.AlignHCenter

                spacing: 30

                Button {
                    id: nextButton
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: qsTr("Next/Prev.")
                    Material.roundedScale: roundedScale

                    onClicked: {
                        checkDoublePress()
                    }
                }

                Button {
                    id: playButton
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: qsTr("Play/Stop")
                    checkable: true
                    checked: false
                    Material.roundedScale: roundedScale

                    onCheckedChanged:  {
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



        Rectangle {
            id: presetArea
            width: parent.width-20
            height: parent.height - y - 5
            anchors.horizontalCenter: parent.horizontalCenter
            property int maxY: controlArea.y + controlArea.height + 10
            property int minY: soundTypeCombobox.y
            y: maxY

            color: Material.backgroundColor; // otherwise presetForm is semi-transparent
            radius: 8

                MouseArea {
                    id: presetMouseArea
                    anchors.fill: parent
                    drag.target: parent
                    drag.axis: Drag.YAxis
                    drag.minimumY: parent.minY
                    drag.maximumY: parent.maxY

                    onDoubleClicked: {
                        presetArea.y = (presetArea.y===presetArea.maxY) ? presetArea.minY : presetArea.maxY;
                    }


                }


            PresetForm {
                id:presetForm
                anchors.fill: parent
            }


        }



    }


}

