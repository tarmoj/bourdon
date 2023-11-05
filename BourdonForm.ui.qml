import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Item {
    width: 300
    height: 600
    anchors.fill: parent
    //property alias sawWaveSwitch: sawWaveSwitch
    property alias addButton: addButton
    property alias stopButton: stopButton
    property alias bourdonButtonGrid: bourdonButtonGrid

    property alias bourdonButtons: bourdonButtons
    property alias playButton: playButton
    property alias nextButton: nextButton
    property alias presetLabel: presetLabel
    property alias bourdonArea: bourdonArea
    property alias a4SpinBox: a4SpinBox
    property alias soundTypeCombobox: soundTypeCombobox

    property int roundedScale: Material.ExtraSmallScale

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
    }

    ColumnLayout {
        id: column
        anchors.fill: parent
        spacing: 10

        Item {
            id: configRow
            Layout.fillWidth: true
            Layout.preferredHeight: a4SpinBox.height + 4

            RowLayout {
                anchors.fill: parent

                ComboBox {
                    id: soundTypeCombobox
                    model: [qsTr("Sample"), qsTr("Saw wave"), qsTr("Snthesized") ]
                }

//                Switch {
//                    id: sawWaveSwitch
//                    text: qsTr("Use saw wave")
//                }

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
                }
            }
        }

        RowLayout {
            id: stopAndAddRow
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            spacing: 10

            ToolButton {
                id: stopButton
                icon.source: "qrc:/images/stop-button.png"
                //text: qsTr("Stop all")
            }

            Item {
                Layout.fillWidth: true
            }


            ToolButton {
                id: addButton
                icon.source: "qrc:/images/add.png"
                //text: "+" // qsTr("Add to presets")
                //Material.roundedScale: roundedScale
            }
        }

        Item {
            id: bourdonArea

            Layout.preferredHeight: column.height * 0.3 //bourdonButtonGrid.height //
            Layout.fillWidth: true

            GridLayout {
                id: bourdonButtonGrid
                width: parent.width * 0.95
                columns: 6 //width / bourdonButtons.itemAt(0).width

                anchors.horizontalCenter: parent.horizontalCenter

                Repeater {
                    id: bourdonButtons
                    model: ["G", "c", "d", "e", "g", "a", "h", "c1", "d1", "e1", "g1", "a1", "h1"]

                    BourdonButton {
                        required property int index
                        required property string modelData
                        sound: index + 1
                        text: modelData
                        Material.roundedScale: roundedScale
                    }
                }
            }
        }

        Item {
            id: controlArea

            Layout.fillWidth: true

            Row {
                id: mainButtonRow
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20

                Button {
                    id: nextButton
                    width: Math.min(column.width, column.height) / 3
                    height: width
                    text: "NEXT"
                    Material.roundedScale: roundedScale
                }

                Button {
                    id: playButton
                    width: nextButton.width
                    height: width
                    text: qsTr("Play/Stop")
                    checkable: true
                    checked: false
                    Material.roundedScale: roundedScale
                }
            }

            Row {
                id: presetLabelRow
                //anchors.left: mainButtonRow.left
                anchors.top: mainButtonRow.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.topMargin: 20
                spacing: 20

                Label {
                    font.pointSize: 18
                    text: qsTr("Current preset: ")
                    anchors.verticalCenter: parent.verticalCenter
                }

                Label {
                    id: presetLabel
                    font.pointSize: 22
                    font.bold: true
                    text: "0"
                }
            }
        }

        Item {
            Layout.fillHeight: true
        } // spacer
    }
}
