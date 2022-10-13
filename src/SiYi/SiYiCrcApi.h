#ifndef SIYICRCAPI_H
#define SIYICRCAPI_H

#include <QObject>
#ifndef SAK_IMPORT_MODULE_TESTLIB
#include <QComboBox>
#endif
#include <QStringList>

class SiYiCrcApi : public QObject
{
    Q_OBJECT
public:
    enum SAKEnumCrcModel{
        CRC_8,
        CRC_8_ITU,
        CRC_8_ROHC,
        CRC_8_MAXIM,

        CRC_16_IBM,
        CRC_16_MAXIM,
        CRC_16_USB,
        CRC_16_MODBUS,
        CRC_16_CCITT,
        CRC_16_CCITT_FALSE,
        CRC_16_x25,
        CRC_16_XMODEM,
        CRC_16_DNP,

        CRC_32,
        CRC_32_MPEG2
    };
    Q_ENUM(SAKEnumCrcModel);


public:
    SiYiCrcApi(QObject *parent = Q_NULLPTR);
    QStringList supportedParameterModels();
    uint32_t poly(SiYiCrcApi::SAKEnumCrcModel model);
    uint32_t xorValue(SiYiCrcApi::SAKEnumCrcModel model);
    uint32_t initialValue(SiYiCrcApi::SAKEnumCrcModel model);
    QString friendlyPoly(SiYiCrcApi::SAKEnumCrcModel model);
    bool isInputReversal(SiYiCrcApi::SAKEnumCrcModel model);
    bool isOutputReversal(SiYiCrcApi::SAKEnumCrcModel model);
    int bitsWidth(SiYiCrcApi::SAKEnumCrcModel model);
#ifndef SAK_IMPORT_MODULE_TESTLIB
    static void addCrcModelItemsToComboBox(QComboBox *comboBox);
#endif


public:
    template<typename T>
    T crcCalculate(uint8_t *input,
                   uint64_t length,
                   SiYiCrcApi::SAKEnumCrcModel model){
        T crcReg = static_cast<T>(initialValue(model));
        T rawPoly = static_cast<T>(poly(model));
        uint8_t byte = 0;

        T temp = 1;
        while (length--){
            byte = *(input++);
            if (isInputReversal(model)){
                reverseInt(byte,byte);
            }

            crcReg ^= static_cast<T>((byte << 8*(sizeof (T)-1)));
            for(int i = 0;i < 8;i++){
                if(crcReg & (temp << (sizeof (T)*8-1))){
                    crcReg = static_cast<T>((crcReg << 1) ^ rawPoly);
                }else {
                    crcReg = static_cast<T>(crcReg << 1);
                }
            }
        }

        if (isOutputReversal(model)){
            reverseInt(crcReg,crcReg);
        }

        T crc = (crcReg ^ static_cast<T>(xorValue(model))) ;
        return crc;
    }


private:
    QStringList modelStrings;


private:
    template<typename T>
    bool reverseInt(const T &input, T &output){
        int bitsWidth = sizeof (input)*8;
        QString inputStr = QString("%1").arg(QString::number(input, 2), bitsWidth, '0');
        QString outputStr;
        outputStr.resize(bitsWidth);
        for (int i = 0; i < bitsWidth; i++){
            outputStr.replace(i, 1, inputStr.at(bitsWidth-1-i));
        }

        bool ok;
        output = static_cast<T>(outputStr.toULongLong(&ok, 2));
        return ok;
    }
};

#endif
