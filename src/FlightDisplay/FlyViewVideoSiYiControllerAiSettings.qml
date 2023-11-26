import QtQuick 2.15
import QtQuick.Controls 2.15
//import "qrc:/qml/QGroundControl/Controls"

import SiYi.Object 1.0

Item {
    id: root
    width: 200
    height: 200

    property int minW: SiYi.isAndroid ? 4*70 : 70
    property int minH: 70
    property string targetColor: "red"
    property int targetLength: 30
    property int targetWeight: 4
    property bool modified: false
    property int videoW: 1920
    property int videoH: 720

    signal invokeTrackingTarget(var tracking, var x, var y)
    signal confirmTimeout

    Rectangle {
        id: targetRectangle
        width: minW
        height: minH
        //anchors.centerIn: parent
        color: "#04ff0000"
        x: (root.width - width)/2
        y: (root.height - height)/2

        Rectangle {
            id: topRectangleLeft
            width: targetLength
            height: targetWeight
            color: root.targetColor
            anchors.left: parent.left
        }
        Rectangle {
            id: topRectangleRight
            width: targetLength
            height: targetWeight
            color: root.targetColor
            anchors.right: parent.right
        }
        Rectangle {
            id: bottomRectangleLeft
            width: targetLength
            height: targetWeight
            color: root.targetColor
            anchors.left: parent.left
            anchors.bottom: parent.bottom
        }
        Rectangle {
            id: bottomRectangleRight
            width: targetLength
            height: targetWeight
            color: root.targetColor
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }
        Rectangle {
            id: leftRectangleTop
            width: targetWeight
            height: targetLength
            color: root.targetColor
            anchors.left: parent.left
        }
        Rectangle {
            id: leftRectangleBottom
            width: targetWeight
            height: targetLength
            color: root.targetColor
            anchors.bottom: parent.bottom
        }
        Rectangle {
            id: rightRectangleTop
            width: targetWeight
            height: targetLength
            color: root.targetColor
            anchors.right: parent.right
        }
        Rectangle {
            id: rightRectangleBottom
            width: targetWeight
            height: targetLength
            color: root.targetColor
            anchors.right: parent.right
            anchors.bottom: parent.bottom
        }

        Rectangle {
            anchors.centerIn: parent
            width: targetLength
            height: targetWeight/2
            color: root.targetColor
        }

        Rectangle {
            anchors.centerIn: parent
            width: targetWeight/2
            height: targetLength
            color: root.targetColor
        }

        MouseArea {
            id: movingMouseArea
            width: targetLength
            height: width
            cursorShape: Qt.SizeAllCursor
            anchors.fill: parent
            onPressed: movingMouseArea.pressedPoint = Qt.point(mouse.x, mouse.y)
            onClicked: {
                confirmColumn.visible = true
                modified = false
            }
            onPositionChanged: {
                modified = true

                var deltaX = mouse.x - movingMouseArea.pressedPoint.x
                var deltaY = mouse.y - movingMouseArea.pressedPoint.y
                var tmpX = targetRectangle.x + deltaX
                var tmpY = targetRectangle.y + deltaY

                if (tmpX < 0) {
                    tmpX = 0
                } else if (tmpX > root.width - targetRectangle.width) {
                    tmpX = root.width - targetRectangle.width
                }

                if (tmpY < 0) {
                    tmpY = 0
                } else if (tmpY > root.height - targetRectangle.height) {
                    tmpY = root.height - targetRectangle.height
                }

                targetRectangle.x = tmpX
                targetRectangle.y = tmpY
            }

            property point pressedPoint: Qt.point(0, 0)
        }
        MouseArea {
            id: resizingMouseArea
            width: targetLength
            height: width
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            cursorShape: Qt.SizeFDiagCursor
            onPressed: resizingMouseArea.pressedPoint = Qt.point(mouse.x, mouse.y)
            onReleased: {
                confirmColumn.visible = modified
                modified = false
            }
            onPositionChanged: {
                modified = true

                var deltaX = mouse.x - resizingMouseArea.pressedPoint.x
                var deltaY = mouse.y - resizingMouseArea.pressedPoint.y
                var rootPoint = mapToItem(root, mouse.x, mouse.y)
                var w = targetRectangle.width + deltaX
                var h = targetRectangle.height + deltaY
                if (w < minW) {
                    w = minW
                } else if (w > (root.width - targetRectangle.x)) {
                    w = root.width
                }

                if (h < minH) {
                    h = minH
                } else if (h > (root.height - targetRectangle.y)) {
                    h = root.height - targetRectangle.y
                }

                targetRectangle.width = w
                targetRectangle.height = h
            }

            property point pressedPoint: Qt.point(0, 0)
        }
    }

    Column {
        id: confirmColumn
        visible: false
        anchors.centerIn: targetRectangle
        onVisibleChanged: {
            if (confirmColumn.visible) {
                confirmTimer.start()
            } else {
                if (confirmTimer.running) {
                    confirmTimer.stop()
                }
            }
        }
        Button {
            text: qsTr("确定")
            onClicked: {
                confirmColumn.visible = false
                var w = targetRectangle.width
                var h = targetRectangle.height
                var x = targetRectangle.x + w/2
                var y = targetRectangle.y + h/2
                var cookedX = x*videoW / root.width
                var cookedY = y*videoH / root.height
                root.invokeTrackingTarget(true, cookedX, cookedY)
            }
        }
        Button {
            text: qsTr("取消")
            onClicked: {
                confirmColumn.visible = false
                root.invokeTrackingTarget(false, x, y)
            }
        }
        Button {
            text: qsTr("关闭")
            onClicked: {
                confirmColumn.visible = false
                root.visible = false
            }
        }

        Timer {
            id: confirmTimer
            interval: 5000
            running: false
            onTriggered: {
                confirmColumn.visible = false
                root.confirmTimeout()
            }
        }
    }

    function updatePosition(x, y, w, h) {
        var cookedX = x*root.width / videoW
        var cookedY = y*root.height / videoH
        var cookedW = w*root.width / videoW
        var cookedH = h*root.height / videoH

        targetRectangle.x = cookedX
        targetRectangle.y = cookedY
        targetRectangle.width = cookedW
        targetRectangle.height = cookedH
    }
}
