#include <QTimer>
#include <QtEndian>
#include <QDateTime>
#include <QTcpSocket>
#include <QTimerEvent>

#include "SiYiCrcApi.h"
#include "SiYiTcpClient.h"



SiYiTcpClient::SiYiTcpClient(const QString ip, quint16 port, QObject *parent)
    : QThread(parent)
    , ip_(ip)
    , port_(port)
{
    sequence_ = quint16(QDateTime::currentMSecsSinceEpoch());
    // 自动重连
    connect(this, &SiYiTcpClient::finished, this, [=](){start();});
}

SiYiTcpClient::~SiYiTcpClient()
{
    if (isRunning()) {
        exit();
        wait();
    }
}

void SiYiTcpClient::sendMessage(const QByteArray &msg)
{
    if (isRunning()) {
        txMessageVectorMutex_.lock();
        txMessageVector_.append(msg);
        txMessageVectorMutex_.unlock();
    }
}

quint16 SiYiTcpClient::sequence()
{
    quint16 seq = sequence_;
    sequence_ += 1;
    return seq;
}

void SiYiTcpClient::run()
{
    QTcpSocket *tcpClient = new QTcpSocket();
    QTimer *txTimer = new QTimer();
    QTimer *rxTimer = new QTimer();
    QTimer *heartbeatTimer = new QTimer();
    const QString info = QString("[%1:%2]:").arg(ip_, QString::number(port_));

    connect(tcpClient, &QTcpSocket::connected, tcpClient, [=](){
        heartbeatTimer->start();
        emit connected();
        this->isConnected_ = true;
        emit isConnectedChanged();
        qInfo() << info << "Connect to server successfully!";
    });
    connect(tcpClient, &QTcpSocket::disconnected, tcpClient, [=](){
        this->isConnected_ = false;
        emit isConnectedChanged();
        txMessageVectorMutex_.lock();
        txMessageVector_.clear();
        txMessageVectorMutex_.unlock();
        heartbeatTimer->stop();
        exit();
        qInfo() << info << "Disconnect from server!";
    });
    connect(tcpClient, &QTcpSocket::errorOccurred, tcpClient, [=](){
        heartbeatTimer->stop();
        exit();
        qInfo() << info << tcpClient->errorString();
    });
    connect(tcpClient, &QTcpSocket::readyRead, tcpClient, [=](){
        QByteArray bytes = tcpClient->readAll();
        this->rxBytesMutex_.lock();
        this->rxBytes_.append(bytes);
        this->rxBytesMutex_.unlock();

        qInfo() << info << "Rx:" << bytes.toHex(' ');
    });

    // 定时发送
    txTimer->setInterval(10);
    txTimer->setSingleShot(true);
    connect(txTimer, &QTimer::timeout, txTimer, [=](){
        txMessageVectorMutex_.lock();
        QByteArray msg = txMessageVector_.isEmpty()
                ? QByteArray() : txMessageVector_.takeFirst();
        txMessageVectorMutex_.unlock();

        if ((!msg.isEmpty())
                && (tcpClient->state() == QTcpSocket::ConnectedState)) {
            if (tcpClient->write(msg) != -1) {
                qInfo() << info << "Tx:" << msg.toHex(' ');
            } else {
                qInfo() << info << tcpClient->errorString();
            }
        }

        txTimer->start();
    });

    // 定时处理接收数据
    rxTimer->setInterval(10);
    rxTimer->setSingleShot(true);
    connect(rxTimer, &QTimer::timeout, rxTimer, [=](){
        analyzeMessage();
        rxTimer->start();
    });

    // 心跳
    heartbeatTimer->setInterval(1500);
    heartbeatTimer->setSingleShot(true);
    connect(heartbeatTimer, &QTimer::timeout, heartbeatTimer, [=](){
        QByteArray msg = heartbeatMessage();
        sendMessage(msg);
        heartbeatTimer->start();
    });

    tcpClient->connectToHost(ip_, port_);

    txTimer->start();
    rxTimer->start();
    exec();
    txTimer->deleteLater();
    tcpClient->deleteLater();
}

quint32 SiYiTcpClient::checkSum32(const QByteArray &bytes)
{
    return SiYiCrcApi::calculateCrc32(bytes);
}

void SiYiTcpClient::resetIp(const QString &ip)
{
    if (ip_ != ip) {
        ip_ = ip;
        exit();
        wait();
        emit ipChanged();
    }
}
