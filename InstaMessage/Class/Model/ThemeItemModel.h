//
//  ThemeItemModel.h
//  InstaMessage
//
//  Created by 何少博 on 16/7/27.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ThemeItemModel : NSObject

@property (nonatomic,strong)NSString * photoEnabled;

@property (nonatomic,strong)NSString * thumbImageName;

@property (nonatomic,strong)NSString * bottomImage;

@property (nonatomic,strong)NSString * imageName;

@property (nonatomic,strong)NSString * fontName;

@property (nonatomic,strong)NSString * attribute;

+(NSMutableArray*)getAllThemeItemArray;

-(instancetype)initWithDictionary:(NSDictionary*)dictionary;
+(instancetype)themeItemModelWithDictionary:(NSDictionary *)dictionary;



@end
