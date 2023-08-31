import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Controls.Material

// Maybe Toolbutton
Button {

    checkable: true
    property int sound: 0


    onClicked: {
        const instrument = "1."+sound.toString()
        let scoreLine = "";
        if (checked) {
            scoreLine = `i ${instrument} 0 -1 ${sound}`;
        } else {
            scoreLine = `i -${instrument} 0 -0 ${sound}`;
        }

//        const time = new Date().getTime()%1000000;
//        console.log(scoreLine, time);
        //app.readScore(scoreLine); // this does not, when no QCoreApplication::processEvents() in while loop...
        csound.readScore(scoreLine) // this works
    }


}
