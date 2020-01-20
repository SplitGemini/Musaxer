//
//  MusicViewController.m
//  Musaxer
//
//  Created by 郭弘 on 2019/12/27.
//  Copyright © 2019 郭弘. All rights reserved.
//

#import "MusicViewController.h"
#import "Slider.h"
#import "AlbumView.h"
#import "LyricViewController.h"
#import "DeliveryView.h"
#import <SDWebImage.h>
#import <FTPopOverMenu.h>


@interface MusicViewController () <PlayerDelegate>
//background
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, weak) IBOutlet UIView *backgroundView;

//labels
@property (nonatomic, weak) IBOutlet UILabel *artistLabel;
@property (nonatomic, weak) IBOutlet UILabel *musicNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *musicTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *beginTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel *endTimeLabel;

//buttons
@property (nonatomic, weak) IBOutlet UIButton *favoriteButton;
@property (nonatomic, weak) IBOutlet UIButton *previousMusicButton;
@property (nonatomic, weak) IBOutlet UIButton *nextMusicButton;
@property (nonatomic, weak) IBOutlet UIButton *musicToggleButton;
@property (nonatomic, weak) IBOutlet UIButton *musicCycleButton;
@property (nonatomic, weak) IBOutlet UIButton *musicMenuButton;

//slider
@property (nonatomic, weak) IBOutlet Slider *slider;
//cd view
@property (nonatomic, weak) IBOutlet AlbumView *albumView;
//lyric view
@property (nonatomic, weak) IBOutlet UITableView *lyricTableView;

//blur visual effect
@property (nonatomic, strong) UIVisualEffectView *visualEffectView;
//now is showed music in music view
@property (nonatomic, strong) Music *music;

//lyric view controller
@property (nonatomic, strong) LyricViewController *lyricVC;

//delivery View
@property (nonatomic, weak) DeliveryView *deliveryView;
//...
@property (nonatomic, assign) BOOL deliveryViewIsHide;
@property (nonatomic, assign) BOOL isInitCycletype;
@end

@implementation MusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //set lyric view
    _lyricVC = [[LyricViewController alloc] init];
    [_lyricVC setTableView:_lyricTableView];
    _lyricTableView.alpha = 0;
    
    //set album view
    _albumView.lyricAlbumViewDelegate = (id)_lyricVC.self;
    [_albumView.center_rotationView addAnimation];
    
    //set slider tapped recognizer
    [_slider addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTappedSlider:)]];
    
    _isInitCycletype = NO;
    //title
    _musicTitleLabel.text = @"Musaxer";

    //init flag
    _deliveryViewIsHide = YES;
    
    //delivery view show and hide gesture
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTappedMusicView:)]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    //refresh every time into music view
    [self setupMusicView:[PLAYER currentMusic]];
    //read property from user settings: restore music cycle type
    if(!_isInitCycletype){
        [self setMusicCycleType:USER.musicCycleType];
        _isInitCycletype = YES;
    }
    
    [self updateBottomViewButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

#pragma mark - Set up views

- (void)setupMusicView:(Music *)music {
    if(music.musicId == _music.musicId) {
        NSLog(@"setup music view canceled refresh: will set music is nil: %d, view music is nil:%d, Id is same:%d, now music name is:%@",music == nil,_music == nil,music.musicId == _music.musicId,_music.musicName);
        return;
    }
    NSLog(@"music view set up success");
    _music = music;
    _musicNameLabel.text = _music.musicName;
    _artistLabel.text = _music.artistName;
    [self setupBackgroudImage];
    [self checkMusicFavoritedIcon];
    [_lyricVC setLyrics:[Helper lyricParseWithLyricString:[PLAYER currentMusic].musicLyric]];
    [_albumView setPrevoiusAndNextCover];
}


- (void)checkMusicFavoritedIcon {
    if (_music.isFavorited) {
        [_favoriteButton setImage:[UIImage imageNamed:@"red_heart"] forState:UIControlStateNormal];
    } else {
        [_favoriteButton setImage:[UIImage imageNamed:@"empty_heart"] forState:UIControlStateNormal];
    }
}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Background image

- (void)setupBackgroudImage {
    NSURL *imageUrl = [NSURL URLWithString:_music.cover];
    [_backgroundImageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"music"]];
    [_albumView.center_rotationView.CDimageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"music"]];
    
    if(![_visualEffectView isDescendantOfView:_backgroundView]) {
        UIVisualEffect *blurEffect;
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        _visualEffectView.frame = self.view.bounds;
        [_backgroundView addSubview:_visualEffectView];
    }
    
    [Helper startTransitionAnimation:_backgroundView];
    [Helper startTransitionAnimation:_albumView.center_rotationView.CDimageView];
}


/*
- (void)addPanRecognizer {
    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didTouchDismissButton:)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeRecognizer];
}
*/


#pragma mark Slider changed and tapped actions

