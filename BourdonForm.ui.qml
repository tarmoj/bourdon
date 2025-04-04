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
    property alias playButton: playButton
    property alias nextButton: nextButton
    property alias presetLabel: presetLabel
    property alias bourdonArea: bourdonArea
    property alias a4SpinBox: a4SpinBox
    property alias soundTypeCombobox: soundTypeCombobox
    property alias presetNullButton: presetNullButton
    property alias presetArea: presetArea
    property alias presetMouseArea: presetMouseArea
    property alias presetForm: presetForm
    property alias tuningCombobox: tuningCombobox

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


        Column {
            id: configArea // we need better name. not config any more
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
                    model: [qsTr("Sample"), qsTr("Saw wave"), qsTr("Snthesized") ]
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
                }
            }

            RowLayout {
                id: stopAndAddRow
                width: parent.width
                spacing: 10

                //TODO: remove stopButton
                ToolButton {
                    id: stopButton
                    visible: false
                    icon.source: "qrc:/images/stop-button.png"
                    //text: qsTr("Stop all")
                }

                ComboBox {
                    id: tuningCombobox
                    enabled: soundTypeCombobox.currentIndex>0 // only when not samples
                    currentIndex: 0
                    Layout.preferredWidth: 150
                    model: [qsTr("Equal temp."), qsTr("Natural G"), qsTr("Natural D"), qsTr("Natural A"), qsTr("Natural C")]
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

            RowLayout { // later place null button somewhere else
                width: parent.width
                spacing: 10

                ToolButton {
                    id: presetNullButton
                    text: qsTr("Preset 0")
                }
            }
        }


        Column {
            id: bourdonArea // name to: bourdonButtonArea

            //Layout.preferredHeight: column.height * 0.3 //bourdonButtonGrid.height //
            width: configArea.width
            anchors.horizontalCenter: parent.horizontalCenter
            //height: bourdonButtonGrid.height
            anchors.top: configArea.bottom


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
            anchors.top: bourdonArea.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            //Rectangle {anchors.fill: parent; color: "darkblue"}

            //anchors.bottom: presetArea.top
            RowLayout {
                id: mainButtonRow
                width: parent.width
                Layout.alignment: Qt.AlignHCenter

                //anchors.horizontalCenter: parent.horizontalCenter
                spacing: 30

                Button {
                    id: nextButton
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: "NEXT"
                    Material.roundedScale: roundedScale
                }

                Button {
                    id: playButton
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    text: qsTr("Play/Stop")
                    checkable: true
                    checked: false
                    Material.roundedScale: roundedScale
                }
            }

            Row {
                id: presetLabelRow
                Layout.alignment: Qt.AlignHCenter

                spacing: 20

                Label {
                    font.pointSize: 18
                    text: qsTr("Current preset: ")
                    fontSizeMode: Text.Fit
                    anchors.verticalCenter: parent.verticalCenter
                }

                Label {
                    id: presetLabel
                    font.pointSize: 22
                    font.bold: true
                    fontSizeMode: Text.Fit
                    text: "0"
                }
            }
        }



        Rectangle {
            id: presetArea
            width: parent.width-20
            height: parent.height - y//presetForm.height // work on this. anchors. top?
            anchors.horizontalCenter: parent.horizontalCenter
            property int maxY: Math.max(parent.height*0.75, (controlArea.y + controlArea.height + 10) )
            property int minY: soundTypeCombobox.y
            y: maxY

            color: Material.backgroundColor;
            radius: 8

                MouseArea {
                    id: presetMouseArea
                    anchors.fill: parent
                    drag.target: parent
                    drag.axis: Drag.YAxis
                    drag.minimumY: parent.minY
                    drag.maximumY: parent.maxY

                }


            PresetForm { id:presetForm }


        }



    }


}

