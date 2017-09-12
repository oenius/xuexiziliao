//
//  SNImagePickerCollectionViewCell.m
//  MindMap
//
//  Created by 何少博 on 2017/8/29.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNImagePickerCollectionViewCell.h"
#import "SNAssetViewModel.h"
#import "SNAssetModel.h"
@interface SNImagePickerCollectionViewCell ()




@end


@implementation SNImagePickerCollectionViewCell




-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}





-(void)layoutSubviews{
    [super layoutSubviews];
    
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        _imageView = imageView;
    }
    return _imageView;
}



-(void)setModel:(SNAssetModel *)model{
    _model = model;
    if (model.isNone) {
        self.imageView.image = [UIImage imageNamed:@"none.png"];
    }else{
        self.imageView.image = [UIImage imageNamed:@"tmp.png"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString * assetid = [_model.assetID copy];
            assetid = [assetid stringByReplacingOccurrencesOfString:@"/" withString:@""];
            assetid = [assetid stringByReplacingOccurrencesOfString:@"-" withString:@""];
            _model.thumPath = [NSTemporaryDirectory() stringByAppendingFormat:@"%@.jpg",assetid];
            UIImage * image = [UIImage imageWithContentsOfFile:_model.thumPath];
            if (image == nil) {
                [SNAssetViewModel requestThumbImageWithAsset:_model thumb:YES completed:^(UIImage *thumbImage) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (thumbImage != nil) {
                            self.imageView.image = thumbImage;
                        }
                    });
                }];
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.imageView.image = image;
                });
            }
        });
    }
    
}

@end
