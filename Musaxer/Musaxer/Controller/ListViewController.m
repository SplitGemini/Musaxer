//
//  ListViewController.m
//  Musaxer
//
//  Created by 郭弘 on 2019/12/27.
//  Copyright © 2019 郭弘. All rights reserved.
//

#import "ListViewController.h"
#import "MusicViewController.h"
#import "ListCell.h"
#import "MBProgressHUD.h"
#import "ListBottomView.h"
#import "NetworkHelper.h"
#import <SDWebImage.h>
#import <Reachability.h>
#import <MJExtension.h>

@interface ListViewController () <PlayerDelegate>
@property (nonatomic, strong) NSArray<Music*> *musics;
@property (nonatomic, strong) ListBottomView *listBottomView;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSBlockOperation *> *operations;
@end

static NSString *musicListCellId = @"musicListCell";

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.title = @"音乐列表";
    PLAYER.listPlayerDelegate = self;
    [self.view addSubview:[self ListBottomView]];
    [self loadJson];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


#pragma mark - queue operations

- (NSOperationQueue *)queue {
    if (_queue == nil) {
        _queue = [[NSOperationQueue alloc]init];
        //设置最大并发数
        _queue.maxConcurrentOperationCount = 3;
    }
    return _queue;
}

-(NSMutableDictionary *)operations {
    if (_operations == nil) {
        _operations = [NSMutableDictionary dictionary];
    }
    return _operations;
}


#pragma mark - Internet check

- (BOOL)checkConnected {
    Reachability *reach = [Reachability reachabilityForInternetConnection];
    if ([reach isReachable]) {
        return TRUE;
    }
    else {
        [Helper showMiddleHint:@"未连接互联网"];
        NSLog(@"internet disconnected");
        return FALSE;
    }
}

# pragma mark - Load data from server or local

- (void)loadJson {
    if(![self checkConnected]) {
        [Helper showAlertMsg:self withMsg:@"无网络连接" withHandler:nil];
        return;
    }
    weakSELF;
    void (^finishBlock)(NSDictionary*) = ^(NSDictionary *dic) {
        strongSELF;
        [Music mj_setupIgnoredPropertyNames:^NSArray*{
                return @[@"isFavorited"];
            }];
        strongSelf.musics = [[NSArray alloc] initWithArray:[Music mj_objectArrayWithKeyValuesArray:dic[@"data"]]];
        PLAYER.originMusics = [[NSArray alloc] initWithArray:strongSelf.musics];
        PLAYER.musics = [NSMutableArray arrayWithArray:strongSelf.musics];
        PLAYER.currentIndex = [PLAYER indexOfMusicFromMusicId:USER.musicId];
        PLAYER.musicCycleType = USER.musicCycleType;
        [PLAYER printNowList];
        [strongSelf.tableView reloadData];
        [strongSelf updateBottomViewLabelAndCover];
    };
        //get data from server
        [NetworkHelper doGetRequest:finishBlock];
}

# pragma mark - Tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(PLAYER.currentMusic.musicId != [_musics objectAtIndex:indexPath.row].musicId || PLAYER.isStop) {
        [PLAYER playMusicAtIndex:[PLAYER indexOfMusicFromMusicId:[_musics objectAtIndex:indexPath.row].musicId]];
        
    }
    [self presentToMusicViewWithMusicVC:[MusicViewController sharedInstance]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

# pragma mark - Jump to music view

- (void)presentToMusicViewWithMusicVC:(MusicViewController *)musicVC {
    dispatch_async(dispatch_get_main_queue(), ^ {
        //[self.navigationController presentViewController:musicVC animated:YES completion:nil];
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:musicVC];
        [self.navigationController presentViewController:navigationController animated:YES completion:nil];
    });
    
}

# pragma mark - Update music indicator

- (void)updatePlaybackIndicatorOfCell:(ListCell *)cell {
    if (cell.musicId == [PLAYER currentMusic].musicId) {
        cell.state = PLAYER.isPlaying ? NAKPlaybackIndicatorViewStatePlaying : NAKPlaybackIndicatorViewStatePaused;
    } else {
        cell.state = NAKPlaybackIndicatorViewStateStopped;
    }
}

#pragma mark - ListPlayerDelegate

- (void)updatePlaybackIndicatorOfVisisbleCells {
    for (ListCell *cell in self.tableView.visibleCells) {
        [self updatePlaybackIndicatorOfCell:cell];
    }
}

- (void)updateBottomViewButton{
    if(!PLAYER.isPlaying){
        [_listBottomView.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }else [_listBottomView.playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
}

- (void)updateBottomViewLabelAndCover{
    Music *tempMusic = [PLAYER currentMusic];
    _listBottomView.artistLable.text = tempMusic.artistName;
    [_listBottomView.imageView sd_setImageWithURL:[NSURL URLWithString:tempMusic.cover] placeholderImage:[UIImage imageNamed:@"music"]];
    _listBottomView.titleLable.text = tempMusic.musicName;
}

# pragma mark - Tableview datasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _musics.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    Music *music = _musics[indexPath.row];
    ListCell *cell = [tableView dequeueReusableCellWithIdentifier:musicListCellId];
    [cell setMusicNumber:indexPath.row + 1];
    [cell setMusic:music];
    cell.state = NAKPlaybackIndicatorViewStateStopped;
    NSString *urlStr = music.cover;
    
    weakSELF;
    NSBlockOperation *download = [self.operations objectForKey:urlStr];
    if(!download) {
        download = [NSBlockOperation blockOperationWithBlock:^{
            NSURL *imageUrl = [NSURL URLWithString:urlStr];
            [cell.album sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"music"]];
            [weakSelf.operations removeObjectForKey:urlStr];
        }];
        [self.queue addOperation:download];
        [self.operations setObject:download forKey:urlStr];
    }
    return cell;
}

#pragma mark - Lazy load

- (ListBottomView*)ListBottomView{
    if (nil == _listBottomView) {
        _listBottomView = [[[NSBundle mainBundle] loadNibNamed:@"ListBottomView" owner:nil options:nil] lastObject];
        _listBottomView.backgroundColor = [UIColor clearColor];
    }
    return _listBottomView;
}
@end
