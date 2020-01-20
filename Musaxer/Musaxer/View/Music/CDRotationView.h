//
//  CDRotationView.h
//  Musaxer
//
//  Created by 郭弘 on 2020/1/11.
//  Copyright © 2020 郭弘. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CDRotationView : UIView

//cover image view showed in the center of cd
@property (nonatomic, weak) IBOutlet  UIImageView *CDimageView;
//start and add rotation animation
- (void)start;
//pause and remove rotation animation
- (void)stop;
//just pause rotation animation
- (void)pauseRotation;
//just start rotation animation
- (void)startRotation;
//add animations for music view init method used
- (void)addAnimation;
@end

NS_ASSUME_NONNULL_END
