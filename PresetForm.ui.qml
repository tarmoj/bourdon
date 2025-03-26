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
    property alias presetList: presetList
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


    // tryout for delegate


        ListView {
            id: presetList
            width: parent.width
            height: parent.height
            y: 40
            model: ListModel {
                id: presetModel
                ListElement { nr: 1; tuning: "G"; sound: "sample"; notes: "G,g,c1"; volumeCorrection: 0 }
                ListElement { nr: 2; tuning: "F"; sound: "saw"; notes: ""; volumeCorrection: 0 }
            }

            delegate: Item {
                id: rowDelegate
                width: ListView.view.width
                height: 60  // Set height explicitly
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.right: parent.right

                RowLayout {
                    anchors.fill: parent
                    // property int vSize: parent.height
                    //spacing: 5

                    Label {
                        text: model.nr
                        Layout.alignment: Qt.AlignHCenter
                    }

                    ComboBox {
                        background: Rectangle {
                            color: "transparent"
                        }
                        indicator: Item { width: 0; height: 0 }

                        model: [qsTr("Sample"), qsTr("Saw"), qsTr("Synth")]
                        currentIndex: model.sound === "sample" ? 0 : model.sound === "saw" ? 1 : 2
                        Layout.preferredWidth: 70
                        Layout.preferredHeight: rowDelegate.height
                    }

                    ComboBox {
                        background: Rectangle {
                            color: "transparent"
                        }
                        indicator: Item { width: 0; height: 0 }
                        model: app.tunings
                        Layout.preferredWidth: 55
                        Layout.preferredHeight: rowDelegate.height
                    }

                    Item {
                        Layout.preferredHeight: rowDelegate.height
                        Layout.fillWidth: true

                        MouseArea {
                            anchors.fill: parent
                        }

                        RowLayout {
                            spacing: 5
                            height: parent.height

                            Repeater {
                                model: parent.model.notes.split(",")

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


                    RoundButton {
                        text: "Vol."

                    }

                    // Dial {
                    //     from: -48
                    //     to: 12
                    //     scale: 0.6
                    //     Layout.preferredHeight:  rowDelegate.height
                    //     Layout.maximumWidth: rowDelegate.heightvSize
                    //     Layout.alignment:  Qt.AlignRight
                    //     value: model.volumeCorrection

                    //     Label {
                    //         anchors.horizontalCenter: parent.horizontalCenter
                    //         anchors.top: parent.top
                    //         anchors.topMargin: -20
                    //         text: parent.value.toFixed(1) + " dB"
                    //     }
                    // }
                }
            }

        }

}
