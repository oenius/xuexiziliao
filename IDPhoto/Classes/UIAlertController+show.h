//
//  UIAlertController+show.h
//  IDPhoto
//
//  Created by 何少博 on 17/4/27.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    AlertActionTypeCancel,
    AlertActionTypeOK,
} AlertActionType;

//typedef <#returnType#>(^<#name#>)(<#arguments#>);
@interface UIAlertController (show)

+(void)showMessageOKAndCancel:(NSString *)message action:(void(^)(AlertActionType actionType)) block;


@end
