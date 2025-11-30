#ifndef CSOUNDPROXY_H
#define CSOUNDPROXY_H

#include <QObject>
#include <QQueue>
#include <QString>
#include <csound.h>

class CsoundProxy : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double fadeTime READ fadeTime WRITE setFadeTime NOTIFY fadeTimeChanged)
    
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

    double fadeTime() const { return m_fadeTime; }
    void setFadeTime(double fadeTime);

signals:
    void fadeTimeChanged();

    //CSOUND * getCsound();

private:
    void *cs; // CsoundObj will be pointed here. Cannot import Objective C CsoundObj here
    CSOUND *csound;
    QQueue<QString> m_eventQueue;
    double m_fadeTime = 0.1;
    
    void initializeCsound();
    void processEventQueue();
    bool isCsoundReady() const;
};

#endif // CSOUNDPROXY_H
