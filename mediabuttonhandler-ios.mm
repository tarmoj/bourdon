// code created by Github Copilot, slightly edited
#include "mediabuttonhandler-ios.h"
#import <MediaPlayer/MediaPlayer.h>
#import <objc/runtime.h>
#include <QVariant>

@interface MediaButtonHandlerObjC : NSObject
@property (nonatomic, assign) MediaButtonHandler* handler;
@end

@implementation MediaButtonHandlerObjC

- (MPRemoteCommandHandlerStatus)handlePlayCommand:(MPRemoteCommandEvent *)event {
    qDebug() << "[RC] Play pressed, thread is main?" << ([NSThread isMainThread] ? "yes" : "no");
    bool ok = false;
    if (self.handler) ok = QMetaObject::invokeMethod(self.handler, "play", Qt::QueuedConnection);
    qDebug() << "[RC] invoke play ->" << ok;
    return ok ? MPRemoteCommandHandlerStatusSuccess : MPRemoteCommandHandlerStatusCommandFailed;
}

- (MPRemoteCommandHandlerStatus)handlePauseCommand:(MPRemoteCommandEvent *)event {
    qDebug() << "[RC] Pause pressed, thread is main?" << ([NSThread isMainThread] ? "yes" : "no");
    bool ok = false;
    if (self.handler) ok = QMetaObject::invokeMethod(self.handler, "pause", Qt::QueuedConnection);
    qDebug() << "[RC] invoke pause ->" << ok;
    return ok ? MPRemoteCommandHandlerStatusSuccess : MPRemoteCommandHandlerStatusCommandFailed;
}

- (MPRemoteCommandHandlerStatus)handleNextCommand:(MPRemoteCommandEvent *)event {
    qDebug() << "[RC] Next pressed";
    bool ok = false;
    if (self.handler) ok = QMetaObject::invokeMethod(self.handler, "next", Qt::QueuedConnection);
    qDebug() << "[RC] invoke next ->" << ok;
    return ok ? MPRemoteCommandHandlerStatusSuccess : MPRemoteCommandHandlerStatusCommandFailed;
}

- (MPRemoteCommandHandlerStatus)handlePreviousCommand:(MPRemoteCommandEvent *)event {
    qDebug() << "[RC] Previous pressed";
    bool ok = false;
    if (self.handler) ok = QMetaObject::invokeMethod(self.handler, "previous", Qt::QueuedConnection);
    qDebug() << "[RC] invoke previous ->" << ok;
    return ok ? MPRemoteCommandHandlerStatusSuccess : MPRemoteCommandHandlerStatusCommandFailed;
}

- (MPRemoteCommandHandlerStatus)handleStopCommand:(MPRemoteCommandEvent *)event {
    qDebug() << "[RC] Stop pressed";
    bool ok = false;
    if (self.handler) ok = QMetaObject::invokeMethod(self.handler, "stop", Qt::QueuedConnection);
    qDebug() << "[RC] invoke stop ->" << ok;
    return ok ? MPRemoteCommandHandlerStatusSuccess : MPRemoteCommandHandlerStatusCommandFailed;
}

- (MPRemoteCommandHandlerStatus)handleToggleCommand:(MPRemoteCommandEvent *)event {
    static bool isPlaying = false;

    if (isPlaying) {
        qDebug() << "[RC] Toggle → Pause";
        isPlaying = false;
        if (self.handler) QMetaObject::invokeMethod(self.handler, "pause", Qt::QueuedConnection);
    } else {
        qDebug() << "[RC] Toggle → Play";
        isPlaying = true;
        if (self.handler) QMetaObject::invokeMethod(self.handler, "play", Qt::QueuedConnection);
    }

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
        // Best practice: remove targets to avoid dangling references
        MPRemoteCommandCenter *cc = [MPRemoteCommandCenter sharedCommandCenter];
        [cc.playCommand removeTarget:d->objcHandler];
        [cc.pauseCommand removeTarget:d->objcHandler];
        [cc.nextTrackCommand removeTarget:d->objcHandler];
        [cc.previousTrackCommand removeTarget:d->objcHandler];
        [cc.stopCommand removeTarget:d->objcHandler];
        [cc.togglePlayPauseCommand removeTarget:d->objcHandler];

        [d->objcHandler release];
        delete d;
    }
}

void MediaButtonHandler::setupRemoteCommandCenter()
{
    auto d = reinterpret_cast<MediaButtonHandlerPrivate*>(property("_mbh_dptr").value<void*>());
    if (!d || !d->objcHandler) return;

    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];

    // Ensure commands are explicitly enabled for debugging
    commandCenter.playCommand.enabled = NO;
    commandCenter.pauseCommand.enabled = NO;
    commandCenter.nextTrackCommand.enabled = YES;
    commandCenter.previousTrackCommand.enabled = YES;
    commandCenter.stopCommand.enabled = YES;
    commandCenter.togglePlayPauseCommand.enabled = YES;

    [commandCenter.playCommand addTarget:d->objcHandler action:@selector(handleToggleCommand:)];
    [commandCenter.pauseCommand addTarget:d->objcHandler action:@selector(handleToggleCommand:)];
    [commandCenter.nextTrackCommand addTarget:d->objcHandler action:@selector(handleNextCommand:)];
    [commandCenter.previousTrackCommand addTarget:d->objcHandler action:@selector(handlePreviousCommand:)];
    [commandCenter.stopCommand addTarget:d->objcHandler action:@selector(handleStopCommand:)];
    // Either implement toggle properly, or comment this out while debugging:
    [commandCenter.togglePlayPauseCommand addTarget:d->objcHandler action:@selector(handleToggleCommand:)];
}
