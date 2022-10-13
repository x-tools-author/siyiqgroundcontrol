#include <QTimer>
#include <QtEndian>
#include <QTcpSocket>

#include "SiYiCrcApi.h"
#include "SiYiTcpClient.h"

#define PROTOCOL_STX 0x5566AABB

SiYiTcpClient::SiYiTcpClient(QObject *parent)
    : QTcpSocket(parent)
{
    sequence_ = quint16(qrand());
}

SiYiTcpClient::~SiYiTcpClient()
{
    if (this->state() == QTcpSocket::ConnectedState) {
        disconnectFromHost();
    }
}

QByteArray SiYiTcpClient::sendMessage(quint8 control, quint8 cmdId,
                                      const QByteArray &data, bool *ok)
{
    QByteArray msg = packMessage(control, cmdId, data);
    qDebug() << "Tx:" << QString(msg.toHex(' '));
    if (QTcpSocket::ConnectedState == state()) {
        if (msg.length() == write(msg)) {
            if (ok) *ok = true;
            qDebug() << "Tx:" << QString(msg.toHex(' '));
            if (control & 0x01) {
                if (waitForReadyRead()) {
                    QByteArray ack = readAll();
                    qDebug() << "Rx:" << QString(ack.toHex(' '));
                    return ack;
                }
            } else {
                if (ok) *ok = true;
                return QByteArray();
            }
        }
    }

    if (ok) *ok = false;
    return QByteArray();
}

QByteArray SiYiTcpClient::packMessage(quint8 control, quint8 cmdId,
                                      const QByteArray &data)
{
    ProtocolMessageContext ctx;
    ctx.header.stx = PROTOCOL_STX;
    ctx.header.control = control;
    ctx.header.dataLength = data.length();
    ctx.header.sequence = sequence();
    ctx.header.cmdId = cmdId;
    ctx.header.crc = headerCheckSum32(&ctx.header);
    ctx.data = data;
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

bool SiYiTcpClient::unpackMessage(ProtocolMessageContext *ctx,
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

quint16 SiYiTcpClient::sequence()
{
//    quint16 seq = sequence_;
//    sequence_ += 1;
//    return seq;

    return 0;
}

quint32 SiYiTcpClient::headerCheckSum32(ProtocolMessageHeaderContext *ctx)
{
    if (ctx) {
        QByteArray bytes;
        quint32 beStx = qToBigEndian<quint32>(ctx->stx);
        bytes.append(reinterpret_cast<char*>(&beStx), 4);
        bytes.append(reinterpret_cast<char*>(&ctx->control), 1);
        bytes.append(reinterpret_cast<char*>(&ctx->dataLength), 4);
        bytes.append(reinterpret_cast<char*>(&ctx->sequence), 2);
        bytes.append(reinterpret_cast<char*>(&ctx->cmdId), 1);
        qDebug() << "Header:" << QString(bytes.toHex(' '));

        return checkSum32(bytes);
    }

    return 0;
}

quint32 SiYiTcpClient::packetCheckSum32(ProtocolMessageContext *ctx)
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

quint32 SiYiTcpClient::checkSum32(const QByteArray &bytes)
{
    SiYiCrcApi crcApi;
    QByteArray input = bytes;
    quint32 crc32 = crcApi.crcCalculate<quint32>(
                reinterpret_cast<uint8_t *>(input.data()),
                bytes.length(),
                SiYiCrcApi::CRC_32_MPEG2);
    return crc32;
}
