//
//  CDView.m
//  Musaxer
//
//  Created by 郭弘 on 2020/1/11.
//  Copyright © 2020 郭弘. All rights reserved.
//

#import "AlbumView.h"
#import <SDWebImage.h>


@interface AlbumView() <UIScrollViewDelegate,PlayerDelegate>
@property (nonatomic, weak) IBOutlet CDRotationView *left_rotationView;
@property (nonatomic, weak) IBOutlet CDRotationView *right_rotationView;
@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;
@property (nonatomic, weak) IBOutlet UIImageView *needle;
@property (nonatomic, weak) IBOutlet UIImageView *mask1;
@property (nonatomic, weak) IBOutlet UIImageView *mask2;

//user hand made drag to scroll the scroll view, avoid a circular actions
@property (atomic, assign) BOOL isHandMadeAction;
//needle is plaing
@property (atomic, assign) BOOL isNeedlePlaying;
//cover is hidden
@property (atomic, assign) BOOL isCoverHidden;
@end

@implementation AlbumView

- (void)awakeFromNib {
    [super awakeFromNib];
    PLAYER.scrollPlayerDelegate = self;
    [self buildView];
    [self addTappedGesture];
}

#pragma mark - Build view and add tap gestures

- (void)addTappedGesture{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverTapped)];
    [_center_rotationView addGestureRecognizer:tap];
    UITapGestureRecognizer *tapLyric = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lyricTapped)];
    [self addGestureRecognizer:tapLyric];
}

- (void)coverTapped{
    NSLog(@"tapped cover");
    self.isCoverHidden = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            [self hideOrShow:YES];
        } completion:^(BOOL finished) {
            //send to lyric view controller
            if (self.lyricAlbumViewDelegate && [self.lyricAlbumViewDelegate respondsToSelector:@selector(setHidden:)]) {
                [self.lyricAlbumViewDelegate setHidden:NO];
            }
        }];
    });
}

- (void)lyricTapped{
    NSLog(@"tapped lyric view");
    if(_isCoverHidden){
        self.isCoverHidden = NO;
        //send to lyric view controller
        if (self.lyricAlbumViewDelegate && [self.lyricAlbumViewDelegate respondsToSelector:@selector(setHidden:)]) {
            [self.lyricAlbumViewDelegate setHidden:YES];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 animations:^{
                [self hideOrShow:NO];
            } completion:nil];
        });
    }
}

//hide or show cover, needle, mask1 and mask2, according to hidden flag
- (void)hideOrShow:(BOOL)hide{
    if(hide){
        self.scrollView.alpha = 0;
        self.needle.alpha = 0;
        self.mask1.alpha = 0;
        self.mask2.alpha = 0;
    }else{
        self.scrollView.alpha = 1;
        self.needle.alpha = 1;
        self.mask1.alpha = 1;
        self.mask2.alpha = 1;
    }
}

- (void)buildView{
    //set scroll view delegate to self
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(self.frame.size.width * 3, 0);
    //set anchor point of needle
    [self setAnchorPoint];
    //needle animation transform
    CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI_2 / 3);
    _needle.transform = transform;
    
    //init to no
    _isNeedlePlaying = NO;
    _isHandMadeAction = NO;
    
    //reset left and right rotation view images
    [self setPrevoiusAndNextCover];
    
    weakSELF;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //move to center
        [weakSelf.scrollView setContentOffset:CGPointMake(CURRENT_FRAME_WIDTH, 0) animated:NO];
        NSLog(@"scroll view move to center");
    });
    NSLog(@"build view");
}

// set needle's anchor point
- (void)setAnchorPoint{
    CGPoint oldOrigin = _needle.frame.origin;
    _needle.layer.anchorPoint = CGPointMake(0.2, 0.15);
    
    CGPoint newOrigin = _needle.frame.origin;
    
    CGPoint transition;
    transition.x = newOrigin.x - oldOrigin.x;
    transition.y = newOrigin.y - oldOrigin.y;
    _needle.center = CGPointMake(_needle.center.x - transition.x, _needle.center.y - transition.y);
}

#pragma mark - Final action after a scroll progress

- (void)reloadCDRotationView{
    NSInteger direction;
    CGPoint offset = [_scrollView contentOffset];
    if (offset.x > self.scrollView.frame.size.width * 1.5 ) { //scroll to right
        direction = 1;
        NSLog(@"Scroll view scroll is right");
    }else if (offset.x < self.scrollView.frame.size.width * 0.5) { //to left
        direction = 0;
        NSLog(@"Scroll view scroll is left");
    } else direction = 2;
    //manual scroll scale is too small
    if(direction == 2) {
        _isHandMadeAction = NO;
        return;
    }
    
    
    //player action
    if(_isHandMadeAction){
        if(direction == 1){
            [PLAYER playNext:NO];
        }
        if(direction == 0){
            [PLAYER playPre];
        }
    }
    //move to center
    [self.scrollView setContentOffset:CGPointMake(CURRENT_FRAME_WIDTH, 0) animated:NO];
    NSLog(@"scroll view move to center");
    
    weakSELF;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //make sure last animation completed
        [weakSelf performSelector:@selector(needleStartWithAnimation) withObject:nil afterDelay:0.2];
        
        //reset left and right rotation view images
        //[weakSelf setPrevoiusAndNextCover];
    });
    
    NSLog(@"album view reload view");
}


