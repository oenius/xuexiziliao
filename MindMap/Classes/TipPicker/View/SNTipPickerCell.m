//
//  SNTipPickerCell.m
//  MindMap
//
//  Created by 何少博 on 2017/8/17.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNTipPickerCell.h"
#import "SNTipModel.h"
@interface SNTipPickerCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end


@implementation SNTipPickerCell


-(void)setModel:(SNTipModel *)model{
    _model = model;
    UIImage * image = [UIImage imageNamed:_model.name];
    if (image) {
        self.imageView.image = image;
    }else{
        self.imageView.image = [UIImage imageNamed:@"close"];
    }
    
}

-(void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
}


-(void)layoutSubviews{
    [super layoutSubviews];
    
}

@end
