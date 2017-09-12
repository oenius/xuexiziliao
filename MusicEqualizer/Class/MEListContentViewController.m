//
//  MEListContentViewController.m
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/3.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "MEListContentViewController.h"
#import "MEMusicChooseViewController.h"
#import "MEEqualizerViewController.h"
#import "MEAddMusicToListChooseView.h"
#import "MESongsTableViewCell.h"
#import "MEListContentViewModel.h"
#import "MEUserDefaultManager.h"
#import "MEAudioPlayer.h"
#import "MBProgressHUD.h"
#import "MEList.h"
#import "UIColor+x.h"
#import "NPCommonConfig.h"
@interface MEListContentViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *addMusicBtn;

@property (strong,nonatomic) MEList * musicList;

@property (strong,nonatomic) MEListContentViewModel * viewModel;

@property (strong, nonatomic) NSMutableArray * selectedIndexPaths;

@property (weak,nonatomic) MEAudioPlayer * player;

@property (nonatomic,strong) UIRefreshControl * refreshControl;

@property (strong,nonatomic) UIView * maskView;

@property (strong,nonatomic)MEAddMusicToListChooseView * listChooseView;

@end

NSString * const listContentTableViewCellID  = @"ListContentTableViewCell";

@implementation MEListContentViewController

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andmusicList:(MEList *)list{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.musicList = list;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.navigationItem.title = ([self.musicList.name isEqualToString:@"myFavorite"])?MEL_MyFavorite:self.musicList.name;
    [self setupAddMusicBtn];
    [self setupTableView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackgroundNotificatioin:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [self.addMusicBtn setTitle:MEL_AddMusic forState:UIControlStateNormal];
    
    BOOL shouldShowAd = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    if (shouldShowAd) {
        self.interstitialButton = [NPInterstitialButton buttonWithType:NPInterstitialButtonTypeIcon viewController:self];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.interstitialButton];
    }
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.tableView) {
        self.viewModel = nil;
        [self.tableView reloadData];
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.viewModel resetMusicEditState];
    [self.selectedIndexPaths removeAllObjects];
    [self.tableView reloadData];
}
-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    self.tableView.contentInset = contentInsets;
}

#pragma mark - 懒加载

-(UIRefreshControl *)refreshControl{
    if (nil == _refreshControl) {
        _refreshControl = [[UIRefreshControl alloc]init];
        
        [self.tableView addSubview:_refreshControl];
    }
    return _refreshControl;
}

-(MEAudioPlayer *)player{
    if (nil == _player) {
        _player  = [MEAudioPlayer defaultPlayer];
        _player.playModel = [[MEUserDefaultManager defaultManager] getPlayModel];
    }
    return _player;
}

-(NSMutableArray *)selectedIndexPaths{
    if (nil == _selectedIndexPaths) {
        _selectedIndexPaths = [NSMutableArray array];
    }
    return _selectedIndexPaths;
}

-(MEListContentViewModel *)viewModel{
    if (nil == _viewModel) {
        _viewModel = [[MEListContentViewModel alloc]initWithMusicList:self.musicList];;
    }
    return _viewModel;
}

#pragma mark - 初始化

-(void)setupAddMusicBtn{
    [self.addMusicBtn setTitleColor:[UIColor colorWithHexString:@"a20707"] forState:UIControlStateNormal];
    self.addMusicBtn.layer.borderColor = [UIColor colorWithHexString:@"a20707"].CGColor;
    self.addMusicBtn.layer.borderWidth = 2;
    self.addMusicBtn.layer.cornerRadius = 5;
    self.addMusicBtn.layer.masksToBounds = YES;
}

