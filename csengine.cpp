#include "csengine.h"
#include <QDebug>
#include <QTemporaryFile>
#include <QCoreApplication>


//#include <QDateTime>


// NB! use DEFINES += USE_DOUBLE


CsEngine::CsEngine(QObject *parent) : QObject(parent)
{

    // should be probably in main.cpp
    //csoundInitialize(CSOUNDINIT_NO_ATEXIT | CSOUNDINIT_NO_SIGNAL_HANDLER); // not sure if necessary, but Steven Yi claims, it should be there

#ifdef Q_OS_ANDROID
	cs = new AndroidCsound();
	cs->setOpenSlCallbacks(); // for android audio to work
    cs->SetOption("--env:SSDIR=/sdcard/Music/Bourdon/samples/");
#elif defined(Q_OS_MACOS)
    cs = new Csound();
    QString SSDirOption =  "--env:SSDIR=" + QCoreApplication::applicationDirPath() + "/../Resources/samples";
    qDebug() << "MacOS samples path: " << SSDirOption;
    cs->SetOption(SSDirOption.toLocal8Bit().data());
    cs->SetOption("-+rtaudio=auhal");
#else
	cs = new Csound();
    cs->SetOption("--env:SSDIR=/home/tarmo/tarmo/programm/bourdon/bourdon-app2/samples/");
#endif
    perfThread = nullptr;
    mStop=false;
	cs->SetOption("-odac");
    cs->SetOption("-d");
    // maybe here start the engine?
    if (!open(":/bourdon.csd")) {
        //cs->Start();
        perfThread = new CsoundPerformanceThread(cs);

    }
}

CsEngine::~CsEngine()
{
    stop();
    delete perfThread;
    delete cs;  
}

void CsEngine::play() {

    if (!perfThread) {
        perfThread = new CsoundPerformanceThread(cs);

    }
    perfThread->Play();
    qDebug() << "Performance thread started";
}

int CsEngine::open(QString csd)
{

    QTemporaryFile *tempFile = QTemporaryFile::createNativeFile(csd); //TODO: checi if not 0

    //qDebug()<<tempFile->fileName() <<  tempFile->readAll();

	if (!cs->Compile( tempFile->fileName().toLocal8Bit().data()) ){
        return 0;
    } else {
        qDebug()<<"Could not open csound file: "<<csd;
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


void CsEngine::setChannel(const QString &channel, MYFLT value)
{
    qDebug()<<"setChannel "<<channel<<" value: "<<value;
    cs->SetChannel(channel.toLocal8Bit(), value);
}

void CsEngine::readScore(const QString &scoreLine)
{
    // test time:
//    int time =  QDateTime::currentMSecsSinceEpoch()%1000000;

    qDebug()<<"csEvent" << scoreLine ; // << time;
    // cs->ReadScore(scoreLine.toLocal8Bit());
    if (perfThread) {
        perfThread->InputMessage(scoreLine.toLocal8Bit());
    }
}

void CsEngine::compileOrc(const QString &code)
{
    cs->CompileOrc(code.toLocal8Bit());
}

QVariant CsEngine::getAudioDevices()
{
    QStringList deviceList; // mapped in pairs: device_name, device_id, device_name2, device_id2, ...


    CSOUND *csound = csoundCreate(nullptr);
    csoundSetRTAudioModule(csound, "pa"); // on Android probably does not work...
    int i,newn, n = csoundGetAudioDevList(csound, nullptr, 1);
    CS_AUDIODEVICE *devs = (CS_AUDIODEVICE *) malloc(n*sizeof(CS_AUDIODEVICE));
    newn = csoundGetAudioDevList(csound,devs,1);
    if (newn != n) {
        qDebug()  << "OutputDevices Device number changed";
        return QVariant(deviceList);
    }
    for (i = 0; i < n; i++) {
        qDebug()  << devs[i].device_name << devs[i].device_id;
        deviceList << QString(devs[i].device_name) << QString(devs[i].device_id);
    }
    free(devs);
    csoundDestroy(csound);

    return  QVariant(deviceList);

}
