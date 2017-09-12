//
//  FontPickerView.h
//  InstaMessage
//
//  Created by Mac_H on 16/8/3.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FontPickerViewDelegate;

@interface FontPickerView : UIView

@property (nonatomic,weak) id<FontPickerViewDelegate> delegate;

@end

@protocol FontPickerViewDelegate <NSObject>

-(void)fontPickerView:(FontPickerView*)fontPickerView chooseFontName:(NSString *)fontName;
-(void)fontPickerViewCancelButtonClick:(FontPickerView*)fontPickerView;
-(void)fontPickerViewDoneButtonClick:(FontPickerView*)fontPickerView;

@end