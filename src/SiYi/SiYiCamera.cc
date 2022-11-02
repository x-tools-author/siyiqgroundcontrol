#include <QtEndian>
#include <QTimerEvent>

#include "SiYiCamera.h"

SiYiCamera::SiYiCamera(QObject *parent)
    : SiYiTcpClient("192.168.144.25", 37256)
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

    QByteArray msg = packMessage(0x01, cmdId, body);
    sendMessage(msg);
    return true;
}

bool SiYiCamera::resetPostion()
{
    uint8_t cmdId = 0x9b;
    QByteArray body;
    body.append(char(0x01));

    QByteArray msg = packMessage(0x01, cmdId, body);
    sendMessage(msg);
    return true;
}

bool SiYiCamera::autoFocus()
{
    uint8_t cmdId = 0x97;
    QByteArray body;
    body.append(char(0x01));

    QByteArray msg = packMessage(0x01, cmdId, body);
    sendMessage(msg);
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

    QByteArray msg = packMessage(0x01, cmdId, body);
    sendMessage(msg);
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

    QByteArray msg = packMessage(0x01, cmdId, body);
    sendMessage(msg);
    return true;
}

QByteArray SiYiCamera::heartbeatMessage()
{
    return packMessage(0x01, 0x80, QByteArray());
}

void SiYiCamera::analyzeMessage()
{

}

QByteArray SiYiCamera::packMessage(quint8 control, quint8 cmd,
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
    msg.append(reinterpret_cast<char*>(&ctx.header.dataLength), 4); // Data_len
    msg.append(reinterpret_cast<char*>(&ctx.header.sequence), 2);   // SEQ
    msg.append(reinterpret_cast<char*>(&ctx.header.cmdId), 1);      // CMD_ID
    msg.append(reinterpret_cast<char*>(&ctx.header.crc), 4);        // CRC32(header)
    msg.append(ctx.data);                                           // DATA
    msg.append(reinterpret_cast<char*>(&ctx.crc), 4);               // CRC32(packet)

    return msg;
}

quint32 SiYiCamera::headerCheckSum32(ProtocolMessageHeaderContext *ctx)
{
    if (ctx) {
        QByteArray bytes;
        quint32 beStx = qToBigEndian<quint32>(ctx->stx);
        bytes.append(reinterpret_cast<char*>(&beStx), 4);
        bytes.append(reinterpret_cast<char*>(&ctx->control), 1);
        bytes.append(reinterpret_cast<char*>(&ctx->dataLength), 4);
        bytes.append(reinterpret_cast<char*>(&ctx->sequence), 2);
        bytes.append(reinterpret_cast<char*>(&ctx->cmdId), 1);

        return checkSum32(bytes);
    }

    return 0;
}

quint32 SiYiCamera::packetCheckSum32(ProtocolMessageContext *ctx)
{
    if (ctx) {
        QByteArray bytes;
        quint32 beStx = qToBigEndian<quint32>(ctx->header.stx);
        bytes.append(reinterpret_cast<char*>(&beStx), 4);
        bytes.append(reinterpret_cast<char*>(&ctx->header.control), 1);
        bytes.append(reinterpret_cast<char*>(&ctx->header.dataLength), 4);
        bytes.append(reinterpret_cast<char*>(&ctx->header.sequence), 2);
        bytes.append(reinterpret_cast<char*>(&ctx->header.cmdId), 1);
        bytes.append(reinterpret_cast<char*>(&ctx->header.crc), 4);

        bytes.append(ctx->data);

        return checkSum32(bytes);
    }

    return 0;
}

bool SiYiCamera::unpackMessage(ProtocolMessageContext *ctx,
                               const QByteArray &msg)
{
    if (ctx) {
        int offset = 0;
        if (msg.length() >= 16) {
            // STX
            const quint32 *ptr32 =
                    reinterpret_cast<const quint32 *>(msg.data());
            quint32 i32 = *ptr32;
            i32 = qToBigEndian<quint32>(i32);
            ctx->header.stx = i32;
            offset += 4;
            // CTRL
            const quint8 *ptr8 =
                    reinterpret_cast<const quint8*>(msg.data() + offset);
            quint8 i8 = *ptr8;
            ctx->header.control = i8;
            offset += 1;
            // Data_len
            ptr32 = reinterpret_cast<const quint32 *>(msg.data() + offset);
            i32 = *ptr32;
            ctx->header.dataLength = i32;
            offset += 4;
            // SEQ
            const quint16 *ptr16 =
                    reinterpret_cast<const quint16*>(msg.data() + offset);
            quint16 i16 = *ptr16;
            ctx->header.sequence = i16;
            offset += 2;
            // CMD_ID
            ptr8 = reinterpret_cast<const quint8*>(msg.data() + offset);
            i8 = *ptr8;
            ctx->header.cmdId = i8;
            offset += 1;
            // CRC32(header)
            ptr32 = reinterpret_cast<const quint32 *>(msg.data() + offset);
            i32 = *ptr32;
            ctx->header.crc = i32;
            offset += 4;

            if (msg.length() >= int(16 + ctx->header.dataLength + 2)) {
                QByteArray data(msg.data() + offset, ctx->header.dataLength);
                ctx->data = data;
                offset += ctx->header.dataLength;

                ptr32 = reinterpret_cast<const quint32 *>(msg.data() + offset);
                i32 = *ptr32;
                ctx->crc = i32;

                if (ctx->header.stx == PROTOCOL_STX) {
                    QByteArray headerBytes(msg.data(), 16);
                    QByteArray packetBytes(msg.data(), 16
                                           + ctx->header.dataLength);
                    quint32 headerCrc = checkSum32(headerBytes);
                    quint32 packetCrc = checkSum32(packetBytes);
                    if (headerCrc == ctx->header.crc
                            && packetCrc == ctx->crc) {
                        return true;
                    }
                }
            }
        }
    }

    return false;
}
