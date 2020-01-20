//
//  ListBottomView.m
//  Musaxer
//
//  Created by 郭弘 on 2020/1/7.
//  Copyright © 2020 郭弘. All rights reserved.
//

#import "ListBottomView.h"
#import "MusicViewController.h"

@interface ListBottomView() <UIGestureRecognizerDelegate>
@property (nonatomic,strong) UITapGestureRecognizer *tapGesture;
@end

@implementation ListBottomView 

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.frame = CGRectMake(0, SCREEN_HEIGHT - 160, SCREEN_WIDTH, 60);
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTouch:)];
    _tapGesture.delegate = (id)self;
    [self addGestureRecognizer:_tapGesture];
    _imageView.layer.cornerRadius = _imageView.frame.size.width / 2.0;
    _imageView.layer.masksToBounds = YES;
}


#pragma mark == UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    //if touched area is button, dont't present to music view
    if ([touch.view isKindOfClass:[UIButton class]]) {
        return NO;
    }
    return YES;
}
#pragma mark - check player state

-(BOOL)checkPlayerState{
    if (PLAYER.musics.count == 0) {
        [Helper showAlertMsg:[Helper topViewController] withMsg:@"你还没有播放歌曲" withHandler:nil];
        return NO;
    }
    return YES;
}

#pragma mark - event response

- (void)tapTouch:(UITapGestureRecognizer *)tap {
     if([self checkPlayerState]) {
        [[Helper topViewController] presentViewController:[MusicViewController sharedInstance] animated:YES completion:nil];
    }
}

#pragma mark - button actions

- (IBAction)play:(id)sender{
    if([self checkPlayerState]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [PLAYER pause];
        });
    }
        
}

- (IBAction)next:(id)sender{
    if([self checkPlayerState]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [PLAYER playNext:NO];
        });
    }
        
}


@end
