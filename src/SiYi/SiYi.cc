#include <QCoreApplication>

#include "SiYi.h"

SiYi *SiYi::instance_ = Q_NULLPTR;
SiYi::SiYi(QObject *parent)
    : QObject{parent}
{
    camera_ = new SiYiCamera(this);
    transmitter_ = new SiYiTransmitter(this);
    connect(transmitter_, &SiYiCamera::connected, this, [=](){
        this->isTransmitterConnected_ = true;
        camera_->start();
    });
    connect(transmitter_, &SiYiCamera::disconnected, this, [=](){
        this->isTransmitterConnected_ = false;
        transmitter_->exit();
    });

    connect(camera_, &SiYiCamera::ipChanged, this, [=](){
        if (isTransmitterConnected_) {
            camera_->start();
        } else {
            qInfo() << QString("Ip changed:%1, "
                               "but transmitter is not connected!")
                       .arg(camera_->property("ip").toString());
        }
    });

#ifdef Q_OS_ANDROID
    isAndroid_ = true;
#else
    isAndroid_ = false;
#endif

    transmitter_->start();
#if 0   // 为1时，云台控制无需先连接
    camera_->start();
#endif
}

SiYi *SiYi::instance()
{
    if (!instance_) {
        instance_ = new SiYi(qApp);
    }

    Q_ASSERT_X(instance_, __FUNCTION__,
               "Can not allocate memory for SiYi instance!");
    return instance_;
}

SiYiCamera *SiYi::cameraInstance()
{
    return camera_;
}

SiYiTransmitter *SiYi::transmitterInstance()
{
    return transmitter_;
}
