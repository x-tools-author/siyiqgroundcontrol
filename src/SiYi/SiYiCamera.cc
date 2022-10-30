#include <QTimerEvent>
#include "SiYiCamera.h"

SiYiCamera::SiYiCamera(QObject *parent)
    : SiYiTcpClient("192.168.144.25", 37256)
    , heartheatTimerId_(-1)
{

}

SiYiCamera::~SiYiCamera()
{

}

bool SiYiCamera::turn(int yaw, int pitch)
{
    uint8_t cmdId = 0x9a;
    QByteArray body;
    body.append(char(yaw));
    body.append(char(pitch));

    bool ok = false;
    QByteArray response = sendMessage(0x01, cmdId, body, &ok);
    qDebug() << QString(response.toHex(' '));
    return true;
}

bool SiYiCamera::resetPostion()
{
    uint8_t cmdId = 0x9b;
    QByteArray body;
    body.append(char(0x01));

    bool ok = false;
    QByteArray response = sendMessage(0x01, cmdId, body, &ok);
    qDebug() << QString(response.toHex(' '));
    return true;
}

bool SiYiCamera::autoFocus()
{
    uint8_t cmdId = 0x97;
    QByteArray body;
    body.append(char(0x01));

    bool ok = false;
    QByteArray response = sendMessage(0x01, cmdId, body, &ok);
    qDebug() << QString(response.toHex(' '));
    return true;
}

Q_INVOKABLE bool SiYiCamera::zoom(int option)
{
    if (option != 1 && option != 0 && option != -1) {
        option = 0;
    }

    uint8_t cmdId = 0x98;
    QByteArray body;
    body.append(char(option));

    bool ok = false;
    QByteArray response = sendMessage(0x01, cmdId, body, &ok);
    qDebug() << QString(response.toHex(' '));
    return true;
}

Q_INVOKABLE bool SiYiCamera::focus(int option)
{
    if (option != 1 && option != 0 && option != -1) {
        option = 0;
    }

    uint8_t cmdId = 0x99;
    QByteArray body;
    body.append(char(option));

    bool ok = false;
    QByteArray response = sendMessage(0x01, cmdId, body, &ok);
    qDebug() << QString(response.toHex(' '));
    return true;
}

QByteArray SiYiCamera::heartbeatMessage()
{
    return packMessage(0x01, 0x80, QByteArray());
}

void SiYiCamera::onHeartBearMessageReceived(const QByteArray &msg)
{

}
