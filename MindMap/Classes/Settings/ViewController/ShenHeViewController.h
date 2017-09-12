//
//  ShenHeViewController.h
//  PrivateAlbumV1.0
//
//  Created by 刘胜 on 2017/8/22.
//  Copyright © 2017年 刘胜. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ShenHedelegate <NSObject>

- (void)cancelClick;

@end

@interface ShenHeViewController : UIViewController

@property (nonatomic, weak) id <ShenHedelegate> delegate;

@end
