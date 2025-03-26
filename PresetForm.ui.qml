import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Qt.labs.qmlmodels

Item {
    width: 400
    height: 600

    //color: "darkgreen" //Material.backgroundColor
    anchors.fill: parent
    //property alias presetText: presetText
    //property alias presetList: presetList
    //property alias presetModel: presetModel
    property alias updateButton: updateButton
    //signal textChanged(): presetText.textChanged()


    Label {
        x: 15; y:10
        font.pointSize: 14
        text: qsTr("Presets")
    }

    Rectangle { // the dragging line
        anchors.horizontalCenter: parent.horizontalCenter
        y: 15
        height: 2
        width: 100
        color: Material.backgroundDimColor
    }

    ToolButton {
        id: updateButton
        anchors.right: parent.right
        anchors.rightMargin: 10
        text: qsTr("Update")
    }

    RowLayout {
        y: 40
        width: parent.width
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        property int vSize: 60
        //spacing: 5

        Label {
            text: qsTr("No")
            Layout.alignment: Qt.AlignHCenter
        }

        ComboBox {
            background: Rectangle {
                color: "transparent"
            }
            indicator: Item { width: 0; height: 0 }

            //scale: 0.8
            model: ["Sample", "Saw", "Synth"]
            Layout.preferredWidth: 70
            Layout.preferredHeight: parent.vSize
        }

        ComboBox {
            background: Rectangle {
                color: "transparent"
            }
            indicator: Item { width: 0; height: 0 }
            model: ["EQ","G", "F", "C"]
            Layout.preferredWidth: 50
            Layout.preferredHeight: parent.vSize
        }

        Item {
            Layout.preferredHeight: parent.vSize
            Layout.fillWidth: true

            MouseArea {
                anchors.fill: parent
            }

            RowLayout {
                spacing: 5
                height: parent.height

                Repeater {
                    model: [ "G", "d" ]

                    Rectangle {
                        Layout.alignment:  Qt.AlignVCenter
                        width: textItem.implicitWidth + 10
                        height: textItem.implicitHeight + 5
                        border.color: Material.primaryColor
                        radius: 5
                        color: "transparent"

                        Label {
                            id: textItem
                            text: modelData
                            anchors.centerIn: parent
                        }
                    }
                }
            }
        }

        Dial {
            from: -48
            to: 12
            scale: 0.6
            Layout.preferredHeight:  parent.vSize
            Layout.maximumWidth: parent.vSize
            Layout.alignment:  Qt.AlignRight

            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: -20
                text: parent.value.toFixed(1) + " dB"
            }
        }


    }

/*
    TableModel {
        id: presetModel
        TableModelColumn { display: "nr" }
        TableModelColumn { display: "tuning" }
        TableModelColumn { display: "sound" }
        TableModelColumn { display: "notes" }
        TableModelColumn { display: "volume" }


        rows: [
            { nr: 1, tuning: "G", sound: "Bagpipe", notes: ["G","d"], volume: 0 }
        ]

    }

    TableView {
        id: presetView
        anchors.fill: parent
        columnSpacing: 5
        rowSpacing: 2
        clip: true

        model: presetModel


        delegate: Rectangle {
            //implicitHeight: 40
            //implicitWidth: tableView.columnWidths[column]
            width: parent.width
            border.color: "lightgray"
            color: "transparent"

            RowLayout {
                anchors.fill: parent
                spacing: 5

                // ✅ Column 0: "No" (Label with row number)
                Label {
                    visible: column === 0
                    text: model.nr
                    Layout.alignment: Qt.AlignHCenter
                }

                // ✅ Column 1: "Sound" (ComboBox: Sample, Saw, Synth)
                ComboBox {
                    visible: column === 1
                    model: ["Sample", "Saw", "Synth"]
                    currentIndex: model.sound === "Sample" ? 0 : model.sound === "Saw" ? 1 : 2
                    onActivated: model.sound = modelData
                }

                // ✅ Column 2: "Tuning" (ComboBox: values from app.tunings)
                ComboBox {
                    visible: column === 2
                    model: app.tunings  // Should be defined in C++ or another QML file
                    currentIndex: app.tunings.indexOf(model.tuning)
                    onActivated: model.tuning = modelData
                }

                // ✅ Column 3: "Notes" (Row of rounded rectangles)
                Row {
                    visible: column === 3
                    spacing: 5
                    Layout.fillWidth: true

                    Repeater {
                        model: model.notes

                        Rectangle {
                            width: textItem.implicitWidth + 10
                            height: textItem.implicitHeight + 5
                            border.color: "black"
                            radius: 5
                            color: "lightgray"

                            Label {
                                id: textItem
                                text: modelData
                                anchors.centerIn: parent
                            }
                        }
                    }
                }

                // ✅ Column 4: "Volume" (Dial with range -48 to 12)
                Dial {
                    visible: column === 4
                    from: -48
                    to: 12
                    value: model.volumeCorrection
                    onValueChanged: model.volumeCorrection = value
                    scale: 0.5
                    width: 40
                    height: 40
                }

            }



    }

*/

    // ScrollView {
    //     id: presetView
    //     anchors.fill: parent
    //     anchors.topMargin: 30
    //     anchors.leftMargin: 10
    //     anchors.rightMargin: 10
    //     anchors.bottomMargin: 10

    //     ListView {
    //         id: presetList
    //         width: parent.width
    //         height: parent.height
    //         y: 20
    //         model: ListModel {
    //             ListElement { nr: 1; tuning: "G"; sound: "Bagpipe"; notes: "G,d"; volumeCorrection: 0 }
    //             ListElement { nr: 2; tuning: "F"; sound: "Whistle"; notes: "F,c"; volumeCorrection: 0 }
    //             // Add more elements as needed
    //         }

    //         delegate: Rectangle {
    //             width: parent.width
    //             height: 40
    //             border.color: "lightgray"
    //             color: "transparent"
    //             RowLayout {
    //                 spacing: 10
    //                 width: parent.width
    //                 Label { text: nr; }
    //                 Label { text: tuning; }
    //                 Label { text: sound; }
    //                 Label {
    //                     text: notes
    //                     Layout.fillWidth: true
    //                 }
    //                 Dial {
    //                     Layout.preferredWidth: 24
    //                     Layout.preferredHeight: 24
    //                     Layout.fillWidth: true
    //                     from: -24
    //                     to: 12
    //                     value: volumeCorrection
    //                     onValueChanged: volumeCorrection = value
    //                 }
    //             }
    //         }
    //     }

    // }

}
