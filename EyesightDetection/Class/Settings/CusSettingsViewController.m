//
//  CusSettingsViewController.m
//  AngleMeter
//
//  Created by 何少博 on 16/9/19.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "CusSettingsViewController.h"
#import "NPCommonConfig.h"
@interface CusSettingsViewController ()
//@property (assign,nonatomic)BOOL isTempSwitch;
@end

@implementation CusSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"Setting", @"Settings");
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    self.view.backgroundColor = color_f2f2f2;
    self.navigationController.navigationBar.barTintColor = color_2bc083;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(natitialViewChange) name:@"natitialViewChange" object:nil];
}
-(void)natitialViewChange{
    self.nativeAdView.alpha = 1;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.nativeAdView.alpha = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setProductSectionItems {
    [super setProductSectionItems];
    [self.productSectionDataArray addObject:NSLocalizedString(@"Type of visual acuity chart", @"Type of eye chart")];
    [self.productSectionDataArray addObject:NSLocalizedString(@"Shake", @"Shake")];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * subClassCellID = @"subClassCellID";
    UITableViewCell * cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:subClassCellID];
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:subClassCellID];
            }
            cell.textLabel.text = NSLocalizedString(@"Type of visual acuity chart", @"Type of eye chart");
            cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults]objectForKey:ShiLiTableStyle];;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:subClassCellID];
            if (cell == nil) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:subClassCellID];
            }
            cell.textLabel.text = NSLocalizedString(@"Shake", @"Shake");
            UISwitch * aSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
            [aSwitch addTarget:self action:@selector(onSwichVlaueChange:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = aSwitch;
            aSwitch.on = [[NSUserDefaults standardUserDefaults]boolForKey:YaoYiYao];
            if ([self lockYaoYiYao]) {
                aSwitch.on = NO;
            }
//            _isTempSwitch = aSwitch.on;
        }
    }else{
        cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0 ) {
        if (indexPath.row == 1) return;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Type of visual acuity chart", @"Type of eye chart") preferredStyle:UIAlertControllerStyleAlert];
        //rate action
        UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
        UIAlertAction * style1 = [UIAlertAction actionWithTitle:@"1.0" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            cell.detailTextLabel.text = @"1.0";
            [[NSUserDefaults standardUserDefaults]setObject:@"1.0" forKey:ShiLiTableStyle];
            [[NSUserDefaults standardUserDefaults]synchronize];
            NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
            // 发布通知，把要传递的数据存入字典中，
            [notification postNotificationName:ShiLiTableStyleChanged object:self userInfo:@{@"info":@"1.0"}];
            
        }];
        UIAlertAction * style2 = [UIAlertAction actionWithTitle:@"5.0" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            cell.detailTextLabel.text = @"5.0";
            [[NSUserDefaults standardUserDefaults]setObject:@"5.0" forKey:ShiLiTableStyle];
            [[NSUserDefaults standardUserDefaults]synchronize];
            NSNotificationCenter * notic = [NSNotificationCenter defaultCenter];
            [notic postNotificationName:ShiLiTableStyleChanged object:self userInfo:@{@"info":@"5.0"}];
        }];
        [alert addAction:style1];
        [alert addAction:style2];
        [self presentViewController:alert animated:YES completion:NULL];
    }else{
        [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    }
}

-(void)onSwichVlaueChange:(UISwitch*)sender{

//    if (sender.on == _isTempSwitch) return;
    
    if ([self lockYaoYiYao]) {
        [[NPCommonConfig shareInstance] showPinlunJiesuoView];
        sender.on = NO;
        return;
    }
    
    [[NSUserDefaults standardUserDefaults]setBool:sender.on forKey:YaoYiYao];
    [[NSUserDefaults standardUserDefaults]synchronize];
    NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
    // 发布通知，把要传递的数据存入字典中，
    [notification postNotificationName:YaoYiYao object:self userInfo:@{YaoYiYao:[NSNumber numberWithBool:sender.on]}];
}

-(void)removeAdNotification:(NSNotification *)notification{
    [super removeAdNotification:notification];
    [self.tableView reloadData];
}

-(BOOL)lockYaoYiYao{
    BOOL  lock = NO;
    BOOL pinglun = [NPCommonConfig shareInstance].isAnyVersionRated;
    BOOL shangxian = [NPCommonConfig shareInstance].isCurrentVersionOnline;
    if (pinglun == NO && shangxian == YES) {
        lock = YES;
    }
    return lock;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
