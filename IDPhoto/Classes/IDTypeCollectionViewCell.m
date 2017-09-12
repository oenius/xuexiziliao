//
//  IDTypeCollectionViewCell.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/21.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDTypeCollectionViewCell.h"

@interface IDTypeCollectionViewCell ()


@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end


@implementation IDTypeCollectionViewCell


-(void)setModel:(IDTypeModel *)model{
    _model = model;
    self.nameLabel.text = model.title;
    if (model.image) {
        self.imageView.image = model.image;
    }else{
        self.imageView.image = [UIImage imageNamed:model.imageName];
    }
}


-(void)awakeFromNib{
    [super awakeFromNib];
    self.backgroundColor = [UIColor clearColor];
    _imageView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    _imageView.layer.shadowOffset = CGSizeMake(0,-3);
    _imageView.layer.shadowOpacity = 0.3;
    _imageView.layer.shadowRadius = 3;
}

-(void)layoutSubviews{
    [super layoutSubviews];
}

@end
