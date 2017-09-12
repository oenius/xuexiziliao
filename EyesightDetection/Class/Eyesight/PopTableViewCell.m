//
//  PopTableViewCell.m
//  EyesightDetection
//
//  Created by 何少博 on 16/10/10.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "PopTableViewCell.h"

@interface PopTableViewCell ()

@property (strong,nonatomic) UILabel * myLabel;

@end

@implementation PopTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect newFrame = frame;
        newFrame.origin = CGPointMake(0, 0);
        self.myLabel = [[UILabel alloc]initWithFrame:newFrame];
        self.myLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.myLabel];;
    }
    return self;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.myLabel = [[UILabel alloc]init];
        self.myLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.myLabel];;
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.myLabel.frame = self.bounds;
}

-(void)setText:(NSString *)text{
    _text = text;
    self.myLabel.text = text;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
