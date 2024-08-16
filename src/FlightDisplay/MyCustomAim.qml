import QtQuick 2.11
import QtQuick.Controls 2.4
import QtLocation 5.3
import QtPositioning 5.3
import QtQuick.Dialogs 1.2

import QGroundControl 1.0
import QGroundControl.Airspace 1.0
import QGroundControl.Controllers 1.0
import QGroundControl.Controls 1.0
import QGroundControl.FlightDisplay 1.0
import QGroundControl.FlightMap 1.0
import QGroundControl.Palette 1.0
import QGroundControl.ScreenTools 1.0
import QGroundControl.Vehicle 1.0

Rectangle {

    id: container
    width: parent.width
    height: parent.height
    color: "transparent"
    z: 10

    Rectangle {
        id: customAim
        width: 540
        height: 540
        color: "transparent"
        anchors.centerIn: parent
        visible: toggleSwitch.checked
        z: 10

        // Горизонтальні та вертикальні центральні лінії
        Rectangle {
            width: (parent.width / 2) - 15
            height: 5
            color: "#00FF00"
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: (parent.width / 2) - 15
            height: 5
            color: "#00FF00"
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: 5
            height: (parent.height / 2) - 15
            color: "#00FF00"
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            width: 5
            height: (parent.height / 2) - 15
            color: "#00FF00"
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Горизонтальні відсічення
        Repeater {
            model: 6
            Rectangle {
                width: 5
                height: index === 0 ? 90 : 45
                color: "#00FF00"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: index * 45
            }
        }

        // Додаткові
        Repeater {
            model: 6
            Rectangle {
                width: 3
                height: 22.5
                color: "#FFA500"
                visible: togglePepSwitch.checked
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 22.5 + (index * 45)
            }
        }

        Repeater {
            model: 6
            Rectangle {
                width: 5
                height: index === 0 ? 90 : 45
                color: "#00FF00"
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: index * 45
            }
        }

        // Додаткові
        Repeater {
            model: 6
            Rectangle {
                width: 3
                height: 22.5
                color: "#FFA500"
                visible: togglePepSwitch.checked
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 22.5 + (index * 45)
            }
        }

        // Вертикальные отсечки
        Repeater {
            model: 6
            Rectangle {
                width: index === 0 ? 90 : 45
                height: 5
                color: "#00FF00"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: index * 45
            }
        }

        // Додаткові
        Repeater {
            model: 6
            Rectangle {
                width: 22.5
                height: 3
                color: "#FFA500"
                visible: togglePepSwitch.checked
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 22.5 + (index * 45)
            }
        }

        Repeater {
            model: 6
            Rectangle {
                width: index === 0 ? 90 : 45
                height: 5
                color: "#00FF00"
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: index * 45
            }
        }

        // Додаткові
        Repeater {
            model: 6
            Rectangle {
                width: 22.5
                height: 3
                color: "#FFA500"
                visible: togglePepSwitch.checked
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 22.5 + (index * 45)
            }
        }

        // Косі відсічення - верхні
        Repeater {
            model: 4
            Rectangle {
                width: 45
                height: 5
                color: "#00FF00"
                anchors.top: parent.top
                anchors.topMargin: (index + 1) * 45
                anchors.right: parent.horizontalCenter
                anchors.rightMargin: 200 - index * 45
            }
        }

        // Додаткові верхні
        Repeater {
            model: 5
            Rectangle {
                width: 20
                height: 5
                color: "#FFFF00"
                visible: togglePepSwitch.checked
                anchors.top: parent.top
                anchors.topMargin: 22.5 + (index * 45)
                anchors.right: parent.horizontalCenter
                anchors.rightMargin: 110 - index * 20
            }
        }

        // Додаткові нижні
        Repeater {
            model: 5
            Rectangle {
                width: 20
                height: 5
                color: "#FFFF00"
                visible: togglePepSwitch.checked
                anchors.top: parent.top
                anchors.topMargin: 140 + (index * 20)
                anchors.right: parent.horizontalCenter
                anchors.rightMargin: 240 - index * 40
            }
        }

        Repeater {
            model: 4
            Rectangle {
                width: 40
                height: 5
                color: "#00FF00"
                anchors.top: parent.top
                anchors.topMargin: (index + 1) * 45
                anchors.left: parent.horizontalCenter
                anchors.leftMargin: 200 - index * 45
            }
        }

        // Додаткові верхні
        Repeater {
            model: 5
            Rectangle {
                width: 20
                height: 5
                color: "#FFFF00"
                visible: togglePepSwitch.checked
                anchors.top: parent.top
                anchors.topMargin: 22.5 + (index * 45)
                anchors.left: parent.horizontalCenter
                anchors.leftMargin: 110 - index * 20
            }
        }

        // Додаткові нижні
        Repeater {
            model: 5
            Rectangle {
                width: 20
                height: 5
                color: "#FFFF00"
                visible: togglePepSwitch.checked
                anchors.top: parent.top
                anchors.topMargin: 140 + (index * 20)
                anchors.left: parent.horizontalCenter
                anchors.leftMargin: 240 - index * 40
            }
        }

        // Косі відсічки - нижні
        Repeater {
            model: 4
            Rectangle {
                width: 40
                height: 5
                color: "#00FF00"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: (index + 1) * 45
                anchors.right: parent.horizontalCenter
                anchors.rightMargin: 200 - index * 45
            }
        }

        // Додаткові верхні
        Repeater {
            model: 5
            Rectangle {
                width: 20
                height: 5
                color: "#FFFF00"
                visible: togglePepSwitch.checked
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 22.5 + (index * 45)
                anchors.right: parent.horizontalCenter
                anchors.rightMargin: 120 - index * 24
            }
        }

        // Додаткові нижні
        Repeater {
            model: 5
            Rectangle {
                width: 20
                height: 5
                color: "#FFFF00"
                visible: togglePepSwitch.checked
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 140 + (index * 20)
                anchors.right: parent.horizontalCenter
                anchors.rightMargin: 240 - index * 40
            }
        }

        Repeater {
            model: 4
            Rectangle {
                width: 40
                height: 5
                color: "#00FF00"
                anchors.bottom: parent.bottom
                anchors.bottomMargin: (index + 1) * 45
                anchors.left: parent.horizontalCenter
                anchors.leftMargin: 200 - index * 45
            }
        }

        // Додаткові верхні
        Repeater {
            model: 5
            Rectangle {
                width: 20
                height: 5
                color: "#FFFF00"
                visible: togglePepSwitch.checked
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 22.5 + (index * 45)
                anchors.left: parent.horizontalCenter
                anchors.leftMargin: 120 - index * 24
            }
        }

        // Додаткові нижні
        Repeater {
            model: 5
            Rectangle {
                width: 20
                height: 5
                color: "#FFFF00"
                visible: togglePepSwitch.checked
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 140 + (index * 20)
                anchors.left: parent.horizontalCenter
                anchors.leftMargin: 240 - index * 40
            }
        }

        Rectangle {
            width: 30
            height: 30
            color: "transparent"
            border.color: "#00FF00"
            border.width: 5
            radius: 15
            anchors.centerIn: parent
        }
    }

    Switch {
        id: togglePepSwitch
        text: qsTr("Додатково")
        checked: false
        visible: toggleSwitch.checked
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 20
        anchors.bottomMargin: 106
        z: 10

        indicator: Rectangle {
            implicitWidth: 150
            implicitHeight: 76
            x: togglePepSwitch.leftPadding
            y: parent.height / 2 - height / 2
            radius: 38
            color: togglePepSwitch.checked ? "#17a81a" : "#ffffff"
            border.color: togglePepSwitch.checked ? "#17a81a" : "#cccccc"

            Rectangle {
                x: togglePepSwitch.checked ? parent.width - width : 0
                width: 76
                height: 76
                radius: 38
                color: togglePepSwitch.down ? "#cccccc" : "#ffffff"
                border.color: togglePepSwitch.checked ? (togglePepSwitch.down ? "#17a81a" : "#21be2b") : "#999999"
            }
        }

        contentItem: Text {
            text: togglePepSwitch.text
            font: togglePepSwitch.font
            opacity: enabled ? 1.0 : 0.3
            color: togglePepSwitch.down ? "#17a81a" : "#21be2b"
            verticalAlignment: Text.AlignVCenter
            // @disable-check M16
            leftPadding: togglePepSwitch.indicator.width + togglePepSwitch.spacing
        }
    }

    Switch {
        id: toggleSwitch
        text: qsTr("Приціл")
        checked: true
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 20
        z: 10

        indicator: Rectangle {
            implicitWidth: 150
            implicitHeight: 76
            x: toggleSwitch.leftPadding
            y: parent.height / 2 - height / 2
            radius: 38
            color: toggleSwitch.checked ? "#17a81a" : "#ffffff"
            border.color: toggleSwitch.checked ? "#17a81a" : "#cccccc"

            Rectangle {
                x: toggleSwitch.checked ? parent.width - width : 0
                width: 76
                height: 76
                radius: 38
                color: toggleSwitch.down ? "#cccccc" : "#ffffff"
                border.color: toggleSwitch.checked ? (toggleSwitch.down ? "#17a81a" : "#21be2b") : "#999999"
            }
        }

        contentItem: Text {
            text: toggleSwitch.text
            font: toggleSwitch.font
            opacity: enabled ? 1.0 : 0.3
            color: toggleSwitch.down ? "#17a81a" : "#21be2b"
            verticalAlignment: Text.AlignVCenter
            // @disable-check M16
            leftPadding: toggleSwitch.indicator.width + toggleSwitch.spacing
        }
    }
}
