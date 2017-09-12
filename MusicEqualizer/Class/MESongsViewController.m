//
//  MESongsViewController.m
//  MusicEqualizer
//
//  Created by 何少博 on 16/12/26.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "MESongsViewController.h"
#import "MESongsTableViewCell.h"
#import "MESongsViewModel.h"
#import "MEUserDefaultManager.h"
#import "MEAudioPlayer.h"
#import "MEEqualizerViewController.h"
#import "MBProgressHUD.h"
#import "MEAddMusicToListChooseView.h"
#import "MEPlayControlView.h"
#import "DirectoryWatcher.h"
#import "UIColor+x.h"
#import "UIDevice+x.h"
#import "NPCommonConfig.h"
#import "NPGoProButton.h"
@interface MESongsViewController () <UITableViewDelegate,UITableViewDataSource,DirectoryWatcherDelegate>

@property (weak, nonatomic) IBOutlet UIButton *refreshListBtn;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet MEPlayControlView *playControlView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (weak,nonatomic) MEAudioPlayer *player;

@property (strong, nonatomic) MESongsViewModel * viewModel;

@property (strong, nonatomic) NSMutableArray * selectedIndexPaths;

@property (strong,nonatomic) UIView * maskView;

@property (strong,nonatomic)MEAddMusicToListChooseView * listChooseView;

@property (assign,nonatomic) MPMediaLibraryAuthorizationStatus mediaAuthorizationStatus;

@property (strong,nonatomic) DirectoryWatcher * dirWatcher;

//@property (assign,)

@end

static NSString * songsCellID = @"songsCellID";

@implementation MESongsViewController

#pragma mark - 懒加载

-(NSMutableArray *)selectedIndexPaths{
    if (nil == _selectedIndexPaths) {
        _selectedIndexPaths = [NSMutableArray array];
    }
    return _selectedIndexPaths;
}
-(MESongsViewModel *)viewModel{
    if (_viewModel == nil) {
        _viewModel = [[MESongsViewModel alloc]init];
    }
    return _viewModel;
}

-(MEAudioPlayer *)player{
    if (nil == _player) {
        _player = [MEAudioPlayer defaultPlayer];
        _player.playModel = [[MEUserDefaultManager defaultManager] getPlayModel];
    }
    return _player;
}

#pragma mark - 视图相关

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.refreshListBtn setTitle:MEL_iPodSyn forState:UIControlStateNormal];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = self.tabBarItem.title;
    [self setupTableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enterBackgroundNotificatioin:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    __weak typeof(self) weakSelf = self;
    [self.playControlView viewTapCallBack:^(BOOL isTap) {
        if (weakSelf.player.musicList<=0) {
            return ;
        }
        MEEqualizerViewController * eqVC = [[MEEqualizerViewController alloc]initWithNibName:@"MEEqualizerViewController" bundle:[NSBundle mainBundle] player:self.player];
        UINavigationController * navi = [[UINavigationController alloc]initWithRootViewController:eqVC];
        [weakSelf presentViewController:navi animated:YES completion:nil];
    }];
    
    self.refreshListBtn.layer.borderColor = [UIColor colorWithHexString:@"a20707"].CGColor;
    self.refreshListBtn.layer.borderWidth = 2;
    self.refreshListBtn.layer.cornerRadius = 5;
    self.refreshListBtn.layer.masksToBounds = YES;
    
    NSString * docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    self.dirWatcher = [DirectoryWatcher watchFolderWithPath:docPath delegate:self];

    BOOL shouldShowAd = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    if (shouldShowAd) {
         self.interstitialButton = [NPInterstitialButton buttonWithType:NPInterstitialButtonTypeIcon viewController:self];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.interstitialButton];
        NPGoProButton * goPro = [NPGoProButton goProButton];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:goPro];
        
    }

}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.viewModel resetMusicEditState];
    [self.selectedIndexPaths removeAllObjects];
    [self.tableView reloadData];
    
    //获得媒体库授权状态
    if ([UIDevice systemVersionGreaterThan9_3]) {
        self.mediaAuthorizationStatus = [MPMediaLibrary authorizationStatus];
        if (self.mediaAuthorizationStatus == MPMediaLibraryAuthorizationStatusNotDetermined) {
            [self accessMediaAuthorization];
        }
    }
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if ([[NPCommonConfig shareInstance] shouldShowAdvertise]) {
        BOOL showAD = [[MEUserDefaultManager defaultManager] isShouldShowAD];
        if (showAD) {
            [[NPCommonConfig shareInstance] showFullScreenAdWithNativeAdAlertViewForController:self];
        }
    }
    
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    self.bottomConstraint.constant = contentInsets.bottom;
    
}
-(void)removeAdNotification:(NSNotification *)notification{
    [super removeAdNotification:notification];
    self.navigationItem.leftBarButtonItem = nil;
}

