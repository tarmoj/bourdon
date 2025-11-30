import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Controls.Material

ToolButton {
    id: bourdonButton
    checkable: true
    property int sound: 0

    onCheckedChanged: {

        // if (bourdonForm.editMode) {
        //     // make changes in model but do not play
        //     bourdonForm.presetChanged();
        // } else {
            const instrument = "1."+sound.toString()
            let scoreLine = "";
            if (checked) {
                // Start Csound if not already running
                if (!csound.isPlaying()) {
                    csound.startCsound();
                }
                scoreLine = `i ${instrument} 0 -1 ${sound}`;
            } else {
                scoreLine = `i -${instrument} 0 -0 ${sound}`;
            }
            csound.readScore(scoreLine)
            
            // Stop Csound if no sound is playing after unchecking
            // Use fade time + 0.1 seconds to allow the sound to fade out
            if (!checked) {
                stopCsoundTimer.start()
            }
        // }
    }

    Timer {
        id: stopCsoundTimer
        interval: (app.fadeTime + 0.1) * 1000  // fade time + extra time for fade out
        running: false
        repeat: false
        onTriggered: {
            if (!bourdonForm.isPlaying()) {
                csound.stopCsound();
            }
        }
    }

    onClicked: {


        // if in preset 0 (sandbox mode), set/update the preset:
        console.log("Clicked")
        if (bourdonForm.currentPreset==-1) {

            app.sandBoxData =  bourdonForm.getPresetFromButtons()
            bourdonForm.sandboxChanged()
        } else {
            bourdonForm.presetChanged(); // make the changes in the model data
        }
    }

    // add clear border
    Rectangle {
        id: buttonBorder
        anchors.fill: parent
        color: "transparent"
        radius: 4
        border.color:  Material.frameColor //"lightyellow"
        border.width: parent.checked? 2 : 0


        // editmode -  as soon it is in, make everything blink but don't play
        Timer { // use some global variable for master borderwidth
            id: blinkTimer
            interval: 500
            running: bourdonForm.editMode && bourdonButton.checked
            repeat: true
            onTriggered: {
                parent.border.width = parent.border.width === 2 ? 0 : 2;
            }
        }
    }


}
