//
//  TextMdel.h
//  InstaMessage
//
//  Created by 何少博 on 16/8/1.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextMdel : NSObject
@property (nonatomic,strong) NSString * cellImagePath;

-(instancetype)initWithImageArray:(NSArray*)imageArary;
+(instancetype)themeItemModelWithImageArray:(NSArray*)imageArary;

@end
