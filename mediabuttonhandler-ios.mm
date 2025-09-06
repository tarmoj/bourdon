// code created by Github Copilot, slightly edited
#include "mediabuttonhandler-ios.h"
#import <MediaPlayer/MediaPlayer.h>
#import <objc/runtime.h>
#include <QVariant>

@interface MediaButtonHandlerObjC : NSObject
@property (nonatomic, assign) MediaButtonHandler* handler;
@end

@implementation MediaButtonHandlerObjC
- (MPRemoteCommandHandlerStatus)handlePlayCommand {
    qDebug() << "Play pressed";
    if (self.handler) QMetaObject::invokeMethod(self.handler, "play", Qt::QueuedConnection);
    return MPRemoteCommandHandlerStatusSuccess;
}
- (MPRemoteCommandHandlerStatus)handlePauseCommand {
    qDebug() << "Pause pressed";
    if (self.handler) QMetaObject::invokeMethod(self.handler, "pause", Qt::QueuedConnection);
    return MPRemoteCommandHandlerStatusSuccess;
}
- (MPRemoteCommandHandlerStatus)handleNextCommand {
    qDebug() << "Next pressed";
    if (self.handler) QMetaObject::invokeMethod(self.handler, "next", Qt::QueuedConnection);
    return MPRemoteCommandHandlerStatusSuccess;
}
- (MPRemoteCommandHandlerStatus)handlePreviousCommand {
    qDebug() << "Previous pressed";
    if (self.handler) QMetaObject::invokeMethod(self.handler, "previous", Qt::QueuedConnection);
    return MPRemoteCommandHandlerStatusSuccess;
}
- (MPRemoteCommandHandlerStatus)handleStopCommand {
    qDebug() << "Stop pressed";
    if (self.handler) QMetaObject::invokeMethod(self.handler, "stop", Qt::QueuedConnection);
    return MPRemoteCommandHandlerStatusSuccess;
}

@end

struct MediaButtonHandlerPrivate {
    MediaButtonHandlerObjC* objcHandler = nullptr;
};

MediaButtonHandler::MediaButtonHandler(QObject* parent) : QObject(parent)
{
    auto d = new MediaButtonHandlerPrivate;
    d->objcHandler = [[MediaButtonHandlerObjC alloc] init];
    d->objcHandler.handler = this;
    setProperty("_mbh_dptr", QVariant::fromValue(reinterpret_cast<void*>(d)));
}

MediaButtonHandler::~MediaButtonHandler()
{
    auto d = reinterpret_cast<MediaButtonHandlerPrivate*>(property("_mbh_dptr").value<void*>());
    if (d) {
        [d->objcHandler release];
        delete d;
    }
}

void MediaButtonHandler::setupRemoteCommandCenter()
{
    auto d = reinterpret_cast<MediaButtonHandlerPrivate*>(property("_mbh_dptr").value<void*>());
    if (!d || !d->objcHandler) return;

    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];

    [commandCenter.playCommand addTarget:d->objcHandler action:@selector(handlePlayCommand)];
    [commandCenter.pauseCommand addTarget:d->objcHandler action:@selector(handlePauseCommand)];
    [commandCenter.nextTrackCommand addTarget:d->objcHandler action:@selector(handleNextCommand)];
    [commandCenter.previousTrackCommand addTarget:d->objcHandler action:@selector(handlePreviousCommand)];
    [commandCenter.stopCommand addTarget:d->objcHandler action:@selector(handleStopCommand)];
    [commandCenter.togglePlayPauseCommand addTarget:d->objcHandler action:@selector(handlePauseCommand)];
}

