//
//  SNMindFileViewController.m
//  MindMap
//
//  Created by 何少博 on 2017/8/7.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNMindFileViewController.h"
#import "SNFileTableViewCell.h"
#import "SNMindFileViewModel.h"
#import "SNFileModel.h"
#import "SNTools.h"
#import "SNMindMapViewController.h"
#import "SNBaseNavigationController.h"
#import "SNCMFileBaseViewController.h"
#import "UIAlertController+SN.h"
#import "MBProgressHUD.h"
#import "SNNodeAsset.h"
#import "JXButton.h"
#import "DirectoryWatcher.h"
#import "SNSettingsViewController.h"
#import "NPCommonConfig+FeiFan.h"
#import "BaseViewController+FeiFan.h"
@interface SNMindFileViewController ()
<UITableViewDelegate,
UITableViewDataSource,
DirectoryWatcherDelegate,
SNMindFileViewModelDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayout;
@property (weak, nonatomic) IBOutlet JXButton *fuziButton;
@property (weak, nonatomic) IBOutlet JXButton *moveButton;
@property (weak, nonatomic) IBOutlet JXButton *deleteButton;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel1;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel2;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel3;
@property (weak, nonatomic) IBOutlet UILabel *tipLabel4;
@property (weak, nonatomic) IBOutlet UIView *tipView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipLable1Height;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tipViewHeight;

//@property (nonatomic, strong) DirectoryWatcher *dirWatcher;
@property (nonatomic, strong) UIBarButtonItem *selectAll;
@property (nonatomic, strong) UIBarButtonItem *myBack;
@property (nonatomic, strong) UIBarButtonItem *myAdd;
@property (nonatomic, strong) UIBarButtonItem *myEdit;
@property (nonatomic, strong) UIBarButtonItem *settingItem;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIBarButtonItem *cancelChange;
@property (nonatomic, strong)  NSMutableArray <NSIndexPath *>*currentSelectArry;
@property (nonatomic, strong) SNMindFileViewModel * viewModel;
@property (nonatomic, assign)  BOOL isRootController;
@property (nonatomic, assign) BOOL isGoMapBack;
@property (assign, nonatomic) BOOL isOnce;
@end

static NSString * kMindFileCellID = @"87368jubjv-ihp3r89gfb78hi";

@implementation SNMindFileViewController


-(void)dealloc{
//    [_dirWatcher invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"%s",__func__);
}

- (NSMutableArray <NSIndexPath *>*)currentSelectArry{
    if (!_currentSelectArry) {
        _currentSelectArry = [NSMutableArray new];
    }
    return _currentSelectArry;
}

-(SNMindFileViewModel *)viewModel{
    if (_viewModel == nil) {
        _viewModel = [[SNMindFileViewModel alloc]initWithPath:self.dirPath];
        _viewModel.delegate = self;
    }
    return _viewModel;
}

- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel  = [[UILabel alloc]init];
        _titleLabel.frame = CGRectMake(0, 0, 100, 40);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:20];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

#pragma mark - lifeCirle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isOnce = YES;
    
    if (self.dirPath == nil) {
        self.dirPath = [SNTools documentPath];
        self.isRootController = YES;
    }
//    self.dirWatcher = [DirectoryWatcher watchFolderWithPath:self.dirPath delegate:self];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateTableViewWithNoti:) name:kSNMindFilePathDidChangedNotification object:nil];
 
    [self setupItem];
    [self setupTableView];
    [self setupBottomView];
    [self closeTipView];
    [self setupTipLabel];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.viewModel.fileCount == 0) {
        [self showTipView];
    }
    if (_isOnce) {
        [self.viewModel startScanning];
        _isOnce = NO;
    }
    self.viewModel.canBackGroundSearch = YES;
    [[SNiCloudTool shareInstance] checkiCloudStatus];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (_isGoMapBack) {
        [SNTools showADRandom:2 forController:self];
        _isGoMapBack = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.viewModel.canBackGroundSearch = NO;
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
}

