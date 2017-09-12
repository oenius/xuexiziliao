//
//  MEMusicListViewController.m
//  MusicEqualizer
//
//  Created by 何少博 on 16/12/26.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "MEMusicListViewController.h"
#import "MEMusicListViewModel.h"
#import "MEMusicListTableViewCell.h"
#import "MEListContentViewController.h"
#import "UIColor+x.h"
#import "MEList.h"
#import "NPCommonConfig.h"
typedef enum : NSUInteger {
    MEAlertStyleRename,
    MEAlertStyleAddList,
} MEAlertStyle;

static const CGFloat addBtnBottomDefault = 5;


@interface MEMusicListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIButton *addListBtn;

@property (strong,nonatomic) MEMusicListViewModel * viewModel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addBtnBottom;

@end

static NSString * musicListTabelViewCellID = @"musicListTabelViewCell";

@implementation MEMusicListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = self.tabBarItem.title;
    [self setupNaviItem];
    [self setupTableView];
    BOOL shouldShowAd = [[NPCommonConfig shareInstance] shouldShowAdvertise];
    if (shouldShowAd) {
        self.interstitialButton = [NPInterstitialButton buttonWithType:NPInterstitialButtonTypeIcon viewController:self];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.interstitialButton];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.addListBtn.layer.cornerRadius = self.addListBtn.bounds.size.width/2;
    self.addListBtn.layer.masksToBounds = YES;
}
#pragma mark - 懒加载

-(MEMusicListViewModel *)viewModel{
    if (nil == _viewModel) {
        _viewModel = [MEMusicListViewModel new];
    }
    return _viewModel;
}

#pragma mark - 初始化

-(void)setupNaviItem{
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"排序" style:UIBarButtonItemStylePlain target:self action:@selector(orderItemClick:)];
}

-(void)setupTableView{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UINib * nib = [UINib nibWithNibName:NSStringFromClass([MEMusicListTableViewCell class]) bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:musicListTabelViewCellID];
    self.tableView.separatorColor  = [UIColor colorWithHexString:@"666464"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - 广告

-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    self.addBtnBottom.constant = addBtnBottomDefault + contentInsets.bottom;
}


#pragma mark - actions

- (IBAction)addListBtnClick:(UIButton *)sender {
    [self remindAlertWithStyle:MEAlertStyleAddList atIndexPath:nil];
}

-(void)orderItemClick:(UIBarButtonItem * )sender{
    
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.viewModel numberOfSectionsInTableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.viewModel numberOfRowsInSection:section];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MEMusicListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:musicListTabelViewCellID];
    if (nil == cell) {
        cell = [[MEMusicListTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:musicListTabelViewCellID];
    }

    [self fillCellInformation:cell indexPath:indexPath];
    
    return cell;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.viewModel canEditRowAtIndexPath:indexPath];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MEList * list = [self.viewModel getMusicListModelAtIndexPath:indexPath];
    MEListContentViewController * listContentController = [[MEListContentViewController alloc]initWithNibName:NSStringFromClass([MEListContentViewController class]) bundle:[NSBundle mainBundle] andmusicList:list];
    [self.navigationController pushViewController:listContentController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    editingStyle = UITableViewCellEditingStyleDelete;
}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    __weak typeof(self) weakSelf = self;
    
    UITableViewRowAction * delete  = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:MEL_Delete handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakSelf.viewModel deleteMusicListAtIndexPath:indexPath];
        [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
    }];
    
    UITableViewRowAction * newName  = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:MEL_Rename handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [weakSelf remindAlertWithStyle:MEAlertStyleRename atIndexPath:indexPath];
    }];
    delete.backgroundColor = [UIColor colorWithHexString:@"a20707"];
    newName.backgroundColor = [UIColor colorWithHexString:@"a20707"];
    return @[delete,newName];
}

-(void)fillCellInformation:(MEMusicListTableViewCell *)cell indexPath:(NSIndexPath *)indexPath{
    MEList * listModel = [self.viewModel getMusicListModelAtIndexPath:indexPath];
    cell.listModel = listModel;

    
    //其他相关设置
}
#pragma mark - Alerts提示相关

-(void)remindAlertWithStyle:(MEAlertStyle)alertStyle atIndexPath:(NSIndexPath *)indexPath{
    
    NSString * title;
    NSString * messge = MEL_EnterName;
    NSString * placeHolder = messge;
    
    if (MEAlertStyleRename == alertStyle) {
        title = MEL_Rename;
    }
    else if (MEAlertStyleAddList == alertStyle){
        title = MEL_Add;
    }
    
    __weak typeof(self) weakSelf = self;
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:messge preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:MEL_Cancel style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
    
    UIAlertAction * OK = [UIAlertAction actionWithTitle:MEL_OK style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField * textField = alertController.textFields.firstObject;
        if(nil == textField.text || textField.text.length == 0){
            [weakSelf newNameCannotBeNil];
            return ;
        }else{
            if (MEAlertStyleRename == alertStyle) {
                [weakSelf.viewModel renameMusicListName:textField.text atIndexPath:indexPath];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                });
            }
            else if (MEAlertStyleAddList == alertStyle){
                [weakSelf.viewModel insertMusicListWithName:textField.text];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.tableView reloadData];
                });
            }
        }
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = placeHolder;
    }];
    [alertController addAction:cancel];
    [alertController addAction:OK];
    [self presentViewController:alertController animated:YES completion:nil];
}
//字符串为空的提示
-(void)newNameCannotBeNil{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:MEL_Prompt message:MEL_NotBeNull preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * ok = [UIAlertAction actionWithTitle:MEL_OK style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
