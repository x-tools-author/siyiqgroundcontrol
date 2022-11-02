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

    Grid {
        anchors.bottom: controlRectangle.top
        columns: 2
        Repeater {
            model: [
                qsTr("信道:"), transmitter.channel,
                qsTr("信号质量:"), transmitter.signalQuality,
                qsTr("信号强度:"), transmitter.rssi,
                qsTr("延时时间:"), transmitter.inactiveTime,
                qsTr("上行数据量:"), transmitter.upStream,
                qsTr("下行数据量:"), transmitter.downStream,
                qsTr("上行带宽:"), transmitter.txBanWidth,
                qsTr("下行带宽:"), transmitter.rxBanWidth,
            ]
            QGCLabel {
                text: modelData
                color: "white"
            }
        }
    }

    Rectangle {
        id: controlRectangle
        color: "#80ffffff"
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: controlColumn.width
        height: controlColumn.height
        Column {
            id: controlColumn
            Repeater {
                model: [
                    [qsTr("放大"), "qrc:/resources/SiYi/ZoomIn.svg", false],
                    [qsTr("缩小"), "qrc:/resources/SiYi/ZoomOut.svg", false],
                    [qsTr("回中"), "qrc:/resources/SiYi/Reset.svg", false],
                    [qsTr("对焦"), "qrc:/resources/SiYi/BeadSight.svg", false],
                    [qsTr("向上"), "qrc:/resources/SiYi/Up.svg", true],
                    [qsTr("向下"), "qrc:/resources/SiYi/Down.svg", true],
                    [qsTr("向左"), "qrc:/resources/SiYi/Left.svg", true],
                    [qsTr("向右"), "qrc:/resources/SiYi/Right.svg", true]
                ]
                Row {
                    spacing: 10
                    Text {
                        text: modelData[0]
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Image {
                        id: iconImage
                        width: 32
                        height: 32
                        source: modelData[1]
                        anchors.verticalCenter: parent.verticalCenter
                        MouseArea {
                            id: iconMouse
                            anchors.fill: parent
                            onPressed: {
                                if (index === 0) { // 放大
                                    camera.zoom(1)
                                } else if (index === 1) { // 缩小
                                    camera.zoom(-1)
                                } else if (index === 2) { // 回中
                                    camera.resetPostion()
                                } else if (index === 3) { // 自动对焦
                                    camera.autoFocus()
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
                            color: iconMouse.pressed ? "green" : "white"
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
