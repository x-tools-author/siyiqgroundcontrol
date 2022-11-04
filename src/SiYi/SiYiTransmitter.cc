#include <QtEndian>
#include "SiYiTransmitter.h"

SiYiTransmitter::SiYiTransmitter(QObject *parent)
    : SiYiTcpClient{"192.168.144.12", 5864, parent}
{

}

QByteArray SiYiTransmitter::heartbeatMessage()
{
#if 1
    return packMessage(0x01, 0x83, QByteArray());
#else
    return packMessage(0x01, 0x2f, QByteArray());
#endif
}

void SiYiTransmitter::analyzeMessage()
{
    rxBytesMutex_.lock();
    while (rxBytes_.length() >= 4) {
        if (rxBytes_.at(0) == 0x55 && rxBytes_.at(1) == 0x56
                && rxBytes_.at(2) == 0xaa && rxBytes_.at(3) == 0xbb) {
            int headerLength = 4+1+2+2+1+4;
            if (rxBytes_.length() >= (4+1+2+2+1+4)) {
                ProtocolMessageHeaderContext header;
                header.stx = *reinterpret_cast<quint32*>(rxBytes_.data());
                header.control = *reinterpret_cast<quint8*>(rxBytes_.data() + 4);
                header.dataLength = *reinterpret_cast<quint16*>(rxBytes_.data() + 1);
                header.sequence = *reinterpret_cast<quint16*>(rxBytes_.data() + 2);
                header.cmdId = *reinterpret_cast<quint16*>(rxBytes_.data() + 2);
                header.crc = *reinterpret_cast<quint16*>(rxBytes_.data() + 1);

                header.stx = qToBigEndian<quint32>(header.stx);
                header.control = qToBigEndian<quint8>(header.control);
                header.dataLength = qToBigEndian<quint16>(header.dataLength);
                header.sequence = qToBigEndian<quint16>(header.sequence);
                header.cmdId = qToBigEndian<quint8>(header.cmdId);
                header.crc = qToBigEndian<quint32>(header.crc);

                ProtocolMessageContext msg;
                msg.header = header;
                if (rxBytes_.length() >= (headerLength + header.dataLength + 4)) {
                    msg.data = QByteArray(rxBytes_.data() + headerLength);
                    int offset = headerLength + header.dataLength;
                    msg.crc = *reinterpret_cast<quint16*>(rxBytes_.data() + offset);
                    msg.crc = qToBigEndian<quint32>(msg.crc);
                }

                int msgLen = headerLength + msg.data.length() + 4;
                if (msg.header.cmdId == 0x83) {
                    QByteArray packet = QByteArray(rxBytes_.data(), msgLen);
                    onHeartbeatMessageReceived(packet);
                }

                rxBytes_.remove(0, msgLen);
            }
        } else {
            rxBytes_.remove(0, 1);
        }
    }
    rxBytesMutex_.unlock();
}

QByteArray SiYiTransmitter::packMessage(quint8 control, quint8 cmd,
                       const QByteArray &payload)
{
    ProtocolMessageContext ctx;
    ctx.header.stx = PROTOCOL_STX;
    ctx.header.control = control;
    ctx.header.dataLength = payload.length();
    ctx.header.sequence = sequence();
    ctx.header.cmdId = cmd;
    ctx.header.crc = headerCheckSum32(&ctx.header);
    ctx.data = payload;
    ctx.crc = packetCheckSum32(&ctx);

    QByteArray msg;
    quint32 beStx = qToBigEndian<quint32>(ctx.header.stx);

    msg.append(reinterpret_cast<char*>(&beStx), 4);                 // STX
    msg.append(reinterpret_cast<char*>(&ctx.header.control), 1);    // CTRL
    msg.append(reinterpret_cast<char*>(&ctx.header.dataLength), 2); // Data_len
    msg.append(reinterpret_cast<char*>(&ctx.header.sequence), 2);   // SEQ
    msg.append(reinterpret_cast<char*>(&ctx.header.cmdId), 1);      // CMD_ID
    msg.append(reinterpret_cast<char*>(&ctx.header.crc), 4);        // CRC32(header)
    msg.append(ctx.data);                                           // DATA
    msg.append(reinterpret_cast<char*>(&ctx.crc), 4);               // CRC32(packet)

    return msg;
}

quint32 SiYiTransmitter::headerCheckSum32(ProtocolMessageHeaderContext *ctx)
{
    if (ctx) {
        QByteArray bytes;
        quint32 beStx = qToBigEndian<quint32>(ctx->stx);
        bytes.append(reinterpret_cast<char*>(&beStx), 4);
        bytes.append(reinterpret_cast<char*>(&ctx->control), 1);
        bytes.append(reinterpret_cast<char*>(&ctx->dataLength), 2);
        bytes.append(reinterpret_cast<char*>(&ctx->sequence), 2);
        bytes.append(reinterpret_cast<char*>(&ctx->cmdId), 1);

        return checkSum32(bytes);
    }

    return 0;
}

quint32 SiYiTransmitter::packetCheckSum32(ProtocolMessageContext *ctx)
{
    if (ctx) {
        QByteArray bytes;
        quint32 beStx = qToBigEndian<quint32>(ctx->header.stx);
        bytes.append(reinterpret_cast<char*>(&beStx), 4);
        bytes.append(reinterpret_cast<char*>(&ctx->header.control), 1);
        bytes.append(reinterpret_cast<char*>(&ctx->header.dataLength), 2);
        bytes.append(reinterpret_cast<char*>(&ctx->header.sequence), 2);
        bytes.append(reinterpret_cast<char*>(&ctx->header.cmdId), 1);
        bytes.append(reinterpret_cast<char*>(&ctx->header.crc), 4);

        bytes.append(ctx->data);

        return checkSum32(bytes);
    }

    return 0;
}

void SiYiTransmitter::onHeartbeatMessageReceived(const QByteArray &msg)
{
    int offset = 4 + 1 + 2 + 2 + 1 + 4;
    if (msg.length() == int(offset + sizeof(HeartbeatAckContext))) {
        const char *ptr = msg.constData();
        ptr += offset;
        auto ctx = reinterpret_cast<const HeartbeatAckContext*>(ptr);

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
    } else {
        qWarning() << "bad heartbeat message:" << msg.toHex(' ') ;
    }
}
