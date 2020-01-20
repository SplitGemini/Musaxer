//
//  Player.h
//  Musaxer
//
//  Created by 郭弘 on 2020/1/7.
//  Copyright © 2020 郭弘. All rights reserved.
//

#import <FSAudioStream.h>


NS_ASSUME_NONNULL_BEGIN

@protocol PlayerDelegate<NSObject>
@optional
//delegate to set progress slider value change with player state, used in music view
- (void)updateProgressWithCurrentPosition:(FSStreamPosition)currentPosition endPosition:(FSStreamPosition)endPosition;

//delegate to set play and pause button icon and album view rotation state with player state, used both in list and music view
- (void)updateBottomViewButton;

//delegate to set music infomation label text and album scroll view scroll state with player state, used both in list and music view
- (void)updateBottomViewLabelAndCover;

//delegate to set indicator of list state change with player state, used in list view
- (void)updatePlaybackIndicatorOfVisisbleCells;

//let album view's scroll view scroll to left or right
- (void)scrollLeft;
- (void)scrollRight;

//all animations' actions of album view
- (void)startAlbumAnimations;
- (void)stopAlbumAnimations;
@end



@interface Player : FSAudioStream
//now is playing playlist
@property (nonatomic, strong) NSMutableArray<Music*> *musics;

//origin music list, same as list of list view
@property (nonatomic, strong) NSArray<Music*> *originMusics;

//current index in now is playing playlist
@property (nonatomic, assign) NSUInteger currentIndex;
//player is stop
@property (nonatomic, assign) BOOL isStop;

//delegate for music view
@property (nonatomic, weak) id<PlayerDelegate>musicPlayerDelegate;
//delegate for list view
@property (nonatomic, weak) id<PlayerDelegate>listPlayerDelegate;
//delegate for scroll view
@property (nonatomic, weak) id<PlayerDelegate>scrollPlayerDelegate;

//now cycle type
@property (nonatomic, assign) MusicCycleType musicCycleType;

//default player instance, use 'PLAYER' as define variable
+ (instancetype)defaultPlayer;

- (void)playMusicAtIndex:(NSUInteger)index;

- (void)playPre;

//isAutoplay: player completing plaing music and auto play next flag
- (void)playNext:(BOOL)isAutoPlay;

//return current playing music model
- (Music*)currentMusic;

//return index of music according a giving musicId
- (NSUInteger)indexOfMusicFromMusicId:(NSNumber*)Id;

//print now plaing play list to console
- (void)printNowList;

NS_ASSUME_NONNULL_END
@end
