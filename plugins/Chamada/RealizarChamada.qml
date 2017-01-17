import QtQuick 2.7
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.0

import "../../qml/components/"

Page {
    id: page
    title: qsTr("Student attendance")

    property int lesson_id: 0
    property int classes_id: 0
    property bool checkedAll: true

    property var configJson: {}
    property var checkedStatus: {}
    property var toolBarActions: ["save"]
    property var attendance: {"attendance": []};

    property string attendanceDate: ""
    property string toolBarState: "goback"
    property string defaultUserImage: "user-default.png"

    property list<MenuItem> toolBarMenuList: [
        MenuItem {
            text: "Exibir em " + (listView.visible ? "grade" : "lista")
            onTriggered: gridView.visible = !gridView.visible
        },
        MenuItem {
            text: checkedAll ? "Desmarcar todos" : "Marcar todos"
            onTriggered: {
                var attendanceTemp = attendance
                for(var key in attendanceTemp)
                    attendanceTemp[key].status = checkedAll ? "F" : "P"
                attendance = attendanceTemp
                checkedAll = !checkedAll
            }
        }
    ]

    function requestToSave() {
        if (!attendanceDate) {
            alert("Atenção!", "Você precisa informar a data referente a aula desta chamada", "Ok", function() { datePicker.open(); }, "Cancelar", function() {  });
            return;
        }
        jsonListModel.requestMethod = "POST"
        jsonListModel.requestParams = JSON.stringify(chamada)
        jsonListModel.source += "/student_attendance_register/"+lesson_id
        jsonListModel.load()
        jsonListModel.stateChanged.connect(function() {
            // after get server response, close the current page
            if (jsonListModel.state === "ready")
                popPage(); // is a function from Main.qml
        })
    }

    function actionExec(action) {
        if (action === "save")
            requestToSave();
    }

    function save(student_id, status) {
        for (var i = 0; i < attendance["attendance"].length; ++i) {
            if (attendance["attendance"][i].student_id && attendance["attendance"][i].student_id === student_id)
                attendance["attendance"].splice(i,1);
        }
        attendance["attendance"].push({"student_id": student_id, "status": status});
        var checkedStatusTemp = ({});
        checkedStatusTemp[student_id] = status;
        checkedStatus = checkedStatusTemp;
    }

    Component.onCompleted: {
        jsonListModel.source += "students_course_section/" + classes_id
        jsonListModel.load()
    }

    Connections {
        target: jsonListModel
        onStateChanged: {
            if (jsonListModel.state === "ready" && currentPage.title === page.title) {
                var modelTemp = jsonListModel.model;
                gridView.model = modelTemp;
            }
        }
    }

    DatePicker {
        id: datePicker
        onDateSelected: {
            attendanceDate = date.month + "-" + date.day + "-" + date.year;
            requestToSave();
        }
    }

    Component {
        id: gridViewDelegate

        Item {
            id: item
            width: gridView.cellWidth; height: gridView.cellHeight
            opacity: switchStatus.checked ? 0.75 : 1.0

            Rectangle {
                width: parent.width * 0.70; height: 1
                color: switchStatus.checked ? appSettings.theme.colorPrimary : appSettings.theme.colorAccent
                anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter }
            }

            Column {
                spacing: 15; width: 200; height: 300
                anchors { top: parent.top; topMargin: 10; horizontalCenter: parent.horizontalCenter }

                Image {
                    id: imgProfile
                    asynchronous: true
                    source: defaultUserImage
                    width: 35; height: 35
                    fillMode: Image.PreserveAspectCrop
                    clip: true; cache: true; smooth: true
                    sourceSize { width: width; height: height }
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Column {
                    spacing: 2
                    anchors.horizontalCenter: parent.horizontalCenter

                    Label {
                        text: id || ""
                        font.pointSize: 10
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Label {
                        text: email
                        font.pointSize: 8
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                Switch {
                    id: switchStatus
                    text: checkedStatus != null && checkedStatus[id] ? checkedStatus[id] : "P"
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.weight: Font.DemiBold
                    checked: switchStatus.text == "P"
                    onClicked: {
                        switchStatus.text = (switchStatus.text == "F" ? "P" : "F")
                        save(id, switchStatus.text)
                    }
                }
            }
        }
    }

    Component {
        id: listViewDelegate

        Column {
            spacing: 0; width: parent.width; height: 60

            Component.onCompleted: save(id, labelStatus.text);

            Rectangle {
                width: parent.width; height: parent.height - 1

                RowLayout {
                    spacing: 35
                    anchors.fill: parent
                    width: parent.width; height: parent.height
                    anchors.verticalCenter: parent.verticalCenter

                    Image {
                        id: imgProfile
                        asynchronous: true
                        width: 35; height: 35
                        source: defaultUserImage
                        fillMode: Image.PreserveAspectCrop
                        clip: true; cache: true; smooth: true
                        sourceSize { width: width; height: height }
                        anchors { left: parent.left; leftMargin: 15; verticalCenter: parent.verticalCenter }
                    }

                    Column {
                        spacing: 2
                        anchors { left: imgProfile.right; leftMargin: 15; verticalCenter: parent.verticalCenter }

                        Label {
                            text: email
                        }
                    }

                    RowLayout {
                        spacing: 15
                        anchors { right: parent.right; rightMargin: 15; verticalCenter: parent.verticalCenter }

                        CheckBox {
                            anchors.verticalCenter: parent.verticalCenter
                            checked: labelStatus.text == "P"
                            onClicked: {
                                labelStatus.text = (labelStatus.text == "F" ? "P" : "F")
                                save(id, labelStatus.text);
                            }
                        }

                        Label {
                            id: labelStatus
                            text: checkedStatus != null && checkedStatus[id] ? checkedStatus[id] : "P"
                            anchors.verticalCenter: parent.verticalCenter
                            color: text == "F" ? "red" : "blue"
                            font.weight: Font.DemiBold
                        }
                    }
                }
            }

            // draw a border separator
            Rectangle { color: "#ccc"; width: parent.width; height: 1 }
        }
    }

    BusyIndicator {
        id: busyIndicator
        antialiasing: true
        visible: jsonListModel.state === "running"
        anchors { top: parent.top; topMargin: 20; horizontalCenter: parent.horizontalCenter }
    }

    GridView {
        id: gridView
        visible: false
        anchors.fill: parent
        delegate: gridViewDelegate
        cellWidth: 180; cellHeight: cellWidth
        Keys.onUpPressed: gridViewScrollBar.decrease()
        Keys.onDownPressed: gridViewScrollBar.increase()
        ScrollBar.vertical: ScrollBar { id: gridViewScrollBar }
    }

    ListView {
        id: listView
        visible: !busyIndicator.visible && !gridView.visible
        anchors.fill: parent
        model: gridView.model
        delegate: listViewDelegate
        Keys.onUpPressed: listViewScrollBar.decrease()
        Keys.onDownPressed: listViewScrollBar.increase()
        ScrollBar.vertical: ScrollBar { id: listViewScrollBar }
    }
}
