//
//  Lyric.h
//  Musaxer
//
//  Created by 郭弘 on 2020/1/11.
//  Copyright © 2020 郭弘. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Lyric : NSObject
@property (nonatomic, assign) NSTimeInterval msTime;
@property (nonatomic, copy) NSString *content;
@end

NS_ASSUME_NONNULL_END