-(void)setupTableView{
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 0.1)];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 0.1)];
    self.tableView.sectionFooterHeight = 0;
    UINib * cellNib = [UINib nibWithNibName:[MESongsTableViewCell className] bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:songsCellID];
    self.tableView.separatorColor  = [UIColor colorWithHexString:@"383838"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

#pragma mark - button actions

- (IBAction)refreshListBtnClick:(UIButton *)sender {

    [self.selectedIndexPaths removeAllObjects];
    [self.viewModel refreshiPod];
    [self.viewModel refreshDocument];
    [self.viewModel resetMusicEditState];
    self.viewModel = nil;
    [self.tableView reloadData];
    [self.player reset];
    [self.playControlView reset];

    if ([UIDevice systemVersionGreaterThan9_3]) {
        self.mediaAuthorizationStatus = [MPMediaLibrary authorizationStatus];
        if (self.mediaAuthorizationStatus == MPMediaLibraryAuthorizationStatusDenied ||
            self.mediaAuthorizationStatus == MPMediaLibraryAuthorizationStatusRestricted) {
            [self remindToSetMediaAuthorizationStatus];
        }
    }else{
        MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = MEL_RefreshedSuccessfully;
        [hud hideAnimated:YES afterDelay:1.5f];
    }
    
    
}

#pragma  mark - UITableViewDelegate  UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.viewModel numberOfSectionsInTableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.viewModel numberOfRowsInSection:section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.selectedIndexPaths containsObject:indexPath]) {
        return cellActiveHeight;
    }
    return cellDefaultHeight;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MESongsTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:songsCellID];
    if (cell == nil) {
        cell = [[MESongsTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:songsCellID];
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



#pragma mark - cellActions

-(void)musicNotExistenceRemind{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:MEL_Prompt message:MEL_NotExist preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction * ok = [UIAlertAction actionWithTitle:MEL_OK style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:ok];
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)fillCellInformation:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath{
    MESongsTableViewCell * songsCell =  (MESongsTableViewCell *)cell;
    MEMusic * musicModel = [self.viewModel getMusicModelAtIndexPath:indexPath];
    songsCell.musicModel = musicModel;
    __weak typeof(self) weakSelf = self;
    [songsCell cellActionsCallBackBlock:^(MESongsCellActionType actionType, UITableViewCell *cell) {
        LOG(@"MESongsCellActionType:%lu",(unsigned long)actionType);
        [weakSelf dealWithCell:(MESongsTableViewCell*)cell action:actionType music:musicModel atIndexPath:indexPath];
    }];
}

-(void)dealWithCell:(MESongsTableViewCell*)cell action:(MESongsCellActionType)type music:(MEMusic *)musicModel atIndexPath:(NSIndexPath *)indexPath{

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
                [self.viewModel removeMusicFromFavorite:musicModel];
                [cell setIsFavorive:NO];
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
                [self.selectedIndexPaths removeAllObjects];;
                [self.player checkMusicList];
                [self.viewModel resetMusicEditState];
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
//#pragma mark - 媒体库授权状态
//
//-(void)checkMediaAuthorizationStatus{
//    
//    switch (_mediaAuthorizationStatus) {
//        case MPMediaLibraryAuthorizationStatusNotDetermined:
//            [self accessMediaAuthorization];
//            break;
//        case MPMediaLibraryAuthorizationStatusDenied:
//        case MPMediaLibraryAuthorizationStatusRestricted:
//            [self remindToSetMediaAuthorizationStatus];
//            break;
//        case MPMediaLibraryAuthorizationStatusAuthorized:
//            break;
//        default:
//            break;
//    }
//
//}

-(void)remindToSetMediaAuthorizationStatus{
    NSString * message = [NSString stringWithFormat:@"%@,%@",MEL_AuthorizationFailed,MEL_SetToAuthorization];
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:MEL_Prompt message:message preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction * setting = [UIAlertAction actionWithTitle:MEL_setting style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        NSURL * Url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if([[UIApplication sharedApplication] canOpenURL:Url]) {
            [[UIApplication sharedApplication] openURL:Url];
        }
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:MEL_Cancel style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:cancel];
    [alertController addAction:setting];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)accessMediaAuthorization{
    if (![UIDevice systemVersionGreaterThan9_3]) { return; }
    [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
        switch (status) {
            case MPMediaLibraryAuthorizationStatusNotDetermined:
                LOG(@"未决定");
                break;
            case MPMediaLibraryAuthorizationStatusDenied:
            case MPMediaLibraryAuthorizationStatusRestricted:
                self.mediaAuthorizationStatus = MPMediaLibraryAuthorizationStatusDenied;
                break;
            case MPMediaLibraryAuthorizationStatusAuthorized:
            {
                self.viewModel = nil;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView reloadData];
                });
            }
                break;
            default:
                break;
        }
    }];
}


#pragma mark - 通知,DirectoryWatcherDelegate

-(void)directoryDidChange:(DirectoryWatcher *)folderWatcher{
    
    [self.viewModel resetMusicEditState];
    [self.selectedIndexPaths removeAllObjects];
    [self.viewModel refreshDocument];
    self.viewModel = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
    
}

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
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
