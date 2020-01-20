//
//  NetworkHelper.m
//  Musaxer
//
//  Created by 郭弘 on 2020/1/13.
//  Copyright © 2020 郭弘. All rights reserved.
//

#import "NetworkHelper.h"
#import <MBProgressHUD.h>

@implementation NetworkHelper

+ (AFHTTPSessionManager *)shareAFNManager{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer.timeoutInterval = 10.0f;
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept" ];
    [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type" ];
    manager.responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/xml", @"text/xml",@"text/html", @"application/json",@"text/plain",nil];
    return manager;
}

+ (void)doGetRequest:(void(^)(NSDictionary *dic))finishBlock{
   NSDictionary *parameters=@{};
    
    //prograss animation use MPProgressHUD
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    hud.label.text = @"Loading...";
    hud.removeFromSuperViewOnHide = YES;
   [[NetworkHelper shareAFNManager] GET:JSON_DATA_URL parameters:parameters progress:^(NSProgress * _Nonnull downloadProgress) {
       NSProgress *progress = downloadProgress;
       hud.progressObject = progress;
   } success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        [hud hideAnimated:YES];
       finishBlock(responseObject);
   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
       [hud hideAnimated:YES];
       [Helper showAlertMsg:[Helper topViewController] withMsg:@"加载失败,重试？" withHandler:^(UIAlertAction *action){
           [NetworkHelper doGetRequest:finishBlock];
       }];
   }];
}
@end
