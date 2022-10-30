#include "SiYiTransmitter.h"

SiYiTransmitter::SiYiTransmitter(QObject *parent)
    : SiYiTcpClient{"192.168.144.12", 5864, parent}
{
    // 连接成功后，获取固件版本
    connect(this, &SiYiTransmitter::connected, this, [=](){
        bool ok = false;
        QByteArray ack = this->sendMessage(0x01, 0x20, QByteArray(), &ok);
        if (ack.length() >= 3) {
            int major = ack[2];
            int minor = ack[1];
            int patch = ack[0];
            this->version_ = QString("%1.%2.%3").arg(major, minor, patch);
            emit this->versionChanged();
        }
    });
}

QByteArray SiYiTransmitter::heartbeatMessage()
{
    return packMessage(0x01, 0x2f, QByteArray());
}

void SiYiTransmitter::onHeartBearMessageReceived(const QByteArray &msg)
{
    if (msg.length() == sizeof(HeartbeatAckContext))
    {
        auto ctx = reinterpret_cast<const HeartbeatAckContext*>(msg.data());

        signalQuality_ = ctx->signal;
        inactiveTime_ = ctx->inactiveTime;
        upStream_ = ctx->upStream;
        downStream_ = ctx->downStream;
        txBanWidth_ = ctx->txBanWidth;
        rxBanWidth_ = ctx->rxBanWidth;
        rssi_ = ctx->rssi;
        freq_ = ctx->freq;
        channel_ = ctx->channel;

        emit signalQualityChanged();
        emit inactiveTimeChanged();
        emit upStreamChanged();
        emit downStreamChanged();
        emit txBanWidthChanged();
        emit rxBanWidthChanged();
        emit rssiChanged();
        emit freqChanged();
        emit channelChanged();
    }
}
