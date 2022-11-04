#ifndef SIYITRANSMITTER_H
#define SIYITRANSMITTER_H

#include "SiYiTcpClient.h"

class SiYiTransmitter : public SiYiTcpClient
{
    Q_OBJECT
    Q_PROPERTY(int signalQuality READ signalQuality NOTIFY signalQualityChanged)
    Q_PROPERTY(int inactiveTime READ inactiveTime NOTIFY inactiveTimeChanged)
    Q_PROPERTY(int upStream READ upStream NOTIFY upStreamChanged)
    Q_PROPERTY(int downStream READ downStream NOTIFY downStreamChanged)
    Q_PROPERTY(int txBanWidth READ txBanWidth NOTIFY txBanWidthChanged)
    Q_PROPERTY(int rxBanWidth READ rxBanWidth NOTIFY rxBanWidthChanged)
    Q_PROPERTY(int rssi READ rssi NOTIFY rssiChanged)
    Q_PROPERTY(int freq READ freq NOTIFY freqChanged)
    Q_PROPERTY(int channel READ channel NOTIFY channelChanged)

    Q_PROPERTY(QString version READ version NOTIFY versionChanged)
public:
    struct ProtocolMessageHeaderContext {
        quint32 stx;
        quint8 control;
        quint16 dataLength;
        quint16 sequence;
        quint8 cmdId;
        quint32 crc;
    };
    struct ProtocolMessageContext {
        ProtocolMessageHeaderContext header;
        QByteArray data;
        quint32 crc;
    };
    struct HeartbeatAckContext {
        qint32 signal;
        qint32 inactiveTime;
        qint32 upStream;
        qint32 downStream;
        qint32 txBanWidth;
        qint32 rxBanWidth;
        qint32 rssi;
        qint32 freq;
        qint32 channel;
    };
public:
    explicit SiYiTransmitter(QObject *parent = nullptr);
protected:
    QByteArray heartbeatMessage() override;
    void analyzeMessage() override;
private:
    QByteArray packMessage(quint8 control, quint8 cmd,
                           const QByteArray &payload);
    quint32 headerCheckSum32(ProtocolMessageHeaderContext *ctx);
    quint32 packetCheckSum32(ProtocolMessageContext *ctx);
    void onHeartbeatMessageReceived(const QByteArray &msg);
private:
    int signalQuality_{-1};
    int signalQuality(){return signalQuality_;}
    Q_SIGNAL void signalQualityChanged();

    int inactiveTime_{-1};
    int inactiveTime(){return inactiveTime_;}
    Q_SIGNAL void inactiveTimeChanged();

    int upStream_{-1};
    int upStream(){return upStream_;}
    Q_SIGNAL void upStreamChanged();

    int downStream_{-1};
    int downStream(){return downStream_;}
    Q_SIGNAL void downStreamChanged();

    int txBanWidth_{-1};
    int txBanWidth(){return txBanWidth_;}
    Q_SIGNAL void txBanWidthChanged();

    int rxBanWidth_{-1};
    int rxBanWidth(){return rxBanWidth_;}
    Q_SIGNAL void rxBanWidthChanged();

    int rssi_{-1};
    int rssi(){return rssi_;}
    Q_SIGNAL void rssiChanged();

    int freq_{-1};
    int freq(){return freq_;}
    Q_SIGNAL void freqChanged();

    int channel_{-1};
    int channel(){return channel_;}
    Q_SIGNAL void channelChanged();

    QString version_{"--"};
    QString version(){return version_;}
    Q_SIGNAL void versionChanged();
};

#endif // SIYITRANSMITTER_H()l;
