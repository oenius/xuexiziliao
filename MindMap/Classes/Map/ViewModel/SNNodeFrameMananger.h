//
//  SNNodeFrameMananger.h
//  MindMap
//
//  Created by 何少博 on 2017/8/15.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class SNNodeView;
typedef enum : NSUInteger {
    SNNodeImageModeLimited,
    SNNodeImageModeFreedom,
} SNNodeImageMode;
@interface SNNodeFrameMananger : NSObject

@property (nonatomic,assign) BOOL resized;
@property (nonatomic,assign) CGFloat imageWidthOnFreedomMode;
@property (nonatomic,assign) SNNodeImageMode imageMode;
@property (nonatomic,strong) NSAttributedString * attributeText;
@property (nonatomic,assign) UIEdgeInsets textContainerInset;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) UIImage *tipImage;
@property (nonatomic,assign) CGFloat innerWidth;
@property (nonatomic,assign) CGRect recommendContainerBounds;
@property (nonatomic,assign) CGRect textFrame;
@property (nonatomic,assign) CGRect imageFrame;
@property (nonatomic,assign) CGRect tipImageFrame;
@property (nonatomic,assign) CGFloat childHeight;
@property (nonatomic,assign) CGFloat height;
@property (nonatomic,assign) CGPoint A;
@property (nonatomic,assign) CGPoint B;
@property (nonatomic,assign) CGPoint startAnchor;
@property (nonatomic,assign) CGPoint midAnchor;
@property (nonatomic,assign) CGPoint endAnchor;
@property (weak, nonatomic) SNNodeView *node;

-(instancetype)initWithNote:(SNNodeView *)node;
-(void)updateNodeFrame;

@end
