#ifndef CSOUNDPROXY_H
#define CSOUNDPROXY_H

#include <QObject>
#include <QQueue>
#include <QString>
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
    Q_INVOKABLE void compileOrc(const QString &code);
    Q_INVOKABLE void startCsound();
    Q_INVOKABLE void stopCsound();
    Q_INVOKABLE bool isPlaying() const;

    //CSOUND * getCsound();

signals:
    void csoundReady();

private:
    void *cs; // CsoundObj will be pointed here. Cannot import Objective C CsoundObj here
    CSOUND *csound;
    QQueue<QString> m_eventQueue;
    
    void initializeCsound();
    void processEventQueue();
};

#endif // CSOUNDPROXY_H
