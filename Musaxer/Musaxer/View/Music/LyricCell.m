//
//  LyricCell.m
//  Musaxer
//
//  Created by 郭弘 on 2020/1/12.
//  Copyright © 2020 郭弘. All rights reserved.
//

#import "LyricCell.h"

@implementation LyricCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.textLabel.textColor = [UIColor grayColor];
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    self.textLabel.numberOfLines = 0;
    self.textLabel.font = [UIFont systemFontOfSize:16.0];
    self.selectedBackgroundView = [UIView new];
    self.backgroundColor = [UIColor clearColor];
}

@end
