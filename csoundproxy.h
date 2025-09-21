#ifndef CSOUNDPROXY_H
#define CSOUNDPROXY_H

#include <QObject>
#include <csound.h>

class CsoundProxy : public QObject
{
    Q_OBJECT
public:
    explicit CsoundProxy(QObject *parent = nullptr);
    ~CsoundProxy();

    Q_INVOKABLE void play();
    Q_INVOKABLE void readScore(const QString &scoreLine);
    Q_INVOKABLE void setChannel(QString channel, double value);
    Q_INVOKABLE void stop();
    Q_INVOKABLE void restartCsound();

    //CSOUND * getCsound();
    

private:
    void *cs; // CsoundObj will be pointed here. Cannot import Objective C CsoundObj here
    CSOUND *csound;
    
    void initializeCsound();
    void stopCsound();
    void startCsound();
};

#endif // CSOUNDPROXY_H
