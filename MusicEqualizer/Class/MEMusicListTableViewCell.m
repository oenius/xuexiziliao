//
//  MEMusicListTableViewCell.m
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/3.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "MEMusicListTableViewCell.h"

@interface MEMusicListTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *myImageView;

@property (weak, nonatomic) IBOutlet UILabel *listNameLabel;

@end


@implementation MEMusicListTableViewCell

-(void)setListModel:(MEList *)listModel{
    _listModel = listModel;
//    self.myImageView.image = [UIImage imageWithData:listModel.image];
    self.listNameLabel.text = ([listModel.name isEqualToString:@"myFavorite"])?MEL_MyFavorite:listModel.name;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor colorWithRed:38.0/255.0 green:38.0/255.0 blue:38.0/255.0 alpha:1];
    self.listNameLabel.textColor = [UIColor whiteColor];
    self.highlighted = NO;
    UIView * selectView = [[UIView alloc]initWithFrame:self.bounds];
    selectView.backgroundColor = [UIColor blackColor];
    self.selectedBackgroundView = selectView;
    
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
