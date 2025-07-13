#import "csoundproxy.h"

#import "csound-iOS/classes/CsoundObj.h"

#include <QDebug>
#include <QThread>


#import <MediaPlayer/MediaPlayer.h>


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
  
   //cs = [[CsoundObj alloc] init ];
   CsoundObj *csObj = [[CsoundObj alloc] init];
   cs = (void *)csObj;
    
    if (!cs) {
        NSLog(@"Failed to initialize CsoundObj");
    } else {
        NSLog(@"CsoundObj initialized: %@", cs);
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
}

CsoundProxy::~CsoundProxy()
{
  csoundCleanup(csound); // not sure if needed
  csoundDestroy(csound);
  cs = nullptr;

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

// Objective-C category for media button handling
@interface MediaButtonHandler : NSObject
{
    CsoundProxy *_proxy;
}
- (instancetype)initWithProxy:(CsoundProxy *)proxy;
- (void)setupRemoteCommandCenter;
@end

@implementation MediaButtonHandler

- (instancetype)initWithProxy:(CsoundProxy *)proxy
{
    if ((self = [super init])) {
        _proxy = proxy;
    }
    return self;
}

- (void)setupRemoteCommandCenter
{
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];

    [commandCenter.playCommand addTarget:self action:@selector(handlePlayCommand)];
    [commandCenter.pauseCommand addTarget:self action:@selector(handlePauseCommand)];
    [commandCenter.togglePlayPauseCommand addTarget:self action:@selector(handlePauseCommand)]; // treate it as pause buton (toggle)
    [commandCenter.stopCommand addTarget:self action:@selector(handleStopCommand)];
    [commandCenter.nextTrackCommand addTarget:self action:@selector(handleNextCommand)];
    [commandCenter.previousTrackCommand addTarget:self action:@selector(handlePreviousCommand)];
}

- (MPRemoteCommandHandlerStatus)handlePlayCommand
{
    if (_proxy) {
        QMetaObject::invokeMethod(_proxy, "playPressed", Qt::QueuedConnection);
    }
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handlePauseCommand
{
    if (_proxy) {
        QMetaObject::invokeMethod(_proxy, "pausePressed", Qt::QueuedConnection);
    }
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handleStopCommand
{
    if (_proxy) {
        QMetaObject::invokeMethod(_proxy, "stopPressed", Qt::QueuedConnection);
    }
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handleNextCommand
{
    if (_proxy) {
        QMetaObject::invokeMethod(_proxy, "nextPressed", Qt::QueuedConnection);
    }
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handlePreviousCommand
{
    if (_proxy) {
        QMetaObject::invokeMethod(_proxy, "previousPressed", Qt::QueuedConnection);
    }
    return MPRemoteCommandHandlerStatusSuccess;
}

@end

// Static handler instance
static MediaButtonHandler *g_mediaButtonHandler = nil;


void CsoundProxy::setupMediaButtonHandling()
{
    if (!g_mediaButtonHandler) {
        g_mediaButtonHandler = [[MediaButtonHandler alloc] initWithProxy:this];
        [g_mediaButtonHandler setupRemoteCommandCenter];
    }
}



