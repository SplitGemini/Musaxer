//
//  GVUserDefaults+Properties.h
//  Musaxer
//
//  Created by 郭弘 on 2019/12/28.
//  Copyright © 2019 郭弘. All rights reserved.
//

#import <GVUserDefaults.h>


@interface GVUserDefaults (Properties)
//use setting ,store musicCycleType and now playing music's musicId
@property (nonatomic, assign) MusicCycleType musicCycleType;
@property (nonatomic, assign) NSNumber* musicId;
@end

