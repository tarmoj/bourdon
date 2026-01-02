#ifndef CSENGINE_H
#define CSENGINE_H
#include <QObject>
#include <QQueue>
#include <QString>
#include <QVariant>

#ifdef Q_OS_ANDROID
#include "AndroidCsound.hpp"
#else
#include <csound.hpp>
#endif

#include <csPerfThread.hpp>

class CsEngine : public QObject
{
    Q_OBJECT

public:
    explicit CsEngine(QObject *parent = 0);
    ~CsEngine();

    void play();
    int open(QString csd);

public slots:

    Q_INVOKABLE void stop();
    Q_INVOKABLE void startCsound();
    Q_INVOKABLE void stopCsound();
    Q_INVOKABLE void restartCsound();
    Q_INVOKABLE bool isPlaying() const;
    void setChannel(const QString &channel, double value);
    void readScore(const QString &event);
    void compileOrc(const QString &code);
    void tableSet(int table, int index, double value);

    //Q_INVOKABLE double getChannel(const char *channel);
    Q_INVOKABLE QVariant getAudioDevices();

signals:
    void csoundReady();

private:
    bool mStop;
#ifdef Q_OS_ANDROID
    AndroidCsound *cs;
#else
    Csound *cs;
#endif

    CsoundPerformanceThread *perfThread;
    QQueue<QString> m_eventQueue;

    void initializeCsound();
    void processEventQueue();
};

#endif // CSENGINE_H
