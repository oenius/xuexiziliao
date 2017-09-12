//
//  PotoContentView.h
//  InstaMessage
//
//  Created by 何少博 on 16/7/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "He_enum.h"

@protocol PotoContentViewDelegate ;


@interface PotoContentView : UIView

@property (nonatomic,weak) id<PotoContentViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

-(BOOL)isHiddenBannerView;
@end



@protocol PotoContentViewDelegate <NSObject>

-(void)potoContentView:(PotoContentView *)potoContentView actionWithTag:(PhotoActionTag)tag;
-(void)potoContentView:(PotoContentView *)potoContentView duiBiDuValue:(CGFloat)value;
-(void)potoContentView:(PotoContentView *)potoContentView maoBoLiValue:(CGFloat)value;
-(void)potoContentView:(PotoContentView *)potoContentView baoHeDuValue:(CGFloat)value;
-(void)potoContentView:(PotoContentView *)potoContentView liangDuValue:(CGFloat)value;



@end
