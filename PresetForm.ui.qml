import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material


Item {
    width: 400
    height: 600

    anchors.fill: parent


    Row {
        id: titleRow
        width: parent.width

        Label {
            id: presetsTitle;
            anchors.horizontalCenter: parent.horizontalCenter
            font.pointSize: 14
            font.bold: true
            text: qsTr("Presets")
        }

    }


    ScrollView {
        id: presetView
        width: parent.width*0.9
        anchors.top: titleRow.bottom
        anchors.topMargin: 10
        anchors.bottom: parent.bottom
        anchors.bottomMargin:  10

        anchors.horizontalCenter: parent.horizontalCenter

        TextArea {
            id: presetArea
            background: Rectangle { anchors.fill: parent }

            placeholderText: "G,d\nF,c"
        }

    }


}
