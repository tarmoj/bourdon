import QtQuick
import QtQuick.Controls


Rectangle {
    id: lockForm
    width: 400
    height: 600
    //anchors.fill: parent
    color: Material.backgroundColor
    property int unlockAttempts: 0

    gradient: Gradient {
        GradientStop {
            position: 0
            color: Material.backgroundColor
        }
        GradientStop {
            position: 0.5
            color: Material.backgroundColor.darker(1.2)
        }

        GradientStop {
            position: 1.00
            color: "black"
        }
    }

    MouseArea {
                anchors.fill: parent
                // To prevent swipes from being passed to SwipeView
                acceptedButtons: Qt.AllButtons
                preventStealing: true
                onPressed: {} // Required to consume the event
            }

    Label {
        id: centerLabel
        width: parent.width * 0.8
        height: implicitHeight
        anchors.bottom: unlockButton.top
        anchors.bottomMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: qsTr("Press the button below 4 times to go back to main view.")
    }

    Button {
        id: unlockButton
        anchors.centerIn: parent
        text: qsTr("Unlock: %1").arg(4-lockForm.unlockAttempts)
        onClicked: {
            lockForm.unlockAttempts += 1
            if (lockForm.unlockAttempts >= 4) {
                lockForm.unlockAttempts = 0
                app.mainView.setCurrentIndex(1)
            }
        }
    }
}