-(void)setupTableView{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UINib * nib = [UINib nibWithNibName:NSStringFromClass([MESongsTableViewCell class]) bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:listContentTableViewCellID];
    [self.refreshControl addTarget:self action:@selector(refreshTableView:) forControlEvents:UIControlEventValueChanged];
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 0.1)];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 0.1)];
    self.tableView.sectionFooterHeight = 0;
    self.tableView.separatorColor  = [UIColor colorWithHexString:@"666464"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

#pragma mark - actions

- (IBAction)addMusicBtnClick:(UIButton *)sender {
    MEMusicChooseViewController * choose = [[MEMusicChooseViewController alloc]initWithNibName:NSStringFromClass([MEMusicChooseViewController class]) bundle:[NSBundle mainBundle] andmusicList:self.musicList];
    UINavigationController * navi = [[UINavigationController alloc]initWithRootViewController:choose];
    
    __weak typeof(self) wealSelf = self;
    [choose musicChooseCallBack:^(NSArray *array) {
        [wealSelf.viewModel checkMusicModelArray:array];
        dispatch_async(dispatch_get_main_queue(), ^{
            [wealSelf.tableView reloadData];
        });
    }];
    
    [self presentViewController:navi animated:YES completion:nil];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.selectedIndexPaths containsObject:indexPath]) {
        return cellActiveHeight;
    }
    return cellDefaultHeight;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.viewModel numberOfSectionsInTableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.viewModel numberOfRowsInSection:section];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MESongsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:listContentTableViewCellID];
    if (nil == cell) {
        cell = [[MESongsTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:listContentTableViewCellID];
    }
    [self fillCellInformation:cell indexPath:indexPath];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MEMusic * musicModel = [self.viewModel getMusicModelAtIndexPath:indexPath];
    BOOL isExist = [self.player checkMusicExistence:musicModel];
    if (!isExist) {
        [self musicNotExistenceRemind];
        return;
    }
    NSURL * musicUrl = [self.viewModel fixMusicModelUrl:musicModel];
    MEEqualizer * equalizer = [self.viewModel getCurrentEQ];
    if (musicUrl == nil) {
        return;
    }
    BOOL isSomeMusic = [musicModel.describe isEqualToString:self.player.currentMusic.describe];
    NSTimeInterval time = self.player.currentTime;
    [self.player playWithUrl:musicUrl music:musicModel];
    [self.player setEqualizer:equalizer];
    if (isSomeMusic) {
        [self.player setPlayTime:time];
    }
    NSArray * allMusicModel = [self.viewModel getAllMusicModel];
    [self.player setMusicList:allMusicModel andIndex:indexPath.row];
    MEEqualizerViewController * eqVC = [[MEEqualizerViewController alloc]initWithNibName:@"MEEqualizerViewController" bundle:[NSBundle mainBundle] player:self.player];
    UINavigationController * navi = [[UINavigationController alloc]initWithRootViewController:eqVC];
    [self presentViewController:navi animated:YES completion:nil];
}

-(void)fillCellInformation:(MESongsTableViewCell *)cell indexPath:(NSIndexPath *)indexPath{
    MEMusic * musicModel = [self.viewModel getMusicModelAtIndexPath:(NSIndexPath *)indexPath];
    cell.musicModel = musicModel;
    __weak typeof(self) weakSelf = self;
    [cell cellActionsCallBackBlock:^(MESongsCellActionType actionType, UITableViewCell *cell) {
        LOG(@"MESongsCellActionType:%lu",(unsigned long)actionType);
        [weakSelf dealWithCell:(MESongsTableViewCell *)cell action:actionType music:musicModel atIndexPath:indexPath];
    }];

}

