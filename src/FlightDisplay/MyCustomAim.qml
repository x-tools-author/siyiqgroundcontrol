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
    property int size: togglePepSwitch.checked ? 800 : 600
    property string baseColor: "#00FF00"
    property string addColor: "#FF0000"
    property string dotColor: "#FF1493"
    property int baseThickness: 5
    property int addThickness: 3
    property int baseElementSize: 50
    property int zIndex: 1100
    property int circleRadius: 15
    property int dotDadius: 6
    property int counter: (size / 2) / baseElementSize


    id: container
    width: parent.width
    height: parent.height
    color: "transparent"
    z: zIndex

    Rectangle {
        id: customAim
        width: size
        height: size
        color: "transparent"
        anchors.centerIn: parent
        visible: toggleSwitch.checked
        z: zIndex

        // Горизонтальні та вертикальні центральні лінії
        Rectangle {
            width: (size / 2) - circleRadius
            height: baseThickness
            color: baseColor
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: (size / 2) - circleRadius
            height: baseThickness
            color: baseColor
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: baseThickness
            height: (size / 2) - circleRadius
            color: baseColor
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            width: baseThickness
            height: (size / 2) - circleRadius
            color: baseColor
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Коло
        Rectangle {
            width: circleRadius * 2
            height: circleRadius * 2
            color: "transparent"
            border.color: baseColor
            border.width: baseThickness
            radius: circleRadius
            anchors.centerIn: parent
        }

        // Горизонтальні відсічення
        Repeater {
            model: counter
            Rectangle {
                width: baseThickness
                height: index === 0 ? baseElementSize * 2 : baseElementSize
                color: baseColor
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: index * baseElementSize
            }
        }

        // Додаткові
        Repeater {
            model: counter
            Rectangle {
                width: addThickness
                height: baseElementSize / 2
                color: addColor
                visible: togglePepSwitch.checked
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: baseElementSize / 2 + (index * baseElementSize)
            }
        }

        Repeater {
            model: counter
            Rectangle {
                width: baseThickness
                height: index === 0 ? baseElementSize * 2 : baseElementSize
                color: baseColor
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: index * baseElementSize
            }
        }

        // Додаткові
        Repeater {
            model: counter
            Rectangle {
                width: addThickness
                height: baseElementSize / 2
                color: addColor
                visible: togglePepSwitch.checked
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: baseElementSize / 2 + (index * baseElementSize)
            }
        }

        // Вертикальные отсечки
        Repeater {
            model: counter
            Rectangle {
                width: index === 0 ? baseElementSize * 2 : baseElementSize
                height: baseThickness
                color: baseColor
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: index * baseElementSize
            }
        }

        // Додаткові
        Repeater {
            model: counter
            Rectangle {
                width: baseElementSize / 2
                height: addThickness
                color: addColor
                visible: togglePepSwitch.checked
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: baseElementSize / 2 + (index * baseElementSize)
            }
        }

        Repeater {
            model: counter
            Rectangle {
                width: index === 0 ? baseElementSize * 2 : baseElementSize
                height: baseThickness
                color: baseColor
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: index * baseElementSize
            }
        }

        // Додаткові
        Repeater {
            model: counter
            Rectangle {
                width: baseElementSize / 2
                height: addThickness
                color: addColor
                visible: togglePepSwitch.checked
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: baseElementSize / 2 + (index * baseElementSize)
            }
        }

        // Косі відсічення - верхні
        Repeater {
            model: counter - 2
            Rectangle {
                width: baseElementSize
                height: baseThickness
                color: baseColor
                anchors.top: parent.top
                anchors.right: parent.horizontalCenter
                anchors.topMargin: (size / 2  - baseElementSize * 2) - index * baseElementSize
                anchors.rightMargin: (baseElementSize + baseElementSize / 2) + (index * baseElementSize)
            }
        }

        // Додаткові верхні
        Repeater {
            model: counter - 1
            Rectangle {
                width: dotDadius * 2
                height: dotDadius * 2
                radius: dotDadius
                color: dotColor
                visible: togglePepSwitch.checked
                anchors.top: parent.top
                anchors.right: parent.horizontalCenter
                anchors.topMargin: ((size / 2  - baseElementSize * 2) - index * baseElementSize) + (size / 2  - ((size / 2  - baseElementSize * 2) - index * baseElementSize)) / 2
                anchors.rightMargin: baseElementSize * 2 + (index * baseElementSize)
            }
        }

        // Додаткові нижні
        Repeater {
            model: counter - 1
            Rectangle {
                width: dotDadius * 2
                height: dotDadius * 2
                radius: dotDadius
                color: dotColor
                visible: togglePepSwitch.checked
                anchors.top: parent.top
                anchors.right: parent.horizontalCenter
                anchors.topMargin: size / 2 - (baseElementSize * 2 + index * baseElementSize)
                anchors.rightMargin: (( baseElementSize * 2 + index * baseElementSize) - baseElementSize / 2) / 2
            }
        }

        Repeater {
            model: counter - 2
            Rectangle {
                width: baseElementSize
                height: baseThickness
                color: baseColor
                anchors.top: parent.top
                anchors.left: parent.horizontalCenter
                anchors.topMargin: (size / 2  - baseElementSize * 2) - index * baseElementSize
                anchors.leftMargin: (baseElementSize + baseElementSize / 2) + (index * baseElementSize)
            }
        }

        // Додаткові верхні
        Repeater {
            model: counter - 1
            Rectangle {
                width: dotDadius * 2
                height: dotDadius * 2
                radius: dotDadius
                color: dotColor
                visible: togglePepSwitch.checked
                anchors.top: parent.top
                anchors.left: parent.horizontalCenter
                anchors.topMargin: ((size / 2  - baseElementSize * 2) - index * baseElementSize) + (size / 2  - ((size / 2  - baseElementSize * 2) - index * baseElementSize)) / 2
                anchors.leftMargin: baseElementSize * 2 + (index * baseElementSize)
            }
        }

        // Додаткові нижні
        Repeater {
            model: counter - 1
            Rectangle {
                width: dotDadius * 2
                height: dotDadius * 2
                radius: dotDadius
                color: dotColor
                visible: togglePepSwitch.checked
                anchors.top: parent.top
                anchors.left: parent.horizontalCenter
                anchors.topMargin: size / 2 - (baseElementSize * 2 + index * baseElementSize)
                anchors.leftMargin: (( baseElementSize * 2 + index * baseElementSize) - baseElementSize / 2) / 2
            }
        }

        // Косі відсічки - нижні
        Repeater {
            model: counter - 2
            Rectangle {
                width: baseElementSize
                height: baseThickness
                color: baseColor
                anchors.bottom: parent.bottom
                anchors.right: parent.horizontalCenter
                anchors.bottomMargin: (size / 2  - baseElementSize * 2) - index * baseElementSize
                anchors.rightMargin: (baseElementSize + baseElementSize / 2) + (index * baseElementSize)
            }
        }

        // Додаткові верхні
        Repeater {
            model: counter - 1
            Rectangle {
                width: dotDadius * 2
                height: dotDadius * 2
                radius: dotDadius
                color: dotColor
                visible: togglePepSwitch.checked
                anchors.bottom: parent.bottom
                anchors.right: parent.horizontalCenter
                anchors.bottomMargin: ((size / 2  - baseElementSize * 2) - index * baseElementSize) + (size / 2  - ((size / 2  - baseElementSize * 2) - index * baseElementSize)) / 2
                anchors.rightMargin: baseElementSize * 2 + (index * baseElementSize)
            }
        }

        // Додаткові нижні
        Repeater {
            model: counter - 1
            Rectangle {
                width: dotDadius * 2
                height: dotDadius * 2
                radius: dotDadius
                color: dotColor
                visible: togglePepSwitch.checked
                anchors.bottom: parent.bottom
                anchors.right: parent.horizontalCenter
                anchors.bottomMargin: size / 2 - (baseElementSize * 2 + index * baseElementSize)
                anchors.rightMargin: (( baseElementSize * 2 + index * baseElementSize) - baseElementSize / 2) / 2
            }
        }

        Repeater {
            model: counter - 2
            Rectangle {
                width: baseElementSize
                height: baseThickness
                color: baseColor
                anchors.bottom: parent.bottom
                anchors.left: parent.horizontalCenter
                anchors.bottomMargin: (size / 2  - baseElementSize * 2) - index * baseElementSize
                anchors.leftMargin: (baseElementSize + baseElementSize / 2) + (index * baseElementSize)
            }
        }

        // Додаткові верхні
        Repeater {
            model: counter - 1
            Rectangle {
                width: dotDadius * 2
                height: dotDadius * 2
                radius: dotDadius
                color: dotColor
                visible: togglePepSwitch.checked
                anchors.bottom: parent.bottom
                anchors.left: parent.horizontalCenter
                anchors.bottomMargin: ((size / 2  - baseElementSize * 2) - index * baseElementSize) + (size / 2  - ((size / 2  - baseElementSize * 2) - index * baseElementSize)) / 2
                anchors.leftMargin: baseElementSize * 2 + (index * baseElementSize)
            }
        }

        // Додаткові нижні
        Repeater {
            model: counter - 1
            Rectangle {
                width: dotDadius * 2
                height: dotDadius * 2
                radius: dotDadius
                color: dotColor
                visible: togglePepSwitch.checked
                anchors.bottom: parent.bottom
                anchors.left: parent.horizontalCenter
                anchors.bottomMargin: size / 2 - (baseElementSize * 2 + index * baseElementSize)
                anchors.leftMargin: (( baseElementSize * 2 + index * baseElementSize) - baseElementSize / 2) / 2
            }
        }
    }

    Switch {
        id: togglePepSwitch
        text: qsTr("Детально")
        checked: false
        // visible: toggleSwitch.checked
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 20
        anchors.bottomMargin: 386
        z: zIndex
        visible: false

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
            leftPadding: togglePepSwitch.indicator.width + togglePepSwitch.spacing
        }
    }

    Switch {
        id: toggleSwitch
        text: qsTr("Приціл")
        checked: true
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 300
        anchors.leftMargin: 20
        z: zIndex
        visible: false

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
            leftPadding: toggleSwitch.indicator.width + toggleSwitch.spacing
        }
    }
}
