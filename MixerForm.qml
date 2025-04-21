import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Rectangle {
    id: mixerForm
    width: 400
    height: 600
    color: Material.backgroundColor

    gradient: Gradient {
        GradientStop { position: 0.0; color: Material.backgroundColor }  // Material background
        GradientStop {
            position: 0.5
            color: "#002200"
        }
        GradientStop { position: 1.0; color: "#005500" }  // Dark Green
    }

    property alias individualVolume: individualVolumeCheckbox.checked

    function updateVolumeFromPreset() {
        if (bourdonForm.currentPreset < 0) {
            presetVolume.value = 0
            return
        }

        const item = presetModel.get(bourdonForm.currentPreset)
        const field = "volumeCorrection"

        if (item && field in item) {
            presetVolume.value = item[field]
        } else {
            presetVolume.value = 0
        }
    }

    Connections {
        target: bourdonForm

        function onCurrentPresetChanged() {
            updateVolumeFromPreset()
            if (presetIndexSpinbox.value !== bourdonForm.currentPreset + 1) {
                presetIndexSpinbox.value = bourdonForm.currentPreset + 1
            }

        }
    }

    ColumnLayout {
        id: volumeColumn
        anchors.fill: parent
        anchors.margins: 10
        spacing: 5


        RowLayout {
            spacing: 5

            ToolButton {
                id: bourdonViewButton
                icon.source: "qrc:/images/arrow_back.svg"
                onClicked: {
                    app.mainView.currentIndex = 0
                }
            }

            Item {Layout.fillWidth: true}

            Label {
                text: qsTr("Preset: ")
            }

            SpinBox {
                id: presetIndexSpinbox
                from: 0
                to: app.presetModel.count
                value: 0

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
                value: 0
                Layout.preferredWidth: 80
                Layout.fillWidth: true

                onValueChanged: {
                    presetVolumeLabel.text = presetVolume.value.toFixed(1) + " dB"
                    csound.setChannel("volumeCorrection", presetVolume.value)
                    if (bourdonForm.currentPreset>=0) {
                        presetModel.set(bourdonForm.currentPreset, {"volumeCorrection": presetVolume.value})
                    }
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
            flow: GridLayout.TopToBottom
            rows: Math.round(app.bourdonNotes.length / 2)
            

            Repeater {
                id: volumeRepeater
                model: app.bourdonNotes.length
                delegate: BourdonVolume {
                    bourdonIndex: model.index
                    Layout.fillWidth: true
                    //enabled:  individualVolumeCheckbox.checked
                }

            }
        }



        Item { // spacer
            Layout.fillHeight:  true
        }
    }

}
