import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    width:  500
    height: 40
    enabled: mixerFrom.individualVolume
    property int bourdonIndex: 0

    RowLayout {
        //width: parent.width
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
                // TODO: set to Csound
                //csound.tableSet(app.volumeTable, bourdonIndex, value) // <- this is slow, also via signal slot...
                // try
                bourdonVolumeLabel.text = bourdonSlider.value.toFixed(1) + " dB"
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
