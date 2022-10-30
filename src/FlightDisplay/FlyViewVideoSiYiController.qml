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

Rectangle {
    id:     root
    clip:   true
    anchors.fill: parent
    color: "#8fff0000"

    property var siyi: SiYi
    property SiYiCamera camera: siyi.camera
    property SiYiTransmitter transmitter: siyi.transmitter

    Column {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        Repeater {
            model: [
                [qsTr("放大"), "qrc:/resources/SiYi/ZoomIn.svg", false],
                [qsTr("缩小"), "qrc:/resources/SiYi/ZoomOut.svg", false],
                [qsTr("回中"), "qrc:/resources/SiYi/Reset.svg", false],
                [qsTr("准星"), "qrc:/resources/SiYi/BeadSight.svg", false],
                [qsTr("向上"), "qrc:/resources/SiYi/Up.svg"],
                [qsTr("向下"), "qrc:/resources/SiYi/Down.svg"],
                [qsTr("向左"), "qrc:/resources/SiYi/Left.svg"],
                [qsTr("向右"), "qrc:/resources/SiYi/Right.svg"]
            ]
            Row {
                spacing: 10
                Text {
                    text: modelData[0]
                    anchors.verticalCenter: parent.verticalCenter
                }
                Image {
                    width: 32
                    height: 32
                    source: modelData[1]
                    anchors.verticalCenter: parent.verticalCenter
                }
                Slider {
                    id: slider
                    from: 0
                    to: 100
                    visible: modelData[2]
                    anchors.verticalCenter: parent.verticalCenter
                    onPressedChanged: {}
                }
            }
        }
    }
}
