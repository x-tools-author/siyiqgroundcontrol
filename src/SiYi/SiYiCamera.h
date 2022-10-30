#ifndef SIYICAMERA_H
#define SIYICAMERA_H

#include <QObject>
#include <QHostAddress>

#include "SiYiTcpClient.h"

class SiYiCamera : public SiYiTcpClient
{
    Q_OBJECT
public:
    explicit SiYiCamera(QObject *parent = nullptr);
    ~SiYiCamera();

    Q_INVOKABLE bool turn(int yaw, int pitch);
    Q_INVOKABLE bool resetPostion();
    Q_INVOKABLE bool autoFocus();
    // 1: 放大，0：停止，-1：缩小
    Q_INVOKABLE bool zoom(int option);
    // 1: 远景，0：停止，-1：近景
    Q_INVOKABLE bool focus(int option);
protected:
    QByteArray heartbeatMessage() override;
    void onHeartBearMessageReceived(const QByteArray &msg) override;
private:
    int heartheatTimerId_;
    int connectionTimerId_;
};

#endif // SIYICAMERA_H
