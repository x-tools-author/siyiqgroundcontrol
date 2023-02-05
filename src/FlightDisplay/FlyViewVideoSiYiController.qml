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
    property int minDelta: 15

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
            if (Math.abs(controlMouseArea.yaw) > Math.abs(controlMouseArea.pitch)) {
                if (Math.abs(controlMouseArea.yaw) > minDelta) {
                    controlMouseArea.pitch = 0
                    controlMouseArea.isYDirection = false
                }
            } else {
                if (Math.abs(controlMouseArea.pitch) > minDelta) {
                    controlMouseArea.yaw = 0
                    controlMouseArea.isYDirection = true
                }
            }
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
                    if (Math.abs(controlMouseArea.pitch) > minDelta) {
                        controlMouseArea.prePitch = controlMouseArea.pitch
                    }

                    if (Math.abs(controlMouseArea.yaw) > minDelta) {
                        controlMouseArea.preYaw = controlMouseArea.yaw
                    }

                    if (Math.abs(controlMouseArea.pitch) < minDelta
                            && Math.abs(controlMouseArea.yaw) < minDelta) {
                        return
                    }

                    camera.turn(controlMouseArea.isYDirection ? 0 : Math.abs(controlMouseArea.yaw) < minDelta ? controlMouseArea.preYaw : controlMouseArea.yaw,
                                controlMouseArea.isYDirection ? Math.abs(controlMouseArea.pitch) < minDelta ? -controlMouseArea.prePitch : -controlMouseArea.pitch : 0)
//                    if (SiYi.isAndroid) {
//                        camera.turn(controlMouseArea.isYDirection ? 0 : Math.abs(controlMouseArea.yaw) < minDelta ? controlMouseArea.preYaw : controlMouseArea.yaw,
//                                    controlMouseArea.isYDirection ? Math.abs(controlMouseArea.pitch) < minDelta ? -controlMouseArea.prePitch : -controlMouseArea.pitch : 0)
//                        //camera.turn(controlMouseArea.yaw, -controlMouseArea.pitch)
//                    } else {
//                        var delta = 5 // 变化小于该值时，不转动云台
//                        var yaw = controlMouseArea.yaw
//                        var pitch = controlMouseArea.pitch

//                        if (Math.abs(controlMouseArea.yaw) < delta) {
//                            yaw = controlMouseArea.preYaw
//                        }
//                        if (Math.abs(controlMouseArea.pitch) < delta) {
//                            pitch = controlMouseArea.prePitch
//                        }

//                        camera.turn(yaw, -pitch)
//                    }
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
        property int prePitch: 0
        property int preYaw: 0
        property int originX: 0
        property int originY: 0
        property int currentX: 0
        property int currentY: 0
        property bool isYDirection: false
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

