//
//  SNTSBaseModel.h
//  MindMap
//
//  Created by 何少博 on 2017/8/23.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNTSBaseModel : NSObject

@property (copy, nonatomic) NSString *name;

-(instancetype)initWithNSDictionary:(NSDictionary *)dic;

@end
