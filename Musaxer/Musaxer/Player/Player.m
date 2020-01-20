//
//  Player.m
//  Musaxer
//
//  Created by 郭弘 on 2020/1/7.
//  Copyright © 2020 郭弘. All rights reserved.
//

#import "Player.h"
//#import "ListBottomView.h"
@interface Player()

@property (nonatomic, strong) CADisplayLink *progressTimer;

@end
@implementation Player
+ (instancetype)defaultPlayer
{
    static Player *player = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        FSStreamConfiguration *config = [[FSStreamConfiguration alloc] init];
        config.enableTimeAndPitchConversion = YES;
        config.requireStrictContentTypeChecking = NO;
        config.httpConnectionBufferSize *= 2;
        
        player = [[super alloc] initWithConfiguration:config];
        player.defaultContentType = @"audio/mpeg";
        player.delegate = (id)self;
        player.isStop = YES;
        __weak typeof(Player) *weakPlayer = player;
        player.onFailure = ^(FSAudioStreamError error, NSString *errorDescription) {
            NSLog(@"%@", errorDescription);
            switch (error) {
                case kFsAudioStreamErrorOpen:
                    errorDescription = @"在线音乐，访问错误。";//@"Cannot open the audio stream";
                    break;
                case kFsAudioStreamErrorStreamParse:
                    errorDescription = @"在线音乐，加载错误。";//@"Cannot read the audio stream";
                    break;
                case kFsAudioStreamErrorNetwork:
                    errorDescription = @"网络错误，不能播放。";//@"Network failed: cannot play the audio stream";
                    break;
                case kFsAudioStreamErrorUnsupportedFormat:
                    errorDescription = @"当前格式不支持。";//@"Unsupported format";
                    break;
                case kFsAudioStreamErrorStreamBouncing:
                    errorDescription = @"网络错误，不能继续播放。";//@"Network failed: cannot get enough data to play";
                    break;
                default:
                    errorDescription = @"发生未知错误";//@"Unknown error occurred";
                    break;
            }
            weakPlayer.isStop = YES;
            [weakPlayer updateListBottomViewButton];
            [weakPlayer updateMusicViewButton];
            [weakPlayer updateListCellIndicator];
            [Helper showMiddleHint:errorDescription];
            NSLog(@"player error: %@",errorDescription);
        };
        
        player.onStateChange = ^(FSAudioStreamState state) {
            switch (state) {
                case kFsAudioStreamPlaying:
                {
                    player.isStop = NO;
                    [weakPlayer updateListBottomViewButton];
                    [weakPlayer updateMusicViewButton];
                    [weakPlayer updateListCellIndicator];
                    NSLog(@"player:  playing......");
                }
                    break;
                case kFsAudioStreamStopped:
                {
                    player.isStop = YES;
                    [weakPlayer updateListBottomViewButton];
                    [weakPlayer updateMusicViewButton];
                    [weakPlayer updateListCellIndicator];
                    NSLog(@"player:  stop......");
                }
                    break;
                case kFsAudioStreamPaused:
                {
                    player.isStop = NO;
                    [weakPlayer updateListBottomViewButton];
                    [weakPlayer updateMusicViewButton];
                    [weakPlayer updateListCellIndicator];
                    NSLog(@"player: pause......");
                }
                    break;
                case kFsAudioStreamPlaybackCompleted:
                {
                    player.isStop = YES;
                    NSLog(@"player: completed......");
                    [weakPlayer playNext:YES];
                }
                    break;
                default:
                    break;
            }
        };
    });
    return player;
}



#pragma mark == Private method ,all call delegate

- (void)updateProgress {
    if (self.musicPlayerDelegate && [self.musicPlayerDelegate respondsToSelector:@selector(updateProgressWithCurrentPosition:endPosition:)]) {
        [self.musicPlayerDelegate updateProgressWithCurrentPosition:self.currentTimePlayed endPosition:self.duration];
    }
    
}

- (void)updateListCellIndicator{
    if (self.listPlayerDelegate && [self.listPlayerDelegate respondsToSelector:@selector(updatePlaybackIndicatorOfVisisbleCells)]) {
           [self.listPlayerDelegate updatePlaybackIndicatorOfVisisbleCells];
       }
}

- (void)updateListBottomViewLabelAndCover{
    if (self.listPlayerDelegate && [self.listPlayerDelegate respondsToSelector:@selector(updateBottomViewLabelAndCover)]) {
           [self.listPlayerDelegate updateBottomViewLabelAndCover];
       }
}

- (void)updateListBottomViewButton{
    if (self.listPlayerDelegate && [self.listPlayerDelegate respondsToSelector:@selector(updateBottomViewButton)]) {
           [self.listPlayerDelegate updateBottomViewButton];
       }
}

- (void)updateMusicViewLabelAndCover{
    if (self.musicPlayerDelegate && [self.musicPlayerDelegate respondsToSelector:@selector(updateBottomViewLabelAndCover)]) {
           [self.musicPlayerDelegate updateBottomViewLabelAndCover];
       }
}

- (void)updateMusicViewButton{
    if (self.musicPlayerDelegate && [self.musicPlayerDelegate respondsToSelector:@selector(updateBottomViewButton)]) {
           [self.musicPlayerDelegate updateBottomViewButton];
       }
}

