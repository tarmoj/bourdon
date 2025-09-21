#import "csoundproxy.h"

#import "csound-iOS/classes/CsoundObj.h"

#include <QDebug>
#include <QThread>


extern "C" {
    void csoundMessageCallback(CSOUND *csound, int attr, const char *format, va_list args) {
        char buffer[1024];
        vsnprintf(buffer, sizeof(buffer), format, args);

        // You can filter or route messages based on attr here if needed
        qDebug().noquote() << "[Csound] " << buffer;
    }
}

CsoundProxy::CsoundProxy(QObject *parent)
: QObject(parent)
{
    cs = nullptr;
    csound = nullptr;
    initializeCsound();
}

CsoundProxy::~CsoundProxy()
{
    stopCsound();
}

void CsoundProxy::initializeCsound()
{
    qDebug() << "Initializing Csound...";
    
    // Create CsoundObj
    CsoundObj *csObj = [[CsoundObj alloc] init];
    cs = (void *)csObj;
    
    if (!cs) {
        NSLog(@"Failed to initialize CsoundObj");
        return;
    } else {
        NSLog(@"CsoundObj initialized: %@", cs);
    }
    
    startCsound();
}

void CsoundProxy::startCsound()
{
    qDebug() << "Starting Csound...";
    
    if (!cs) {
        qWarning() << "CsoundObj not initialized";
        return;
    }
    
    NSString *csdFile = [[NSBundle mainBundle] pathForResource:@"bourdon" ofType:@"csd"];
    NSLog(@"Csound FILE PATH: %@", csdFile);
    
    [(CsoundObj *)cs play:csdFile];
    
    csound = nullptr;
    
    const int maxAttempts = 100; // 100 × 10ms = 1 second
    int attempts = 0;
    while (attempts++ < maxAttempts) {
        csound = [(CsoundObj *)cs getCsound];
        if (csound != nullptr) {
            csoundSetMessageCallback(csound, csoundMessageCallback);
            break;
        }
        QThread::msleep(10);
    }
    
    if (csound) {
        qDebug() << "Csound is ready:" << csound << "in " << attempts*10 << " ms";
    } else {
        qWarning() << "Timeout: Csound did not initialize in time.";
    }
    
    qDebug() << "Csound started successfully";
}

void CsoundProxy::stopCsound()
{
    qDebug() << "Stopping Csound...";
    
    if (cs) {
        [(CsoundObj *)cs stop];
        // Clean up the CsoundObj
        cs = nullptr;
    }
    
    if (csound) {
        csoundCleanup(csound);
        csoundDestroy(csound);
        csound = nullptr;
    }
    
    qDebug() << "Csound stopped successfully";
}

void CsoundProxy::restart()
{
    qDebug() << "Restarting Csound...";
    stopCsound();
    initializeCsound();
    qDebug() << "Csound restarted successfully";
}


void CsoundProxy::play() // just for testing at the moment
{    
    if (csound) {
        csoundInputMessage(csound, "i 1 0.1 3  0.8");
    } else {
        NSLog(@"Csound is null");
    }
       
}

void CsoundProxy::readScore(const QString &scoreLine)
{
    if (csound) {
        csoundInputMessage(csound, scoreLine.toLocal8Bit());
    }
}

void CsoundProxy::setChannel(QString channel, double value)
{
    if (csound) {
        qDebug() << "Channel: " << channel << " value: " << value;
        csoundSetControlChannel(csound, channel.toUtf8().constData(), value) ;

    } else {
        qDebug() << "Csound is null";
    }
}


