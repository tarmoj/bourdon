import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    width:  500
    height: 40
    property int bourdonIndex: 0
    property string bourdonNote: app.bourdonNotes[bourdonIndex]
    property alias volume: bourdonSlider.value
    //property string presetNotes: bourdonForm.currentPreset>=0 ? app.presetModel.get(bourdonForm.currentPreset)?.notes : ""
    property bool isEnabled: ( bourdonForm.currentPreset < 0 && mixerForm.individualVolume)  ||
                             (bourdonForm.currentPreset>=0 && isNoteInCurrentPreset() &&  mixerForm.individualVolume )
    enabled: isEnabled


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

    function updateVolumeFromPreset() {
        if (bourdonForm.currentPreset < 0) {
            bourdonSlider.value = 0
            return
        }

        const item = presetModel.get(bourdonForm.currentPreset)
        const channel = "volume" + bourdonIndex

        if (item && channel in item) {
            bourdonSlider.value = item[channel]
        } else {
            bourdonSlider.value = 0
        }
    }

    Connections {
        target: bourdonForm

        function onCurrentPresetChanged() {
            updateEnabled()
            updateVolumeFromPreset()
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

    Component.onCompleted: updateVolumeFromPreset()


    RowLayout {
        anchors.fill: parent
        //spacing: 5
        anchors.margins: 10

        Label {
            text: bourdonNote
        }

        Slider {
            id: bourdonSlider
            Layout.preferredWidth: 80
            Layout.fillWidth: true
            from: -48
            to: 12
            stepSize: 0.1
            value: 0

            onValueChanged: {
                const channel = "volume" + bourdonIndex
                csound.setChannel(channel, value)
                bourdonVolumeLabel.text = bourdonSlider.value.toFixed(1) + " dB"         
                if (bourdonForm.currentPreset >= 0) {
                    // Set the volume for the current preset
                    presetModel.set(bourdonForm.currentPreset, {[channel]: value})
                }
            }

        }

        Label {
            Layout.maximumWidth: 30
            id:bourdonVolumeLabel
            text: bourdonSlider.value.toFixed(1) + " dB"
        }

    }

}
