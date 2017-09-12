//
//  ImageManage.m
//  MemoryTurnCard
//
//  Created by 何少博 on 16/10/24.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "ImageManage.h"

@implementation ImageManage

+(NSArray*)imageWithType:(GameImageType)gameImageType reutrnPath:(BOOL)returnPath{
    NSString * plistName;
    switch (gameImageType) {
        case GameImageTypeFruit:
            plistName = @"FruitName.plist";
            break;
        case GameImageTypeAnimal:
            plistName = @"AnimalName.plist";
            break;
        case GameImageTypeABC:
            plistName = @"ABCName.plist";
            break;
        case GameImageTypeOther:
            plistName = @"OtherName.plist";
            break;
        default:
            break;
    }
    
    NSString * path = [[NSBundle mainBundle]pathForResource:plistName ofType:nil];
    NSArray * imageNameArray = [NSArray arrayWithContentsOfFile:path];
    if (returnPath == NO) {
        return imageNameArray;
    }
    NSString * boundlePath = [[NSBundle mainBundle]bundlePath];
    NSMutableArray * pathArray = [NSMutableArray array];
    for (NSString * name in imageNameArray) {
        NSString * imagePath = [boundlePath stringByAppendingPathComponent:name];
        [pathArray addObject:imagePath];
    }
    return pathArray;
}

+(NSArray*)imageNameWithType:(GameImageType)gameImageType{
   return [ImageManage imageWithType:gameImageType reutrnPath:NO];
}

+(NSArray*)imagePathWithType:(GameImageType)gameImageType{
    return [ImageManage imageWithType:gameImageType reutrnPath:YES];
}
@end