-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];

}


#pragma mark - initSet

-(void)setupTipLabel{
    self.tipLabel1.text = NSLocalizedString(@"create.map", @"创建思维导图");
    self.tipLabel2.text = NSLocalizedString(@"no_map", @"无思维导图文件");
    self.tipLabel3.text = NSLocalizedString(@"create.first.map", @"创建思维导图");
    self.tipLabel4.text = NSLocalizedString(@"new.map.tip", @"点击右上角"+"，创建文件");
}

-(void)setupItem{
    self.selectAll  = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"common.Select All", @"全选") style:UIBarButtonItemStylePlain target:self action:@selector(selectAllClick:)];
    self.myEdit  = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"edit"] style:UIBarButtonItemStylePlain target:self action:@selector(editItemClick:)];
    self.myAdd  = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"add"] style:UIBarButtonItemStylePlain target:self action:@selector(addItemClick:)];
    self.settingItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"set"] style:(UIBarButtonItemStylePlain) target:self action:@selector(settingItemClick:)];
    if (!self.isRootController) {
        self.myBack  = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"fanhui"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
        self.navigationItem.leftBarButtonItem = self.myBack;
    }else{
        self.navigationItem.leftBarButtonItem = self.settingItem;
    }
    
    self.navigationItem.rightBarButtonItems = @[_myAdd,_myEdit];
    self.navigationItem.titleView = self.titleLabel;
    if (_isRootController) {
        self.titleLabel.text = NSLocalizedString(@"MindMap", @"思维导图");
    }else{
        self.titleLabel.text = [self.dirPath lastPathComponent];
    }
    
}
-(void)setupTableView{
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];
    UINib * nib = [UINib nibWithNibName:NSStringFromClass([SNFileTableViewCell class]) bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:kMindFileCellID];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 50, 0);
}
#pragma mark - itemActions
- (void)back:(UIBarButtonItem *)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)selectAllClick:(UIBarButtonItem *)sender{
    NSString * cancelSelected = NSLocalizedString(@"cancel_select_all", @"取消全选");
    NSString * selected = NSLocalizedString(@"common.Select All", @"全选");
    
    if ([sender.title isEqualToString:selected]) {
        [sender setTitle: cancelSelected];
        [self.currentSelectArry removeAllObjects];
        for (int i = 0; i<self.viewModel.fileCount; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [_tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
            [self.currentSelectArry addObject:indexPath];
        }
    }
    else if ([sender.title isEqualToString:cancelSelected]) {
        [sender setTitle: selected];
        [self.currentSelectArry removeAllObjects];
        for (int i = 0; i<self.viewModel.fileCount; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
        }
    }
    
    [self changeTextSelectAndBottomViewStatu];
}

- (void)addItemClick:(UIBarButtonItem *)sender{
    UIAlertController * alertC = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"BG_common.New Album", @"新建") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction * cancle = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:(UIAlertActionStyleCancel)   handler:^(UIAlertAction * _Nonnull action) { }];
    
    UIAlertAction * newFile = [UIAlertAction actionWithTitle:NSLocalizedString(@"MindMap", @"思维导图") style:(UIAlertActionStyleDefault)   handler:^(UIAlertAction * _Nonnull action) {
        [self goMapViewController];
    }];
    UIAlertAction * newDir = [UIAlertAction actionWithTitle:NSLocalizedString(@"Create a new folder", @"新建文件夹") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self creatFolder];
        });
    }];
    [alertC addAction:newFile];
    [alertC addAction:newDir];
    [alertC addAction:cancle];
    
    UIPopoverPresentationController * popvc = alertC.popoverPresentationController;
    if (popvc) {
        popvc.barButtonItem = sender;
        popvc.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    [self presentViewController:alertC animated:YES completion:nil];
}