//            Repeater {
//                model: [
//                    ["qrc:/resources/SiYi/ZoomIn.png", "qrc:/resources/SiYi/ZoomInGreen.svg"],
//                    ["qrc:/resources/SiYi/ZoomOut.svg", "qrc:/resources/SiYi/ZoomOutGreen.svg"],
//                    ["qrc:/resources/SiYi/Reset.svg", "qrc:/resources/SiYi/ResetGreen.svg"],
//                    ["qrc:/resources/SiYi/Photo.svg", "qrc:/resources/SiYi/PhotoGreen.svg"],
//                    ["qrc:/resources/SiYi/Video.svg", "qrc:/resources/SiYi/VideoGreen.svg"],
//                    ["qrc:/resources/SiYi/far.svg", "qrc:/resources/SiYi/farGreen.svg"],
//                    ["qrc:/resources/SiYi/neer.svg", "qrc:/resources/SiYi/neerGreen.svg"]
//                ]
//                Image {
//                    sourceSize.width: btText.width
//                    sourceSize.height: btText.width
//                    MouseArea {
//                        id: imageMouseArea
//                    }
//                }
//            }

            Image { // 放大
                id: zoomInImage
                sourceSize.width: btText.width
                sourceSize.height: btText.width
                source: camera.enableZoom
                        ? zoomInMA.pressed ? "qrc:/resources/SiYi/ZoomInGreen.svg" : "qrc:/resources/SiYi/ZoomIn.svg"
                        : "qrc:/resources/SiYi/empty.png"
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                cache: false
                MouseArea {
                    id: zoomInMA
                    anchors.fill: parent
                    onPressed: {
                        if (camera.is4k) {
                            camera.emitOperationResultChanged(-1)
                        } else {
                            //camera.zoom(1)
                            zoomInTimer.start()
                            console.info("zoomIn start--------------------------------")
                        }
                    }
                    onReleased: {
                        zoomInTimer.stop()
                        camera.zoom(0)
                        console.info("zoomIn stop--------------------------------")
                    }
                }
//                ColorOverlay {
//                    anchors.fill: zoomInImage
//                    source: zoomInImage
//                    color: zoomInMA.pressed ? "green" : "white"
//                }
                Timer {
                    id: zoomInTimer
                    interval: 100
                    repeat: false
                    running: false
                    onTriggered: {
                        camera.zoom(1)
                        zoomInTimer.start()
                    }
                }
            }

            Image { // 缩小
                id: zoomOut
                sourceSize.width: btText.width
                sourceSize.height: btText.width
                source: camera.enableZoom
                        ? zoomOutMA.pressed ? "qrc:/resources/SiYi/ZoomOutGreen.svg" : "qrc:/resources/SiYi/ZoomOut.svg"
                        : "qrc:/resources/SiYi/empty.png"
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                cache: false
                MouseArea {
                    id: zoomOutMA
                    anchors.fill: parent
                    onPressed: {
                        if (camera.is4k) {
                            camera.emitOperationResultChanged(-1)
                        } else {
                            //camera.zoom(-1)
                            zoomOutTimer.start()
                        }
                    }
                    onReleased: {
                        zoomOutTimer.stop()
                        camera.zoom(0)
                    }
                }
//                ColorOverlay {
//                    anchors.fill: zoomOut
//                    source: zoomOut
//                    color: zoomOutMA.pressed ? "green" : "white"
//                }
                Timer {
                    id: zoomOutTimer
                    interval: 100
                    repeat: false
                    running: false
                    onTriggered: {
                        camera.zoom(-1)
                        zoomOutTimer.start()
                    }
                }
            }

            Image { // 回中
                id: reset
                sourceSize.width: btText.width
                sourceSize.height: btText.width
                source: camera.enableControl
                        ? resetMA.pressed ? "qrc:/resources/SiYi/ResetGreen.svg" : "qrc:/resources/SiYi/Reset.svg"
                        : "qrc:/resources/SiYi/empty.png"
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                cache: false
                MouseArea {
                    id: resetMA
                    anchors.fill: parent
                    onPressed: camera.resetPostion()
                }
//                ColorOverlay {
//                    anchors.fill: reset
//                    source: reset
//                    color: resetMA.pressed ? "green" : "white"
//                }
            }

            Image { // 拍照
                id: photo
                sourceSize.width: btText.width
                sourceSize.height: btText.width
                source: camera.enablePhoto
                        ? photoMA.pressed ? "qrc:/resources/SiYi/PhotoGreen.svg" : "qrc:/resources/SiYi/Photo.svg"
                        : "qrc:/resources/SiYi/empty.png"
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                cache: false
                MouseArea {
                    id: photoMA
                    anchors.fill: parent
                    onPressed: camera.sendCommand(SiYiCamera.CameraCommandTakePhoto)
                }
//                ColorOverlay {
//                    anchors.fill: photo
//                    source: photo
//                    color: photoMA.pressed ? "green" : "white"
//                }
            }

            Image { // 录像
                id: video
                //sourceSize.width: btText.width
                //sourceSize.height: btText.width
                width: btText.width
                height: btText.width
                cache: false
//                source: {
//                    if (camera.enableVideo) {
//                        if (camera.isRecording) {
//                            return "qrc:/resources/SiYi/Stop.svg"
//                        } else {
//                            return "qrc:/resources/SiYi/Video.png"
//                        }
//                    } else {
//                        return "qrc:/resources/SiYi/empty.png"
//                    }
//                }
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
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
//                ColorOverlay {
//                    anchors.fill: video
//                    source: video
//                    color: {
//                        if (camera.isRecording) {
//                            return "red"
//                        } else {
//                            return videoMA.pressed ? "green" : "white"
//                        }
//                    }
//                }
                Connections {
                    target: camera
                    function onEnableVideoChanged() {
                        video.source = "qrc:/resources/SiYi/empty.png"
                        if (camera.enableVideo) {
                            if (camera.isRecording) {
                                video.source = "qrc:/resources/SiYi/Stop.svg"
                            } else {
                                video.source = "qrc:/resources/SiYi/Video.png"
                            }
                        }
                    }

                    function onIsRecordingChanged() {
                        video.source = "qrc:/resources/SiYi/empty.png"
                        if (camera.isRecording) {
                            video.source = "qrc:/resources/SiYi/Stop.svg"
                        } else {
                            video.source = "qrc:/resources/SiYi/Video.png"
                        }
                    }
                }
            }

            Image { // 远景
                id: far
                sourceSize.width: btText.width
                sourceSize.height: btText.width
                source: camera.enableFocus
                        ? farMA.pressed ? "qrc:/resources/SiYi/farGreen.svg" : "qrc:/resources/SiYi/far.svg"
                        : "qrc:/resources/SiYi/empty.png"
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                cache: false
                MouseArea {
                    id: farMA
                    anchors.fill: parent
                    onPressed: {
                        //camera.focus(1)
                        farTimer.start()
                    }
                    onReleased: {
                        farTimer.stop()
                        camera.focus(0)
                    }
                }
//                ColorOverlay {
//                    anchors.fill: far
//                    source: far
//                    color: farMA.pressed ? "green" : "white"
//                }
                Timer {
                    id: farTimer
                    interval: 100
                    repeat: false
                    running: false
                    onTriggered: {
                        camera.focus(1)
                        farTimer.start()
                    }
                }
            }

            Image { // 近景
                id: neer
                sourceSize.width: btText.width
                sourceSize.height: btText.width
                source: camera.enableFocus
                        ? neerMA.pressed ? "qrc:/resources/SiYi/neerGreen.svg" : "qrc:/resources/SiYi/neer.svg"
                        : "qrc:/resources/SiYi/empty.png"
                anchors.horizontalCenter: parent.horizontalCenter
                fillMode: Image.PreserveAspectFit
                cache: false
                MouseArea {
                    id: neerMA
                    anchors.fill: parent
                    onPressed: {
                        //camera.focus(-1)
                        neerTimer.start()
                    }
                    onReleased: {
                        neerTimer.stop()
                        camera.focus(0)
                    }
                }
//                ColorOverlay {
//                    anchors.fill: neer
//                    source: neer
//                    color: neerMA.pressed ? "green" : "white"
//                }
                Timer {
                    id: neerTimer
                    interval: 100
                    repeat: false
                    running: false
                    onTriggered: {
                        camera.focus(-1)
                        neerTimer.start()
                    }
                }
            }
        }
    }
}
