#ifndef SIYICAMERA_H
#define SIYICAMERA_H

#include <QObject>
#include <QHostAddress>

#include "SiYiTcpClient.h"

class SiYiCamera : public SiYiTcpClient
{
    Q_OBJECT
    Q_PROPERTY(bool isRecording READ isRecording NOTIFY isRecordingChanged)
    Q_PROPERTY(int zoomMultiple READ zoomMultiple NOTIFY zoomMultipleChanged)
    Q_PROPERTY(bool enableZoom READ enableZoom NOTIFY enableZoomChanged)
    Q_PROPERTY(bool enableFocus READ enableFocus NOTIFY enableFocusChanged)
    Q_PROPERTY(bool enablePhoto READ enablePhoto NOTIFY enablePhotoChanged)
    Q_PROPERTY(bool enableVideo READ enableVideo NOTIFY enableVideoChanged)
    Q_PROPERTY(bool enableControl READ enableControl NOTIFY enableControlChanged)
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
    enum CameraCommand {
        CameraCommandTakePhoto
    };
    Q_ENUM(CameraCommand);
    enum CameraVideoCommand {
        CloseRecording,
        OpenRecording
    };
    Q_ENUM(CameraVideoCommand);

signals:
    void operationResultChanged(int result);

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
    Q_INVOKABLE bool sendCommand(int cmd);
    Q_INVOKABLE bool sendRecodingCommand(int cmd);
    bool GetRecordingState();
    Q_INVOKABLE void analyzeIp(QString videoUrl);
protected:
    QByteArray heartbeatMessage() override;
    void analyzeMessage() override;
private:
    QByteArray packMessage(quint8 control, quint8 cmd,
                           const QByteArray &payload);
    quint32 headerCheckSum32(ProtocolMessageHeaderContext *ctx);
    quint32 packetCheckSum32(ProtocolMessageContext *ctx);
    bool unpackMessage(ProtocolMessageContext *ctx,
                       const QByteArray &msg);
    void GetCamerVersion();

private:
    void messageHandle0x80(const QByteArray &msg);
    void messageHandle0x81(const QByteArray &msg);
    void messageHandle0x94(const QByteArray &msg);
    void messageHandle0x98(const QByteArray &msg);
    void messageHandle0x9e(const QByteArray &msg);

private:
    bool isRecording_{false};
    bool isRecording(){return isRecording_;}
    Q_SIGNAL void isRecordingChanged();

    int zoomMultiple_{1};
    int zoomMultiple(){return zoomMultiple_;}
    Q_SIGNAL void zoomMultipleChanged();

    bool enableZoom_{false};
    bool enableZoom(){return enableZoom_;}
    Q_SIGNAL void enableZoomChanged();

    bool enableFocus_{false};
    bool enableFocus(){return enableFocus_;}
    Q_SIGNAL void enableFocusChanged();

    bool enablePhoto_{false};
    bool enablePhoto(){return enablePhoto_;}
    Q_SIGNAL void enablePhotoChanged();

    bool enableVideo_{false};
    bool enableVideo(){return enableVideo_;}
    Q_SIGNAL void enableVideoChanged();

    bool enableControl_{false};
    bool enableControl(){return enableControl_;}
    Q_SIGNAL void enableControlChanged();
};

#endif // SIYICAMERA_H
