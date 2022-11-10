#ifndef SIYICAMERA_H
#define SIYICAMERA_H

#include <QObject>
#include <QHostAddress>

#include "SiYiTcpClient.h"

class SiYiCamera : public SiYiTcpClient
{
    Q_OBJECT
    Q_PROPERTY(bool isRecording READ isRecording NOTIFY isRecordingChanged)
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

private:
    void messageHandle0x80(const QByteArray &msg);
    void messageHandle0x81(const QByteArray &msg);

private:
    bool isRecording_{false};
    bool isRecording(){return isRecording_;}
    Q_SIGNAL void isRecordingChanged();
};

#endif // SIYICAMERA_H
