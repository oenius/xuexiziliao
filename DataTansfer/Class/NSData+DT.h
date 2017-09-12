//
//  NSData+DT.h
//  DataTansfer
//
//  Created by 何少博 on 17/5/23.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (DT)
///遵循NSCoding协议的归档
+(NSData *)archivedData:(id)object;
///遵循NSCoding 协议的解档
-(id)unarchiveObject;
@end
