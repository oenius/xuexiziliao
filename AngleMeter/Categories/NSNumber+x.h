//
//  NSNumber+x.h
//  iWeibo
//
//  Created by czh0766 on 12-4-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (x)

+(NSNumber *)numberWithHex:(NSString*)hexValue;

-(NSString*) hexStringValue;

@end
