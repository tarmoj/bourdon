import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    width:  500
    height: visible ? 30 : 0 // hide when not visible. But keep it sill in the model  for easier data management
    property int bourdonIndex: 0
    property string bourdonNote: app.bourdonNotes[bourdonIndex]

    property bool isEnabled: ( bourdonForm.currentPreset < 0 && mixerForm.individualVolume)  ||
                             (bourdonForm.currentPreset>=0 && isNoteInCurrentPreset() &&  mixerForm.individualVolume )
    enabled: isEnabled
    property int smallFontSize: 10
    visible: bourdonForm.currentPreset < 0 || (bourdonForm.currentPreset>=0  && isNoteInCurrentPreset())
    property alias volume: volumeSlider.value
    property alias pan: panSlider.value


    function isNoteInCurrentPreset() {
        const currentPreset = app.presetModel.get(bourdonForm.currentPreset)
        const notes = currentPreset.notes.split(",")
        //console.log("isNoteInCurrentPreset notes: ", notes, app.bourdonNotes[bourdonIndex] )
        return notes.includes(app.bourdonNotes[bourdonIndex])
    }

    function updateEnabled() {
        isEnabled = ( bourdonForm.currentPreset < 0 && mixerForm.individualVolume)  ||
                (bourdonForm.currentPreset>=0 && isNoteInCurrentPreset() &&  mixerForm.individualVolume )
    }

    function updateVolumeAndPanFromPreset() {
        if (bourdonForm.currentPreset < 0) {
            volumeSlider.value = 0
            return
        }

        const item = presetModel.get(bourdonForm.currentPreset)
        const volumeChannel = "volume" + bourdonIndex
        const panChannel = "pan" + bourdonIndex

        if (item && volumeChannel in item && item[volumeChannel]!==undefined) {
            volumeSlider.value = item[volumeChannel]
        } else {
            volumeSlider.value = 0
        }

        if (item && panChannel in item && item[panChannel]!==undefined) {
            panSlider.value = item[panChannel]
        } else {
            panSlider.value = 0
        }
    }

    Connections {
        target: bourdonForm

        function onCurrentPresetChanged() {
            updateEnabled()
            updateVolumeAndPanFromPreset()
        }

        function onPresetChanged() {
            // TODO: check notes here app.presetModel.get(bourdonForm.currentPreset)?.notes
            //console.log("Preset changed received in BourdonVolume. Notes: ", app.presetModel.get(bourdonForm.currentPreset).notes) // this is received but the next has no effect.
            updateEnabled()
        }
    }

    Connections {
        target: mixerForm

        function onIndividualVolumeChanged() {
            updateEnabled()
        }
    }

    Component.onCompleted: updateVolumeAndPanFromPreset()


    RowLayout {
        anchors.fill: parent
        //spacing: 5
        anchors.margins: 10

        Label {
            text: bourdonNote
        }


        Slider {
            id: volumeSlider
            Layout.preferredWidth: 80
            Layout.fillWidth: true
            from: -48
            to: 12
            stepSize: 0.1
            value: 0

            onValueChanged: {
                const channel = "volume" + bourdonIndex
                csound.setChannel(channel, value)
                bourdonVolumeLabel.text = volumeSlider.value.toFixed(1) + " dB"
                if (bourdonForm.currentPreset >= 0) {
                    // Set the volume for the current preset
                    presetModel.set(bourdonForm.currentPreset, {[channel]: value})
                }
            }

        }

        Label {
            Layout.maximumWidth: 30
            id:bourdonVolumeLabel
            text: volumeSlider.value.toFixed(1) + " dB"
            font.pointSize: smallFontSize
        }

        Item { Layout.preferredWidth: 30} // small spacer


        Label {
            text: qsTr("L")
            font.pointSize: smallFontSize
        }
        Slider {
            id: panSlider
            Layout.preferredWidth: 80
            Layout.maximumWidth: 120
            Layout.fillWidth: true

            from: -1
            to: 1
            value: 0

            onValueChanged: {
                const channel = "pan" + bourdonIndex
                // scale value from -1..1 to 0..1
                csound.setChannel(channel, value) ; // NB pan -1...1 -  scale in Csound (then 0 wod give centre)
                if (bourdonForm.currentPreset >= 0) {
                    // Set the volume for the current preset
                    presetModel.set(bourdonForm.currentPreset, {[channel]: value})
                }

            }
        }

        Label {
            text: qsTr("R")
            font.pointSize: smallFontSize
        }
    }

}
