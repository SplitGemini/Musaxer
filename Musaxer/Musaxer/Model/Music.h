//
//  Music.h
//  Musaxer
//
//  Created by 郭弘 on 2019/12/27.
//  Copyright © 2019 郭弘. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Music : NSObject
@property (nonatomic, copy) NSNumber *musicId;
@property (nonatomic, copy) NSString *musicName;
@property (nonatomic, copy) NSString *musicUrl;
@property (nonatomic, copy) NSString *cover;
@property (nonatomic, copy) NSString *artistName;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) BOOL isFavorited;
@property (nonatomic, copy) NSString *musicDescription;
@property (nonatomic, copy) NSString *musicLyric;
@end

NS_ASSUME_NONNULL_END
