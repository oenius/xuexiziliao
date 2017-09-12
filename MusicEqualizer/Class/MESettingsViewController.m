//
//  MESettingsViewController.m
//  MusicEqualizer
//
//  Created by 何少博 on 16/12/26.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "MESettingsViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CVWifiUploadViewController.h"
#import "NPCommonConfig.h"
@interface MESettingsViewController ()

@property (assign,nonatomic) BOOL isShouldShowAD;

@end

@implementation MESettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.title = self.tabBarItem.title;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setProductSectionItems {
    [super setProductSectionItems];
    
    [self.productSectionDataArray addObject:MEL_iTunsSyn];
    [self.productSectionDataArray addObject:MEL_WiFiTransfer];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if ([[NPCommonConfig shareInstance] shouldShowAdvertise]) {
        if (self.isShouldShowAD) {
            [[NPCommonConfig shareInstance] showFullScreenAdWithNativeAdAlertViewForController:self];
            self.isShouldShowAD = NO;
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *title = [self titleForIndexPath:indexPath];
    if ([title isEqualToString:MEL_iTunsSyn]) {
        [self playGuide];
    }else if ([title isEqualToString:MEL_WiFiTransfer]){
        [self wifiImprot];
    }
    else{
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}


-(void)playGuide{
    self.isShouldShowAD = YES;
    NSURL * url = [[NSBundle mainBundle]URLForResource:@"GuideVideo.mp4" withExtension:nil];
    MPMoviePlayerViewController * playCon = [[MPMoviePlayerViewController alloc]initWithContentURL:url];
    [self presentMoviePlayerViewControllerAnimated:playCon];
    playCon.moviePlayer.movieSourceType=MPMovieSourceTypeFile;
    [playCon.moviePlayer play];
}

-(void)wifiImprot{
    self.isShouldShowAD = YES;
    CVWifiUploadViewController *wifiVc = [[CVWifiUploadViewController alloc] initWithNibName:@"CVWifiUploadViewController" bundle:nil];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:wifiVc];
    [self presentViewController:nvc animated:YES completion:^{
        
    }];
}



-(UIColor *)tableViewCellTextColor{
    return [UIColor colorWithRed:239/255.0 green:239/255.0 blue:239/255.0 alpha:1];
}
-(UIColor *)tableViewBackgroundColor{
    return [UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:1];
}
-(UIColor *)tableViewHeadViewTextColor{
    return [UIColor whiteColor];
}
-(UIColor *)tableViewCellBackgroundColor{
    return [UIColor colorWithRed:38/255.0 green:38/255.0 blue:38/255.0 alpha:1];
}
-(UIColor *)tableViewHeadViewBackgroundColor
{
    return [UIColor colorWithRed:25/255.0 green:25/255.0 blue:25/255.0 alpha:1];
}

@end
