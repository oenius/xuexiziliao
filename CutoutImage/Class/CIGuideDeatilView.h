//
//  CIGuideDeatilView.h
//  CutoutImage
//
//  Created by 何少博 on 17/2/17.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    CIGuideDeatilPictureZero,
    CIGuideDeatilPictureOne,
    CIGuideDeatilPictureTwo,
    CIGuideDeatilPictureThree,
    CIGuideDeatilPictureFour,
} CIGuideDeatilPicture;


@interface CIGuideDeatilView : UIView

-(instancetype)initWithFrame:(CGRect)frame type:(CIGuideDeatilPicture)pictrue;

@end
