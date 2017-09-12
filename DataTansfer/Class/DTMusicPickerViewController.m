//
//  DTMusicPickerViewController.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/19.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTMusicPickerViewController.h"
#import "DTMusicPickerCell.h"
@interface DTMusicPickerViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *tableView;

@property (strong,nonatomic) NSMutableArray * selectedIndexPaths;

@end


static NSString * const  kMucsicPickerCellID = @"kMucsicPickerCellID";

@implementation DTMusicPickerViewController





#pragma mark - 懒加载

-(NSMutableArray *)selectedIndexPaths{
    if (nil == _selectedIndexPaths) {
        _selectedIndexPaths = [NSMutableArray new];
    }
    return _selectedIndexPaths;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout  = UIRectEdgeNone;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:[DTConstAndLocal done] style:UIBarButtonItemStylePlain target:self action:@selector(doneItemClick)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:[DTConstAndLocal quanxuan] style:UIBarButtonItemStylePlain target:self action:@selector(selectorAllItemClick:)];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"08c364"];
    self.view.layer.contents  = (__bridge id _Nullable)([UIImage imageNamed:@"tongxunlubg"].CGImage);
    [self setNaviagtionItemTitle:0 totleCount:[self.viewModel numberOfRowsInSection:0]];
    [self setupTableView];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.viewModel getSelectIndexPathsFromModels:self.selectedIndexPaths];
    NSInteger totleCount = [self.viewModel numberOfRowsInSection:0];
    if (self.selectedIndexPaths.count == totleCount) {
        [self selectorAllItemClick:self.navigationItem.rightBarButtonItem];
    }else{
        for (NSIndexPath * indexPath in self.selectedIndexPaths) {
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:(UITableViewScrollPositionNone)];
        }
    }
    [self setNaviagtionItemTitle:self.selectedIndexPaths.count totleCount:totleCount];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
#pragma mark - 初始化
-(void)setupTableView{
    self.tableView = [[UITableView alloc]initWithFrame:CGRectZero style:(UITableViewStyleGrouped)];\
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.editing = YES;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[DTMusicPickerCell class] forCellReuseIdentifier:kMucsicPickerCellID];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}

#pragma mark - actions


-(void)doneItemClick{
    
    [self.viewModel setSelectedArrayWithIndexPaths:self.selectedIndexPaths];

    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)selectorAllItemClick:(UIBarButtonItem *)sender{
    
    NSInteger count = [self.viewModel numberOfRowsInSection:0];
    BOOL isSelectAll = NO;
    if ([sender.title isEqualToString:[DTConstAndLocal quanxuan]]) {
        [sender setTitle:[DTConstAndLocal cancel]];
        isSelectAll = YES;
        [self setNaviagtionItemTitle:(int)count totleCount:(int)count];
    }else{
        [sender setTitle:[DTConstAndLocal quanxuan]];
        [self setNaviagtionItemTitle:0 totleCount:(int)count];
    }
    [self.selectedIndexPaths removeAllObjects];
    for (int i = 0; i < count; i ++) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        if (isSelectAll) {
            [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
            [self.selectedIndexPaths addObject:indexPath];
        }else{
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [self.viewModel numberOfSectionsInTableView];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.viewModel numberOfRowsInSection:section];
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 5;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DTMusicPickerCell * cell = [tableView dequeueReusableCellWithIdentifier:kMucsicPickerCellID];
    if (nil == cell){
        cell = [[DTMusicPickerCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:kMucsicPickerCellID];
    }
    cell.model = [self.viewModel modelAtIndexPath:indexPath];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self selectArrayAddOrRemoveIndexPath:indexPath];
}

-(NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self selectArrayAddOrRemoveIndexPath:indexPath];
    return indexPath;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete & UITableViewCellEditingStyleInsert;
}

-(void)selectArrayAddOrRemoveIndexPath:(NSIndexPath *)indexPath{
    if ([self.selectedIndexPaths containsObject:indexPath]) {
        [self.selectedIndexPaths removeObject:indexPath];
    }else{
        [self.selectedIndexPaths addObject:indexPath];
    }
    NSInteger count = [self.viewModel numberOfRowsInSection:0];
    if (self.selectedIndexPaths.count >= count) {
        self.navigationItem.rightBarButtonItem.title = [DTConstAndLocal cancel];
    }else{
        self.navigationItem.rightBarButtonItem.title = [DTConstAndLocal quanxuan];
    }
    [self setNaviagtionItemTitle:(int)self.selectedIndexPaths.count totleCount:(int)count];
}

-(void)setNaviagtionItemTitle:(NSInteger) selectCount totleCount:(NSInteger) totleCount{
    self.navigationItem.title = [NSString stringWithFormat:@"%@:%d / %d",[DTConstAndLocal xuanze],(int)selectCount,(int)totleCount];
}


@end
