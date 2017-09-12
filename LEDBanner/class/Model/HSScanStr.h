//
//  HSScanStr.h
//  GetImageDataTest
//
//  Created by Mac_H on 16/6/18.
//  Copyright © 2016年 何少博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface HSScanStr : NSObject
@property(nonatomic,assign)NSShowModel showModel;
@property (nonatomic,strong)UIColor * fontColor;
@property (nonatomic,strong)UIColor * offColor;
@property (nonatomic,strong)UIFont * font;
@property (nonatomic,assign) BOOL ledDirection;
-(NSArray *)getStingDotMatrix:(NSString *)showString;
@end
