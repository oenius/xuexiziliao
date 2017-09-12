//
//  DTMusicPickerCell.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/19.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTMusicPickerCell.h"
#import "DTMusicViewModel.h"

@interface DTMusicPickerCell ()


@end

@implementation DTMusicPickerCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.tintColor = [UIColor colorWithHexString:@"08c364"];
        self.myImageView.layer.cornerRadius = 5;
        self.backgroundColor = [UIColor clearColor];
        UIButton * share = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
        [share setImage:[UIImage imageNamed:@"share"] forState:(UIControlStateNormal)];
        [share addTarget:self action:@selector(shareClick) forControlEvents:(UIControlEventTouchUpInside)];
        self.accessoryView = share;
        self.accessoryView.hidden = YES;
    }
    return self;
}

-(void)setShowShare:(BOOL)showShare{
    _showShare = showShare;
    self.accessoryView.hidden = !showShare;
}


-(void)shareClick{
    if (self.shareBlock) {
        self.shareBlock(_model);
    }
}
-(void)setModel:(DTMusicModel *)model{
    _model = model;
    self.titleLabel.text = model.name;
    self.detailLabel.text = model.singer;
    UIImage * image = [UIImage imageWithData:model.imageData];
    if (image == nil) {
        image = [UIImage imageNamed:@"moren"];
    }
    self.myImageView.image = image;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