- (IBAction)didChangeMusicSliderValue:(id)sender {
    FSStreamPosition position = {};
    unsigned totalSeconds = PLAYER.duration.minute*60 + PLAYER.duration.second;
    unsigned currentSeconds = totalSeconds * _slider.value;
    
    position.second = currentSeconds % 60;
    position.minute = currentSeconds / 60;
    [PLAYER seekToPosition:position];
}

- (void)didTappedSlider:(UITapGestureRecognizer *)sender {
    if(PLAYER.isStop) return;
    CGPoint touchPoint = [sender locationInView:_slider];
    CGFloat value = (_slider.maximumValue - _slider.minimumValue) * (touchPoint.x / _slider.frame.size.width );
    [_slider setValue:value animated:YES];
    FSStreamPosition position = {};
    unsigned totalSeconds = PLAYER.duration.minute*60 + PLAYER.duration.second;
    unsigned currentSeconds = totalSeconds * _slider.value;
    
    position.second = currentSeconds % 60;
    position.minute = currentSeconds / 60;
    if(!PLAYER.isPlaying) [PLAYER pause];
    [PLAYER seekToPosition:position];
    
}


#pragma mark - Setup ramdom list to player

- (void)setupRandomMusicIfNeed {
    //last state is shuffle, so restore to origin
    if(PLAYER.musicCycleType == SingleLoop) {
        PLAYER.musics = [NSMutableArray arrayWithArray:PLAYER.originMusics];
        PLAYER.currentIndex = [PLAYER indexOfMusicFromMusicId:_music.musicId];
        return;
        
    //set shuffle list
    }else if (PLAYER.musicCycleType == Shuffle){
          NSUInteger idx = PLAYER.originMusics.count - 1;
          while(idx) {
            [PLAYER.musics exchangeObjectAtIndex:idx
                         withObjectAtIndex:arc4random_uniform((uint32_t)idx)];
            idx --;
          }
        PLAYER.currentIndex = [PLAYER indexOfMusicFromMusicId:_music.musicId];
        [PLAYER printNowList];
    }
    //else do nothing
}

#pragma mark - Music PlayerDelegate

- (void)updateProgressWithCurrentPosition:(FSStreamPosition)currentPosition endPosition:(FSStreamPosition)endPosition {
    [_slider setValue:currentPosition.position animated:YES];
    //auto add 0 to label head
    NSString *textFormat = [(currentPosition.minute > 9 ? @"%u" : @"0%u") stringByAppendingString:(currentPosition.second > 9 ? @":%u" : @":0%u")];
    _beginTimeLabel.text = [NSString stringWithFormat:textFormat,currentPosition.minute,currentPosition.second];
    
    textFormat = [(endPosition.minute > 9 ? @"%u" : @"0%u") stringByAppendingString:(endPosition.second > 9 ? @":%u" : @":0%u")];
    _endTimeLabel.text = [NSString stringWithFormat:textFormat,endPosition.minute,endPosition.second];
    
    //a block to calculate ms from a FSStreamPosition variable
    NSTimeInterval (^calculateMs)(FSStreamPosition) = ^(FSStreamPosition position){
        NSTimeInterval time = position.minute * 60 * 1000 + position.second * 1000;
        return time;
    };
    
    //update lyric to scroll
    [_lyricVC scrollLyricWithCurrentTime:calculateMs(currentPosition) totalTime:calculateMs(endPosition)];
}

- (void)updateBottomViewButton{
    if (!PLAYER.isPlaying) {
        [_musicToggleButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_albumView pause];
    } else {
        [_musicToggleButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
        [_albumView resume];
    }
}

- (void)updateBottomViewLabelAndCover{
    [self setupMusicView:[PLAYER currentMusic]];
}

#pragma mark - Music button actions

- (IBAction)didTouchMenuButton:(id)sender {
    [Helper showMiddleHint:@"鲤鱼王使用了技能：水溅跃"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [Helper showMiddleHint:@"但是什么也没发生..."];
    });
}

- (IBAction)didTouchMusicToggleButton:(id)sender {
    [PLAYER pause];
}

- (IBAction)playPreviousMusic:(id)sender {
    [PLAYER playPre];
}

- (IBAction)playNextMusic:(id)sender {
    [PLAYER playNext:NO];
}

- (IBAction)didTouchDismissButton:(id)sender {
    //[self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [[Helper topViewController] dismissViewControllerAnimated:YES completion:^(void){
        NSLog(@"dismiss from music view");
    }];
}

- (IBAction)didTouchFavoriteButton:(id)sender {
    [Helper startDuangAnimation:_favoriteButton];
    if (_music.isFavorited) {
        _music.isFavorited = NO;
        [_favoriteButton setImage:[UIImage imageNamed:@"empty_heart"] forState:UIControlStateNormal];;
    } else {
        _music.isFavorited = YES;
        [_favoriteButton setImage:[UIImage imageNamed:@"red_heart"] forState:UIControlStateNormal];;
    }
}


