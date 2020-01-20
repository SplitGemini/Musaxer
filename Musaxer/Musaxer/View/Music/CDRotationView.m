//
//  CDRotationView.m
//  Musaxer
//
//  Created by 郭弘 on 2020/1/11.
//  Copyright © 2020 郭弘. All rights reserved.
//

#import "CDRotationView.h"
@interface CDRotationView()
@property (atomic, assign) BOOL isCDRotating;
@end

@implementation CDRotationView


- (void)awakeFromNib{
    [super awakeFromNib];
    // Initialization code
    _CDimageView.layer.cornerRadius = _CDimageView.frame.size.width / 2.0;
    _CDimageView.layer.masksToBounds = YES;
}

- (void)addAnimation{
    //Rotation
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0];
    rotationAnimation.duration = 18;
    rotationAnimation.repeatCount = FLT_MAX;
    rotationAnimation.cumulative = NO;
    rotationAnimation.removedOnCompletion = NO; //No Remove
    [self.layer addAnimation:rotationAnimation forKey:@"rotation"];
    self.layer.speed = 0;
    _isCDRotating = NO;
}


- (void)startRotation{
    if(!_isCDRotating){
        _isCDRotating = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
           self.layer.speed = 1.0;
            self.layer.beginTime = 0.0;
            CFTimeInterval pausedTime = [self.layer timeOffset];
            CFTimeInterval timeSincePause = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
            self.layer.beginTime = timeSincePause;
        });
        NSLog(@"Rotation rotating...");
    }
}


- (void)pauseRotation{
    if(_isCDRotating){
        _isCDRotating = NO;
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:1 animations:^{
                CFTimeInterval pausedTime = [self.layer convertTime:CACurrentMediaTime() fromLayer:nil];
                self.layer.speed = 0.0;
                self.layer.timeOffset = pausedTime;
            }];
        });
        NSLog(@"Rotation paused");
    }
}

- (void)start{
    NSLog(@"Rotation started");
    self.layer.speed = 0;
    [self.layer removeAllAnimations];
    [self addAnimation];
    [self startRotation];
}

- (void)stop{
    self.layer.speed = 0;
    [self.layer removeAllAnimations];
    _isCDRotating = NO;
    NSLog(@"Rotation stopped");
}

@end
