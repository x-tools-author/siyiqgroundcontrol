#ifndef SIYITCPCLIENT_H
#define SIYITCPCLIENT_H

#include <QMutex>
#include <QThread>
#include <QVector>
#include <QTcpSocket>

#define PROTOCOL_STX 0x5566AABB

class SiYiTcpClient : public QThread
{
    Q_OBJECT
public:
    SiYiTcpClient(const QString ip, quint16 port, QObject *parent = Q_NULLPTR);
    ~SiYiTcpClient();

    void sendMessage(const QByteArray &msg);
protected:
    virtual void analyzeMessage() = 0;
    virtual QByteArray heartbeatMessage() = 0;
protected:
    QVector<QByteArray> txMessageVector_;
    QMutex txMessageVectorMutex_;
    QByteArray rxBytes_;
    QMutex rxBytesMutex_;
protected:
    quint16 sequence();
    void run() override;
    quint32 checkSum32(const QByteArray &bytes);
private:
    quint16 sequence_;
    const QString ip_;
    const quint16 port_;
};

#endif // SIYITCPCLIENT_H
