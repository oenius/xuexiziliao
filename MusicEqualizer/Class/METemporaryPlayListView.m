//
//  METemporaryPlayListView.m
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/4.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "METemporaryPlayListView.h"
#import "METemporaryTableViewCell.h"
#import "MEUserDefaultManager.h"

@interface METemporaryPlayListView ()<UITableViewDelegate,UITableViewDataSource,MEAudioPlayerDelegate>

@property (strong, nonatomic) IBOutlet UIButton *playModelBtn;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (strong,nonatomic) NSMutableArray* list;

@property (assign,nonatomic) NSInteger index;

@property (weak,nonatomic) MEAudioPlayer * player;

@end

NSString * const temporaryTableViewCellID = @"TemporaryTableViewCell";

@implementation METemporaryPlayListView



-(void)setCurrentIndex:(NSInteger)index{
    self.index = index;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupView];
    }
    return self;
}

-(void)setupView{
    
    self.backgroundColor = [UIColor blackColor];
    self.player = [MEAudioPlayer defaultPlayer];
    self.player.playModel = [[MEUserDefaultManager defaultManager]getPlayModel];
    self.player.delegate = self;
    
    self.playModelBtn = [[UIButton alloc]init];
    [self addSubview:self.playModelBtn];
    MEAudioPlayerPlayModel playModel = [[MEUserDefaultManager defaultManager] getPlayModel];
    [self changePlayBtnImageWithPlayModel:playModel];
    
    [self.playModelBtn addTarget:self action:@selector(playModelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    self.tableView = [[UITableView alloc]init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UINib * nib = [UINib nibWithNibName:NSStringFromClass([METemporaryTableViewCell class]) bundle:[NSBundle mainBundle]];
    [self.tableView registerNib:nib forCellReuseIdentifier:temporaryTableViewCellID];
    [self addSubview:self.tableView];
    self.list = self.player.musicList;
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.player.currentIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
}



-(void)awakeFromNib{
    [super awakeFromNib];
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.backgroundColor = [UIColor blackColor];
    CGFloat btnHeight = 46;
    self.playModelBtn.frame = CGRectMake(5, 5, btnHeight, btnHeight);
    self.tableView.frame = CGRectMake(5, btnHeight+10, self.bounds.size.width-10, self.bounds.size.height-btnHeight-15);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor blackColor];
}

#pragma mark - actions



- (void)playModelBtnClick:(UIButton *)sender {
    
    switch (self.player.playModel) {
        case MEAudioPlayerPlayModelOrder:
            self.player.playModel  = MEAudioPlayerPlayModelRandom;
            break;
        case MEAudioPlayerPlayModelRandom:
            self.player.playModel  = MEAudioPlayerPlayModelSingle;
            break;
        case MEAudioPlayerPlayModelSingle:
            self.player.playModel  = MEAudioPlayerPlayModelOrder;
            break;
        default:
            self.player.playModel  = MEAudioPlayerPlayModelOrder;
            break;
    }
    [[MEUserDefaultManager defaultManager] setPlayModel:self.player.playModel];
}

#pragma mark - meaudioPlayerDelegate

-(void)audioPlayer:(MEAudioPlayer *)player playModelChanged:(MEAudioPlayerPlayModel)playModel{
    [self changePlayBtnImageWithPlayModel:playModel];
}

-(void)changePlayBtnImageWithPlayModel:(MEAudioPlayerPlayModel)playModel{

    switch (playModel) {
        case MEAudioPlayerPlayModelOrder:
            [self.playModelBtn setImage:[UIImage imageNamed:@"order"] forState:UIControlStateNormal];
            break;
        case MEAudioPlayerPlayModelRandom:
            [self.playModelBtn  setImage:[UIImage imageNamed:@"suiji"] forState:UIControlStateNormal];
            break;
        case MEAudioPlayerPlayModelSingle:
            [self.playModelBtn  setImage:[UIImage imageNamed:@"Single"] forState:UIControlStateNormal];
            break;
        default:
            [self.playModelBtn  setImage:[UIImage imageNamed:@"order"] forState:UIControlStateNormal];
            break;
    }
}

-(void)audioPlayer:(MEAudioPlayer *)player musicIndexChanged:(NSInteger)index{
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:YES scrollPosition:(UITableViewScrollPositionNone)];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.list.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    METemporaryTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:temporaryTableViewCellID];
    if (nil == cell) {
        cell = [[METemporaryTableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:temporaryTableViewCellID];
    }
    [self fillCellInfo:cell atIndexPath:indexPath];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == self.player.currentIndex) {
        return;
    }
    [self.player playMusicWithIndex:indexPath.row];
}

-(void)fillCellInfo:(METemporaryTableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath{
    MEMusic * model = [self.list objectAtIndex:indexPath.row];
    cell.musicModel = model;
    __weak typeof(self) weakSelf = self;
    [cell deleteBtnCallBack:^(MEMusic *musicModel) {
        [weakSelf.player deleteMusicAtIndex:indexPath.row];
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
        });
    }];
}


@end
