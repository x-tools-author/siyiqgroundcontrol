/****************************************************************************
 *
 * (c) 2009-2020 QGROUNDCONTROL PROJECT <http://www.qgroundcontrol.org>
 *
 * QGroundControl is licensed according to the terms in the file
 * COPYING.md in the root of the source code directory.
 *
 ****************************************************************************/


import QtQuick                          2.11
import QtQuick.Controls                 2.4

import QGroundControl                   1.0
import QGroundControl.FlightDisplay     1.0
import QGroundControl.FlightMap         1.0
import QGroundControl.ScreenTools       1.0
import QGroundControl.Controls          1.0
import QGroundControl.Palette           1.0
import QGroundControl.Vehicle           1.0
import QGroundControl.Controllers       1.0

import SiYi.Object 1.0
import QtGraphicalEffects 1.12
import "qrc:/qml/QGroundControl/Controls"

Rectangle {
    id:     root
    clip:   true
    anchors.fill: parent
    color: "#00000000"

    property var siyi: SiYi
    property SiYiCamera camera: siyi.camera
    property SiYiTransmitter transmitter: siyi.transmitter
    property bool isRecording: camera.isRecording

    MouseArea {
        id: controlMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onPressed: {
            enableControl = true
            controlMouseArea.originX = mouse.x
            controlMouseArea.originY = mouse.y
            controlMouseArea.currentX = mouse.x
            controlMouseArea.currentY = mouse.y
            controlMouseArea.pitch = 0
            controlMouseArea.yaw = 0
            contrlTimer.start()
        }
        onReleased: {
            enableControl = false
            contrlTimer.stop()
        }
        onPositionChanged: {
            controlMouseArea.currentX = mouse.x
            controlMouseArea.currentY = mouse.y
            controlMouseArea.yaw = controlMouseArea.currentX - controlMouseArea.originX
            controlMouseArea.pitch = controlMouseArea.currentY - controlMouseArea.originY
        }
        onDoubleClicked: camera.resetPostion()
        onClicked: camera.autoFocus()

        Timer {
            id: contrlTimer
            running: false
            interval: 100
            repeat: true
            onTriggered: {
                if (controlMouseArea.enableControl) {
                    if (controlMouseArea.yaw < -100) {
                        controlMouseArea.yaw = -100
                    }

                    if (controlMouseArea.yaw > 100) {
                        controlMouseArea.yaw = 100
                    }

                    if (controlMouseArea.pitch < -100) {
                        controlMouseArea.pitch = -100
                    }

                    if (controlMouseArea.pitch > 100) {
                        controlMouseArea.pitch = 100
                    }

                    /*console.info(controlMouseArea.yaw, controlMouseArea.pitch,
                                 controlMouseArea.originX, controlMouseArea.originY,
                                 controlMouseArea.currentX, controlMouseArea.currentY)*/
                    if (SiYi.isAndroid) {
                        camera.turn(controlMouseArea.yaw, -controlMouseArea.pitch)
                    } else {
                        var delta = 5 // 变化小于该值时，不转动云台
                        var yaw = controlMouseArea.yaw
                        var pitch = controlMouseArea.pitch

                        if (Math.abs(controlMouseArea.yaw) < delta) {
                            yaw = 0
                        }
                        if (Math.abs(controlMouseArea.pitch) < delta) {
                            pitch = 0
                        }

                        camera.turn(yaw, -pitch)
                    }
                }

                controlMouseArea.originX = controlMouseArea.currentX
                controlMouseArea.originY = controlMouseArea.currentY
            }
            onRunningChanged: {
                if (!running) {
                    controlMouseArea.originX = 0
                    controlMouseArea.originY = 0
                    controlMouseArea.currentX = 0
                    controlMouseArea.currentY = 0
                    camera.turn(0, 0)
                }
            }
        }

        property bool enableControl: false
        property int pitch: 0
        property int yaw: 0
        property int originX: 0
        property int originY: 0
        property int currentX: 0
        property int currentY: 0
    }

    Grid {
        id: infoGrid
        columns: 2
        anchors.left: parent.left
        anchors.leftMargin: 150
        visible: false
        Repeater {
            model: [
                qsTr("信道:"), transmitter.channel,
                qsTr("信号质量:"), transmitter.signalQuality,
                qsTr("信号强度:"), transmitter.rssi,
                qsTr("延时时间:"), transmitter.inactiveTime + "ms",
                qsTr("上行数据量:"), (transmitter.upStream/1000).toFixed(3) + "KB",
                qsTr("下行数据量:"), (transmitter.downStream/1000).toFixed(3) + "KB",
                qsTr("上行带宽:"), (transmitter.txBanWidth/1000).toFixed(1) + "Mbps",
                qsTr("下行带宽:"), (transmitter.rxBanWidth/1000).toFixed(1) + "Mbps",
            ]
            QGCLabel {
                text: modelData
                color: "white"
            }
        }
    }

    Rectangle {
        id: controlRectangle
        color: "#00000000"
        anchors.left: parent.left
        //anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 150
        anchors.topMargin: 10
        width: controlColumn.width
        height: controlColumn.height
        anchors.top: parent.top
        //anchors.top: infoGrid.bottom
        Column {
            id: controlColumn
            spacing: 20
            Repeater {
                model: [
                    [qsTr("放大"), "qrc:/resources/SiYi/ZoomIn.svg", false],
                    [qsTr("缩小"), "qrc:/resources/SiYi/ZoomOut.svg", false],
                    [qsTr("回中"), "qrc:/resources/SiYi/Reset.svg", false],
//                    [qsTr("对焦"), "qrc:/resources/SiYi/BeadSight.svg", false],
                    [qsTr("拍照"), "qrc:/resources/SiYi/Photo.svg", false],
                    [qsTr("录像"), "qrc:/resources/SiYi/Video.svg", false]
//                    [qsTr("向上"), "qrc:/resources/SiYi/Up.svg", true],
//                    [qsTr("向下"), "qrc:/resources/SiYi/Down.svg", true],
//                    [qsTr("向左"), "qrc:/resources/SiYi/Left.svg", true],
//                    [qsTr("向右"), "qrc:/resources/SiYi/Right.svg", true]
                ]
                Row {
                    spacing: 10
                    Text {
                        id: btText
                        text: modelData[0]
                        anchors.verticalCenter: parent.verticalCenter
                        visible: false
                    }
                    Image {
                        id: iconImage
                        width: btText.width
                        height: width
                        source: modelData[1]
                        anchors.verticalCenter: parent.verticalCenter

                        property bool isRecording: root.isRecording

                        onIsRecordingChanged: {
                            if (index === 4) {
                                source = isRecording
                                        ? "qrc:/resources/SiYi/Stop.svg"
                                        : "qrc:/resources/SiYi/Video.svg"
                            }
                        }

                        Component.onCompleted: {
                            if (index === 4) {
                                source = isRecording
                                        ? "qrc:/resources/SiYi/Stop.svg"
                                        : "qrc:/resources/SiYi/Video.svg"
                            }
                        }

                        MouseArea {
                            id: iconMouse
                            anchors.fill: parent
                            onPressed: {
                                if (index === 0) { // 放大
                                    camera.zoom(1)
                                } else if (index === 1) { // 缩小
                                    camera.zoom(-1)
                                } else if (index === 2) {
                                    camera.resetPostion()
                                } else if (index === 3) { // 拍照
                                    camera.sendCommand(SiYiCamera.CameraCommandTakePhoto)
                                } else if (index === 4) { // 录像
                                    if (camera.isRecording) {
                                        camera.sendRecodingCommand(SiYiCamera.CloseRecording)
                                    } else {
                                        camera.sendRecodingCommand(SiYiCamera.OpenRecording)
                                    }
                                }
                            }
                            onReleased: {
                                if (index === 0 || index === 1) {
                                    camera.zoom(0)
                                }
                            }
                        }
                        ColorOverlay {
                            anchors.fill: iconImage
                            source: iconImage
                            color: {
                                if (index === 4) {
                                    if (camera.isRecording) {
                                        return "red"
                                    } else {
                                        return iconMouse.pressed ? "green" : "white"
                                    }
                                } else {
                                    return iconMouse.pressed ? "green" : "white"
                                }
                            }
                        }
                    }
                    Slider {
                        id: slider
                        from: 0
                        to: 100
                        visible: modelData[2]
                        anchors.verticalCenter: parent.verticalCenter
                        onPressedChanged: {
                            if (pressed) {
                                sendingTimer.enableSending = true
                                sendingTimer.start()
                            } else {
                                sendingTimer.enableSending = false
                                sendingTimer.stop()
                                camera.turn(0, 0)
                            }
                        }

                        onValueChanged: {
                            if (sendingTimer.enableSending) {
                                if (index === 4) { // 上
                                    camera.turn(0, slider.value)
                                } else if (index === 5) { // 下
                                    camera.turn(0, -slider.value)
                                } else if (index === 6) { // 左
                                    camera.turn(slider.value, 0)
                                } else if (index === 7) { // 右
                                    camera.turn(-slider.value, 0)
                                }
                            }
                        }

                        Timer {
                            id: sendingTimer
                            running: false
                            interval: 100

                            property bool enableSending: false

                            onTriggered: {
                                enableSending = true
                            }
                        }
                    }
                }
            }
        }
    }
}
