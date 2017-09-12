//
//  UIAlertController+SN.h
//  MindMap
//
//  Created by 何少博 on 2017/8/19.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (SN)
+(void)alertMessage:(NSString *)message
         controller:(UIViewController*)controller
          okHandler:(void(^)(UIAlertAction * okAction))handler;
@end
