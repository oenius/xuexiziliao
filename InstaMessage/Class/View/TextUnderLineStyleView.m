//
//  TextUnderLineStyleView.m
//  InstaMessage
//
//  Created by 何少博 on 16/8/3.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "TextUnderLineStyleView.h"

@interface TextUnderLineStyleView ()
@property (weak, nonatomic) IBOutlet UIButton *cancel;
@property (weak, nonatomic) IBOutlet UIButton *Done;


@end


@implementation TextUnderLineStyleView



-(void)awakeFromNib{
    [super awakeFromNib];

}
-(void)layoutSubviews{
    [super layoutSubviews];

}
- (IBAction)onDoneButtonClick:(UIButton *)sender {
    [self removeFromSuperview];
}
- (IBAction)onCancelButtonClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(textUnderLineStyleViewCancelButtonClick:)]) {
        [self.delegate textUnderLineStyleViewCancelButtonClick:self];
        [self removeFromSuperview];
    }
}
#pragma mark - action

- (IBAction)onUnderStyleNoneClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(textUnderLineStyleView:chooseUnderlineStyle:)]) {
        [self.delegate textUnderLineStyleView:self chooseUnderlineStyle:NSUnderlineStyleNone];
    }
}
- (IBAction)onUnderStyleSingleClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(textUnderLineStyleView:chooseUnderlineStyle:)]) {
        [self.delegate textUnderLineStyleView:self chooseUnderlineStyle:NSUnderlineStyleSingle];
    }
}
- (IBAction)onUnderStylethickClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(textUnderLineStyleView:chooseUnderlineStyle:)]) {
        [self.delegate textUnderLineStyleView:self chooseUnderlineStyle:NSUnderlineStyleThick];
    }
}
- (IBAction)onUnderStyleDoubleClick:(UIButton *)sender {
    if ([self.delegate respondsToSelector:@selector(textUnderLineStyleView:chooseUnderlineStyle:)]) {
        [self.delegate textUnderLineStyleView:self chooseUnderlineStyle:NSUnderlineStyleDouble];
    }
}

@end
