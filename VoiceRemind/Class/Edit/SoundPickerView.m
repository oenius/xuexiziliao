//
//  SoundPickerView.m
//  VoiceRemind
//
//  Created by 何少博 on 16/8/26.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "SoundPickerView.h"

@interface SoundPickerView ()<
UITableViewDelegate,
UITableViewDataSource
>
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;

@property (strong,nonatomic)NSArray * soundNameArray;
@property (strong,nonatomic)NSArray * soundPathArray;
@property (strong,nonatomic)NSArray * cellTitle;
@property (strong,nonatomic)NSIndexPath * choooseIndexPath;


@end

static NSString * SoundCellID = @"SoundCellID";

@implementation SoundPickerView




-(AVRecoder *)recoderPlay{
    if (!_recoderPlay) {
        _recoderPlay = [[AVRecoder alloc]init];
    }
    return _recoderPlay;
}

-(NSArray*)cellTitle{
    if (_cellTitle == nil) {
        NSMutableArray * titlearray = [NSMutableArray array];
        for (NSString * name in self.soundNameArray) {
            NSRange range = [name rangeOfString:@"."];
            NSString * newName = [name substringToIndex:range.location];
            [titlearray addObject:newName];
        }
        _cellTitle = titlearray;
    }
    return _cellTitle;
}

-(NSArray *)soundNameArray{
    if (_soundNameArray == nil) {
        NSString * path = [[NSBundle mainBundle]pathForResource:@"sound.plist" ofType:nil];
        _soundNameArray = [NSArray arrayWithContentsOfFile:path];
    }
    return _soundNameArray;
}

-(NSArray *)soundPathArray{
    if (_soundPathArray == nil) {
        NSMutableArray * patharray = [NSMutableArray array];
        for (NSString * name in self.soundNameArray) {
            NSString* path = [[NSBundle mainBundle]pathForResource:name ofType:nil];
            [patharray addObject:path];
        }
        _soundPathArray = patharray;
    }
    return _soundPathArray;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.contentView.layer.cornerRadius = 8;
    self.contentView.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.titleLabel.text = NSLocalizedString(@"Default.Alert.Sount", @"Alert sound");
//    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
//    [self addGestureRecognizer:tap];
}
-(void)tapGesture:(UITapGestureRecognizer*)tap{
    CGPoint point = [tap locationInView:self.contentView];
    CGRect rect = self.contentView.bounds;
    if (!CGRectContainsPoint(rect, point)){
        [self removeFromSuperview];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.cellTitle.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:SoundCellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SoundCellID];
    }
    if (self.choooseIndexPath == indexPath) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = self.cellTitle[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell * lastCell = [tableView cellForRowAtIndexPath:self.choooseIndexPath];
    lastCell.accessoryType = UITableViewCellAccessoryNone;
    UITableViewCell * currentCell = [tableView cellForRowAtIndexPath:indexPath];
    currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.choooseIndexPath = indexPath;
    NSString * name_ = self.cellTitle[indexPath.row];
    NSString * namecaf = self.soundNameArray[indexPath.row];
    BOOL showPingLun = NO;
    if (indexPath.row*45 >self.tableView.frame.size.height) {
        showPingLun = YES;
    }
    if ([self.delegate respondsToSelector:@selector(chooseSoundNameCaf:name_:showPinlun:)]) {
        [self.delegate chooseSoundNameCaf:namecaf name_:name_ showPinlun:showPingLun];
    }

    NSString * soundPath = self.soundPathArray[indexPath.row];
    if (self.recoderPlay.playRecodering) {
        [self.recoderPlay stopPlayRecoder];
    }
    [self.recoderPlay PlayRecoderWithFileUrl:soundPath];
}

-(void)dealloc{
    LOG(@"00000000");
}

//- (IBAction)cancelBtnClick:(UIButton *)sender {
//    self.recoderPlay = nil;
//    [self removeFromSuperview];
//}
//- (IBAction)doneBtnClick:(UIButton *)sender {
//    NSString * name_ = self.cellTitle[self.choooseIndexPath.row];
//    NSString * namecaf = self.soundNameArray[self.choooseIndexPath.row];
//    if ([self.delegate respondsToSelector:@selector(chooseSoundNameCaf:name_:)]) {
//        [self.delegate chooseSoundNameCaf:namecaf name_:name_];
//    }
//    [self removeFromSuperview];
//}


@end
