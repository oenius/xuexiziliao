//
//  ThemeItemModel.m
//  InstaMessage
//
//  Created by 何少博 on 16/7/27.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "ThemeItemModel.h"


@interface ThemeItemModel ()


@end


@implementation ThemeItemModel


-(instancetype)initWithDictionary:(NSDictionary *)dictionary{
    self = [super init];
    if (self) {
        _photoEnabled = [dictionary objectForKey:@"photo enabled"];;
        _thumbImageName = [dictionary objectForKey:@"thumb image"];
        _imageName = [dictionary objectForKey:@"image"];
        _fontName = [dictionary objectForKey:@"font name"];
        _bottomImage = [dictionary objectForKey:@"bottom image"];
        _attribute = [dictionary objectForKey:@"attribute"];
    }
    return self;
}

+(instancetype)themeItemModelWithDictionary:(NSDictionary *)dictionary{
    return [[self alloc] initWithDictionary:dictionary];
}

//从plist文件中获取主题数据
+(NSMutableArray *)getAllThemeItemArray{
    NSMutableArray * tempArray = [NSMutableArray array];
    
    NSString * path_Base = [[NSBundle mainBundle]pathForResource:@"themeGroup_Base" ofType:@"plist"];
    NSDictionary * dic_Base= [NSDictionary dictionaryWithContentsOfFile:path_Base];
    NSArray * itemarray_Base = [dic_Base objectForKey:@"theme items"];
    [tempArray addObject:itemarray_Base];
    
    NSString * path_Photo = [[NSBundle mainBundle]pathForResource:@"themeGroup_Photo" ofType:@"plist"];
    NSDictionary * dic_Photo= [NSDictionary dictionaryWithContentsOfFile:path_Photo];
    NSArray * itemarray_Photo = [dic_Photo objectForKey:@"theme items"];
    [tempArray addObject:itemarray_Photo];
    
    if (tempArray.count == 0) return nil;
    return tempArray;
}
@end
