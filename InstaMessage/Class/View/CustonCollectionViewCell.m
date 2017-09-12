//
//  CustonCollectionViewCell.m
//  InstaMessage
//
//  Created by 何少博 on 16/7/27.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "CustonCollectionViewCell.h"

@interface CustonCollectionViewCell ()


@property (nonatomic,strong)UIImageView *imageView;
@property (nonatomic,strong)UIImageView *lockImageView;
@property (nonatomic,strong)UILabel * tempLabel;

@end

@implementation CustonCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if(self=[super initWithFrame:frame])
    {
        _imageView=[[UIImageView alloc] init];
        [self.contentView addSubview:_imageView];
        _lockImageView=[[UIImageView alloc] init];
        _lockImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:_lockImageView];
        _tempLabel = [[UILabel alloc]init];
        _tempLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_tempLabel];
    }
    return self;
}

-(void)setImage:(UIImage *)image{
    _image = image;
    self.imageView.image = image;
}

-(void)setTextFont:(NSString *)textFont{
    _textFont = textFont;
    self.tempLabel.text = @"Font";
    self.tempLabel.font = [UIFont fontWithName:textFont size:18];
}

-(void)setModel:(ThemeItemModel *)model{
    _model = model;
    NSString * path = [[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"%@",model.thumbImageName] ofType:nil];
    self.imageView.image = [UIImage imageWithContentsOfFile:path];
    NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
    if ([model.photoEnabled isEqualToString:@"YES"]) {
        NSArray * goProAray = [userDefault objectForKey:kGoProArray];
        if ([goProAray containsObject:model.imageName]) {
            self.lockImageView.image = [UIImage imageNamed:@"lock"];
        }else{
            self.lockImageView.image = nil;
        }
    }else{
        NSArray * commentAray = [userDefault objectForKey:kCommentArray];
        if ([commentAray containsObject:model.imageName] ) {
            self.lockImageView.image = [UIImage imageNamed:@"lock"];
        }else{
            self.lockImageView.image = nil;
        }
    }
}
-(void)setTextModel:(TextViewModel *)textModel{
    _textModel = textModel;
    _imageView.contentMode = UIViewContentModeCenter;
    self.imageView.image = [UIImage imageNamed:textModel.imageName];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.imageView.frame = self.bounds;
    
    self.tempLabel.frame = self.bounds;
    self.tempLabel.font = [UIFont systemFontOfSize:17];
    self.tempLabel.textColor = [UIColor blackColor];
    
    CGFloat x = self.bounds.size.width - 24;
    CGFloat y = self.bounds.size.height - 31;
    CGRect frame = CGRectMake(x, y, 24, 31);
    self.lockImageView.frame = frame;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.imageView.image = nil;
    self.lockImageView.image = nil;
    self.backgroundColor = [UIColor whiteColor];
}

@end
