import QtQuick 2.7
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.0

import "AwesomeIcon/"

Item {
    width: 400
    height: 680

    property var semestres: []

    Component.onCompleted: {
        var semestresTemp = [];
        for (var i = 1; i < jsonData.students_program_history.length; i++) {
            var result = jsonData.students_program_history.filter(function(obj) {
                return obj.course.program_section === i;
            });
            if (result && result.length)
                semestresTemp.push(result);
        }
        semestres = semestresTemp;
        console.log(JSON.stringify(semestres[0]));
    }

    function getColor(grade,times) {
        if (5 <= grade && grade < 7) {
            return "#A9F5A9";
        } else if (7 <= grade && grade < 9) {
            return "#40FF00";
        } else if (9 <= grade && grade <= 10) {
            return "#088A08";
        } else if (times === "1") {
            return "#F4FA58";
        } else if (times === "2") {
            return "#FACC2E";
        } else if (times === "3") {
            return "#FF0000";
        }
        return "#FFFFFF";
    }

    function getOpacity(status) {
        if (status === "1")
            return 1;
        else
            return 0.4;
    }

    function printIcon(status) {
        if (status === "1")
            return true;
        else
            return false;
    }

    function getFontStyle(status) {
        if (status === "1")
            return false
        else
            return true
    }

    function getTimes(times) {
        if (times === "0")
            return " "
        return times
    }

    function rectScale(rect) {
        if (rect.width > rect.width*0.35)
            return rect.scale += 0.2;
        rect.scale -= 0.2;
    }

    Flickable {
        width: parent.width; height: parent.height
        flickableDirection: Flickable.HorizontalFlick
        contentWidth: contentItem.childrenRect.width
        contentHeight: contentItem.childrenRect.height
        anchors { top: parent.top; topMargin: 16; left: parent.left; leftMargin: 16; right: parent.right; rightMargin: 8}

        Row {
            id: row
            spacing: 5

            Repeater {
                model: semestres

                ListView {
                    spacing: 8
                    visible: false
                    width: window.width*0.40
                    height: window.height+200
                    model: students_program_history
                    delegate: Rectangle {
                        id: rect
                        width: window.width*0.35
                        height: window.height/10+30
                        radius: 8
                        border.color: "black"
                        //                        color: getColor(grade,times)
                        //                        opacity: getOpacity(status)
                        //color: "black"}

                        MouseArea {
                            anchors.fill: parent
                            //                               onPressAndHold: parent.scale += 0.4
                            //                               onDoubleClicked: rect.scale -= 0.4

                        }

                        RowLayout {
                            width: parent.width
                            anchors { top: parent.top; topMargin: 5 }

                            Label {
                                text: " " + course.code
                                font { bold: true; pointSize: 9 }
                                anchors { left: parent.left; leftMargin: 5 }
                                font.italic : getFontStyle(status)
                            }

                            AwesomeIcon {
                                name: "circle"
                                color: "#00FF00"
                                size: 15
                                anchors { right: parent.right; rightMargin: 5}
                                visible: printIcon(status)
                            }
                        }

                        RowLayout {
                            width: parent.width
                            anchors {bottom:parent.bottom; bottomMargin: 5}

                            Label{
                                anchors {left: parent.left; bottom: parent.bottom}
                                text: "  " + getTimes(times)
                                font.bold: false
                                font.pointSize: 9
                                font.italic : getFontStyle(status)
                            }

                            Label {
                                anchors {right: parent.right; rightMargin: 5 }
                                text: course.hours + " - " + course.credits
                                font.bold: false
                                font.pointSize: 9
                                font.italic : getFontStyle(status)
                            }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: course.name
                            font.bold: false
                            font.italic : getFontStyle(status)
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
