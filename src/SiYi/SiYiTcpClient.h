#ifndef SIYITCPCLIENT_H
#define SIYITCPCLIENT_H

#include <QMutex>
#include <QThread>
#include <QVector>
#include <QTcpSocket>

class SiYiTcpClient : public QTcpSocket
{
    Q_OBJECT
public:
    struct ProtocolMessageHeaderContext {
        quint32 stx;
        quint8 control;
        quint32 dataLength;
        quint16 sequence;
        quint8 cmdId;
        quint32 crc;
    };
    struct ProtocolMessageContext {
        ProtocolMessageHeaderContext header;
        QByteArray data;
        quint32 crc;
    };
public:
    SiYiTcpClient(const QString ip, quint16 port, QObject *parent = Q_NULLPTR);
    ~SiYiTcpClient();

    QByteArray sendMessage(quint8 control, quint8 cmdId,
                           const QByteArray &data, bool *ok = Q_NULLPTR);
    QByteArray sendMessage(const QByteArray &msg, bool needResponse,
                           bool *ok = Q_NULLPTR);
protected:
    void timerEvent(QTimerEvent *event) override;

    QByteArray packMessage(quint8 control, quint8 cmdId,
                           const QByteArray &data);
    bool unpackMessage(ProtocolMessageContext *ctx, const QByteArray &msg);
    quint16 sequence();
protected:
    virtual QByteArray heartbeatMessage() = 0;
    virtual void onHeartBearMessageReceived(const QByteArray &msg) = 0;
private:
    quint16 sequence_;
    int heartheatTimerId_;
    int connectionTimerId_;
    const QString ip_;
    const quint16 port_;
private:
    quint32 headerCheckSum32(ProtocolMessageHeaderContext *ctx);
    quint32 packetCheckSum32(ProtocolMessageContext *ctx);
    quint32 checkSum32(const QByteArray &bytes);
};

#endif // SIYITCPCLIENT_H
