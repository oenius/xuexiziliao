//
//  CustomTableViewCell.m
//  VoiceRemind
//
//  Created by 何少博 on 16/8/25.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "CustomTableViewCell.h"
#import "VoiceRemindENUM.h"

@interface CustomTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UILabel *titlelabelF;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabelF;
@property (weak, nonatomic) IBOutlet UILabel *timeLable;
@property (weak, nonatomic) IBOutlet UILabel *timeLengthLabel;
@property (weak, nonatomic) IBOutlet UILabel *sateLabel;

@end



@implementation CustomTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.myImageView.image = [UIImage imageNamed:@"reminder"];
    self.titlelabelF.text = [NSString stringWithFormat:@"%@:",NSLocalizedString(@"Content", @"Content")];
    self.timeLabelF.text = [NSString stringWithFormat:@"%@:",NSLocalizedString(@"Date", @"Date")];
}

-(void)setModel:(RemindCellModel *)model{
    _model = model;
    self.titleLabel.text = model.titleName;
    self.timeLengthLabel.text = model.timeLength;
    self.timeLable.text = [NSDateFormatter localizedStringFromDate:model.noticeDate dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle];
    switch (model.imageType.integerValue) {
        case RemindImageType_Done:
            self.sateLabel.text = NSLocalizedString(@"Have read", @"Have read");
            self.sateLabel.textColor = [UIColor lightGrayColor];
//            self.myImageView.image = [UIImage imageNamed:@"imageTypeDone"];
            break;
        case RemindImageType_Ing:
            self.sateLabel.text = @"";
            self.sateLabel.textColor = [UIColor lightGrayColor];
//            self.myImageView.image = [UIImage imageNamed:@"imageTypeIng"];
            break;
        case RemindImageType_Out:
            self.sateLabel.text = NSLocalizedString(@"unread", @"Unread");
            self.sateLabel.textColor = [UIColor redColor];
//            self.myImageView.image = [UIImage imageNamed:@"imageTypeOut"];
            break;
        default:
            break;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

-(void)prepareForReuse{
    [super prepareForReuse];
}
@end
