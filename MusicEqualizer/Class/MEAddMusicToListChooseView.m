//
//  MEAddMusicToListChooseView.m
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/6.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "MEAddMusicToListChooseView.h"
#import "MEAddMusicToListViewModel.h"
#import "MEList.h"
@interface MEAddMusicToListChooseView ()<UITableViewDelegate,UITableViewDataSource>

@property (strong,nonatomic)UITableView * talbeView;

@property (strong,nonatomic)UILabel * topLabel;

@property (strong,nonatomic)UIButton * closeBtn;

@property (strong,nonatomic) MEAddMusicToListViewModel * viewModel;

@property (copy,nonatomic) ChooseListBlock block;

@end

NSString * const  MEAddMusicToListChooseViewCellID = @"MEAddMusicToListChooseViewCellID";

@implementation MEAddMusicToListChooseView

-(MEAddMusicToListViewModel *)viewModel{
    if (nil == _viewModel) {
        _viewModel = [MEAddMusicToListViewModel new];
    }
    return _viewModel;
}

-(instancetype)initWithFrame:(CGRect)frame chooseMusicCallBack:(ChooseListBlock)block{
    self = [super initWithFrame:frame];
    if (self) {
        self.block = block;
        self.backgroundColor = [UIColor blackColor];
        [self setupSubViews];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self setupSubViews];
    }
    return self;
}

-(void)setupSubViews{
    self.topLabel = [[UILabel alloc]init];
    [self addSubview:_topLabel];
    _topLabel.text = MEL_SongList;
    _topLabel.textAlignment = NSTextAlignmentCenter;
    _topLabel.numberOfLines = 1;
    _topLabel.textColor = [UIColor whiteColor];
    _topLabel.adjustsFontSizeToFitWidth = YES;
    
    self.talbeView = [[UITableView alloc]init];
    self.talbeView.delegate = self;
    self.talbeView.dataSource = self;
    self.talbeView.backgroundColor = [UIColor colorWithRed:38.0/255.0 green:38.0/255.0 blue:38.0/255.0 alpha:1];
    self.talbeView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self addSubview:self.talbeView];
    
    self.closeBtn = [[UIButton alloc]init];
    [self.closeBtn setTitle:MEL_Close forState:UIControlStateNormal];
    [self.closeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeBtn];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat spacing = 2;
    CGFloat T_B_H = 46;
    CGFloat selfWidth = self.bounds.size.width;
    CGFloat selfHeight = self.bounds.size.height;
    self.topLabel.frame = CGRectMake(0, 0, selfWidth, T_B_H);
    self.talbeView.frame = CGRectMake(0, T_B_H+spacing, selfWidth, selfHeight-(T_B_H+spacing)*2);
    
    self.closeBtn.frame = CGRectMake(0, selfHeight-T_B_H,selfWidth ,T_B_H);
}

-(void)closeBtnClick{
    if (self.block) {
        self.block(nil);
    }
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
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:MEAddMusicToListChooseViewCellID];
    if (nil == cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:MEAddMusicToListChooseViewCellID];
    }
    [self fillCellInformation:cell indexPath:indexPath];
    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MEList * list = [self.viewModel getMusicListModelAtIndexPath:indexPath];
    if (self.block) {
        self.block(list);
    }
    
}
-(void)fillCellInformation:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath{
    MEList * listModel = [self.viewModel getMusicListModelAtIndexPath:indexPath];
    cell.textLabel.text = ([listModel.name isEqualToString:@"myFavorite"]) ? MEL_MyFavorite : listModel.name;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor colorWithRed:38.0/255.0 green:38.0/255.0 blue:38.0/255.0 alpha:1];
    //其他相关设置
    cell.highlighted = NO;
    UIView * selectView = [[UIView alloc]initWithFrame:self.bounds];
    selectView.backgroundColor = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1];
    cell.selectedBackgroundView = selectView;
}
@end
