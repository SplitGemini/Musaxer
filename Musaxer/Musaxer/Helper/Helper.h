//
//  Helper.h
//  Musaxer
//
//  Created by 郭弘 on 2019/12/27.
//  Copyright © 2019 郭弘. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface Helper : NSObject
//twinkle animation for heart button
+ (void)startDuangAnimation:(UIButton*)button;
//show middle hint use MPProgressHUD
+ (void)showMiddleHint:(NSString*)hint;

//show alert message with view controller message and action
+ (void)showAlertMsg:(UIViewController*)vc withMsg:(NSString*)msg withHandler:(void (^)(UIAlertAction*))action;
//transition animation for background view in musci view
+ (void)startTransitionAnimation:(UIView*)view;
//return top view controller
+ (UIViewController*)topViewController;
//parse lyrics to a lyric array
+ (NSArray*)lyricParseWithLyricString:(NSString *)LyricString;
@end


