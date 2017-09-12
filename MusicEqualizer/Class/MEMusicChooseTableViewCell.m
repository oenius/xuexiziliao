//
//  MEMusicChooseTableViewCell.m
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/4.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "MEMusicChooseTableViewCell.h"
#import "MEMusic.h"

@interface MEMusicChooseTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *myImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *singerLabel;

@end

@implementation MEMusicChooseTableViewCell

-(void)setMusicModel:(MEMusic *)musicModel{
    _musicModel = musicModel;
    self.myImageView.image = [UIImage imageWithData:musicModel.image];
    self.nameLabel.text = musicModel.name;
    self.singerLabel.text = musicModel.singer;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor blackColor];
    UIView * selectView = [[UIView alloc]initWithFrame:self.bounds];
    selectView.backgroundColor = [UIColor blackColor];
    self.selectedBackgroundView = selectView;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
