//
//  LyricView.h
//  Musaxer
//
//  Created by 郭弘 on 2020/1/12.
//  Copyright © 2020 郭弘. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Lyric.h"

NS_ASSUME_NONNULL_BEGIN

@interface LyricViewController : UITableViewController

- (void)setLyrics:(NSArray<Lyric*> *)lyrics;
- (void)scrollLyricWithCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;

@end

NS_ASSUME_NONNULL_END
