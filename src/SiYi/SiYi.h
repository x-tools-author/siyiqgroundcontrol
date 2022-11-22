#ifndef SIYI_H
#define SIYI_H

#include <QMutex>
#include <QObject>
#include <QVariant>

#include "SiYiCamera.h"
#include "SiYiTransmitter.h"

class SiYi : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariant camera READ camera CONSTANT)
    Q_PROPERTY(QVariant transmitter READ transmitter CONSTANT)
    Q_PROPERTY(bool isAndroid READ isAndroid CONSTANT)
public:
    explicit SiYi(QObject *parent = nullptr);
    static SiYi *instance();
    SiYiCamera *cameraInstance();
    SiYiTransmitter *transmitterInstance();
private:
    static SiYi *instance_;
    SiYiCamera *camera_;
    SiYiTransmitter *transmitter_;
    bool isTransmitterConnected_{false};
private:
    QVariant camera(){return QVariant::fromValue(camera_);}
    QVariant transmitter(){return QVariant::fromValue(transmitter_);}
private:
    bool isAndroid_;
    bool isAndroid(){return isAndroid_;}
};

#endif // SIYI_H
