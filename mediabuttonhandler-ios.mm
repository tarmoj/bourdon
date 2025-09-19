// mediabuttonhandler-ios.mm
#include "mediabuttonhandler-ios.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <objc/runtime.h>
#include <QVariant>
#include <QDebug>

@interface MediaButtonHandlerObjC : NSObject
@property (nonatomic, assign) MediaButtonHandler* handler;
@property (nonatomic, assign) BOOL isPlaying;
@end

@implementation MediaButtonHandlerObjC

- (instancetype)init {
    if (self = [super init]) {
        _isPlaying = NO;
    }
    return self;
}

- (void)updateNowPlayingInfo {
    MPNowPlayingInfoCenter *infoCenter = [MPNowPlayingInfoCenter defaultCenter];
    NSMutableDictionary *info = [NSMutableDictionary dictionary];

    info[MPMediaItemPropertyTitle] = @"Qt iOS App";


    info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(0);
    info[MPMediaItemPropertyPlaybackDuration] = @(0);


    info[MPNowPlayingInfoPropertyPlaybackRate] = @(_isPlaying ? 1.0 : 0.0);

    infoCenter.nowPlayingInfo = info;

    qDebug() << "NowPlaying updated. isPlaying=" << _isPlaying;

    infoCenter.nowPlayingInfo = info;
}

- (MPRemoteCommandHandlerStatus)handlePlayCommand {
    qDebug() << "Play pressed";
    _isPlaying = YES;
    [self updateNowPlayingInfo];
    if (self.handler) emit self.handler->play();
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handlePauseCommand {
    qDebug() << "Pause pressed";
    if (_isPlaying) {
        qDebug() << "Toggle → Pause pressed";
        _isPlaying = NO;
        [self updateNowPlayingInfo];
[self updateNowPlayingInfo];
qDebug() << "PlaybackRate now:"
         << [[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] doubleValue];

        if (self.handler) emit self.handler->pause();
    } else {
        qDebug() << "Toggle → Play pressed";
        _isPlaying = YES;
        [self updateNowPlayingInfo];
[self updateNowPlayingInfo];
qDebug() << "PlaybackRate now:"
         << [[MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] doubleValue];

        if (self.handler) emit self.handler->play();
    }
    return MPRemoteCommandHandlerStatusSuccess;

}

- (MPRemoteCommandHandlerStatus)handleToggleCommand {
    if (_isPlaying) {
        return [self handlePauseCommand];
    } else {
        return [self handlePlayCommand];
    }
}


- (MPRemoteCommandHandlerStatus)handleNextCommand {
    qDebug() << "Next pressed";
    if (self.handler) emit self.handler->next();
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handlePreviousCommand {
    qDebug() << "Previous pressed";
    if (self.handler) emit self.handler->previous();
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handleStopCommand {
    qDebug() << "Stop pressed";
    _isPlaying = NO;
    [self updateNowPlayingInfo];
    if (self.handler) emit self.handler->stop();
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

    // Activate audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error = nil;
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        qWarning() << "AVAudioSession setCategory error:" << error.localizedDescription.UTF8String;
    }
    [session setActive:YES error:&error];
    if (error) {
        qWarning() << "AVAudioSession setActive error:" << error.localizedDescription.UTF8String;
    }
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
    [commandCenter.togglePlayPauseCommand addTarget:d->objcHandler action:@selector(handleToggleCommand)];
    [commandCenter.nextTrackCommand addTarget:d->objcHandler action:@selector(handleNextCommand)];
    [commandCenter.previousTrackCommand addTarget:d->objcHandler action:@selector(handlePreviousCommand)];
    [commandCenter.stopCommand addTarget:d->objcHandler action:@selector(handleStopCommand)];

commandCenter.togglePlayPauseCommand.enabled = YES;
commandCenter.playCommand.enabled = YES;
commandCenter.pauseCommand.enabled = YES;

}