- (void)scrollLeft{
    if (self.scrollPlayerDelegate && [self.scrollPlayerDelegate respondsToSelector:@selector(scrollLeft)]) {
           [self.scrollPlayerDelegate scrollLeft];
       }
}

- (void)scrollRight{
    if (self.scrollPlayerDelegate && [self.scrollPlayerDelegate respondsToSelector:@selector(scrollRight)]) {
           [self.scrollPlayerDelegate scrollRight];
       }
}

- (void)startAlbumAnimations{
    if (self.scrollPlayerDelegate && [self.scrollPlayerDelegate respondsToSelector:@selector(startAlbumAnimations)]) {
        [self.scrollPlayerDelegate startAlbumAnimations];
    }
}

- (void)stopAlbumAnimations{
    if (self.scrollPlayerDelegate && [self.scrollPlayerDelegate respondsToSelector:@selector(stopAlbumAnimations)]) {
        [self.scrollPlayerDelegate stopAlbumAnimations];
    }
}

#pragma mark == overloading

- (void)setProgressTimer{
    if(_progressTimer == nil){
        _progressTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateProgress)];
        [_progressTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)pause {
    if(!_isStop){
        [super pause];
    } else{
        [self playMusicAtIndex:_currentIndex];
    }
    
}

- (void)play {
    if(self.url == nil){
        NSLog(@"url is nil");
        return;
    }
    [super play];
    [self setProgressTimer];
}

- (void)playFromURL:(NSURL *)url {
    [self stop];
    [super playFromURL:url];
    [self setProgressTimer];
}

- (void)playFromOffset:(FSSeekByteOffset)offset {
    [super playFromOffset:offset];
    [self setProgressTimer];
}

- (void)stop {
    [super stop];
    if (_progressTimer) {
        [_progressTimer invalidate];
        _progressTimer = nil;
    }
}


#pragma mark == public method

- (void)playMusicAtIndex:(NSUInteger)index {
    if (index < _musics.count && index >= 0) {
        //if shoud update new infomation of music view
        BOOL shoudUpdate = _currentIndex != index;
        _currentIndex = index;
        USER.musicId = [_musics objectAtIndex:index].musicId;
        if(shoudUpdate){
            [self updateListBottomViewLabelAndCover];
            [self updateMusicViewLabelAndCover];
        }
        [self startAlbumAnimations];
        [self playFromURL:[NSURL URLWithString:[_musics objectAtIndex:index].musicUrl]];
        NSLog(@"player play music at index: %lu, music count: %ld, name: %@",index,_musics.count,[_musics objectAtIndex:index].musicName);
    }else NSLog(@"player play music at index error, index :%lud, count:%ld",index,_musics.count);
}

- (void)playPre {
    switch (_musicCycleType) {
        case AllLoop:
        case Shuffle:
        {
            NSUInteger index = (_currentIndex - 1 + _musics.count) % _musics.count;
            [PLAYER playMusicAtIndex:index];
            [self scrollLeft];
        }
            break;
        case Advance:
        case SingleLoop:
        {
            if(_currentIndex != 0){
                [PLAYER playMusicAtIndex:_currentIndex - 1];
                [self scrollLeft];
            }
            else {
                [Helper showMiddleHint:@"已经是第一首了"];
            }
        }
            break;
        default:
            break;
    }
        
}

- (void)playNext:(BOOL)isAutoPlay {
    switch (_musicCycleType) {
        case AllLoop:
        case Shuffle:
        {
            NSUInteger index = (_currentIndex + 1) % _musics.count;
            [self playMusicAtIndex:index];
            [self scrollRight];
        }
            break;
        case Advance:
        {
            if(_currentIndex != _musics.count - 1){
                [self playMusicAtIndex:_currentIndex + 1];
                [self scrollRight];
            }
            else {
                if(isAutoPlay){
                    [self stop];
                    [self stopAlbumAnimations];
                }
                [Helper showMiddleHint:@"已经是最后一首了"];
            }
        }
            break;
        case SingleLoop:
        {
            if(isAutoPlay){
                [self playMusicAtIndex:_currentIndex];
                break;
            }
            if(_currentIndex != _musics.count - 1){
                [self playMusicAtIndex:_currentIndex + 1];
                [self scrollRight];
            }
            else {
                [Helper showMiddleHint:@"已经是最后一首了"];
            }
        }
            break;
        default:
            break;
    }
}

- (Music*)currentMusic {
    if(_musics.count > _currentIndex && _currentIndex >= 0)
        return [_musics objectAtIndex:_currentIndex];
    else{
        NSLog(@"player current music: current music is nil");
        return nil;
    }
}

- (NSUInteger)indexOfMusicFromMusicId:(NSNumber*)Id{
    for(int i = 0;i < PLAYER.musics.count;i ++){
        if(PLAYER.musics[i].musicId == Id)
            return i;
    }
    return 0;
}

- (void)printNowList{
    for(Music *music in _musics){
        NSLog(@"%@",music.musicName);
    }
    NSLog(@"current index is: %lu",_currentIndex);
}
@end
