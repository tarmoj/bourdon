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

    // Load files when dialog opens
    onVisibleChanged: {
        if (visible) {
            fileList = fileio.listPresets()
            fileView.editingIndex = -1  // Clear any editing state
            errorLabel.visible = false  // Clear any error messages
        }
    }

    function setNewFileName(currentName, newName) {
        console.log("Renaming file: ", currentName, currentName);
        if (newName.trim() !== "" && newName !== currentName) {
            if (fileio.renameFile(currentName, newName.trim())) {
                // Refresh file list
                fileList = fileio.listPresets()
                nameField.text = newName.trim()
            } else {
                errorLabel.text = qsTr("Failed to rename file.")
                errorLabel.visible = true
            }
        }
        fileView.editingIndex = -1
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
            
            property int editingIndex: -1
            
            delegate: Rectangle {
                id: itemRect
                width: fileView.width
                height: 40
                color: mouseArea.containsMouse ? Qt.rgba(0, 0, 0, 0.1) : "transparent"
                border.color: Qt.rgba(0, 0, 0, 0.1)
                border.width: 1
                
                property bool isEditing: fileView.editingIndex === index
                
                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (!parent.isEditing) {
                            nameField.text = modelData
                        }
                    }
                    onPressAndHold: {
                        fileView.editingIndex = index
                        editField.text = modelData
                        editField.forceActiveFocus()
                        //editField.selectAll()
                    }
                }
                
                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 2
                    color: "transparent"
                    


                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 5
                        anchors.rightMargin: 5
                        spacing: 5
                        
                        // File name display/edit
                        Item {
                            width: parent.width - editButton.width - deleteButton.width - (parent.spacing * 2)
                            height: parent.height
                            
                            Label {
                                id: fileLabel
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData
                                visible: !itemRect.isEditing
                                elide: Text.ElideRight
                                width: parent.width
                            }
                            
                            TextField {
                                id: editField
                                anchors.verticalCenter: parent.verticalCenter
                                width: parent.width
                                visible: itemRect.isEditing
                                
                                onAccepted: {
                                    setNewFileName(modelData, text)
                                }
                                
                                onFocusChanged: {
                                    if (!focus && itemRect.isEditing) {
                                        // Cancel editing if focus lost
                                        fileView.editingIndex = -1
                                    }
                                }
                            }
                        }
                        
                        // Edit/Apply  button
                        Item {
                            width: 32
                            height: 32

                            ToolButton {
                                id: editButton
                                anchors.fill: parent
                                anchors.verticalCenter: parent.verticalCenter
                                icon.source: "qrc:/images/edit.svg"
                                icon.width: width/2
                                icon.height: height/2
                                visible:  !itemRect.isEditing

                                onClicked: {
                                    fileView.editingIndex = index
                                    editField.text = modelData
                                    editField.forceActiveFocus()
                                    //editField.selectAll()
                                }
                            }

                            ToolButton {
                                id: applyButton
                                anchors.fill: parent
                                anchors.verticalCenter: parent.verticalCenter
                                icon.source: "qrc:/images/check.svg"
                                icon.width: width/2
                                icon.height: height/2
                                visible:  itemRect.isEditing

                                onClicked: {
                                    setNewFileName(modelData, editField.text)
                                }
                            }
                        }
                        
                        // Delete button
                        ToolButton {
                            id: deleteButton
                            width: 32
                            height: 32
                            anchors.verticalCenter: parent.verticalCenter
                            icon.source: "qrc:/images/delete.svg"
                            icon.width: 16
                            icon.height: 16
                            
                            onClicked: {
                                if (fileio.deleteFile(modelData)) {
                                    // Refresh file list
                                    fileList = fileio.listPresets()
                                    // Clear name field if it was the deleted file
                                    if (nameField.text === modelData) {
                                        nameField.text = ""
                                    }
                                } else {
                                    errorLabel.text = qsTr("Failed to delete file.")
                                    errorLabel.visible = true
                                }
                            }
                        }
                    }
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

        const basePath = fileio.presetsPath()
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
