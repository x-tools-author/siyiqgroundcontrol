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
        visible: camera.isConnected
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

    Item {
        id: controlRectangle
        anchors.left: parent.left
        anchors.leftMargin: 150
        anchors.topMargin: 10
        width: controlColumn.width
        height: controlColumn.height
        anchors.top: parent.top
        //visible: camera.isConnected
        Text {
            id: btText
            text: "1234"
            anchors.verticalCenter: parent.verticalCenter
            visible: false
        }

        Column {
            id: controlColumn
            spacing: 20

            Image { // 放大
                id: zoomInImage
                sourceSize.width: btText.width
                sourceSize.height: btText.width
                source: camera.enableZoom ? "qrc:/resources/SiYi/ZoomIn.png" : "qrc:/resources/SiYi/empty.png"
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                cache: false
                MouseArea {
                    id: zoomInMA
                    anchors.fill: parent
                    onPressed: camera.zoom(1)
                    onReleased: camera.zoom(0)
                }
                ColorOverlay {
                    anchors.fill: zoomInImage
                    source: zoomInImage
                    color: zoomInMA.pressed ? "green" : "white"
                }
            }

            Image { // 缩小
                id: zoomOut
                sourceSize.width: btText.width
                sourceSize.height: btText.width
                source: camera.enableZoom ? "qrc:/resources/SiYi/ZoomOut.png" : "qrc:/resources/SiYi/empty.png"
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                visible: camera.enableZoom
                cache: false
                MouseArea {
                    id: zoomOutMA
                    anchors.fill: parent
                    onPressed: camera.zoom(-1)
                    onReleased: camera.zoom(0)
                }
                ColorOverlay {
                    anchors.fill: zoomOut
                    source: zoomOut
                    color: zoomOutMA.pressed ? "green" : "white"
                }
            }

            Image { // 回中
                id: reset
                sourceSize.width: btText.width
                sourceSize.height: btText.width
                source: "qrc:/resources/SiYi/Reset.png"
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                cache: false
                MouseArea {
                    id: resetMA
                    anchors.fill: parent
                    onPressed: camera.resetPostion()
                }
                ColorOverlay {
                    anchors.fill: reset
                    source: reset
                    color: resetMA.pressed ? "green" : "white"
                }
            }

            Image { // 拍照
                id: photo
                sourceSize.width: btText.width
                sourceSize.height: btText.width
                source: "qrc:/resources/SiYi/Photo.png"
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                cache: false
                MouseArea {
                    id: photoMA
                    anchors.fill: parent
                    onPressed: camera.sendCommand(SiYiCamera.CameraCommandTakePhoto)
                }
                ColorOverlay {
                    anchors.fill: photo
                    source: photo
                    color: photoMA.pressed ? "green" : "white"
                }
            }

            Image { // 录像
                id: video
                sourceSize.width: btText.width
                sourceSize.height: btText.width
                source: camera.isRecording ? "qrc:/resources/SiYi/Stop.svg" : "qrc:/resources/SiYi/Video.png"
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                cache: false
                MouseArea {
                    id: videoMA
                    anchors.fill: parent
                    onPressed: {
                        if (camera.isRecording) {
                            camera.sendRecodingCommand(SiYiCamera.CloseRecording)
                        } else {
                            camera.sendRecodingCommand(SiYiCamera.OpenRecording)
                        }
                    }
                }
                ColorOverlay {
                    anchors.fill: video
                    source: video
                    color: {
                        if (camera.isRecording) {
                            return "red"
                        } else {
                            return videoMA.pressed ? "green" : "white"
                        }
                    }
                }
            }

            Image { // 远景
                id: far
                sourceSize.width: btText.width
                sourceSize.height: btText.width
                source: camera.enableFocus ? "qrc:/resources/SiYi/far.png" : "qrc:/resources/SiYi/empty.png"
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                visible: camera.enableFocus
                cache: false
                MouseArea {
                    id: farMA
                    anchors.fill: parent
                    onPressed: camera.focus(1)
                    onReleased: camera.focus(0)
                }
                ColorOverlay {
                    anchors.fill: far
                    source: far
                    color: farMA.pressed ? "green" : "white"
                }
            }

            Image { // 近景
                id: neer
                sourceSize.width: btText.width
                sourceSize.height: btText.width
                source: camera.enableFocus ? "qrc:/resources/SiYi/neer.png" : "qrc:/resources/SiYi/empty.png"
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                visible: camera.enableFocus
                cache: false
                MouseArea {
                    id: neerMA
                    anchors.fill: parent
                    onPressed: camera.focus(-1)
                    onReleased: camera.focus(0)
                }
                ColorOverlay {
                    anchors.fill: neer
                    source: neer
                    color: neerMA.pressed ? "green" : "white"
                }
            }
        }
    }
}
