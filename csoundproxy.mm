#import "csoundproxy.h"

#import "csound-iOS/classes/CsoundObj.h"
#import "csound-iOS/headers/csound.h"
#include "fileio.h"

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
    if (cs) {
        [(CsoundObj *)cs stop];
    }
    // Let ARC handle cleanup
    cs = nullptr;
    csound = nullptr;
}

void CsoundProxy::initializeCsound()
{
    qDebug() << "Initializing Csound...";
    
    // Copy .ogg files from resources to writable location before initializing Csound
    FileIO fileIO;
    QString samplesDir = fileIO.getWritableSamplesPath();
    
    qDebug() << "Copying .ogg files to samples directory:" << samplesDir;
    if (!fileIO.copyOggFilesToWritableLocation(samplesDir)) {
        qDebug() << "Failed to copy .ogg files to samples directory";
    } else {
        qDebug() << "Successfully copied .ogg files to samples directory";
    }
    
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
            
            // Set SSDIR environment variable for iOS
            FileIO fileIO;
            QString samplesDir = fileIO.getWritableSamplesPath();
            QString ssdirOption = "--env:SSDIR=" + samplesDir + "/";
            qDebug() << "Setting SSDIR for iOS:" << ssdirOption;
            csoundSetOption(csound, ssdirOption.toLocal8Bit().data());
            
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
        // Stop the CsoundObj
        [(CsoundObj *)cs stop];
        qDebug() << "CsoundObj stop called";
    }
    
    // Clear our reference to the CSOUND instance
    // The CsoundObj will handle its own cleanup
    csound = nullptr;
    
    qDebug() << "Csound stopped successfully";
}

void CsoundProxy::restartCsound()
{
    qDebug() << "Restarting Csound...";
    
    // Simply stop current instance and create a fresh one
    if (cs) {
        [(CsoundObj *)cs stop];
    }
    
    // Clear references
    csound = nullptr;
    cs = nullptr;
    
    // Wait a bit for the background thread to finish
    QThread::msleep(200);
    
    // Create fresh instance
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

void CsoundProxy::stop()
{
    if (cs) {
        [(CsoundObj *)cs stop];
        qDebug() << "Csound playback stopped";
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


