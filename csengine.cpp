#include "csengine.h"
#include "fileio.h"
#include <QCoreApplication>
#include <QDebug>
#include <QFile>
#include <QTemporaryFile>
#include <QThread>
#include <QTimer>

//#include <QDateTime>

// NB! use DEFINES += USE_DOUBLE

CsEngine::CsEngine(QObject *parent)
    : QObject(parent)
{
    perfThread = nullptr;
    mStop = false;
    cs = nullptr;

    // Don't auto-start Csound - it will be started when sound is needed
}

void CsEngine::initializeCsound()
{
    /*
    // Copy .ogg files from resources to writable location before setting SSDIR
    FileIO fileIO;
    QString samplesDir = fileIO.getWritableSamplesPath();

    qDebug() << "Copying .ogg files to samples directory:" << samplesDir;
    if (!fileIO.copyOggFilesToWritableLocation(samplesDir)) {
        qDebug() << "Failed to copy .ogg files to samples directory";
    } else {
        qDebug() << "Successfully copied .ogg files to samples directory";

        // Verify a couple of key files exist
        QString testFile1 = samplesDir + "/G0.ogg";
        QString testFile2 = samplesDir + "/A0.ogg";
        if (QFile::exists(testFile1) && QFile::exists(testFile2)) {
            qDebug() << "Verification successful: Key .ogg files found in" << samplesDir;
        } else {
            qDebug() << "Warning: Some .ogg files may not have been copied correctly";
        }
    }
*/
#ifdef Q_OS_ANDROID
    cs = new AndroidCsound();
    cs->setOpenSlCallbacks(); // for android audio to work

    // Set SSDIR environment variable to the writable samples directory
    // QString ssdirOption = "--env:SSDIR=" + samplesDir + "/";
    // qDebug() << "Setting SSDIR:" << ssdirOption;
    // cs->SetOption(ssdirOption.toLocal8Bit().data());
#elif defined(Q_OS_MACOS)
    cs = new Csound();
    //QString SSDirOption = "--env:SSDIR=" + QCoreApplication::applicationDirPath()
                          + "/../Resources/samples";
    //qDebug() << "MacOS samples path: " << SSDirOption;
    //cs->SetOption(SSDirOption.toLocal8Bit().data());
    //cs->SetOption(QString("--env:SSDIR=%1/").arg(samplesDir).toLocal8Bit().data());
    cs->SetOption("-+rtaudio=auhal");
#else
    cs = new Csound();
    //cs->SetOption("--env:SSDIR=/home/tarmo/tarmo/programm/bourdon/bourdon-app2/ogg/"); // for local build only.
    // cs->SetOption(QString("--env:SSDIR=%1/").arg(samplesDir).toLocal8Bit().data());
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
    QTemporaryFile *tempFile = QTemporaryFile::createNativeFile(csd);

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
        // If already running, don't reinitialize
        qDebug() << "Csound already running";
        return;
    }

    initializeCsound();
    play();
    
    // Process any queued events
    processEventQueue();
    
    qDebug() << "Csound started successfully";
}

void CsEngine::stopCsound()
{
    qDebug() << "Stopping Csound...";

    // Wait for fade time + 0.1 seconds to allow sounds to fade out
    int delayMs = static_cast<int>((m_fadeTime + 0.1) * 1000);
    qDebug() << "Waiting" << delayMs << "ms for fade out...";
    QThread::msleep(delayMs);

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
    play();
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
    if (isCsoundReady()) {
        perfThread->InputMessage(scoreLine.toLocal8Bit());
    } else {
        qDebug() << "Csound not ready, queuing event:" << scoreLine;
        m_eventQueue.enqueue(scoreLine);
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

// not used, but keep it for future
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

void CsEngine::setFadeTime(double fadeTime)
{
    if (m_fadeTime != fadeTime) {
        m_fadeTime = fadeTime;
        emit fadeTimeChanged();
    }
}

void CsEngine::processEventQueue()
{
    if (!isCsoundReady()) {
        qDebug() << "Cannot process event queue - Csound not ready";
        return;
    }
    
    while (!m_eventQueue.isEmpty()) {
        QString event = m_eventQueue.dequeue();
        qDebug() << "Processing queued event:" << event;
        perfThread->InputMessage(event.toLocal8Bit());
    }
}

bool CsEngine::isCsoundReady() const
{
    return perfThread != nullptr && cs != nullptr;
}
