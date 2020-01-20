//
//  LyricView.m
//  Musaxer
//
//  Created by 郭弘 on 2020/1/12.
//  Copyright © 2020 郭弘. All rights reserved.
//

#import "LyricViewController.h"
#import "LyricCell.h"
#import "AlbumView.h"


@interface LyricViewController() <AlbumViewDelegate>
//lyrics and index
@property (nonatomic, strong) NSArray<Lyric*> *lyrics;
@property (nonatomic, assign) NSInteger lyricIndex;
@end

static NSString *lyricCellId = @"LyricCell";

@implementation LyricViewController

- (void)viewDidLoad{
    [super viewDidLoad];
    [self.tableView registerClass:[LyricCell class] forCellReuseIdentifier:lyricCellId];
}

#pragma mark - Public metrod

//set now is playing lyrics array
- (void)setLyrics:(NSArray<Lyric*> *)lyrics {
    _lyrics = lyrics;
    [self.tableView reloadData];
    //scroll to center line
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:5 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
}

#pragma mark - Album view delegate

//according 'hidden' paremeter to set table view is show or hide
- (void)setHidden:(BOOL)hidden{
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.5 animations:^{
            if(hidden) self.tableView.alpha = 0;
            else self.tableView.alpha = 1;
        } completion:nil];
    });
}

#pragma mark - Scroll with time

//scroll lyric according current time and total time
- (void)scrollLyricWithCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    if (_lyrics.count == 0) _lyricIndex = 0;
    
    for (NSInteger i = 0; i < _lyrics.count; i++) {
        Lyric *currentLyric = _lyrics[i];
        Lyric *nextLyric    = nil;
        if (i < _lyrics.count - 1) {
            nextLyric = _lyrics[i + 1];
        }
        
        //current time is betweem curent lyric's time and next lycis's time, sub 500 ms to fix human feeling factor
        if ((_lyricIndex != i && currentTime > currentLyric.msTime -  500) && (!nextLyric || currentTime < nextLyric.msTime - 500)) {
            _lyricIndex = i;
            [self.tableView reloadData];
            
            //let hightlighted label in the middle but a little down position. So here index is lyricIndex + 4, and cell highlighted index is lyricindex + 5
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:(_lyricIndex + 4) inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
        }
    }
}



#pragma mark - UITableView dataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // more 10 lines leave blank in top and bottom
    return _lyrics.count + 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //avoid exceed range
    if(indexPath.row < 5 || indexPath.row > _lyrics.count + 4) return 30;
    
    //calculate wrapped line height
    NSString* cellText = _lyrics[indexPath.row - 5].content;
    UIFont *cellFont = [UIFont systemFontOfSize:18.0];
    CGSize constraintSize = CGSizeMake(self.tableView.frame.size.width, MAXFLOAT);
    NSStringDrawingOptions opts = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineBreakMode:NSLineBreakByCharWrapping];
    NSDictionary *attributes = @{ NSFontAttributeName : cellFont, NSParagraphStyleAttributeName : style };
    CGRect rect = [cellText boundingRectWithSize:constraintSize
                                     options:opts
                                  attributes:attributes
                                     context:nil];
    
    return rect.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LyricCell *cell = [tableView dequeueReusableCellWithIdentifier:lyricCellId forIndexPath:indexPath];
    
    //blank above and below lyrics
    if (indexPath.row < 5 || indexPath.row > _lyrics.count + 4) {
        cell.textLabel.textColor = [UIColor clearColor];
        cell.textLabel.text      = @"";
        
    //now lyric set to white and larger, others set to gray and smaller
    } else {
        cell.textLabel.text = _lyrics[indexPath.row - 5].content;
        
        //let hightlighted label in the middle but a little down position
        if (indexPath.row == _lyricIndex + 5) {
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.textLabel.font      = [UIFont systemFontOfSize:18.0];
        }else {
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.font      = [UIFont systemFontOfSize:16.0];
        }
    }
    
    return cell;
}

@end
