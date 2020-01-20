//
//  Slider.m
//  Musaxer
//
//  Created by 郭弘 on 2019/12/27.
//  Copyright © 2019 郭弘. All rights reserved.
//

#import "Slider.h"

@implementation Slider
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    //drag process does not trigger value changed
    self.continuous = NO;
    UIImage *thumbImage = [self scaleImageToSize:[UIImage imageNamed:@"music_slider_circle"] scaleToSize:CGSizeMake(30, 30)] ;
    [self setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [self setThumbImage:thumbImage forState:UIControlStateNormal];
}

- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value {
    rect.origin.x = rect.origin.x - 10 ;
    rect.size.width = rect.size.width + 20;
    //hte area can be touched  in thumb
    return CGRectInset ([super thumbRectForBounds:bounds trackRect:rect value:value], 10 , 10);
}

//scale image to custom size
-(UIImage*)scaleImageToSize:(UIImage*)image scaleToSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0,0, size.width, size.height)];
    UIImage* scaledImage =UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
@end
