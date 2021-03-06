import QtQuick 2.8
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.3

import "../../qml/components/"
import "../../qml/components/AwesomeIcon/"

BasePage {
    id: page
    title: qsTr("My curriculum")
    hasListView: false

    property var semestres: []

    function requestCallback(result, status) {
        var semestresTemp = [];
        for (var i = 1; i < result.students_program_history.length; i++) {
            var array = result.students_program_history.filter(function(obj) {
                return obj.course.program_section === i;
            });
            if (array && array.length)
                semestresTemp.push(array);
        }
        semestres = semestresTemp;
    }

    function request() {
        jsonListModel.source += "students_program_history/" + userProfileData.id;
        jsonListModel.load(requestCallback);
    }

    Component.onCompleted: request();

    function getColor(grade,times) {
        if (5 <= grade && grade < 7)
            return "#80ff80";
        else if (7 <= grade && grade < 9)
            return "#00ff00";
        else if (9 <= grade && grade <= 10)
            return "#006600";
        else if (times === 1)
            return "#ffff00";
        else if (times === 2)
            return "#ffcc00";
        else if (times === 3)
            return "#ff0000";
        return "#FFFFFF";
    }

    function getOpacity(status) {
        return (status === 1) ? 1 : 0.4;
    }

    function printIcon(status) {
        return (status === 1);
    }

    function getFontStyle(status) {
        return (status === 1);
    }

    function getTimes(times) {
        if (times === 0 || times === undefined)
            return " ";
        return times;
    }

    function getImage(status) {
        if (status === 1)
            return "Images/green-circle1.png"
        return "Images/green-circle-void.png"
    }

    function getBold(status) {
        return (status === 1);
    }

    Flickable {
        width: window.width * 0.90
        height: window.height * 0.90
        flickableDirection: Flickable.AutoFlickDirection
        contentWidth: contentItem.childrenRect.width
        contentHeight: contentItem.childrenRect.height
        anchors { top: parent.top; topMargin: 16; left: parent.left; leftMargin: 16; right: parent.right; rightMargin: 8}

        Row {
            id: row
            spacing: 5

            Repeater {
                id: repeater
                model: semestres

                ListView {
                    id: listView
                    spacing: 8
                    width: window.width*0.40
                    height: window.height+200
                    model: modelData
                    delegate: Rectangle {
                        id: rect
                        width: window.width*0.35
                        height: window.height/10+30
                        radius: 8
                        border.color: "black"
                        color: getColor(modelData.grade, modelData.times)
                        opacity: getOpacity(modelData.status.id)

                        RowLayout {
                            width: parent.width
                            anchors { top: parent.top; topMargin: 5 }

                            Label {
                                text: " " + modelData.course.code
                                font { bold: true; pointSize: 9 }
                                anchors { left: parent.left; leftMargin: 5 }
                                font.italic : getFontStyle(modelData.status.id)
                            }

                            AwesomeIcon {
                                name: "check_circle"
                                color: "#00FF00"
                                size: 15
                                anchors { right: parent.right; rightMargin: 5}
                                visible: printIcon(modelData.status.id)
                            }
                        }

                        RowLayout {
                            width: parent.width
                            anchors {bottom:parent.bottom; bottomMargin: 5}

                            Label{
                                anchors {left: parent.left; bottom: parent.bottom}
                                text: "  " + getTimes(modelData.times)
                                font.bold: false
                                font.pointSize: 9
                                font.italic : getFontStyle(modelData.status.id)
                            }

                            Label{
                                anchors {right: parent.right; rightMargin: 5 }
                                text: modelData.course.hours + " - " + modelData.course.credits
                                font.bold: false
                                font.pointSize: 9
                                font.italic : getFontStyle(modelData.status.id)
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: modelData.course.name
                            font.bold: getBold(modelData.status.id)
                            font.italic : getFontStyle(modelData.status.id)
                            font.pointSize: 8
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            width: parent.width
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
    }
}
