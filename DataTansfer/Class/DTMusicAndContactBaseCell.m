//
//  DTMusicAndContactBaseCell.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/22.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTMusicAndContactBaseCell.h"

@interface DTMusicAndContactBaseCell ()

@end

@implementation DTMusicAndContactBaseCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.myImageView = [[UIImageView alloc]init];
        self.myImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.myImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:self.myImageView];
        self.titleLabel = [[UILabel alloc]init];
        self.titleLabel.adjustsFontSizeToFitWidth = YES;
        self.titleLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.titleLabel];
        self.detailLabel = [[UILabel alloc]init];
//        self.detailLabel.adjustsFontSizeToFitWidth = YES;
        self.detailLabel.textColor = [UIColor blackColor];
        self.detailLabel.font = [UIFont systemFontOfSize:12];
        self.detailLabel.numberOfLines = 2;
        [self.contentView addSubview:self.detailLabel];
        
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat Width = self.contentView.bounds.size.width;
    CGFloat Height = self.contentView.bounds.size.height;
    
    CGRect imageViewFrame = CGRectMake(10, 10, Height-20, Height-20);
    self.myImageView.frame = imageViewFrame;
    
    CGRect titleLabelFrame = CGRectMake(CGRectGetMaxX(imageViewFrame)+10, 15, Width-Height-10, 16);
    self.titleLabel.frame = titleLabelFrame;
    
    CGRect detailLabelFrame = CGRectMake(CGRectGetMaxX(imageViewFrame)+10, CGRectGetMaxY(titleLabelFrame)+10, Width-Height-10, 12);
    self.detailLabel.frame = detailLabelFrame;
}


@end
