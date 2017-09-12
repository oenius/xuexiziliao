//
//  FontPickerView.h
//  fonttext
//
//  Created by Mac_H on 16/6/30.
//  Copyright © 2016年 何少博. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FontPickerViewDelegate <NSObject>

-(void)setSelectFontName:(NSString *)fontName;

@end

@interface FontPickerView : UIView
@property (nonatomic,weak)id<FontPickerViewDelegate> delegate;
@property (nonatomic,strong)NSString * preViewString;
@end
