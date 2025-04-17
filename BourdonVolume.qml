import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    width:  500
    height: 40
    enabled: mixerFrom.individualVolume
    property int bourdonIndex: 0
    property alias volume: bourdonSlider.value

    RowLayout {
        anchors.fill: parent
        //spacing: 5
        anchors.margins: 10

        Label {
            text: app.bourdonNotes[bourdonIndex]
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
                csound.setChannel("volume" + bourdonIndex, value)
                bourdonVolumeLabel.text = bourdonSlider.value.toFixed(1) + " dB"
                // TODO: set to model
                //presetModel.set(bourdonForm.currentPreset, {"volume"+i.toString(): 0})
            }

        }

        Label {
            Layout.maximumWidth: 30
            id:bourdonVolumeLabel
            text: bourdonSlider.value.toFixed(1) + " dB"
        }

        // Button {
        //     text: qsTr("Reset")
        //     onClicked: {
        //         bourdonSlider.value = 0
        //     }
        // }

    }

}
