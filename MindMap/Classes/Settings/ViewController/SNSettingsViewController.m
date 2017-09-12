//
//  SNSettingsViewController.m
//  MindMap
//
//  Created by 何少博 on 2017/8/28.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNSettingsViewController.h"
#import "NPCommonConfig+FeiFan.h"
#import "ShenHeViewController.h"
#import "SNBaseNavigationController.h"
#import "MBProgressHUD.h"
@interface SNSettingsViewController ()

@end

@implementation SNSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = nil;
    UIImage * image = [UIImage imageNamed:@"bg"];
    self.view.layer.contents = (__bridge id _Nullable)(image.CGImage);
}


-(void)setPaymentSectionItems{
    [self.purchaseSectionDataArray removeAllObjects];
   
    NSArray * array = @[
                        NSLocalizedString(@"Subscribe_here",@"订阅"),
                        NSLocalizedString(@"dj_Restore.Purchase",@"恢复购买"),
                        NSLocalizedString(@"Privacy_Policy.new", @"隐私政策"),
                        NSLocalizedString(@"service.detial", @"服务条款"),
                        NSLocalizedString(@"Subscription Details", @"订阅详情")];
    [self.purchaseSectionDataArray addObjectsFromArray:array];
}

-(UIColor *)tableViewBackgroundColor{
    return [UIColor clearColor];
}

-(UIColor *)tableViewCellBackgroundColor{
    return [UIColor clearColor];
}
-(UIColor *)tableViewCellTextColor{
    return [UIColor colorWithRed:75/255.0 green:80/255.0 blue:101/255.0 alpha:1.0];
}

-(UIColor *)tableViewHeadViewBackgroundColor{
    return [UIColor colorWithWhite:1 alpha:0.3];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
            {
                [[NPCommonConfig shareInstance] showVipViewControllerForController:self];
            }
                break;
            case 1:
            {
                [[NPCommonConfig shareInstance] restoreSubscription];
                
            }
                break;
            case 2:
            {
                NSURL * url = [NSURL URLWithString:[NPCommonConfig shareInstance].privacyPolicyUrl];
                [[UIApplication sharedApplication] openURL:url];
            }
                break;
            case 3:
            {
                NSURL * url = [NSURL URLWithString:[NPCommonConfig shareInstance].teamOfUseUrl];
                [[UIApplication sharedApplication] openURL:url];
            }
                break;
            case 4:
            {
                ShenHeViewController *vc = [[ShenHeViewController alloc] init];
                SNBaseNavigationController * navi = [[SNBaseNavigationController alloc]initWithRootViewController:vc];
                [self presentViewController:navi animated:YES completion:nil];
            }
                break;
            default:
            {
                ShenHeViewController *vc = [[ShenHeViewController alloc] init];
                SNBaseNavigationController * navi = [[SNBaseNavigationController alloc]initWithRootViewController:vc];
                [self presentViewController:navi animated:YES completion:nil];
            }
                break;
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }else{
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}


@end
