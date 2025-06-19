import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Dialog {
    id: root

    width: app.width*0.9
    height: app.height*0.9
    anchors.centerIn: parent

    title: fileMode === "open" ? qsTr("Open Preset File") : qsTr("Save Preset File As")
    modal: true
    standardButtons: Dialog.Ok | Dialog.Cancel

    property string fileMode: "open" // or "save"
    property alias fileName: nameField.text
    property string selectedFilePath: ""
    property var fileList: []

    signal fileSelected(string fileUrl)

    // TODO: add rename & delete buttons
    // FIXME: show only filenames with .json...

    // Load files when dialog opens
    onVisibleChanged: {
        if (visible) {
            fileList = fileio.listPresets()
        }
    }

    ColumnLayout {
        spacing: 10
        anchors.fill: parent
        anchors.margins: 20

        ListView {
            id: fileView
            Layout.fillWidth: true
            Layout.preferredHeight: 150
            model: fileList
            clip: true
            delegate: ItemDelegate {
                width: fileView.width
                text: modelData
                onClicked: {
                    nameField.text = modelData
                }
            }
        }

        TextField {
            id: nameField
            placeholderText: fileMode === "save" ? qsTr("Enter new file name") : qsTr("Choose file")
            Layout.fillWidth: true
        }

        Label {
            id: errorLabel
            color: "red"
            visible: false
        }
    }

    onAccepted: {
        if (!nameField.text || nameField.text.trim() === "") {
            errorLabel.text = qsTr("Filename cannot be empty.")
            errorLabel.visible = true
            return
        }

        const basePath = fileio.documentsPath()
        const fullPath = basePath + "/" + nameField.text


        if (fileMode === "open" && !fileio.fileExists(fullPath)) {
            errorLabel.text = qsTr("File does not exist.")
            errorLabel.visible = true
            selectedFilePath = ""
            return
        } else {
            selectedFilePath = fullPath
        }



        fileSelected("file://" + fullPath)
        //console.log("selected file ", selectedFilePath)
        errorLabel.visible = false
    }

    onRejected: {
        errorLabel.visible = false
    }
}
