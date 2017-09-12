//
//  SNTSSectionBaseModel.h
//  MindMap
//
//  Created by 何少博 on 2017/8/23.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNTSSectionBaseModel : NSObject
@property (copy, nonatomic) NSString *name;
@property (strong, nonatomic) NSMutableArray *childs;

-(instancetype)initWithDic:(NSDictionary *)dic;
@end