-(void)settingItemClick:(id) sender{
    SNSettingsViewController * set = [[SNSettingsViewController alloc]init];
    [self.navigationController pushViewController:set animated:YES];
}

- (void)editItemClick:(UIBarButtonItem *)sender{
    
    BOOL canEdit = [self.viewModel checkCanEidt];
    if (!canEdit) {
        [UIAlertController alertMessage:NSLocalizedString(@"pleaseSyn", @"含有未同步的文件，请现进行同步") controller:self okHandler:^(UIAlertAction *okAction) {
            
        }];
    }else{
        if (!self.tableView.editing) {
            if (self.vipBannerView != nil && self.vipBannerView.hidden == NO) {
                self.bottomLayout.constant = 50;
            }else{
               self.bottomLayout.constant = 0;
            }
            
            self.bottomView.hidden = NO;
            [self.tableView setEditing:YES animated:YES];
            [sender setTitle:NSLocalizedString(@"Cancel", @"取消编辑")];
            [sender setImage:nil];
            self.navigationItem.leftBarButtonItems  = @[_selectAll];
            self.navigationItem.rightBarButtonItems = @[_myEdit];
            NSString *choose = NSLocalizedString(@"Has chosen", @"已选择");
            self.titleLabel.text = [NSString stringWithFormat:@"%@:0",choose];
            [_selectAll setTitle:NSLocalizedString(@"common.Select All", @"全选")];
            self.bannerView.hidden = YES;
        }else{
            
            self.bottomLayout.constant = -50;
            self.bottomView.hidden = YES;
            [self.tableView setEditing:NO animated:YES];
            [sender setImage:[UIImage imageNamed:@"edit"]];
            [sender setTitle:nil];
            if (self.isRootController) {
                self.navigationItem.leftBarButtonItems  = @[self.settingItem];
            }else{
                self.navigationItem.leftBarButtonItems  = @[self.myBack];
            }
            self.navigationItem.rightBarButtonItems = @[_myAdd,_myEdit];
            if (_isRootController) {
                self.titleLabel.text = NSLocalizedString(@"MindMap", @"思维导图");
            }else{
                self.titleLabel.text = [self.dirPath lastPathComponent];
            }
            self.bannerView.hidden = NO;
        }
        
        [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
        
        [_currentSelectArry removeAllObjects];
    }
}

-(void)goMapViewController{
    UIStoryboard * st = [UIStoryboard storyboardWithName:@"Map" bundle:[NSBundle mainBundle]];
    SNMindMapViewController * map = [st instantiateInitialViewController];
    NSString * newAssetFilePath = [self.dirPath stringByAppendingFormat:@"/%@%@",NSLocalizedString(@"Untitled", @"未命名"),kAssetSuffix];
    map.assetFilePath = newAssetFilePath;
    map.isNewMap = YES;
    map.asset = [[SNNodeAsset alloc]initWithAssetPath:newAssetFilePath];
    map.fileViewModel = self.viewModel;
    _isGoMapBack = YES;
    SNBaseNavigationController * navi = [[SNBaseNavigationController alloc]initWithRootViewController:map];
    [self presentViewController:navi animated:YES completion:nil];
}
-(void)creatFolder{
    
    if (![[NPCommonConfig shareInstance] hasBuySubscription])
    {
        [[NPCommonConfig shareInstance] showVipViewControllerForController:self];
        return;
    }
    else
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Create a new folder", @"新建文件夹") message:@"" preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = NSLocalizedString(@"Please enter name", @"请输入名称");
        }];
        
        UIAlertAction *makeSure = [UIAlertAction actionWithTitle:NSLocalizedString(@"MakeSure", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UITextField *textFile = [alert.textFields firstObject];
            BOOL success = [self.viewModel creatNewFolderName:textFile.text parentDir:self.dirPath];
            if (success) {
                
            }
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:makeSure];
        [alert addAction:cancel];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    
}
#pragma mark - bottomBar operation

