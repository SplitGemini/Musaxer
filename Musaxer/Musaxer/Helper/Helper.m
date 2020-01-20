//
//  Helper.m
//  Musaxer
//
//  Created by 郭弘 on 2019/12/27.
//  Copyright © 2019 郭弘. All rights reserved.
//

#import "Helper.h"
#import "AppDelegate.h"
#import "Lyric.h"
#import <MBProgressHUD.h>

@implementation Helper


+ (void)startDuangAnimation:(UIButton*)button {
    UIViewAnimationOptions op = UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState;
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.15 delay:0 options:op animations:^{
            [button.layer setValue:@(0.80) forKeyPath:@"transform.scale"];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.15 delay:0 options:op animations:^{
                [button.layer setValue:@(1.3) forKeyPath:@"transform.scale"];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.15 delay:0 options:op animations:^{
                    [button.layer setValue:@(1) forKeyPath:@"transform.scale"];
                } completion:NULL];
            }];
        }];
    });
}


+ (void)showMiddleHint:(NSString *)hint {
    UIView *view = [[UIApplication sharedApplication].delegate window];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    hud.mode = MBProgressHUDModeText;
    hud.label.text = hint;
    hud.label.font = [UIFont systemFontOfSize:15];
    hud.margin = 10.f;
    [hud setOffset:CGPointMake(0, 0)];
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:2];
}


+ (void)showAlertMsg:(UIViewController*)vc withMsg:(NSString *)msg withHandler:(void(^)(UIAlertAction *))action {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:msg preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:action];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:sureAction];
    [alertController addAction:cancelAction];
    [vc presentViewController:alertController animated:YES completion:nil];
}

+ (void)startTransitionAnimation:(UIView*)view {
    CATransition *transition = [CATransition animation];
    transition.duration = 1.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade;
    [view.layer addAnimation:transition forKey:nil];
}

+ (UIViewController*)topViewController{
    UIViewController *vc = nil;
    if ([APP.window.rootViewController isKindOfClass:[UINavigationController class]]) {
        vc = ((UINavigationController *)((AppDelegate*)[UIApplication sharedApplication].delegate).window.rootViewController).topViewController;
        
    }else if ([APP.window.rootViewController isKindOfClass:[UIViewController class]]){
        vc = ((UIViewController *)APP.window.rootViewController);
        
    }
    return vc;
}


+ (NSArray *)lyricParseWithLyricString:(NSString *)lyricString{
    //split lyric by "\n"
    NSArray *linesArray = [lyricString componentsSeparatedByString:@"\n"];
    
    //create model array
    NSMutableArray *modelArray = [NSMutableArray new];
    
    // analysis
    // examples:
    // [ti:Six Feet Under]
    // [00:00.00]...
    // [00:00.00][00:00.01][00:00.02]...
    // [00:00.000]...
    //
    
    for (NSString *line in linesArray) {
        //use regular expresion
        NSString *pattern = @"\\[[0-9][0-9]:[0-9][0-9].[0-9]{1,}\\]";
        
        NSRegularExpression *regular = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
        //start match pattern
        NSArray *matchesArray = [regular matchesInString:line options:NSMatchingReportProgress range:NSMakeRange(0, line.length)];
                
        //content of lyric
        NSString *content = [line componentsSeparatedByString:@"]"].lastObject;
        
        //each [00:00.00] time
        for (NSTextCheckingResult *match in matchesArray) {
            NSString *timeStr = [line substringWithRange:match.range];

            // remove '['
            timeStr = [timeStr substringFromIndex:1];
            // remove ']'
            timeStr = [timeStr substringToIndex:(timeStr.length - 1)];
            
            // split minute and second
            NSString *minStr = [timeStr substringWithRange:NSMakeRange(0, 2)];
            NSString *secStr = [timeStr substringWithRange:NSMakeRange(3, 2)];
            
            // the last is ms string
            NSString *mseStr = [timeStr substringFromIndex:6];
            
            // transform to ms
            NSTimeInterval time = [minStr floatValue] * 60 * 1000 + [secStr floatValue] * 1000 + [mseStr floatValue];
            
            //new one model
            Lyric *lyric = [Lyric new];
            lyric.content      = content;
            lyric.msTime       = time;
            [modelArray addObject:lyric];
        }
    }
    
    //sort by time
    //"ascending:YES" : sort from small to large
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"msTime" ascending:YES];
    
    return [modelArray sortedArrayUsingDescriptors:@[descriptor]];
}

@end
