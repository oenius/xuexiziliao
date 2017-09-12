//
//  FontPickerView.m
//  fonttext
//
//  Created by Mac_H on 16/6/30.
//  Copyright © 2016年 何少博. All rights reserved.
//

#import "FontPickerView.h"

@interface FontPickerView ()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (nonatomic,strong)NSArray * fontList;
@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (nonatomic,strong) NSString * fontName;

@end


@implementation FontPickerView

-(void)awakeFromNib{
    [super awakeFromNib];
    self.pickerView.delegate = self;
    self.pickerView.dataSource =self;
    self.contentView.layer.cornerRadius = 15;
    self.contentView.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.doneBtn setTitle:NSLocalizedString(@"common.Done", @"Done") forState:UIControlStateNormal];
    [self.cancleBtn setTitle:NSLocalizedString(@"common.Cancel", @"Cancel") forState:UIControlStateNormal];
    
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.textLabel.text = self.preViewString;
    [self.pickerView selectRow:0 inComponent:0 animated:YES];
    [self pickerView:self.pickerView didSelectRow:0 inComponent:0];
}

- (IBAction)onDoneBtnClick:(UIButton *)sender {
    
    if ([self.delegate respondsToSelector:@selector(setSelectFontName:)]) {
        [self.delegate setSelectFontName:self.fontName];
    }
    
    [self removeFromSuperview];
}
- (IBAction)onCancelBtnClick:(UIButton *)sender {
    [self removeFromSuperview];
}

-(NSArray *)fontList{
    if (!_fontList) {
        NSString * path = [[NSBundle mainBundle]pathForResource:@"UIFontList.plist" ofType:nil];
        _fontList = [NSArray arrayWithContentsOfFile:path];
    }
    return _fontList;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.fontList.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return self.fontList[row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.textLabel.font = [UIFont fontWithName:self.fontList[row] size:18];
    self.fontName = self.fontList[row];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
