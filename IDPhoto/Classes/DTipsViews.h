//
//  DTipsViews.h
//  IDPhoto
//
//  Created by 何少博 on 17/5/9.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTipsViews : NSObject
@property (nonatomic,strong)NSArray* tipViews;
-(void)addKnowBtnTarget:(id)target action:(SEL)action;
@end

@interface DTipsView1 : UIView
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@end

@interface DTipsView2 : UIView
@property (weak, nonatomic) IBOutlet UILabel *tipLabel;
@end

@interface DTipsView3 : UIView
@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UIButton *knowBtn;

@end
