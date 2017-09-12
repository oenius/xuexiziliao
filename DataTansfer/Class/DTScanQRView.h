//
//  DTScanQRView.h
//  DataTansfer
//
//  Created by 何少博 on 17/5/26.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTScanQRView : UIView

-(instancetype)initWithFrame:(CGRect)frame ;

- (void)startScanAnimation;
- (void)stopScanAnimation;
@end