-(void)setupBottomView{
    self.bottomLayout.constant = - 50;
    self.bottomView.hidden = YES;
    [self.fuziButton setTitle:NSLocalizedString(@"Copy", @"复制") forState:(UIControlStateNormal)];
    [self.moveButton setTitle:NSLocalizedString(@"Move", @"移动") forState:(UIControlStateNormal)];
    [self.deleteButton setTitle:NSLocalizedString(@"common.Delete", @"删除") forState:(UIControlStateNormal)];
}

- (IBAction)copyFile{
    [self checkSelectedCountToActionClassName:@"SNCopyFileViewController"];
}

- (IBAction)moveFile{
    [self checkSelectedCountToActionClassName:@"SNMoveFileViewController"];
}
-(void)checkSelectedCountToActionClassName:(NSString *)className{
    if (self.currentSelectArry == nil || self.currentSelectArry.count < 1) {
        [UIAlertController alertMessage: NSLocalizedString(@"Please choose the file", @"请选择文件")  controller:self okHandler:^(UIAlertAction *okAction) {
            
        }];
    }else{
        Class class = NSClassFromString(className);
        SNCMFileBaseViewController * CMFileBase = [[class alloc]init];
        CMFileBase.fileArray = [self.viewModel getSelectedFilePath:self.currentSelectArry];
        CMFileBase.finishCallBack = ^(NSString *message) {
            [self runAsyncOnMainThread:^{
                if (self.tableView.editing == YES) {
                    [self editItemClick:self.myEdit];
                }
            }];
        };
        SNBaseNavigationController * navi = [[SNBaseNavigationController alloc]initWithRootViewController:CMFileBase];
        [self presentViewController:navi animated:YES completion:nil];
    }
}


- (void)renameFileAtIndexPath:(NSIndexPath *)indexPath{
    SNFileModel *model =  [self.viewModel modelAtIndexPath:indexPath]  ;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"gallery.Rename", @"重命名") message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = model.name;
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *makeSure = [UIAlertAction actionWithTitle:NSLocalizedString(@"MakeSure", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *textFiled = [alert.textFields firstObject];
        NSString * msg = [self.viewModel checkReName:textFiled.text];
        if (msg.length <= 0) {
            BOOL success = [self.viewModel renameAtIndexPath:indexPath name:textFiled.text];
            if (success) {
                [self updateTableViewCanResetDataSource:NO];
            }
        }else{
            [self runAsyncOnMainThread:^{
                MBProgressHUD * hud = [MBProgressHUD  showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = msg;
                [hud hideAnimated:YES afterDelay:1];
            }];
            
        }
    }];
    [alert addAction:cancel];
    [alert addAction:makeSure];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:alert animated:YES completion:nil];
    });
    
}

- (IBAction)deleteFile{
    if (self.currentSelectArry.count < 1) {
        [UIAlertController alertMessage:NSLocalizedString(@"Please choose the file", @"请选择文件") controller:self okHandler:^(UIAlertAction *okAction) {
            
        }];
    }else{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"layout_tips", @"提示") message:  NSLocalizedString(@"MY_dingyue.sure.delete", @"确定删除") preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *makeSure = [UIAlertAction actionWithTitle:NSLocalizedString(@"MakeSure", @"确定") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSString * msg = [self.viewModel deleteSelectedFile:self.currentSelectArry];
            if (msg.length <= 0) {
                UIWindow * window = [UIApplication sharedApplication].keyWindow;
                MBProgressHUD * hud = [MBProgressHUD  showHUDAddedTo:window animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = NSLocalizedString(@"gallery.family delete successful", @"删除成功");
                [hud hideAnimated:YES afterDelay:1];
                [self runAsyncOnMainThread:^{
                    if (self.tableView.editing == YES) {
                        [self editItemClick:self.myEdit];
                    }
                    [self updateTableViewCanResetDataSource:YES];
                }];
            }else{
                NSString * fail = NSLocalizedString(@"gallery.family delete failure", @"删除失败");
                NSString * message = [msg stringByAppendingFormat:@"  %@",fail];
                [UIAlertController alertMessage:message controller:self okHandler:^(UIAlertAction *okAction) {
                    [self updateTableViewCanResetDataSource:YES];
                }];
            }
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"取消") style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:cancel];
        [alert addAction:makeSure];
        [self presentViewController:alert animated:YES completion:nil];
    }
}





