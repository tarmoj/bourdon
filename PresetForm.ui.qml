import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material

Item {
    width: 400
    height: 600

    //color: "darkgreen" //Material.backgroundColor
    anchors.fill: parent
    property alias presetArea: presetArea


    ScrollView {
        id: presetView
        anchors.fill: parent
        anchors.margins: 10

        TextArea {
            //anchors.margins: 20
            id: presetArea
            //anchors.fill: parent
            topPadding: 20
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
