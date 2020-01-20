//
//  NetworkHelper.h
//  Musaxer
//
//  Created by 郭弘 on 2020/1/13.
//  Copyright © 2020 郭弘. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN

@interface NetworkHelper : NSObject
//get json data from specified url, the url string is defined at prefixheader. finishBlock:finish actions after finish get data
+ (void)doGetRequest:(void(^)(NSDictionary *dic))finishBlock;
@end

NS_ASSUME_NONNULL_END
