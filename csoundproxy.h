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

    //CSOUND * getCsound();
    
    void setupMediaButtonHandling();
    
signals:
    // Add signals if you want to notify QML/Qt of media button events
    void playPressed();
    void pausePressed();
    void stopPressed();
    void nextPressed();
    void previousPressed();

private:
    void *cs; // CsoundObj will be pointed here. Cannot import Objective C CsoundObj here
    CSOUND *csound;
};

#endif // CSOUNDPROXY_H
