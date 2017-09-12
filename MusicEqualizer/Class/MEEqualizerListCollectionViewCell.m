//
//  MEEqualizerListCollectionViewCell.m
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/5.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "MEEqualizerListCollectionViewCell.h"

@interface MEEqualizerListCollectionViewCell ()

@end


@implementation MEEqualizerListCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
   
}
-(void)layoutSubviews{
    [super layoutSubviews];
     self.backgroundColor = [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1];
    self.nameLabel.font = [UIFont systemFontOfSize:self.bounds.size.height/5];
    self.nameLabel.textColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
}
@end
