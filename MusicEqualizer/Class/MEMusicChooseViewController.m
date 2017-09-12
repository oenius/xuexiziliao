//
//  MEMusicChooseViewController.m
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/3.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "MEMusicChooseViewController.h"
#import "MESongsViewModel.h"
#import "MEMusicChooseTableViewCell.h"
#import "MECoreDataManager.h"
#import "UIColor+x.h"
@interface MEMusicChooseViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic) MESongsViewModel * viewModel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong,nonatomic) NSMutableArray * selectedIndexPaths;

@property (copy,nonatomic) ChooseMusicBlock block;

@property (strong,nonatomic) MEList * list;

@end

static NSString * musicChooseViewcellID = @"MusicChooseViewcellId";

@implementation MEMusicChooseViewController
-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil andmusicList:(MEList *)list{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.list = list;
    }
    return self;
}
#pragma mark - 懒加载

-(NSMutableArray *)selectedIndexPaths{
    if (nil == _selectedIndexPaths) {
        _selectedIndexPaths = [NSMutableArray new];
    }
    return _selectedIndexPaths;
}

-(MESongsViewModel *)viewModel{
    if (nil == _viewModel) {
        _viewModel = [MESongsViewModel new];
    }
    return _viewModel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout  = UIRectEdgeNone;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:MEL_Done style:UIBarButtonItemStylePlain target:self action:@selector(doneItemClick)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:MEL_SelectAll style:UIBarButtonItemStylePlain target:self action:@selector(selectorAllItemClick:)];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"efefef"];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"a20707"];
    NSDictionary * normal = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"efefef"]};
    self.navigationController.navigationBar.titleTextAttributes = normal;
    self.navigationController.navigationBar.translucent = YES;
    
    self.view.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1];
    
    [self setupTableView];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setNaviagtionItemTitle:0 totleCount:(int)[self.viewModel numberOfRowsInSection:0]];
}
-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    self.tableView.contentInset = contentInsets;
}
#pragma mark - 初始化
-(void)setupTableView{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsMultipleSelection = YES;
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.editing = YES;
    UINib * nib = [UINib nibWithNibName:NSStringFromClass([MEMusicChooseTableViewCell class]) bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:musicChooseViewcellID];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - actions

-(void)musicChooseCallBack:(ChooseMusicBlock)block{
    self.block = block;
}

-(void)doneItemClick{
    
    NSMutableArray * musciArray = [NSMutableArray array];
    for (NSIndexPath * indexPath in self.selectedIndexPaths) {
        MEMusic * music = [self.viewModel getMusicModelAtIndexPath:indexPath];
         LOG(@"复制之前：%p",music);
        MEMusic * newMusic = [[MECoreDataManager defaultManager] copyMusic:music toList:self.list];
        if (newMusic) {
            [musciArray addObject:newMusic];
            LOG(@"复制之后：%p",newMusic);
        }
        
    }
   
    self.block(musciArray);
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)selectorAllItemClick:(UIBarButtonItem *)sender{
    
    NSInteger count = [self.viewModel numberOfRowsInSection:0];
    BOOL isSelectAll = NO;
    if ([sender.title isEqualToString:MEL_SelectAll]) {
        [sender setTitle:MEL_Cancel];
        isSelectAll = YES;
        [self setNaviagtionItemTitle:(int)count totleCount:(int)count];
    }else{
        [sender setTitle:MEL_SelectAll];
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MEMusicChooseTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:musicChooseViewcellID];
    if (nil == cell){
        cell = [[MEMusicChooseTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:musicChooseViewcellID];
    }
    [self fillCellInfomation:cell atIndexPath:indexPath];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self selectArrayAddOrRemoveIndexPath:indexPath];
    LOG(@"%@",self.selectedIndexPaths);
}

-(NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self selectArrayAddOrRemoveIndexPath:indexPath];
    LOG(@"%@",self.selectedIndexPaths);
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


-(void)fillCellInfomation:(MEMusicChooseTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    MEMusic *music = [self.viewModel getMusicModelAtIndexPath:indexPath];
    cell.tintColor = [UIColor colorWithHexString:@"a20707"];
    cell.musicModel = music;
}

-(void)selectArrayAddOrRemoveIndexPath:(NSIndexPath *)indexPath{
    if ([self.selectedIndexPaths containsObject:indexPath]) {
        [self.selectedIndexPaths removeObject:indexPath];
    }else{
        [self.selectedIndexPaths addObject:indexPath];
    }
    NSInteger count = [self.viewModel numberOfRowsInSection:0];
    if (self.selectedIndexPaths.count >= count) {
        self.navigationItem.rightBarButtonItem.title = MEL_Cancel;
    }else{
        self.navigationItem.rightBarButtonItem.title = MEL_SelectAll;
    }
    [self setNaviagtionItemTitle:(int)self.selectedIndexPaths.count totleCount:(int)count];
}

-(void)setNaviagtionItemTitle:(int) selectCount totleCount:(int) totleCount{
    self.navigationItem.title = [NSString stringWithFormat:@"%@:%d / %d",MEL_Select,selectCount,totleCount];
}

/*
 设置cell在编辑状态下选中是的状态
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
 
 NSArray *subviews = [[tableView cellForRowAtIndexPath:indexPath] subviews];
 
 for (id obj in subviews) {
 if ([obj isKindOfClass:[UIControl class]]) {
 
 for (id subview in [obj subviews]) {
 if ([subview isKindOfClass:[UIImageView class]]) {
 
 [subview setValue:blueBackground forKey:@"tintColor"];
 break;
 }
 
 }
 }
 }
 }
 
 */

@end
