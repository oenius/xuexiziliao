//
//  DTMusicViewController.m
//  DataTansfer
//
//  Created by 何少博 on 17/6/5.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTMusicViewController.h"
#import "DTMusicViewModel.h"
#import "DTMusicPickerCell.h"
#import "UINavigationController+DT.h"
#import <SVProgressHUD.h>
@interface DTMusicViewController ()<UITableViewDelegate,UITableViewDataSource,AVAudioPlayerDelegate>

@property (nonatomic,strong) UITableView * tableView;

@property (nonatomic,strong) NSMutableArray * dataSource;

@property (nonatomic,strong)  AVAudioPlayer * player;

@property (nonatomic,strong) NSString * musicsDir;

@property (nonatomic,assign) NSUInteger playerCurrentIndex;

@end

static NSString * const kMusicViewControllerCellID = @"kMusicViewControllerCellID";

@implementation DTMusicViewController


-(NSString *)musicsDir{
    if (_musicsDir == nil) {
        _musicsDir = [DTConstAndLocal getMusicsDir];
    }
    return _musicsDir;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubViews];
    [self setupDataSource];
    self.playerCurrentIndex = -1;
    [self.navigationController clearUI];
    self.view.layer.contents = (__bridge id _Nullable)([UIImage imageNamed:@"bg"].CGImage);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:(UIBarButtonItemStylePlain) target:self action:@selector(back)];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [DTConstAndLocal showADRandom:5 forController:self];
}

-(void)setupSubViews{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:(UITableViewStyleGrouped)];
    [self.view addSubview:self.tableView];
    self.tableView.delegate= self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor clearColor];
    [self.tableView registerClass:[DTMusicPickerCell class] forCellReuseIdentifier:kMusicViewControllerCellID];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.bottom.equalTo(self.view.mas_bottom);
        make.right.equalTo(self.view.mas_right);
    }];
}

-(void)setupDataSource{
    NSString * msuicModelsDir= [DTConstAndLocal getMusicModelsDir];
    NSString * musicsDir = [DTConstAndLocal getMusicsDir];
    NSArray * modelsPaths =  [[NSFileManager defaultManager] subpathsAtPath:msuicModelsDir];
    NSMutableArray * temAry = [NSMutableArray array];
    NSMutableArray * cachesNames = [NSMutableArray array];
    NSMutableArray * deleteModelPaths = [NSMutableArray array];
    
    for (NSString * nameT in modelsPaths) {
        NSString * filePath = [msuicModelsDir stringByAppendingPathComponent:nameT];
        NSData * data = [NSData dataWithContentsOfFile:filePath];
        DTMusicModel * model = [data unarchiveObject];
        
        //判断音乐文件是否存在
        NSString * modelMusicPath = [musicsDir stringByAppendingPathComponent:model.fileUrlPath];
        if (![[NSFileManager defaultManager] fileExistsAtPath:modelMusicPath]) {
            [deleteModelPaths addObject:filePath];
            continue;
        }
        
        BOOL haveContain = NO;
        for (NSString * nameS in cachesNames ) {
            if ([nameS isEqualToString:model.fileUrlPath]) {
                haveContain = YES;
                break;
            }
        }
        if (!haveContain) {
            [cachesNames addObject:[model.fileUrlPath copy]];
            [temAry addObject:model];
        }else{
            [deleteModelPaths addObject:filePath];
        }
    }
    self.dataSource = temAry;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_apply(deleteModelPaths.count, queue, ^(size_t index) {
        NSString * path = deleteModelPaths[index];
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    });
}

