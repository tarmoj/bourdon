import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Rectangle {
    width: 400
    height: 600
    color: "lightgreen"

    gradient: Gradient {
        GradientStop { position: 0.0; color: Material.backgroundColor }  // Material background
        GradientStop { position: 1.0; color: "darkgreen" }  // Dark Green
    }

    property alias individualVolume: individualVolumeCheckbox.checked

    ColumnLayout {
        id: volumeColumn
        anchors.fill: parent
        anchors.margins: 10
        spacing: 5

        Label {
            font.pointSize: 16
            font.bold: true

            text: qsTr("Volumes")
        }

        RowLayout {
            spacing: 5

            Label {
                text: qsTr("Preset: ")
            }

            SpinBox {
                from: 1
                to: app.presetModel.count
                value: 1

                onValueChanged: {
                    bourdonForm.currentPreset = value-1
                }
            }
        }

        RowLayout {
            spacing: 5
            width: parent.width
            //anchors.horizontalCenter: parent.horizontalCenter

            Label {
                text: qsTr("Preset volume: ")
            }

            Slider {
                id: presetVolume
                from: -48
                to: 12
                stepSize: 0.1
                onValueChanged: {
                    presetVolumeLabel.text = presetVolume.value.toFixed(1) + " dB"
                    csound.setChannel("volumeCorrection", presetVolume.value)
                    presetModel.set(bourdonForm.currentPreset, {"volumeCorrection": presetVolume.value})
                }
            }

            Label {
                id: presetVolumeLabel
                text: presetVolume.value.toFixed(1) + " dB"
            }

            Button {
                text: qsTr("Reset")
                onClicked: {
                    presetVolume.value = 0
                }
            }

        }

        RowLayout {
            spacing: 5

            Label {
                text: qsTr("Adjust individually:" )
            }

            CheckBox {
                id: individualVolumeCheckbox
                checked: false
            }

            Button {
                enabled: individualVolumeCheckbox.checked
                text: qsTr("Reset all")
                onClicked: {
                    for (var i = 0; i < volumeRepeater.count; i++) {
                        let item = volumeRepeater.itemAt(i);
                        if (item) item.volume = 0;
                    }
                }
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 2
            Repeater {
                id: volumeRepeater
                model: app.bourdonNotes.length
                delegate: BourdonVolume {
                    bourdonIndex: model.index
                    Layout.fillWidth: true
                    enabled: individualVolumeCheckbox.checked
                }

            }
        }



        Item { // spacer
            Layout.fillHeight:  true
        }
    }

}
