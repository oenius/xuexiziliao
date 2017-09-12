//
//  BLUseTableViewCell.m
//  BatteryLife
//
//  Created by vae on 16/11/17.
//  Copyright © 2016年 vae. All rights reserved.
//

#import "BLUseTableViewCell.h"

@implementation AvailableModel

@end

@implementation BLUseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}

- (void)setModel:(AvailableModel *)model{

    _model = model;
    
    NSString * currentLanguage = [[[NSLocale preferredLanguages] firstObject] substringToIndex:2];
    
    if ([currentLanguage containsString:@"zh"]) {
        self.textLabel.text = model.zh_name;
    }
    else if ([currentLanguage containsString:@"vi"]) {
        self.textLabel.text = model.vi_name;
    }
    else {
        self.textLabel.text = model.en_name;
    }
    
    self.imageView.image = [UIImage imageNamed:model.image];
    
    CGFloat currentElectricity = [UIDevice currentDevice].batteryLevel;
    NSInteger currentAvailable = model.ratio * currentElectricity;
    
    
//    NSString * xiaoshi = NSLocalizedString(@"xmfwhitenoise.Hour", @"Hours");
//    NSString * fenzhong = NSLocalizedString(@"xmfMinute", @"Minute");
    if (currentAvailable % 60 == 0) {
        self.detailTextLabel.text = [NSString stringWithFormat:@"%ldh",
                               currentAvailable / 60];
    }
    else {
        self.detailTextLabel.text = [NSString stringWithFormat:@"%ldh %.2ldm",
                               currentAvailable / 60,
                               currentAvailable % 60];
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
