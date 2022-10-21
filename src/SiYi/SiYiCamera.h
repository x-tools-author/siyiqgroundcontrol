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
protected:
    void timerEvent(QTimerEvent *event) override;
private:
    int heartheatTimerId_;
    int connectionTimerId_;
};

#endif // SIYICAMERA_H
