//
//  RepeatTypePickerView.m
//  VoiceRemind
//
//  Created by 何少博 on 16/8/26.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "RepeatTypePickerView.h"

@interface RepeatTypePickerView ()<
UITableViewDelegate,
UITableViewDataSource
>

@property (weak, nonatomic) IBOutlet UIView *contentVIew;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (strong,nonatomic) NSArray * repeatTypeArray;
@property (strong,nonatomic) NSIndexPath * chooseIndexPath;

@end

static NSString * repeatTypeCellID = @"repeatTypeCellID";

@implementation RepeatTypePickerView

-(void)awakeFromNib{
    [super awakeFromNib];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.contentVIew.layer.cornerRadius = 8;
    self.contentVIew.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.titleLabel.text = NSLocalizedString(@"Repeat", @"Repeat");
//    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
//    [self addGestureRecognizer:tap];
}
-(void)tapGesture:(UITapGestureRecognizer*)tap{
    CGPoint point = [tap locationInView:self.contentVIew];
    CGRect rect = self.contentVIew.bounds;
    if (!CGRectContainsPoint(rect, point)){
        [self removeFromSuperview];
    }
}
-(NSArray *)repeatTypeArray{
    if (_repeatTypeArray == nil) {
        _repeatTypeArray = @[
                        NSLocalizedString(@"None", @"None"),
                        NSLocalizedString(@"Every hour", @"Every hour"),
                        NSLocalizedString(@"Every day", @"Every day"),
                        NSLocalizedString(@"Every week", @"Every week"),
                        NSLocalizedString(@"Every month", @"Every month"),
                        NSLocalizedString(@"Every year", @"Every year"),
                        ];
    }
    return _repeatTypeArray;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.repeatTypeArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:repeatTypeCellID];
    if (cell == nil) {
        cell  = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:repeatTypeCellID];
    }
    if (self.chooseIndexPath == indexPath) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = self.repeatTypeArray[indexPath.row];
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell * lastCell = [tableView cellForRowAtIndexPath:self.chooseIndexPath];
    lastCell.accessoryType = UITableViewCellAccessoryNone;
    UITableViewCell * currentCell = [tableView cellForRowAtIndexPath:indexPath];
    currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
    NSString * stringType = self.repeatTypeArray[indexPath.row];
    RepeatType type = [self repeatTypeChoose:indexPath.row];
    if ([self.delegate respondsToSelector:@selector(chooseRepeatType:string:)]) {
        [self.delegate chooseRepeatType:type string:stringType];
    }
}
- (RepeatType)repeatTypeChoose:( NSInteger)sender {
    RepeatType type ;
    switch (sender) {
        case 0:
            type = RepeatType_No;
            break;
        case 1:
            type = RepeatType_Hour;
            break;
        case 2:
            type = RepeatType_Day;
            break;
        case 3:
            type = RepeatType_Week;
            break;
        case 4:
            type = RepeatType_Month;
            break;
        case 5:
            type = RepeatType_Year;
            break;
        default:
            type = RepeatType_No;
            break;
    }
    return type;
}

@end
