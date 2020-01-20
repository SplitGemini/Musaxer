//
//  GVUserDefaults+Properties.m
//  Musaxer
//
//  Created by 郭弘 on 2019/12/28.
//  Copyright © 2019 郭弘. All rights reserved.
//

#import "GVUserDefaults+Properties.h"

@implementation GVUserDefaults (Properties)
@dynamic musicCycleType;
@dynamic musicId;
- (NSDictionary *)setupDefaults {
    static NSDictionary* dic = nil;
        if (dic) {
            return dic;
        }else{
            dic = @{
                    @"musicCycleType":@(AllLoop),
                    @"musicId":@0
                    };
            return dic;
        }
}
@end
