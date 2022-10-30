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
    explicit SiYiTransmitter(QObject *parent = nullptr);
protected:
    QByteArray heartbeatMessage() override;
    void onHeartBearMessageReceived(const QByteArray &msg) override;
private:
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
private:
    int signalQuality_;
    int signalQuality(){return signalQuality_;}
    Q_SIGNAL void signalQualityChanged();

    int inactiveTime_;
    int inactiveTime(){return inactiveTime_;}
    Q_SIGNAL void inactiveTimeChanged();

    int upStream_;
    int upStream(){return upStream_;}
    Q_SIGNAL void upStreamChanged();

    int downStream_;
    int downStream(){return downStream_;}
    Q_SIGNAL void downStreamChanged();

    int txBanWidth_;
    int txBanWidth(){return txBanWidth_;}
    Q_SIGNAL void txBanWidthChanged();

    int rxBanWidth_;
    int rxBanWidth(){return rxBanWidth_;}
    Q_SIGNAL void rxBanWidthChanged();

    int rssi_;
    int rssi(){return rssi_;}
    Q_SIGNAL void rssiChanged();

    int freq_;
    int freq(){return freq_;}
    Q_SIGNAL void freqChanged();

    int channel_;
    int channel(){return channel_;}
    Q_SIGNAL void channelChanged();

    QString version_;
    QString version(){return version_;}
    Q_SIGNAL void versionChanged();
};

#endif // SIYITRANSMITTER_H()l;
