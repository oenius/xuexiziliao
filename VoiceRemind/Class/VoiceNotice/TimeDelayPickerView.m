//
//  TimeDelayPickerView.m
//  VoiceRemind
//
//  Created by 何少博 on 16/9/6.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "TimeDelayPickerView.h"
#import "MBProgressHUD.h"
@interface TimeDelayPickerView ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (assign,nonatomic) BOOL ischoosed;
@property (strong,nonatomic)NSArray * cellTitle;
@property (strong,nonatomic)NSIndexPath * choooseIndexPath;

@end


@implementation TimeDelayPickerView



-(void)awakeFromNib{
    [super awakeFromNib];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.contentView.layer.cornerRadius = 8;
    self.contentView.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Default.Snooze", @"Snooze"),NSLocalizedString(@"gallery.sort date", @"Time")];
//    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
//    [self addGestureRecognizer:tap];
}
-(NSArray*)cellTitle{
    if (_cellTitle == nil) {
        NSMutableArray * titlearray = [NSMutableArray arrayWithObjects:
                                       @"No",
                                       @"5mins",
                                       @"10mins",
                                       @"15mins",
                                       @"30mins",
                                       @"45mins",
                                       @"1hour",
                                       @"2hour",
                                       @"4hour",
                                       @"1week",
                                       nil];
        _cellTitle = titlearray;
    }
    return _cellTitle;
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
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellK"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellK"];
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
    self.ischoosed = YES;
    UITableViewCell * lastCell = [tableView cellForRowAtIndexPath:self.choooseIndexPath];
    lastCell.accessoryType = UITableViewCellAccessoryNone;
    UITableViewCell * currentCell = [tableView cellForRowAtIndexPath:indexPath];
    currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.choooseIndexPath = indexPath;
    if ([self.delegate respondsToSelector:@selector(timeDelaychoosed:string:)]) {
        NSTimeInterval timeInter = [self timeDelayChooseBtnClick:indexPath.row];
        NSDate * date;
        if (timeInter == 0) {
            date = nil;
        }else{
            date = [self.date dateByAddingTimeInterval:timeInter];
        }
        [self.delegate timeDelaychoosed:date string:_cellTitle[indexPath.row]];
    }
}
- (NSTimeInterval)timeDelayChooseBtnClick:(NSInteger )sender {
    NSTimeInterval timeInterval = 0;
    switch (sender) {
        case 0:
            timeInterval = 0;
            break;
        case 1://5分钟
            timeInterval = 5 * 60;
            break;
        case 2://10分钟
            timeInterval = 10 * 60;
            break;
        case 3://15分钟
            timeInterval = 15 * 60;
            break;
        case 4://30分钟
            timeInterval = 30 * 60;
            break;
        case 5://45分钟
            timeInterval = 45 * 60;
            break;
        case 6://1小时
            timeInterval = 60 * 60;
            break;
        case 7://2小时
            timeInterval = 2 * 60 * 60;
            break;
        case 8://4小时
            timeInterval = 4 * 60 * 60;
            break;
        case 9://1天
            timeInterval = 24 * 60 * 60;
            break;
        case 10://1周
            timeInterval = 7 * 24 * 60 * 60;
            break;
        default:
            break;
    }
    return timeInterval;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