-(void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DTMusicPickerCell *cell = [tableView dequeueReusableCellWithIdentifier:kMusicViewControllerCellID forIndexPath:indexPath];
    DTMusicModel * model = self.dataSource[indexPath.row];
    cell.model = model;
    cell.titleLabel.textColor = [UIColor whiteColor];
    cell.detailLabel.textColor = [UIColor whiteColor];
    UIView * vewi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    vewi.backgroundColor = [UIColor blackColor];
    cell.selectedBackgroundView = vewi;
    cell.showShare = YES;
    WEAKSELF_DT
    cell.shareBlock = ^(DTMusicModel * model){
        [weakSelf shareMusicAtIndexPath:indexPath model:model];
    };
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DTMusicModel * model = self.dataSource[indexPath.row];
    NSString * musicPath = [self.musicsDir stringByAppendingPathComponent:model.fileUrlPath];
    NSURL * url = [NSURL fileURLWithPath:musicPath];
    NSError * error;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    if (error) {return;}
    if ([self.player prepareToPlay]) {
        [self.player play];
        self.player.delegate = self;
        self.playerCurrentIndex = indexPath.row;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.playerCurrentIndex == indexPath.row) {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationNone)];
        return;
    }
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DTMusicModel * model = self.dataSource[indexPath.row];
        NSString * musicPath = [self.musicsDir stringByAppendingPathComponent:model.fileUrlPath];
        NSError * error;
        [[NSFileManager defaultManager]removeItemAtPath:musicPath error:&error];
        [self.tableView beginUpdates];
        LOG(@"%@",error);
        if (error == nil) {
            [self.dataSource removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationFade)];
        }else{
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationFade)];
        }
        [self.tableView endUpdates];
    }
}
#pragma mark - AVAudioPlayerDelegate

-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    if (flag) {
        self.playerCurrentIndex ++;
        self.playerCurrentIndex = self.playerCurrentIndex%self.dataSource.count;
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.playerCurrentIndex inSection:0];
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}
-(void)shareMusicAtIndexPath:(NSIndexPath *)indexPath model:(DTMusicModel *)model{
    
    NSString * musicPath = [self.musicsDir stringByAppendingPathComponent:model.fileUrlPath];
    NSString * name = [model.name stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString * tmpMusicPath = [NSTemporaryDirectory() stringByAppendingPathComponent:name];
    tmpMusicPath = [tmpMusicPath stringByAppendingString:@".caf"];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:tmpMusicPath]){
        [[NSFileManager defaultManager]removeItemAtPath:tmpMusicPath error:nil];
    }
    [SVProgressHUD show];
    NSError * error;
    NSURL *musicUrl = [NSURL fileURLWithPath:musicPath];
    NSURL *tmpMusicUrl = [NSURL fileURLWithPath:tmpMusicPath];
    [[NSFileManager defaultManager]copyItemAtURL:musicUrl toURL:tmpMusicUrl error:&error];
//    [[NSFileManager defaultManager] copyItemAtPath:musicPath toPath:tmpMusicPath error:&error];
    if (error) {
        [SVProgressHUD showErrorWithStatus:@""];
        [SVProgressHUD dismissWithDelay:1.5];
    }else{
        [SVProgressHUD dismiss];
        NSArray *activityItem = [NSArray arrayWithObject:[NSURL fileURLWithPath:tmpMusicPath]];
        UIActivityViewController *activity = [[UIActivityViewController alloc]
                                              initWithActivityItems:activityItem
                                              applicationActivities:nil];
        UIPopoverPresentationController *popoverVC = activity.popoverPresentationController;
        activity.completionWithItemsHandler = ^(UIActivityType  activityType, BOOL completed, NSArray *  returnedItems, NSError *  activityError){
            if([[NSFileManager defaultManager] fileExistsAtPath:tmpMusicPath]){
                [[NSFileManager defaultManager]removeItemAtPath:tmpMusicPath error:nil];
            }
            [DTConstAndLocal showADRandom:1 forController:self];
        };
        
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        if (popoverVC) {
            popoverVC.sourceView = cell.accessoryView;
            popoverVC.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        [self presentViewController:activity animated:YES completion:nil];
    }
    
}
-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-contentInsets.bottom);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [self.view setNeedsDisplay];
    }];
}
@end
