//
//  NSData+DT.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/23.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "NSData+DT.h"

@implementation NSData (DT)
///遵循NSCoding协议的归档
+(NSData *)archivedData:(id)object{
    return [NSKeyedArchiver archivedDataWithRootObject:object];
}
///遵循NSCoding 协议的解档
-(id)unarchiveObject{
    return [NSKeyedUnarchiver unarchiveObjectWithData:self];
}
@end
