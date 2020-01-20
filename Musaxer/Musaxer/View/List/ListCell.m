//
//  ListCell.m
//  Musaxer
//
//  Created by 郭弘 on 2019/12/27.
//  Copyright © 2019 郭弘. All rights reserved.
//

#import "ListCell.h"


@interface ListCell ()
@property (weak, nonatomic) IBOutlet UILabel *musicNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *musicTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *musicArtistLabel;
@property (weak, nonatomic) IBOutlet NAKPlaybackIndicatorView *musicIndicator;

@end

@implementation ListCell

- (void)setMusicNumber:(NSInteger)musicNumber {
    _musicNumber = musicNumber;
    _musicNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)musicNumber];
}

- (void)setMusic:(Music *)music {
    _musicTitleLabel.text = music.musicName;
    _musicArtistLabel.text = music.artistName;
    _musicId = music.musicId;
    _album.layer.cornerRadius = _album.frame.size.width / 2.0;
    _album.layer.masksToBounds = YES;
}


- (void)setState:(NAKPlaybackIndicatorViewState)state {
    _musicIndicator.state = state;
    _musicNumberLabel.hidden = (state != NAKPlaybackIndicatorViewStateStopped);
}

@end
