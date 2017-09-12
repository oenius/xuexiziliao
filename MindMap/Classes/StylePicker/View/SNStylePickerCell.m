//
//  SNStylePickerCell.m
//  MindMap
//
//  Created by 何少博 on 2017/8/23.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNStylePickerCell.h"
#import "SNStyleModel.h"
@interface SNStylePickerCell ()

@property (weak, nonatomic) IBOutlet UIImageView *myImageView;

@end


@implementation SNStylePickerCell


-(void)setModel:(SNStyleModel *)model{
    _model = model;
    self.myImageView.image = [UIImage imageNamed:model.imageName];
}


@end
