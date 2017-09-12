//
//  IDWomenClothesView.m
//  IDPhoto
//
//  Created by 何少博 on 17/4/28.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "IDWomenClothesView.h"

@implementation IDWomenClothesView

-(instancetype)initWithSelected:(ClothesBlock)block{
    NSString * path = [[NSBundle mainBundle]pathForResource:@"womenClothes" ofType:@"plist"];
    NSArray * array = [NSArray arrayWithContentsOfFile:path];
    self = [super initDataSource:array didSelected:block];
    if (self) {
        
    }
    return self;
}
-(void)clotheSelectBlock:(ClothesBlock)block{
    NSString * path = [[NSBundle mainBundle]pathForResource:@"womenClothes" ofType:@"plist"];
    NSArray * array = [NSArray arrayWithContentsOfFile:path];
    NSMutableArray * clothesPath = [NSMutableArray array];
    for (NSString * name in array) {
        NSString * path = [[NSBundle mainBundle] pathForResource:name ofType:@"png"];
        [clothesPath addObject:path];
    }
    [self setDataSource:clothesPath selectBlock:block];
}


@end
