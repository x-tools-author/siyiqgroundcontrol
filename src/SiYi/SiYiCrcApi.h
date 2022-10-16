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
    SiYiCrcApi(QObject *parent = Q_NULLPTR);
    static quint32 calculateCrc32(const QByteArray &bytes);
};

#endif
