//
//  DTContactPickerCell.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/22.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTContactPickerCell.h"
#import "DTContactViewModel.h"
@implementation DTContactPickerCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.tintColor = [UIColor colorWithHexString:@"08c364"];
        self.myImageView.layer.cornerRadius = 5;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


-(void)setModel:(DTContactModel *)model{
    _model = model;
    self.titleLabel.text = model.name;
    UIImage * image = [UIImage imageWithData:model.imageData];
    if (image == nil) {
        image = [UIImage imageNamed:@"morentouxiang"];
    }
    self.myImageView.image = image;
    NSString * numbers = @"";
    for (NSDictionary * dic in model.phoneNumbers) {
        NSString * phoneNumber = dic[@"phoneNumber"];
        numbers = [numbers stringByAppendingFormat:@" %@",phoneNumber];
    }
    self.detailLabel.text = numbers;
}

@end
