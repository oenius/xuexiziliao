//
//  METemporaryTableViewCell.m
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/4.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "METemporaryTableViewCell.h"
#import "UIColor+x.h"


@interface METemporaryTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *myImageView;

@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *singerNameLabel;

@property (copy, nonatomic) DeleteBtnBlock block;

@end

@implementation METemporaryTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UIView * selecView = [[UIView alloc]initWithFrame:self.bounds];
    selecView.backgroundColor = [UIColor blackColor];
    self.selectedBackgroundView = selecView;
    self.highlighted = NO;
    self.backgroundColor = [UIColor colorWithHexString:@"262626"];
}

-(void)setMusicModel:(MEMusic *)musicModel{
    _musicModel = musicModel;
    self.myImageView.image = [UIImage imageWithData:musicModel.image];
    self.songNameLabel.text = musicModel.name;
    self.singerNameLabel.text = musicModel.singer;
}

-(void)deleteBtnCallBack:(DeleteBtnBlock)block{
    self.block = block;
}

- (IBAction)deleteBtnclick:(UIButton *)sender {
    if (self.block) {
        self.block(self.musicModel);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
