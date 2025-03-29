import QtQuick
import QtQuick.Controls
import QtQuick.Controls.Material
import QtQuick.Layouts
import Qt.labs.qmlmodels

Rectangle {
    width: 400
    height: 600

    //color: "darkgreen" //Material.backgroundColor
    anchors.fill: parent

    color: Material.backgroundColor;
    radius: 4

    gradient: Gradient {
        GradientStop {
            position: 0.00;
            color: Material.backgroundColor;
        }
        GradientStop {
            position: 1.00;
            color: Material.backgroundDimColor;
        }
    }

    property alias presetList: presetList
    //property alias presetModel: presetModel
    property alias updateButton: updateButton


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


    ListView {
        id: presetList
        //width: parent.width
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.right: parent.right
        anchors.rightMargin: 10
        height: parent.height
        y: 40
        clip: true

        property int selectedIndex: -1
        property int rowHeight: 60

        // not sure if this is good, positionView -> visible would be better
        function scrollTo(index) {
            console.log("position view to: ", index)
            if (index >= 0 && index < model.count) {
                selectedIndex = index;
                contentY = index * presetList.rowHeight //rowDelegate.height;
            }
        }

        model: app.presetModel

        //test
        Component.onCompleted: {
            console.log("Preset Model Count:", app.presetModel ? app.presetModel.count : "Model undefined");
        }

        delegate: Rectangle {
            id: rowDelegate
            width: ListView.view.width
            height: presetList.rowHeight  // Set height explicitly
            color: presetList.selectedIndex === index ? Material.backgroundDimColor : "transparent"  // ✅ Highlight selected item
            radius: 8


            RowLayout {
                anchors.fill: parent
                property string soundValue: model.sound
                property string tuningValue: model.tuning
                spacing: 5

                Label {
                    Layout.leftMargin: 5

                    text: index+1
                    Layout.alignment: Qt.AlignHCenter
                }

                ComboBox {
                    background: Rectangle {
                        color: "transparent"
                    }
                    indicator: Item { width: 0; height: 0 }

                    model: [qsTr("Sample"), qsTr("Saw"), qsTr("Synth")]
                    currentIndex: parent.soundValue === "sample" ? 0 : (parent.soundValue === "saw" ? 1 : 2)
                    Layout.preferredWidth: 70
                    Layout.preferredHeight: rowDelegate.height
                }

                ComboBox {
                    background: Rectangle {
                        color: "transparent"
                    }
                    indicator: Item { width: 0; height: 0 }
                    model: app.tunings
                    currentIndex: app.tunings.indexOf(parent.tuningValue)
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
                        property var notes: model.notes

                        Repeater {
                            model: notes ? notes.split(",") : []

                            Rectangle {
                                Layout.alignment:  Qt.AlignVCenter
                                width: textItem.implicitWidth + 10
                                height: textItem.implicitHeight + 5
                                border.color: Material.frameColor
                                radius: 4
                                color: "transparent"

                                Label {
                                    id: textItem
                                    text: modelData
                                    anchors.centerIn: parent
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        console.log("Clicked note: ", modelData)
                                        // if (notes) {
                                        //     var noteArray = notes.split(",");
                                        //     if (noteArray.length > 1) {
                                        //         noteArray.splice(index, 1);
                                        //         model.notes = noteArray.join(",");
                                        //     } else {
                                        //         model.notes = "";
                                        //     }
                                        }
                                }
                            }
                        }
                    }
                }

                ToolButton {
                    text: "Sel."
                    // icon: select something
                    onClicked: {
                        console.log("listelement clicked: ", index, presetList.selectedIndex)
                        presetList.selectedIndex = index
                        bourdonForm.currentPreset= index+1 // TODO: maybe remove +1 and make presetArray and model the same
                    }
                }

                ToolButton {
                    text: "Ed."
                    // icon: edit something
                    onClicked: {
                        console.log("Edit mode: ", )
                        bourdonForm.editMode = !bourdonForm.editMode
                    }
                }
                ToolButton {
                    text: "Del."
                    // icon: delete something
                    onClicked: {
                        console.log("Delete mode: ", )
                        if (index >= 0) {
                            presetModel.remove(index)
                            if (presetList.selectedIndex === index) {
                                presetList.selectedIndex = -1
                            }
                            // + remove from array, too, if separate
                        }
                    }
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
