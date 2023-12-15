import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Controls.Material

ToolButton {

    checkable: true
    property int sound: 0

    onCheckedChanged: {
        const instrument = "1."+sound.toString()
        let scoreLine = "";
        if (checked) {
            scoreLine = `i ${instrument} 0 -1 ${sound}`;
        } else {
            scoreLine = `i -${instrument} 0 -0 ${sound}`;
        }
        //app.readScore(scoreLine); // this does not, when no QCoreApplication::processEvents() in while loop...
        csound.readScore(scoreLine) // this works
    }

    onClicked: {


        // if in prest 0 (tryout mode), set/update the preset:
        console.log("Clicked")
        if (bourdonForm.currentPreset==0) {

            app.presetsArray[0] =  bourdonForm.getPresetFromButtons()
            bourdonForm.presetZeroChanged()
        }
//        const time = new Date().getTime()%1000000;
//        console.log(scoreLine, time);

    }

    // add clear border
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: 4
        border.color:  "lightyellow"
        border.width: parent.checked? 2 : 0
    }


}
