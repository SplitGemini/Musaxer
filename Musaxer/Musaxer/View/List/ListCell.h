//
//  ListCell.h
//  Musaxer
//
//  Created by 郭弘 on 2019/12/27.
//  Copyright © 2019 郭弘. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NAKPlaybackIndicatorView.h>

@interface ListCell : UITableViewCell
@property (nonatomic, assign) NSInteger musicNumber;
@property (nonatomic, assign) NSNumber *musicId;
@property (nonatomic, assign) NAKPlaybackIndicatorViewState state;
@property (nonatomic, weak) IBOutlet UIImageView *album;
- (void)setMusic:(Music*)music;
@end

