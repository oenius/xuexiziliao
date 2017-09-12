//
//  IDClothesCollectionViewCell.m
//  IDPhoto
//
//  Created by 何少博 on 17/5/2.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDClothesCollectionViewCell.h"

@interface IDClothesCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *clothesImageView;
@property (weak, nonatomic) IBOutlet UIImageView *selectImageView;

@end



@implementation IDClothesCollectionViewCell


-(void)setClothesName:(NSString *)clothesName{
    _clothesName = clothesName;
    [self setImageWithImagePath:clothesName placeholderImage:[UIImage new]];
}

-(void)setIsSelect:(BOOL)isSelect{
    _isSelect = isSelect;
    if (_isSelect)
        self.selectImageView.hidden = NO;
    else
        self.selectImageView.hidden = YES;
}

-(void)setImageWithImagePath:(NSString *)path placeholderImage:(UIImage *)image{
    self.clothesImageView.image = image;
    [self runAsynchronous:^{
        UIImage * scaleImage = [UIImage imageWithContentsOfFile:path];
        scaleImage =[[scaleImage scaleImageAspectFitSize:CGSizeMake(100, 100)] trimmedBetterSize];
        if (scaleImage) {
            [self runAsyncOnMainThread:^{
                self.clothesImageView.image = scaleImage;
            }];
        }
    }];
}
- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor whiteColor];
    self.layer.masksToBounds = YES;
}
-(void)layoutSubviews{
    [super layoutSubviews];
}
@end