-(void)dealWithCell:(MESongsTableViewCell *)cell action:(MESongsCellActionType)type music:(MEMusic *)musicModel atIndexPath:(NSIndexPath *)indexPath{
    
    switch (type) {
        case MESongsCellActionTypeDetail:
        {
            if ([self.selectedIndexPaths containsObject:indexPath]) {
                [self.selectedIndexPaths removeObject:indexPath];
                musicModel.isEditState = NO;
            }else{
                [self.selectedIndexPaths addObject:indexPath];
                musicModel.isEditState = YES;
            }
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
            break;
        case MESongsCellActionTypeFavorite:
        {
            if (musicModel.isFavorite == YES) {
                if ([self.musicList.name isEqualToString:@"myFavorite"]) {
                    return;
                }else{
                    [self.viewModel removeMusicFromFavorite:musicModel];
                    [cell setIsFavorive:NO];
                }
            }else{
                [self.viewModel addMusicToFavorite:musicModel];
                [cell setIsFavorive:YES];
                MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = MEL_Add_Success;
                [hud hideAnimated:YES afterDelay:1.5f];
            }
        }
            break;
        case MESongsCellActionTypeAddToList:
        {
            [self cellAddToListAction:musicModel];
        }
            break;
        case MESongsCellActionTypeNextPlay:
        {
            BOOL success = (self.player.musicList.count > 0);
            NSString * message = [NSString stringWithFormat:@"%@ %@",MEL_none,MEL_Playlists];
            if (success) {
                message = MEL_Add_Success;
                [self.player insertMusicPlayAtNext:musicModel];
            }
            MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = message;
            [hud hideAnimated:YES afterDelay:1.5f];
            
        }
            break;
        case MESongsCellActionTypeDelete:
        {
            MEMusic * music = [self.viewModel getMusicModelAtIndexPath:indexPath];
            if ([self.player.currentMusic.describe isEqualToString:music.describe]) {
                MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = MEL_NowPlaying;
                [hud hideAnimated:YES afterDelay:1.5f];
            }else{
                [self.viewModel deleteMusicAtIndexPath:indexPath];
                [self.selectedIndexPaths removeAllObjects];
                [self.viewModel resetMusicEditState]   ;        
                [self.player checkMusicList];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
        }
            break;
        default:
            break;
    }
}

-(void)cellAddToListAction:(MEMusic *)music{
    if (self.maskView||self.listChooseView) {
        [self.maskView removeFromSuperview];
        self.maskView = nil;
        [self.listChooseView removeFromSuperview];
        self.listChooseView = nil;
    }
    self.maskView = [[UIView alloc]initWithFrame:self.view.bounds];
    self.maskView.backgroundColor = [UIColor clearColor];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeListChooseView)];
    [self.maskView addGestureRecognizer:tap];
    [self.view addSubview:self.maskView];
    
    CGFloat selfWidth = self.view.bounds.size.width;
    CGFloat selfHeight = self.view.bounds.size.height;
    CGRect oldFrame = CGRectMake(0, selfHeight, selfWidth, selfHeight/2);
    __weak typeof(self) weakSelf = self;
    self.listChooseView = [[MEAddMusicToListChooseView alloc]initWithFrame:oldFrame chooseMusicCallBack:^(MEList *list) {
        if (list) {
            
            [weakSelf.viewModel addMusic:music toList:list];
            MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = MEL_Add_Success;
            [hud hideAnimated:YES afterDelay:1.5f];
        }
        [weakSelf removeListChooseView];
    }];
    [self.view addSubview:_listChooseView];
    CGRect newFrame = CGRectMake(0, selfHeight/2, selfWidth, selfHeight/2);
    [UIView animateWithDuration:0.25 animations:^{
        _listChooseView.frame = newFrame;
    }];
}

-(void)removeListChooseView{
    if (self.listChooseView) {
        [self.maskView removeFromSuperview];
        self.maskView = nil;
        CGFloat selfWidth = self.view.bounds.size.width;
        CGFloat selfHeight = self.view.bounds.size.height;
        CGRect newFrame = CGRectMake(0, selfHeight, selfWidth, selfHeight/2);
        
        [UIView animateWithDuration:0.25 animations:^{
            self.listChooseView.frame = newFrame;
        } completion:^(BOOL finished) {
            [self.listChooseView removeFromSuperview];
            self.listChooseView = nil;
        }];
    }
}
-(void)musicNotExistenceRemind{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:MEL_Prompt message:MEL_NotExist preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:MEL_OK style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark - tableView刷新
-(void)refreshTableView:(UIRefreshControl *)sender{
    self.viewModel = nil;
    [self.tableView reloadData];
    [sender endRefreshing];
}

#pragma mark - 通知
-(void)becomeActiveNotification:(NSNotification *)noti{
//    [self.viewModel resetMusicEditState];
//    [self.selectedIndexPaths removeAllObjects];
//    [self.tableView reloadData];
}

-(void)enterBackgroundNotificatioin:(NSNotification *)noti{
    [self.viewModel resetMusicEditState];
    [self.selectedIndexPaths removeAllObjects];
    [self.tableView reloadData];
}

@end
