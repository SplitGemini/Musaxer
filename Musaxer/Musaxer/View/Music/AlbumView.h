//
//  CDView.h
//  Musaxer
//
//  Created by 郭弘 on 2020/1/11.
//  Copyright © 2020 郭弘. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CDRotationView.h"


NS_ASSUME_NONNULL_BEGIN

@protocol AlbumViewDelegate <NSObject>
- (void)setHidden:(BOOL)hidden;
@end

@interface AlbumView : UIView
//center rotation view 
@property (nonatomic, weak) IBOutlet CDRotationView *center_rotationView;
@property (nonatomic, weak) id<AlbumViewDelegate>lyricAlbumViewDelegate;
//pause or resume animations
- (void)pause;
- (void)resume;
- (void)setPrevoiusAndNextCover;
@end

NS_ASSUME_NONNULL_END
