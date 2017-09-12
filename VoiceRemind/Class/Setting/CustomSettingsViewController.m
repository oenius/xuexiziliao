//
//  CustomSettingsViewController.m
//  VoiceRemind
//
//  Created by 何少博 on 16/8/24.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "CustomSettingsViewController.h"
#import "UIColor+x.h"
#import <EventKit/EventKit.h>

@interface CustomSettingsViewController ()
@property (strong,nonatomic) NSIndexPath * indexPath;
@end

@implementation CustomSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Settings", @"Settings");
    self.tableView.backgroundColor = color_eaeaea;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)setProductSectionItems {
    [super setProductSectionItems];
    [self.productSectionDataArray addObject:NSLocalizedString(@"Sync to Calendar", @"Sync to Calendar")];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
        
    }
    if (indexPath.section == 0) {
        self.indexPath = indexPath;
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellId"];
        BOOL shouldeSyncCalendar = [[NSUserDefaults standardUserDefaults] boolForKey:kSyncCalendar];
        UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        aSwitch.on = shouldeSyncCalendar;
        [aSwitch addTarget:self action:@selector(onSwitchClicked:)  forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = aSwitch;
        cell.textLabel.text = NSLocalizedString(@"Sync to Calendar", @"Sync to Calendar");
    }else{
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath ];
    }
    return cell;
}
-(void)onSwitchClicked:(id)sender{
    UISwitch *buttonSwitch = ((UISwitch *)sender);
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    if (buttonSwitch.on == NO) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSyncCalendar];
    }
    if (buttonSwitch.on == YES) {
        buttonSwitch.on = NO;
        if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
        {
            // the selector is available, so we must be on iOS 6 or newer
            [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (error)
                    {
                        LOG(@"未知错误");
                        buttonSwitch.on = NO;
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSyncCalendar];
                    }
                    else if (!granted)
                    {
                        NSString * message = NSLocalizedString(@"setting.permissions", @"No permission in current app,whether go to settings?");
                        UIAlertController *alertVC=[UIAlertController alertControllerWithTitle:NSLocalizedString(@"user.Prompt", @"Prompt") message:message preferredStyle: UIAlertControllerStyleAlert];
                        
                        UIAlertAction *cancelAct=[UIAlertAction actionWithTitle:NSLocalizedString(@"common.Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                            buttonSwitch.on = NO;
                            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kSyncCalendar];
                        }];
                        UIAlertAction *settingAct=[UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", @"Settings") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                            if([[UIApplication sharedApplication] canOpenURL:url]) {
                                [[UIApplication sharedApplication] openURL:url];
                            }
                        }];
                        [alertVC addAction:cancelAct];
                        [alertVC addAction:settingAct];
                        [self presentViewController:alertVC animated:YES completion:^{
                        }];
                    }
                    else
                    {
                        buttonSwitch.on = YES;
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kSyncCalendar];
                    }
                });
            }];
            
        }
        
    }
    
}


@end
