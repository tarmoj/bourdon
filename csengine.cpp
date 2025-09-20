#include "csengine.h"
#include <QCoreApplication>
#include <QDebug>
#include <QTemporaryFile>

//#include <QDateTime>

// NB! use DEFINES += USE_DOUBLE

CsEngine::CsEngine(QObject *parent)
    : QObject(parent)
{
    perfThread = nullptr;
    mStop = false;
    cs = nullptr;
    
    initializeCsound();
}

void CsEngine::initializeCsound()
{
    // should be probably in main.cpp
    //csoundInitialize(CSOUNDINIT_NO_ATEXIT | CSOUNDINIT_NO_SIGNAL_HANDLER); // not sure if necessary, but Steven Yi claims, it should be there

#ifdef Q_OS_ANDROID
    cs = new AndroidCsound();
    cs->setOpenSlCallbacks(); // for android audio to work

    // test
    if (QFile::exists("/sdcard/Music/Bourdon/samples/G0.wav")) {
        qDebug() << "G0.wav found";
    } else {
        qDebug() << "G0.wav not found";
    }

    // add code that checks check if file G0.wav exist in dir
    cs->SetOption("--env:SSDIR=/sdcard/Music/Bourdon/samples/");
#elif defined(Q_OS_MACOS)
    cs = new Csound();
    QString SSDirOption = "--env:SSDIR=" + QCoreApplication::applicationDirPath()
                          + "/../Resources/samples";
    qDebug() << "MacOS samples path: " << SSDirOption;
    cs->SetOption(SSDirOption.toLocal8Bit().data());
    cs->SetOption("-+rtaudio=auhal");
#else
    cs = new Csound();
    cs->SetOption("--env:SSDIR=/home/tarmo/tarmo/programm/bourdon/bourdon-app2/samples/");
#endif
    cs->SetOption("-odac");
    cs->SetOption("-d");

    if (!open(":/bourdon.csd")) {
        perfThread = new CsoundPerformanceThread(cs);
    }
}

CsEngine::~CsEngine()
{
    stopCsound();
}

void CsEngine::play()
{
    if (!perfThread) {
        perfThread = new CsoundPerformanceThread(cs);
    }
    perfThread->Play();
    qDebug() << "Performance thread started";
}

int CsEngine::open(QString csd)
{
    QTemporaryFile *tempFile = QTemporaryFile::createNativeFile(csd); //TODO: checi if not 0

    //qDebug()<< "Csound file contents: " <<  tempFile->fileName() <<  tempFile->readAll();

    if (!cs->Compile(tempFile->fileName().toLocal8Bit().data())) {
        return 0;
    } else {
        qDebug() << "Could not open csound file: " << csd;
        return -1;
    }
}

void CsEngine::stop()
{
    //mStop = true;
    if (perfThread) {
        perfThread->Stop();
        perfThread->Join();
        qDebug() << "Performance thread stopped and joined";
    }
}

void CsEngine::startCsound()
{
    qDebug() << "Starting Csound...";
    if (cs) {
        // If already running, stop first
        stopCsound();
    }
    
    initializeCsound();
    qDebug() << "Csound started successfully";
}

void CsEngine::stopCsound()
{
    qDebug() << "Stopping Csound...";
    
    // Stop performance thread first
    if (perfThread) {
        perfThread->Stop();
        perfThread->Join();
        delete perfThread;
        perfThread = nullptr;
        qDebug() << "Performance thread stopped and cleaned up";
    }
    
    // Cleanup and destroy Csound instance
    if (cs) {
        cs->Cleanup();
        cs->Reset();
        delete cs;
        cs = nullptr;
        qDebug() << "Csound instance cleaned up and destroyed";
    }
    
    qDebug() << "Csound stopped successfully";
}

void CsEngine::restartCsound()
{
    qDebug() << "Restarting Csound...";
    stopCsound();
    startCsound();
    qDebug() << "Csound restarted successfully";
}

void CsEngine::setChannel(const QString &channel, MYFLT value)
{
    //qDebug()<<"setChannel "<<channel<<" value: "<<value;
    if (cs)
        cs->SetChannel(channel.toLocal8Bit(), value);
}

void CsEngine::readScore(const QString &scoreLine)
{
    if (perfThread) {
        perfThread->InputMessage(scoreLine.toLocal8Bit());
    }
}

void CsEngine::compileOrc(const QString &code)
{
    if (cs)
        cs->CompileOrc(code.toLocal8Bit());
}

void CsEngine::tableSet(int table, int index, double value)
{
    if (cs && table > 0 && index >= 0)

        cs->TableSet(table, index, value); // this is slow and seem to block UI
    else {
        qDebug() << "CsEngine::tableSet: invalid table or index";
    }
}

QVariant CsEngine::getAudioDevices()
{
    QStringList deviceList; // mapped in pairs: device_name, device_id, device_name2, device_id2, ...

    CSOUND *csound = csoundCreate(nullptr);
    csoundSetRTAudioModule(csound, "pa"); // on Android probably does not work...
    int i, newn, n = csoundGetAudioDevList(csound, nullptr, 1);
    CS_AUDIODEVICE *devs = (CS_AUDIODEVICE *) malloc(n * sizeof(CS_AUDIODEVICE));
    newn = csoundGetAudioDevList(csound, devs, 1);
    if (newn != n) {
        qDebug() << "OutputDevices Device number changed";
        return QVariant(deviceList);
    }
    for (i = 0; i < n; i++) {
        qDebug() << devs[i].device_name << devs[i].device_id;
        deviceList << QString(devs[i].device_name) << QString(devs[i].device_id);
    }
    free(devs);
    csoundDestroy(csound);

    return QVariant(deviceList);
}
