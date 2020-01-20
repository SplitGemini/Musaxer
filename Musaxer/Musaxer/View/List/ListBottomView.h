//
//  ListBottomView.h
//  Musaxer
//
//  Created by 郭弘 on 2020/1/7.
//  Copyright © 2020 郭弘. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ListBottomView : UIView
//cover
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
//title
@property (nonatomic, strong) IBOutlet UILabel *titleLable;
//artist
@property (nonatomic, strong) IBOutlet UILabel *artistLable;
//play
@property (nonatomic, strong) IBOutlet UIButton *playButton;
//next
@property (nonatomic, strong) IBOutlet UIButton *nextButton;

- (IBAction)play:(id)sender;
- (IBAction)next:(id)sender;
@end

NS_ASSUME_NONNULL_END