- (IBAction)didTouchMusicCycleButton:(id)sender {
    switch (PLAYER.musicCycleType) {
        case AllLoop: {
            [self setMusicCycleType:Shuffle];
            [Helper showMiddleHint:@"随机播放"];
        }
            break;
        case Shuffle: {
            [self setMusicCycleType:SingleLoop];
            [Helper showMiddleHint:@"单曲循环"];
        }
            break;
        case SingleLoop: {
            [self setMusicCycleType:Advance];
            [Helper showMiddleHint:@"列表播放"];
            
        }
            break;
        case Advance : {
            [self setMusicCycleType:AllLoop];
            [Helper showMiddleHint:@"列表循环"];
        }
        default:
            break;
    }
    
    
}

- (IBAction)didTouchMoreButton:(id)sender {
    FTPopOverMenuConfiguration *configuration = [FTPopOverMenuConfiguration defaultConfiguration];
    configuration.menuRowHeight = 50;
    configuration.menuWidth = 150;
    configuration.textColor = [UIColor whiteColor];
    configuration.textFont = [UIFont systemFontOfSize:14];
    configuration.textAlignment = NSTextAlignmentCenter;
    configuration.ignoreImageOriginalColor = NO;
    configuration.allowRoundedArrow = NO;
    configuration.separatorColor = [UIColor whiteColor];
    configuration.shadowOpacity =  0.5;
    weakSELF;
    [FTPopOverMenu showForSender:sender withMenuArray:@[@"歌曲评价",@"删除图片缓存"] imageArray:@[@"info",@"delete"] configuration:configuration
      doneBlock:^(NSInteger selectedIndex) {
        if(selectedIndex == 0){
            [weakSelf showMoreView];
        }else {
            void (^action)(UIAlertAction*) = ^(UIAlertAction *action){
                [[SDImageCache sharedImageCache] clearDiskOnCompletion:^(void){
                    [Helper showMiddleHint:@"已清除图片缓存"];
                }];
                [[NSURLCache sharedURLCache] removeAllCachedResponses];
            };
            [Helper showAlertMsg:[MusicViewController sharedInstance] withMsg:@"删除缓存？" withHandler:action];
        }
    } dismissBlock:nil];
    NSLog(@"\"more\" button touched");
}

#pragma mark - More view


- (void)showMoreView{
    _deliveryViewIsHide = NO;
    [self deliveryView].musicDescription.text = [PLAYER currentMusic].musicDescription;
    [self.view addSubview:_deliveryView];
    
    _deliveryView.transform = CGAffineTransformMakeTranslation(0.01, SCREEN_HEIGHT);
    weakSELF;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            weakSelf.deliveryView .alpha = 1;
            weakSelf.deliveryView.transform = CGAffineTransformMakeTranslation(0.01, 0.01);
        }];
    });
}

- (void)didTappedMusicView:(UIGestureRecognizer*)gesture{
    if(_deliveryViewIsHide) return;
    else {
        self.deliveryViewIsHide = YES;
        weakSELF;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                weakSelf.deliveryView.transform = CGAffineTransformMakeTranslation(0.01, SCREEN_HEIGHT);
                weakSelf.deliveryView .alpha = 0.2;
            } completion:^(BOOL finished) {
                [weakSelf.deliveryView removeFromSuperview];
            }];
        });
    }
}

#pragma mark - Music cycle type setting

- (void)setMusicCycleType:(MusicCycleType)musicCycleType {
    PLAYER.musicCycleType = musicCycleType;
    USER.musicCycleType = musicCycleType;
    [self setupRandomMusicIfNeed];
    [self updateMusicCycleButton];
}

- (void)updateMusicCycleButton {
    switch (PLAYER.musicCycleType) {
        case AllLoop:
            [_musicCycleButton setImage:[UIImage imageNamed:@"repeat_list"] forState:UIControlStateNormal];
            break;
        case Shuffle:
            [_musicCycleButton setImage:[UIImage imageNamed:@"shuffle"] forState:UIControlStateNormal];
            break;
        case SingleLoop:
            [_musicCycleButton setImage:[UIImage imageNamed:@"repeat_song"] forState:UIControlStateNormal];
            break;
        case Advance:
            [_musicCycleButton setImage:[UIImage imageNamed:@"advance"] forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

# pragma mark - Lazy load

- (DeliveryView*)deliveryView{
    if (nil == _deliveryView) {
        _deliveryView = [[[NSBundle mainBundle] loadNibNamed:@"DeliveryView" owner:nil options:nil] lastObject];
    }
    return _deliveryView;
}

# pragma mark - Public method

+ (instancetype)sharedInstance {
    static MusicViewController *_sharedMusicVC = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedMusicVC = [[UIStoryboard storyboardWithName:@"Music" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"Music"];
        PLAYER.musicPlayerDelegate = _sharedMusicVC.self;
    });
    return _sharedMusicVC;
}


@end
