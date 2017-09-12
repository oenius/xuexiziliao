//
//  ScrSettingCell.m
//  LEDBanner
//
//  Created by 何少博 on 16/6/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "ScrSettingCell.h"
#import "UIColor+x.h"
@interface ScrSettingCell ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *ledDirection;
@property (weak, nonatomic) IBOutlet UISlider *ledSpeed;
@property (weak, nonatomic) IBOutlet UISwitch *ledIsFilcker;
@property (weak, nonatomic) IBOutlet UISlider *ledFrequency;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fangxiangLabel;
@property (weak, nonatomic) IBOutlet UILabel *suduLabel;
@property (weak, nonatomic) IBOutlet UILabel *shanshuoLabel;
@property (weak, nonatomic) IBOutlet UILabel *pinlvLabel;
@property (weak, nonatomic) IBOutlet UIView *lineView;


@end


@implementation ScrSettingCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = color_131a20;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    self.ledDirection.selectedSegmentIndex = [userDefault boolForKey:kLedDirection];
    self.ledIsFilcker.on = [userDefault boolForKey:kLedIsFilcker];
    self.ledSpeed.value = [userDefault floatForKey:kLedSpeed];
    self.ledFrequency.value = [userDefault floatForKey:kLedFrequency];
    
    
    
    self.nameLabel.textColor  = color_ffffff;
    self.fangxiangLabel.textColor  = color_666666;
    self.suduLabel.textColor  = color_666666;
    self.shanshuoLabel.textColor  = color_666666;
    self.pinlvLabel.textColor  = color_666666;
    self.ledDirection.tintColor = color_40d0d9;
    self.ledSpeed.tintColor = color_40d0d9;
    self.ledIsFilcker.tintColor = color_40d0d9;
    self.ledIsFilcker.onTintColor = color_40d0d9;
    self.ledFrequency.tintColor = color_40d0d9;
    self.lineView.backgroundColor = color_40d0d9;
    
    NSString * namelabeltext = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"scroll", @"Scroll"),NSLocalizedString(@"Settings", @"Settings")];
    self.nameLabel.text = namelabeltext;
    self.fangxiangLabel.text = NSLocalizedString(@"orientation", @"Direction");
    self.suduLabel.text = NSLocalizedString(@"FIRST_STEPS_SPEED", @"Speed");
    self.pinlvLabel.text = NSLocalizedString(@"frequency", @"Frequency");
    self.shanshuoLabel.text = NSLocalizedString(@"Flicker", @"Twinkle");

}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    
}
- (IBAction)dierctionchange:(UISegmentedControl *)sender {
    //left 0 NO right 1 YES
    BOOL right ;
    if (sender.selectedSegmentIndex == 0) {
        right = NO;
    }else{
        right = YES;
    }
    if ([self.delegate respondsToSelector:@selector(setDirectionChange:)]) {
        [self.delegate setDirectionChange:right];
    }
}

- (IBAction)speedChange:(UISlider *)sender {

    if ([self.delegate respondsToSelector:@selector(setSpeedChange:)]) {
        [self.delegate setSpeedChange:sender.value];
    }
}

- (IBAction)flickerChange:(UISwitch *)sender {
    
    if ([self.delegate respondsToSelector:@selector(setFlickerChange:)]) {
        [self.delegate setFlickerChange:sender.on];
    }
}

- (IBAction)frequencyChange:(UISlider *)sender {
    if ([self.delegate respondsToSelector:@selector(setFrequencyChange:)]) {
        [self.delegate setFrequencyChange:sender.value];
    }
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}





@end