#pragma mark - tabelView deleaget datasouce

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.viewModel numberOfSectionsInTableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.viewModel numberOfRowsInSection:section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [SNFileTableViewCell cellHeight];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    SNFileTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kMindFileCellID];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    SNFileModel * model = [self.viewModel modelAtIndexPath:indexPath];
    cell.model = model;
    __weak SNMindFileViewController * weakSelf = self;
    cell.iCloudStatusBtnClickedBlock = ^(SNFileModel *cellModel) {
        if ([[SNiCloudTool shareInstance]canSynICloud]) {
            MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.label.text = NSLocalizedString(@"Syning",@"正在同步");
            if (cellModel.iCloudStatus == SNFileiCloudStatusNotDownload) {
                [weakSelf.viewModel startDownloadFileAtIndexPath:indexPath completed:^(BOOL success) {
                    [weakSelf runAsyncOnMainThread:^{
                        hud.mode = MBProgressHUDModeText;
                        if (success) {
                            NSLog(@"同步成功");
                            hud.label.text = NSLocalizedString(@"SynSuccess",@"同步成功");
                        }else{
                            NSLog(@"同步失败");
                            hud.label.text = NSLocalizedString(@"SynFaill",@"同步失败");
                        }
                        [hud hideAnimated:YES afterDelay:1];
                        [weakSelf updateTableViewCanResetDataSource:NO];
                        
                    }];
                }];
            }
            else if (cellModel.iCloudStatus == SNFileiCloudStatusNotUpload){
                [weakSelf.viewModel startUploadFileAtIndexPath:indexPath completed:^(BOOL success) {
                    [weakSelf runAsyncOnMainThread:^{
                        hud.mode = MBProgressHUDModeText;
                        if (success) {
                            NSLog(@"同步成功");
                            hud.label.text = NSLocalizedString(@"SynSuccess",@"同步成功");
                        }else{
                            NSLog(@"同步失败");
                            hud.label.text = NSLocalizedString(@"SynFaill",@"同步失败");
                        }
                        [hud hideAnimated:YES afterDelay:1];
                        [weakSelf updateTableViewCanResetDataSource:NO];
                    }];
                }];
            }

        }
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.tableView.editing) {
        [self.currentSelectArry addObject:indexPath];
        [self changeTextSelectAndBottomViewStatu];
    }else{
        SNFileModel *model  = [self.viewModel modelAtIndexPath:indexPath];
        
        if (model.iCloudStatus == SNFileiCloudStatusNotDownload) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        if (model.fileType == SNFileTypeFolder) {
            UIStoryboard * stroy = [UIStoryboard storyboardWithName:@"MindFile" bundle:[NSBundle mainBundle]];
            SNMindFileViewController *mindfile = stroy.instantiateInitialViewController;
            mindfile.dirPath = model.filePath;
            [self.navigationController pushViewController:mindfile animated:YES];
        }else if (model.fileType == SNFileTypeMindMap){
            UIStoryboard * stroy = [UIStoryboard storyboardWithName:@"Map" bundle:[NSBundle mainBundle]];
            SNMindMapViewController *Map = stroy.instantiateInitialViewController;
            Map.assetFilePath = model.filePath;
            Map.isNewMap = NO;
            Map.asset = model.nodeAsset;
            Map.fileViewModel = self.viewModel;
            MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSArray * nodes = [model.nodeAsset load];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (nodes == nil || nodes.count == 0) {
                        hud.label.text = NSLocalizedString(@"MindMapLoadFaill", @"思维导图加载失败");
                        [hud hideAnimated:YES afterDelay:1];
                    }else{
                        [hud hideAnimated:YES];
                        Map.mainNodes = [NSMutableArray arrayWithArray:nodes];
                        _isGoMapBack = YES;
                        SNBaseNavigationController * navi = [[SNBaseNavigationController alloc]initWithRootViewController:Map];
                        [self presentViewController:navi animated:YES completion:nil];
                    }
                });
            });
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}



- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.currentSelectArry removeObject:indexPath];
    [self changeTextSelectAndBottomViewStatu];
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    SNFileModel *model = [self.viewModel modelAtIndexPath:indexPath];
    if (model.iCloudStatus == SNFileiCloudStatusNotDownload) {
        return NO;
    }
    return YES;
}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewRowAction * reNameAc = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:NSLocalizedString(@"gallery.Rename", @"重命名") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self renameFileAtIndexPath:indexPath];
    }];
    return @[reNameAc];
}


- (void)changeTextSelectAndBottomViewStatu{
    NSString * choose = NSLocalizedString(@"Has chosen", @"已选择");
    self.titleLabel.text = [NSString stringWithFormat:@"%@:%ld",choose,(long)self.currentSelectArry.count];
 
    if (!self.tableView.editing) {
        if (_isRootController) {
            self.titleLabel.text = NSLocalizedString(@"MindMap", @"思维导图");
        }else{
            self.titleLabel.text = [self.dirPath lastPathComponent];
        }
    }else{
        if (self.currentSelectArry.count < self.viewModel.fileCount) {
            NSString * selected = NSLocalizedString(@"common.Select All", @"全选");
            [self.selectAll setTitle: selected];
        }else{
            NSString * cancelSelected = NSLocalizedString(@"cancel_select_all", @"取消全选");
            [self.selectAll setTitle: cancelSelected];
        }
    }
}

-(void)removeAdNotification:(NSNotification *)notification{
    [super removeAdNotification:notification];
    [self.viewModel startScanning];
}

-(void)directoryDidChange:(DirectoryWatcher *)folderWatcher{
  
//    [[NSNotificationCenter defaultCenter] postNotificationName:kSNMindFilePathDidChangedNotification object:nil];
}


#pragma mark - SNMindFileViewModelDelegate

-(void)didRetrieveCloud{
    
   [self updateTableViewCanResetDataSource:YES];
}

-(void)saveMapSuccess{
    [self updateTableViewCanResetDataSource:NO];
    
}

-(void)updateTableViewWithNoti:(NSNotification *)noti{
    [self updateTableViewCanResetDataSource:YES];
}

- (void)updateTableViewCanResetDataSource:(BOOL)reset{
    [self runAsyncOnMainThread:^{
        [self.currentSelectArry removeAllObjects];
        if (reset) {
            [self.viewModel reloaData];
        }
        [self.tableView reloadData];
        [self changeTextSelectAndBottomViewStatu];
        if (self.viewModel.fileCount == 0) {
            if (self.tableView.editing == YES) {
                [self editItemClick:self.myEdit];
            }
            [self showTipView];
        }else{
            [self closeTipView];
        }
    }];
}

-(void)showTipView{
    if (_isRootController) {
        self.tipView.hidden = NO;
        self.tipLabel1.hidden = NO;
        self.tipLabel2.hidden = NO;
        self.tipLabel3.hidden = NO;
        self.tipLabel4.hidden = NO;
        self.tipViewHeight.constant = 40;
        self.tipViewHeight.constant = self.view.bounds.size.height;
    }
    
}
-(void)closeTipView{
    self.tipView.hidden = YES;
    self.tipLabel1.hidden = YES;
    self.tipLabel2.hidden = YES;
    self.tipLabel3.hidden = YES;
    self.tipLabel4.hidden = YES;
    self.tipViewHeight.constant = 0;
    self.tipViewHeight.constant = 0;
    
}








@end
