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
    Q_PROPERTY(bool hideWidgets READ hideWidgets WRITE setHideWidgets NOTIFY hideWidgetsChanged FINAL)
    Q_PROPERTY(int iconsHeight READ iconsHeight WRITE setIconsHeight NOTIFY iconsHeightChanged FINAL)
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

    bool hideWidgets_{false};
    bool hideWidgets() { return hideWidgets_; }
    void setHideWidgets(bool hideWidgets)
    {
        hideWidgets_ = hideWidgets;
        emit hideWidgetsChanged();
    }
    Q_SIGNAL void hideWidgetsChanged();

    int iconsHeight_{54};
    int iconsHeight() { return iconsHeight_; }
    void setIconsHeight(int iconsHeight)
    {
        iconsHeight_ = iconsHeight;
        emit iconsHeightChanged();
    }
    Q_SIGNAL void iconsHeightChanged();
};

#endif // SIYI_H
