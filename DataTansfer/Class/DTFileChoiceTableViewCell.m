//
//  DTFileChoiceTableViewCell.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/18.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTFileChoiceTableViewCell.h"
#import "DTFileChoiceViewModel.h"
#import "DTDataBaseViewModel.h"
@interface DTFileChoiceTableViewCell ()


@end


@implementation DTFileChoiceTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        self.detailTextLabel.font = [UIFont systemFontOfSize:12];
        self.detailTextLabel.textColor = [UIColor whiteColor];
        UIView * backView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
        backView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        self.selectedBackgroundView = backView;
        self.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor whiteColor];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

-(void)setupSubViews{

}

-(void)setModel:(DTFileChoiceModel *)model{
    _model = model;
    self.imageView.image = [UIImage imageNamed:model.headImageName];
    self.textLabel.text = model.title;
    self.detailTextLabel.text = [NSString stringWithFormat:@"%d/%d",(int)[model.viewModel selectedCount],(int)[model.viewModel totleCount]];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
