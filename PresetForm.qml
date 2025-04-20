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
        id: mixerViewButton
        anchors.right: parent.right
        anchors.rightMargin: 5
        icon.source: "qrc:/images/equalizer.png"
        onClicked: {
            app.mainView.currentIndex = 1
        }
    }


    ListView {
        id: presetList
        anchors.fill: parent
        anchors.topMargin: 40
        anchors.leftMargin: 5
        clip: true

        property int selectedIndex: -1
        property int rowHeight: 60

        // not sure if this is good, positionView -> visible would be better
        onSelectedIndexChanged: {
            console.log("selectedIndex changed: ", selectedIndex)
            if (selectedIndex >= 0) {
                positionViewAtIndex(selectedIndex, ListView.Beginning)
            }
        }

        model: app.presetModel


        delegate: Rectangle {
            id: rowDelegate
            width: ListView.view.width
            height: presetList.rowHeight  // Set height explicitly
            property bool isSelected: presetList.selectedIndex === index
            color: isSelected ? Material.backgroundDimColor : "transparent"  // ✅ Highlight selected item
            radius: 5

            RowLayout {
                anchors.fill: parent
                anchors.margins: 5
                property int soundValue: model.sound
                property string tuningValue: model.tuning
                spacing: 2

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
                    Layout.preferredWidth: 70
                    Layout.preferredHeight: rowDelegate.height

                    currentIndex: parent.soundValue

                    onCurrentIndexChanged: {
                        app.presetModel.set(index, { "sound": currentIndex })
                        if (rowDelegate.isSelected) { // set it also on master combobox
                            bourdonForm.soundTypeCombobox.currentIndex = currentIndex
                        }
                    }
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

                    onCurrentValueChanged: {
                        app.presetModel.set(index, { "tuning": currentText })
                        if (rowDelegate.isSelected) { // set it also on master combobox
                            bourdonForm.tuningCombobox.currentIndex = currentIndex
                        }
                    }
                }

                Item {
                    Layout.preferredHeight: rowDelegate.height
                    Layout.fillWidth: true

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            if (isSelected) {
                                presetList.selectedIndex = -1
                                bourdonForm.currentPreset = -1
                                bourdonForm.sandBoxButton.clicked()
                            } else {
                                presetList.selectedIndex = index
                                bourdonForm.currentPreset = index
                            }
                        }
                    }

                    RowLayout {
                        spacing: 5
                        height: parent.height
                        clip:true
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
                            }
                        }
                    }
                }


                ToolButton {
                    id: upButton
                    icon.source: "qrc:/images/move_up.svg"
                    visible: index > 0
                    padding: 2
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24

                    onClicked: {
                        if (index > 0) {
                            presetModel.move(index, index - 1, 1)
                            presetList.selectedIndex = index
                            bourdonForm.currentPreset = presetList.selectedIndex
                            app.savePresets() // maybe better to do it on app level as movePreset(index, index - 1)
                        }
                    }

                }

                ToolButton {
                    id: downButton
                    //icon.name: "arrow_downward"
                    icon.source: "qrc:/images/move_down.svg"
                    visible: index < presetList.model.count - 1
                    padding: 2
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24

                    onClicked: {
                        if (index < presetList.model.count - 1) {
                            presetModel.move(index, index + 1, 1)
                            presetList.selectedIndex = index
                            bourdonForm.currentPreset = presetList.selectedIndex
                            app.savePresets() // maybe better to do it on app level as movePreset(index, index + 1)
                        }
                    }
                }


                ToolButton {
                    //icon.name: "delete"
                    icon.source: "qrc:/images/delete.svg"
                    padding: 2
                    Layout.preferredWidth: 24
                    Layout.preferredHeight: 24

                    onClicked: {
                        if (index >= 0) {
                            presetModel.remove(index)
                            if (presetList.selectedIndex === index) {
                                presetList.selectedIndex = -1
                            }
                            app.savePresets() // maybe better to do it on app level as removePreset(index)
                        }
                    }
                }

            }
        }

    }

}
