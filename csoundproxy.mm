#import "csoundproxy.h"

#import "csound-iOS/classes/CsoundObj.h"
#import "csound-iOS/headers/csound.h"
#include "fileio.h"

#include <QDebug>
#include <QThread>
#include <cstdlib>


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
    // Don't auto-start Csound - it will be started when sound is needed
}

CsoundProxy::~CsoundProxy()
{
    stopCsound();
}

void CsoundProxy::initializeCsound()
{
    qDebug() << "Initializing Csound...";
    
/*
// Copy .ogg files from resources to writable location before initializing Csound
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
    
    // If already running, don't reinitialize
    if (isPlaying()) {
        qDebug() << "Csound already running";
        return;
    }
    
    if (!cs) {
        // Create a new CsoundObj if needed
        CsoundObj *csObj = [[CsoundObj alloc] init];
        cs = (void *)csObj;
        
        if (!cs) {
            qWarning() << "Failed to create CsoundObj";
            return;
        }
    }
    
    // Set SSDIR environment variable at process level for iOS
    // FileIO fileIO;
    // QString samplesDir = fileIO.getWritableSamplesPath();
    // qDebug() << "Setting SSDIR environment variable for iOS:" << samplesDir;
    // setenv("SSDIR", samplesDir.toLocal8Bit().data(), 1);
    
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
        emit csoundReady();
        // Process any queued events
        processEventQueue();
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
    cs = nullptr;
    
    qDebug() << "Csound stopped successfully";
}

void CsoundProxy::restartCsound()
{
    qDebug() << "Restarting Csound...";
    
    // Stop Csound
    stopCsound();
    
    // Wait a bit for the background thread to finish
    QThread::msleep(200);
    
    // Start again
    startCsound();
    
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
    if (isPlaying()) {
        if (csound) csoundInputMessage(csound, scoreLine.toLocal8Bit());
    } else {
        qDebug() << "Csound not ready, queuing event:" << scoreLine;
        m_eventQueue.enqueue(scoreLine);
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



void CsoundProxy::compileOrc(const QString &code)
{
    if (csound) {
        csoundCompileOrc(csound, code.toLocal8Bit()) ;

    } else {
        qDebug() << "Csound is null";
    }
}

void CsoundProxy::processEventQueue()
{
    if (!isPlaying()) {
        qDebug() << "Cannot process event queue - Csound not ready";
        return;
    }
    
    while (!m_eventQueue.isEmpty()) {
        QString event = m_eventQueue.dequeue();
        qDebug() << "Processing queued event:" << event;
        csoundInputMessage(csound, event.toLocal8Bit());
    }
}

bool CsoundProxy::isPlaying() const
{
    return csound != nullptr && cs != nullptr;
}

