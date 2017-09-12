//
//  CIGuideDeatilView.m
//  CutoutImage
//
//  Created by 何少博 on 17/2/17.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "CIGuideDeatilView.h"

@interface CIGuideDeatilView ()

@property (strong, nonatomic) UILabel *label;

@property (strong, nonatomic) UIImageView *imageView;

@end



@implementation CIGuideDeatilView

-(instancetype)initWithFrame:(CGRect)frame type:(CIGuideDeatilPicture)pictrue{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc]init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
        
        self.label = [[UILabel alloc]init];
        _label.numberOfLines = 5;
        _label.adjustsFontSizeToFitWidth = YES;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
        [self addSubview:self.label];
        
        NSString * text ;
        NSString * imageName;
        switch (pictrue) {
            case CIGuideDeatilPictureZero:
                text = CI_SelectTheArea1;
                imageName =@"IMG_2000.jpg";
                break;
            case CIGuideDeatilPictureOne:
                text = CI_CompleteTheArea2;
                imageName =@"IMG_2001.jpg";
                break;
            case CIGuideDeatilPictureTwo:
                text = CI_RemoveArea3;
                imageName =@"IMG_2002.jpg";
                break;
            case CIGuideDeatilPictureThree:
                text = CI_ReviseEraser4;
                imageName =@"IMG_2003.jpg";
                break;
            case CIGuideDeatilPictureFour:
                text = CI_Completed5;
                imageName =@"IMG_2004.jpg";
                break;
            default:
                break;
        }
        self.label.text = text;
        NSString * path = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
        self.imageView.image = [UIImage imageWithContentsOfFile:path];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    self.imageView.frame = CGRectMake(0, 0, width, height/4*3);
    self.label.frame = CGRectMake(0, CGRectGetMaxY(self.imageView.frame), width, height/4);
}

//-(CGSize)labelSize:(UILabel*)label maxWidth:(CGFloat)maxWidth attributes:(NSDictionary *)attributes{
//    //    textLabel.font = tfont;
//    //    textLabel.lineBreakMode =NSLineBreakByTruncatingTail ;
//    //限制最大高度和最大宽度
//    CGSize size =CGSizeMake(maxWidth,MAXFLOAT);
//    
//    //获取文本需要的size，限制宽度
//    CGSize  actualsize =[label.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:attributes context:nil].size;
//    return actualsize;
//}
//
//-(NSDictionary *)settingAttributesWithLineSpacing:(CGFloat)lineSpacing FirstLineHeadIndent:(CGFloat)firstLineHeadIndent Font:(UIFont *)font TextColor:(UIColor *)textColor{
//    //分段样式
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    //行间距
//    paragraphStyle.lineSpacing = lineSpacing;
//    //首行缩进
//    paragraphStyle.firstLineHeadIndent = firstLineHeadIndent*font.pointSize;
//    //富文本样式
//    NSDictionary *attributeDic = @{
//                                   NSFontAttributeName : font,
//                                   NSParagraphStyleAttributeName : paragraphStyle,
//                                   NSForegroundColorAttributeName : textColor
//                                   };
//    return attributeDic;
//}


@end
