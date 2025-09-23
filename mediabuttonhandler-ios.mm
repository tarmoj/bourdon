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

    info[MPMediaItemPropertyTitle] = @"Bourdon App";
    info[MPMediaItemPropertyArtist] = @"Tarmo Johannes";
    info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = @(0);
    info[MPMediaItemPropertyPlaybackDuration] = @(NSTimeIntervalSince1970); // Use large duration
    info[MPNowPlayingInfoPropertyPlaybackRate] = @(_isPlaying ? 1.0 : 0.0);
    info[MPNowPlayingInfoPropertyDefaultPlaybackRate] = @(1.0);
    
    infoCenter.nowPlayingInfo = info;
    qDebug() << "NowPlaying updated. isPlaying=" << _isPlaying << "playbackRate=" << (_isPlaying ? 1.0 : 0.0);
    
    NSDictionary *currentInfo = infoCenter.nowPlayingInfo;
        for (id key in currentInfo) {
            id value = currentInfo[key];
            // NSString -> const char*
            qDebug() << [key UTF8String] << ":" << QString::fromNSString([value description]);
        }
}

- (MPRemoteCommandHandlerStatus)handlePlayCommand {
    qDebug() << "Play command pressed";
    if (!_isPlaying) {
        _isPlaying = YES;
        [self updateNowPlayingInfo];
        if (self.handler) emit self.handler->play();
    }
    // If already playing, do nothing - this is the correct behavior for a play command
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handlePauseCommand {
    qDebug() << "Pause command pressed";
    if (_isPlaying) {
        _isPlaying = NO;
        [self updateNowPlayingInfo];
        if (self.handler) emit self.handler->pause();
    }
    // If already paused, do nothing - this is the correct behavior for a pause command
    return MPRemoteCommandHandlerStatusSuccess;
}

- (MPRemoteCommandHandlerStatus)handleToggleCommand {
    qDebug() << "Toggle command pressed, current state: isPlaying =" << _isPlaying;
    if (_isPlaying) {
        _isPlaying = NO;
        [self updateNowPlayingInfo];
        if (self.handler) emit self.handler->stop();
    } else {
        _isPlaying = YES;
        [self updateNowPlayingInfo];
        if (self.handler) emit self.handler->play();
    }
    return MPRemoteCommandHandlerStatusSuccess;
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
    
    // Initialize Now Playing info to ensure external devices know our state
    [d->objcHandler updateNowPlayingInfo];
}

MediaButtonHandler::~MediaButtonHandler()
{
    auto d = reinterpret_cast<MediaButtonHandlerPrivate*>(property("_mbh_dptr").value<void*>());
    if (d) {
        // Clean up remote command center
        MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
        [commandCenter.playCommand removeTarget:d->objcHandler];
        [commandCenter.pauseCommand removeTarget:d->objcHandler];
        [commandCenter.togglePlayPauseCommand removeTarget:d->objcHandler];
        [commandCenter.nextTrackCommand removeTarget:d->objcHandler];
        [commandCenter.previousTrackCommand removeTarget:d->objcHandler];
        [commandCenter.stopCommand removeTarget:d->objcHandler];
        
        [d->objcHandler release];
        delete d;
    }
}

void MediaButtonHandler::setPlayingState(bool isPlaying)
{
    auto d = reinterpret_cast<MediaButtonHandlerPrivate*>(property("_mbh_dptr").value<void*>());
    if (d && d->objcHandler) {
        d->objcHandler.isPlaying = isPlaying;
        [d->objcHandler updateNowPlayingInfo];
        qDebug() << "Playing state updated to:" << isPlaying;
    }
}

void MediaButtonHandler::setupRemoteCommandCenter()
{
    auto d = reinterpret_cast<MediaButtonHandlerPrivate*>(property("_mbh_dptr").value<void*>());
    if (!d || !d->objcHandler) return;

    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];

    // Remove any existing targets first to avoid conflicts
    [commandCenter.playCommand removeTarget:nil];
    [commandCenter.pauseCommand removeTarget:nil];
    [commandCenter.togglePlayPauseCommand removeTarget:nil];
    [commandCenter.nextTrackCommand removeTarget:nil];
    [commandCenter.previousTrackCommand removeTarget:nil];
    [commandCenter.stopCommand removeTarget:nil];

    // Add our targets - route play and pause to toggle for BT compatibility
    [commandCenter.playCommand addTarget:d->objcHandler action:@selector(handleToggleCommand)];
    [commandCenter.pauseCommand addTarget:d->objcHandler action:@selector(handleToggleCommand)];
    [commandCenter.togglePlayPauseCommand addTarget:d->objcHandler action:@selector(handleToggleCommand)];
    [commandCenter.nextTrackCommand addTarget:d->objcHandler action:@selector(handleNextCommand)];
    [commandCenter.previousTrackCommand addTarget:d->objcHandler action:@selector(handlePreviousCommand)];
    [commandCenter.stopCommand addTarget:d->objcHandler action:@selector(handleStopCommand)];

    // Enable the commands
    commandCenter.togglePlayPauseCommand.enabled = YES;
    commandCenter.playCommand.enabled = YES;
    commandCenter.pauseCommand.enabled = YES;
    commandCenter.nextTrackCommand.enabled = YES;
    commandCenter.previousTrackCommand.enabled = YES;
    commandCenter.stopCommand.enabled = YES;
}

