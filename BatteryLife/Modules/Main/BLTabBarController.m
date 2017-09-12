//
//  BLTabBarController.m
//  BatteryLife
//
//  Created by vae on 16/11/16.
//  Copyright © 2016年 vae. All rights reserved.
//

#import "BLTabBarController.h"
#import "BLBatteryLevelController.h"
#import "BLDeviceInfoController.h"
#import "BLUseTimeController.h"
#import "BLSettingController.h"

@interface BLTabBarController ()


@property (nonatomic, strong) NSMutableArray *icons;
@property (nonatomic, strong) NSMutableArray *selectedIcons;

@end

@implementation BLTabBarController

#pragma mark - life cycle

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self loadTabBar];
        [self loadControllers];
    }

    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - loadviews
-(void)loadTabBar{
    
    _icons = [NSMutableArray arrayWithArray:@[@"",
                                              @"",
                                              @"",
                                              @""
                                              ]];
    _selectedIcons = [NSMutableArray arrayWithArray:@[@"",
                                                      @"",
                                                      @"",
                                                      @"",
                                                      ]];
    [self loadTabbarItems];
}


-(void)loadTabbarItems{
    
//    UITabBarItem *
    
    NSLog(@"加载tabbarItems");


}

#pragma mark - Load Tabs
-(void)loadControllers{
    
    NSMutableArray *tabViewController = [[NSMutableArray alloc] init];
    
    //BatteryLevel tab
    BLBatteryLevelController *batteryLevelController = [[BLBatteryLevelController alloc] init];
    

}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