#pragma mark - Private fuction

- (void)setPrevoiusAndNextCover{
    //if music cycle type is AllLool or Shuffle, player will play all music circularly
    //if music cycle type is SingleLool or Advance, player will play list once
    BOOL isAllPlayMode;
    switch (PLAYER.musicCycleType) {
        case AllLoop:
        case Shuffle:
        {
            isAllPlayMode = YES;
        }
            break;
        case Advance:
        case SingleLoop:
        {
            isAllPlayMode = NO;
        }
            break;
        default:
            break;
    }
    
    NSUInteger leftIndex;
    NSUInteger rightIndex;
    if(isAllPlayMode){
        leftIndex = (PLAYER.currentIndex - 1 + PLAYER.musics.count) % PLAYER.musics.count;
        rightIndex = (PLAYER.currentIndex + 1) % PLAYER.musics.count;
        [_right_rotationView.CDimageView sd_setImageWithURL:[NSURL URLWithString:[PLAYER.musics objectAtIndex:rightIndex].cover] placeholderImage:[UIImage imageNamed:@"music"]];
        [_left_rotationView.CDimageView sd_setImageWithURL:[NSURL URLWithString:[PLAYER.musics objectAtIndex:leftIndex].cover] placeholderImage:[UIImage imageNamed:@"music"]];
    } else {
        if(PLAYER.currentIndex == 0) {
            [_left_rotationView.CDimageView setImage:[UIImage imageNamed:@"music"]];
        } else {
            leftIndex = PLAYER.currentIndex - 1;
            [_left_rotationView.CDimageView sd_setImageWithURL:[NSURL URLWithString:[PLAYER.musics objectAtIndex:leftIndex].cover] placeholderImage:[UIImage imageNamed:@"music"]];
        }
        if(PLAYER.currentIndex == PLAYER.musics.count - 1) {
            [_right_rotationView.CDimageView setImage:[UIImage imageNamed:@"music"]];
        }else {
            rightIndex = PLAYER.currentIndex + 1;
            [_right_rotationView.CDimageView sd_setImageWithURL:[NSURL URLWithString:[PLAYER.musics objectAtIndex:rightIndex].cover] placeholderImage:[UIImage imageNamed:@"music"]];
        }
    }
}

#pragma mark - Animations

//needle animations
- (void)needlePauseWithAnimation {
    if(_isNeedlePlaying){
        _isNeedlePlaying = NO;
        weakSELF;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.4 animations:^{
                CGAffineTransform transform = CGAffineTransformMakeRotation(-M_PI_2 / 3);
                weakSelf.needle.transform = transform;
            } completion:^(BOOL finished) {
                NSLog(@"needle pause completed");
            }];
        });
    }
}

- (void)needleStartWithAnimation{
    if(!_isNeedlePlaying){
        _isNeedlePlaying = YES;
        weakSELF;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.4 animations:^{
                CGAffineTransform transform = CGAffineTransformMakeRotation(0);
                weakSelf.needle.transform = transform;
            } completion:^(BOOL finished) {
                NSLog(@"needle start completed");
            }];
        });
    }
    
}


#pragma mark - Scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _isHandMadeAction = YES;
    [self needlePauseWithAnimation];
    NSLog(@"album view begin dragging");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self reloadCDRotationView];
    NSLog(@"album view end decelerating");
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self reloadCDRotationView];
    NSLog(@"album view end scrolling animation");
}

- (void)scrollViewDidEnd:(UIScrollView *)scrollView {
    [self reloadCDRotationView];
    NSLog(@"album view end");
}

#pragma mark - Player delegate

//let cover scroll to right
- (void)scrollRight{
    if(_isHandMadeAction){
        _isHandMadeAction = NO;
        return;
    }
    NSLog(@"player call scroll right");
    [self needlePauseWithAnimation];
    weakSELF;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x + CURRENT_FRAME_WIDTH, 0) animated:YES];
    });
    
    
}

//let cover scroll to left
- (void)scrollLeft{
    if(_isHandMadeAction){
        _isHandMadeAction = NO;
        return;
    }
    NSLog(@"player call scroll left");
    [self needlePauseWithAnimation];
    weakSELF;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.scrollView setContentOffset:CGPointMake(self.scrollView.contentOffset.x - CURRENT_FRAME_WIDTH, 0) animated:YES];
    });
    
    
}

//restart rotation to rotate
- (void)startAlbumAnimations{
    [_center_rotationView start];
    [self needleStartWithAnimation];
}

//rotation stop rotate and reset to init state
- (void)stopAlbumAnimations{
    [_center_rotationView stop];
    [self needlePauseWithAnimation];
}

#pragma mark - Public metrod

//pause rotating
- (void)pause {
    [_center_rotationView pauseRotation];
    [self needlePauseWithAnimation];
}

//resume rotating from pause state
- (void)resume{
    [_center_rotationView startRotation];
    [self needleStartWithAnimation];
}
@end
