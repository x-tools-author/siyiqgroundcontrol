#include <QTimerEvent>
#include "SiYiCamera.h"

SiYiCamera::SiYiCamera(QObject *parent)
    : SiYiTcpClient(parent)
    , heartheatTimerId_(-1)
{
    connect(this, &SiYiCamera::connected, this, [=](){
        this->heartheatTimerId_ = this->startTimer(4000);
    });
    connect(this, &SiYiCamera::disconnected, this, [=](){
        this->killTimer(heartheatTimerId_);
    });

    connectionTimerId_ = startTimer(3000);
}

void SiYiCamera::timerEvent(QTimerEvent *event)
{
    if (heartheatTimerId_ == event->timerId()) {
        bool ok = false;
        QByteArray ack = sendMessage(0x01, 0x80, QByteArray(), &ok);
        if (ok) {
            Q_UNUSED(ack);
        }
    } else if (connectionTimerId_ == event->timerId()) {
        if (QTcpSocket::UnconnectedState == state()) {
            connectToHost("192.168.144.25", 37256);
        }
    }
}
