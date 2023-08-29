import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Controls.Material

Button {

    checkable: true
    property int sound: 0

    onClicked: {
        const instrument = "1."+sound.toString()
        let eventLine = "";
        if (checked) {
            eventLine = `i ${instrument} 0 -1 ${sound}`;
        } else {
            eventLine = `i -${instrument} 0 -0 ${sound}`;
        }

//        const time = new Date().getTime()%1000000;
//        console.log(eventLine, time);
        csound.csEvent(eventLine);
    }


}
