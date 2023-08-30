import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material

Item {
    width: 300
    height: 600
    anchors.fill: parent
    property alias addButton: addButton
    property alias stopButton: stopButton
    property alias bourdonButtonGrid: bourdonButtonGrid

    property alias bourdonButtons: bourdonButtons
    property alias playButton: playButton
    property alias nextButton: nextButton
    property alias presetLabel: presetLabel
    property alias bourdonArea: bourdonArea

    property int roundedScale: Material.ExtraSmallScale

    ColumnLayout {
        id: column
        anchors.fill: parent
        spacing: 10

        //        Item {
        //            Layout.preferredHeight: column.height * 0.1
        //        } // spacer
        RowLayout {
            id: stopAndAddRow
            Layout.fillWidth: true
            Layout.leftMargin: 10
            Layout.rightMargin: 10
            spacing: 2

            Button {
                id: stopButton
                text: qsTr("Stop all")
                Material.roundedScale: roundedScale
            }

            Item {
                Layout.fillWidth: true
            }

            Button {
                id: addButton
                //icon.name: "add"
                text: qsTr("Add to presets")
                Material.roundedScale: roundedScale
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

                //spacing: 2
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
                    Material.roundedScale: Material.ExtraSmallScale
                }

                Button {
                    id: playButton
                    width: nextButton.width
                    height: width
                    text: qsTr("Play/Stop")
                    checkable: true
                    Material.roundedScale: Material.ExtraSmallScale
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
