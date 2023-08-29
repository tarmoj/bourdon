import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material




Rectangle {
    width: 400
    height: 600
    color: Material.backgroundColor

    anchors.fill: parent

    Material.theme: Material.Dark


    ScrollView {
        id: presetView
        anchors.fill: parent
        anchors.margins: 10
//        width: parent.width*0.9
//        anchors.top: parent.bo
//        anchors.topMargin: 10
//        anchors.bottom: parent.bottom
//        anchors.bottomMargin:  10

        //anchors.horizontalCenter: parent.horizontalCenter

        TextArea {
            id: presetArea
            anchors.fill: parent

            //background: Rectangle { anchors.fill: parent }

            text: "G,d\nF,c"

        }

    }




}
