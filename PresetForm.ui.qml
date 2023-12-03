import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material

Item {
    width: 400
    height: 600

    //color: "darkgreen" //Material.backgroundColor
    anchors.fill: parent
    property alias presetText: presetText
    property alias updateButton: updateButton
    //signal textChanged(): presetText.textChanged()


    Label {
        x: 15; y:10
        font.pointSize: 14
        text: qsTr("Presets")
    }

    Rectangle {
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


    ScrollView {
        id: presetView
        anchors.fill: parent
        anchors.topMargin: 30
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        anchors.bottomMargin: 10


        TextArea {
            y:20
            id: presetText
            font.pointSize: 14

            background: Rectangle {
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
                border.color:  presetArea.focus ?  Material.accentColor : Material.frameColor
                border.width: presetArea.focus ? 1.5 : 1
                radius: 8
            }
            text: "G,d\nF,c"
        }
    }
}
