#ifndef SIYI_H
#define SIYI_H

#include <QMutex>
#include <QObject>

#include "SiYiCamera.h"
#include "SiYiTransmitter.h"

class SiYi : public QObject
{
    Q_OBJECT
public:
    explicit SiYi(QObject *parent = nullptr);
    static SiYi *instance();
    SiYiCamera *camera();
    SiYiTransmitter *transmitter();
private:
    static SiYi *instance_;
    SiYiCamera *camera_;
    SiYiTransmitter *transmitter_;
};

#endif // SIYI_H
