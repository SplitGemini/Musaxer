//
//  DeliveryView.m
//  Musaxer
//
//  Created by 郭弘 on 2020/1/13.
//  Copyright © 2020 郭弘. All rights reserved.
//

#import "DeliveryView.h"

@interface DeliveryView()

@end


@implementation DeliveryView

- (void)awakeFromNib{
    [super awakeFromNib];
    [self setSelf];
}

- (void)setSelf{
    CGFloat height = 300;
    self.frame = CGRectMake(0, SCREEN_HEIGHT - height, CURRENT_FRAME_WIDTH, height);
    self.backgroundColor = [UIColor grayColor];
    //rounded top left and top right bounds
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerTopLeft cornerRadii:CGSizeMake(18, 18)];
    CAShapeLayer *mask = [CAShapeLayer layer];
    mask.path = path.CGPath;
    self.layer.mask = mask;
}

@end
