//
//  SNTools.m
//  MindMap
//
//  Created by 何少博 on 2017/8/7.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNTools.h"
#import "SNFileModel.h"
#import "SNMindMapViewController.h"
#import "NPCommonConfig+FeiFan.h"

NSString * const kAssetSuffix       = @".asset";
NSString * const kMapSuffix         = @".snmap";
static      BOOL _isShowADSafe      = YES;
@implementation SNTools

+(NSString*)documentPath{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
}





+(void)showADRandom:(NSInteger) random forController:(UIViewController *)controller{
    if (_isShowADSafe == NO) { return;}
 
    if ([[NPCommonConfig shareInstance]shouldShowAdvertise] ) {
        if ([[NPCommonConfig shareInstance] getProbabilityFor:1 from:random]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _isShowADSafe = NO;
                if([[NPCommonConfig shareInstance] feifan_shouldShowAd]){
                    [[NPCommonConfig shareInstance] showFullScreenAdWithNativeAdAlertViewForController:controller];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        _isShowADSafe = YES;
                    });
                }
            });
        }
    }
}




@end
