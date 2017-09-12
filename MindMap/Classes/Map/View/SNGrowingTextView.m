//
//  SNGrowingTextView.m
//  MindMap
//
//  Created by 何少博 on 2017/8/8.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNGrowingTextView.h"

@interface SNGrowingTextView ()

@property (nonatomic,strong) UITextView *placeholderView;

@end


@implementation SNGrowingTextView


-(UITextView *)placeholderView{
    if (_placeholderView == nil) {
        _placeholderView = [[UITextView alloc]init];
    }
    return _placeholderView;
}

#pragma mark - setter
-(void)setPlaceholder:(NSString *)placeholder{
    _placeholder = placeholder;
    self.placeholderView.text = _placeholder;
}

-(void)setText:(NSString *)text{
    [super setText:text];
    [self textChanged:nil];
}

-(void)setAttributedText:(NSAttributedString *)attributedText{
    [super setAttributedText:attributedText];
    [self textChanged:nil];
}

-(void)setFont:(UIFont *)font{
    [super setFont:font];
    self.placeholderView.font = font;
}

#pragma mark - init
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configure];
    }
    return self;
}


-(instancetype)initWithFrame:(CGRect)frame textContainer:(NSTextContainer *)textContainer{
    self = [super initWithFrame:frame textContainer:textContainer];
    if (self) {
        [self configure];
    }
    return self;
}


-(void)layoutSubviews{
    [super layoutSubviews];
    [self textChanged:nil];
}

-(void)textChanged:(NSNotification *)noti{
    self.placeholderView.hidden = !(self.text.length == 0);
   
    CGFloat width = [self.attributedText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size.width;
    NSInteger length = ceil(width);
    width = length + self.textContainerInset.left + self.textContainerInset.right;
    
    if (_autoGrowingWidth) {
        if (width < self.minWidth) {
            width = self.minWidth;
        }
        else if (width > self.maxWidth){
            width = self.maxWidth;
        }
    }else{
        width = self.bounds.size.width;
    }
    
    CGFloat height = ceil([self sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)].height);
    CGFloat maxHeight = self.font.lineHeight * self.maxLine + self.textContainerInset.top + self.textContainerInset.bottom;
    self.scrollEnabled = height > maxHeight;
    self.showsVerticalScrollIndicator = self.scrollEnabled;
    CGRect oldFrame = self.frame;
    if (self.growingDirection == SNGrowingTextViewDirectionUp) {
        oldFrame = CGRectOffset(oldFrame, 0, oldFrame.size.height - MIN(maxHeight, height));
    }
    oldFrame.size.height = MIN(maxHeight, height);
    oldFrame.size.width = width;
    self.frame = oldFrame; 
}



-(void)loadComponent{
    self.placeholderView.frame = self.bounds;
    self.placeholderView.userInteractionEnabled = NO;
    self.placeholderView.backgroundColor = [UIColor clearColor];
    self.placeholderView.translatesAutoresizingMaskIntoConstraints = YES;
    self.placeholderView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.placeholderView.font = self.font;
    self.placeholderView.textAlignment = NSTextAlignmentCenter;
    self.placeholderView.textColor = self.placeholderColor;
    self.placeholderView.hidden = !(self.text.length == 0);
    [self addSubview:self.placeholderView];
    self.placeholderView.text = self.placeholder;
}
-(void)configure{
    _placeholder = @"";
    _growingDirection = SNGrowingTextViewDirectionDwon;
    _placeholderColor = [UIColor lightGrayColor];
    _autoGrowingWidth = YES;
    _minWidth = 30;
    _maxWidth = 200;
    _maxLine = NSIntegerMax;
    
    [self loadComponent];
    self.translatesAutoresizingMaskIntoConstraints = YES;
    UIEdgeInsets inset = self.textContainerInset;
    inset.left = self.textContainer.lineFragmentPadding;
    inset.right = self.textContainer.lineFragmentPadding;
    self.textContainerInset = inset;
    self.textContainer.lineFragmentPadding = 0;
    
    self.textAlignment = NSTextAlignmentCenter;
    self.layer.cornerRadius = 5;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.layer.borderWidth = 1;
    
    self.scrollEnabled = YES;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:self];
    self.text = @"";
    [self textChanged:nil];
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}
@end
