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
    Q_PROPERTY(bool isConnected READ isConnected NOTIFY isConnectedChanged)
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
    int timeoutCount = 0;
    QMutex timeoutCountMutex;
    QString ip_;
    quint16 port_;
protected:
    quint16 sequence();
    void run() override;
    quint32 checkSum32(const QByteArray &bytes);
    void resetIp(const QString &ip);
private:
    quint16 sequence_;
signals:
    void connected();
    void disconnected();
    void ipChanged();
private:
    bool isConnected_{false};
    bool isConnected(){return isConnected_;}
    Q_SIGNAL void isConnectedChanged();
};

#endif // SIYITCPCLIENT_H
