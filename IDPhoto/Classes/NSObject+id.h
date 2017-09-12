//
//  NSObject+id.h
//  IDPhoto
//
//  Created by 何少博 on 17/4/21.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDConst.h"
@interface NSObject (id)

-(BOOL)isPad;
-(CGSize)getImageSizeWithType:(NSString *)idType;
-(UIColor *)getBGColorWithType:(IDPhotoBGType)type;
@end
