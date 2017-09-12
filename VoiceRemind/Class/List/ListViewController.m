//
//  ListViewController.m
//  VoiceRemind
//
//  Created by 何少博 on 16/8/24.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "ListViewController.h"
#import "NSObject+x.h"
#import "RemindCellModel.h"
#import "NSString+x.h"
#import "CustomTableViewCell.h"
#import "UIView+x.h"
#import "EditViewController.h"
#import "DirectoryWatcher.h"
#import "MBProgressHUD.h"
#import "SendEmailManager+x.h"
#import "AppDelegate.h"
#import "UIColor+x.h"
#define TiShiLableTag 66666

@interface ListViewController ()
<
UITableViewDelegate,
UITableViewDataSource,
DirectoryWatcherDelegate
>
@property (strong, nonatomic) UITableView *tableView;

@property (strong,nonatomic) NSMutableArray * allRemindDayKeys;
@property (strong,nonatomic) NSMutableArray * sectionTitle;
@property (strong,nonatomic) NSMutableDictionary * allRemindDic;
@property (strong,nonatomic) NSMutableArray * allModel;

@property (strong,nonatomic) UIRefreshControl * refreshControl;
@property (strong,nonatomic) DirectoryWatcher * dirWatcher;
//-------
@property (strong,nonatomic) NSMutableDictionary * voicesDictionary;
@property (strong,nonatomic) NSMutableDictionary * someDayDictionary;
@property (strong,nonatomic) NSMutableDictionary * fileDictionary;
@property (strong,nonatomic) NSString * someDayKey;
@property (strong,nonatomic) NSString * fileKey;
@property (assign,nonatomic) BOOL isCanReloadDate;

@end

static NSString * customCellIDForL = @"CellIDForL";

@implementation ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.dirWatcher = [DirectoryWatcher watchFolderWithPath:Voice_directory delegate:self];
    [self initTableView];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(OrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    [self.refreshControl addTarget:self action:@selector(refreshWithControl) forControlEvents:UIControlEventValueChanged];
}



-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (_isCanReloadDate == YES) {
        [self.tableView reloadData];
        if (self.allModel.count == 0) {
            [self addTishiLabel];
        }else{
            [self removeTishiLabel];
        }
        _isCanReloadDate = NO;
    }
}
-(void)initTableView{
    CGRect frame = ScreenBound;
    if ([self needsShowAdView]) {
        if ([self isIPad]) {
            frame.size.height -= 90;
        }else{
            frame.size.height -= 50;
        }
    }
    CGFloat adjust = 0;
    if ([self needsShowAdView]) {
        if ([self isIPad]) {
            adjust = 90;
        }else{
            adjust = 50;
        }
    }
    self.tableView = [[UITableView alloc]initWithFrame:frame style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = color_eaeaea;
    [self.tableView registerNib:[UINib nibWithNibName:@"CustomTableViewCell" bundle:nil] forCellReuseIdentifier:customCellIDForL];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, adjust+64, 0);
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.tableView];
}

-(float)adViewBottomOffsetFromSuperViewBottom{
    return 112;
}

#pragma mark - 加载

-(NSMutableArray *)sectionTitle{
    if (_sectionTitle == nil) {
        NSMutableArray * tempArrray = [NSMutableArray array];
        for (NSString * key in self.allRemindDayKeys) {
            NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
            [formatter setDateFormat:@"yyyyMMdd"];
            NSDate * date = [formatter dateFromString:key];
            NSString * string = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
            [tempArrray addObject:string];
        }
        _sectionTitle = tempArrray;
    }
    return _sectionTitle;
}

-(UIRefreshControl *)refreshControl{
    if (_refreshControl == nil) {
        _refreshControl = [[UIRefreshControl alloc]init];
        [self.tableView addSubview:_refreshControl];
    }
    return  _refreshControl;
}

-(NSMutableDictionary *)voicesDictionary{
    if (_voicesDictionary == nil) {
        _voicesDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:Voice_PlistPath];
        if (_voicesDictionary.count == 0 || _voicesDictionary == nil) {
            _voicesDictionary = [NSMutableDictionary dictionary];
        }
    }
    return _voicesDictionary;
}
-(NSMutableDictionary *)someDayDictionary{
    if (_someDayDictionary == nil) {
        _someDayDictionary = [self.voicesDictionary objectForKey:self.someDayKey];
    }
    return _someDayDictionary;
}
-(NSMutableDictionary *)fileDictionary{
    if (_fileDictionary == nil) {
        _fileDictionary = [self.someDayDictionary objectForKey:self.fileKey];
    }
    return _fileDictionary;
}

-(NSMutableDictionary *)allRemindDic{
    if (_allRemindDic == nil) {
        _allRemindDic = [NSMutableDictionary dictionaryWithContentsOfFile:Voice_PlistPath];
    }
    return _allRemindDic;
}

-(NSMutableArray *)allRemindDayKeys{
    if (_allRemindDayKeys == nil) {
        //先排序
        NSArray * sortArray = [self.allRemindDic.allKeys sortedArrayUsingSelector:@selector(compareBigToSmail:)];
        _allRemindDayKeys =[NSMutableArray arrayWithArray:sortArray];
    }
    
    return _allRemindDayKeys;
}

//取出某一天的字典
-(NSMutableDictionary *)someDayDic:(NSString*)key{
    return [self.allRemindDic objectForKey:key];
}
//取出某一天的所有字典的key
-(NSMutableArray*)allSomedayRemindKeys:(NSMutableDictionary*)someDayDic{
    NSArray * allKeys = someDayDic.allKeys;
    NSArray * sortArray = [allKeys sortedArrayUsingSelector:@selector(compareBigToSmail:)];
    NSMutableArray * array = [NSMutableArray arrayWithArray:sortArray];
    return array;
}
-(NSMutableArray *)allModel{
    if (_allModel == nil) {
        NSMutableArray * array1 = [NSMutableArray array];
        for (NSString * key1 in self.allRemindDayKeys) {
            NSMutableDictionary * someDayDic = [self someDayDic:key1];
            NSArray * someDayDicAllKeys = [self allSomedayRemindKeys:someDayDic];
            NSMutableArray * array2 = [NSMutableArray array];
            for (NSString * key2 in someDayDicAllKeys) {
                NSDictionary * dic = [someDayDic objectForKey:key2];
                RemindCellModel * model = [RemindCellModel modelWithDic:dic];
                
                if (model.imageType.integerValue != RemindImageType_Done) {
                    NSDate *currentDate  = [NSDate date];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
                    double currentDateD = [[dateFormatter stringFromDate:currentDate]substringToIndex:12].doubleValue;
                    double chooseDateD = [[dateFormatter stringFromDate:model.noticeDate]substringToIndex:12 ].doubleValue;
                    if (currentDateD>=chooseDateD) {
                        model.imageType = [NSNumber numberWithInteger:RemindImageType_Out];
                    }else{
                        model.imageType = [NSNumber numberWithInteger:RemindImageType_Ing];
                    }
                }
                [array2 addObject:model];
            }
            [array1 addObject:array2];
        }
        _allModel = array1;
    }
    return _allModel;
}

#pragma  mark - tableView dataSource delegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.allModel.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray * someDayArray = self.allModel[section];
    return someDayArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CustomTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:customCellIDForL];
    if (cell == nil) {
        cell = [CustomTableViewCell viewWithNib:@"CustomTableViewCell" owner:nil];
    }
    NSArray * someDayArray = self.allModel[indexPath.section];
    RemindCellModel * model = someDayArray[indexPath.row];
    cell.model = model;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CustomTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    RemindCellModel * model = cell.model;
    NSString * someDayKey = self.allRemindDayKeys[indexPath.section];
    NSMutableDictionary * someDayDic = [self someDayDic:someDayKey];
    NSArray * someDayDicAllKeys = [self allSomedayRemindKeys:someDayDic];
    NSString * fileKey = someDayDicAllKeys[indexPath.row];
    self.someDayKey = someDayKey;
    self.fileKey = fileKey;
    EditViewController * editVC = [[EditViewController alloc]init];
    editVC.voiceFileName = model.fileName;
    editVC.isEditNotFromRecord = YES;
    editVC.model = model;
    editVC.timeLength = model.timeLength;
    editVC.someDayKey = someDayKey;
    editVC.fileKey = fileKey;
    [self presentViewController:editVC animated:YES completion:nil];
}
//-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    editingStyle = UITableViewCellEditingStyleDelete;
//} 
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * someDayKey = self.allRemindDayKeys[indexPath.section];
    NSMutableDictionary * someDayDic = [self someDayDic:someDayKey];
    NSArray * someDayDicAllKeys = [self allSomedayRemindKeys:someDayDic];
    NSString * fileKey = someDayDicAllKeys[indexPath.row];
    self.someDayKey = someDayKey;
    self.fileKey = fileKey;
    __weak typeof (self) weakSelf = self;
    
    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"common.Delete", @"Delete") handler:^(UITableViewRowAction * action, NSIndexPath * _Nonnull indexPath) {
        NSDate *noticDate  = [weakSelf.fileDictionary objectForKey:kNoticeDate];
        NSString * filePath = [Voice_directory stringByAppendingPathComponent:[weakSelf.fileDictionary objectForKey:kFileName]];
        [weakSelf.someDayDictionary removeObjectForKey:weakSelf.fileKey];
        if (weakSelf.someDayDictionary.count == 0) {
            [weakSelf.voicesDictionary removeObjectForKey:weakSelf.someDayKey];
        }else{
            [weakSelf.voicesDictionary setObject:weakSelf.someDayDictionary forKey:weakSelf.someDayKey];
        }
        [weakSelf removeLocalNotification:noticDate fileKey:weakSelf.fileKey];
        [weakSelf.voicesDictionary writeToFile:Voice_PlistPath atomically:YES];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        NSMutableArray * someDayArray = weakSelf.allModel[indexPath.section];
        [someDayArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        if (someDayArray.count == 0) {
            [weakSelf.allModel removeObjectAtIndex:indexPath.section];
//            NSIndexSet * indexSet = [[NSIndexSet alloc]initWithIndex:indexPath.section];
//            [tableView deleteSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
//            [weakSelf.allModel removeObjectAtIndex:indexPath.section];
        }
        AppDelegate * appD = [UIApplication sharedApplication].delegate;
        UITabBarController * tabarController = appD.tabarController;
        UITabBarItem * itemAllRemind = [tabarController.tabBar.items objectAtIndex:1];
        int num = itemAllRemind.badgeValue.intValue;
        NSString * badgeValue = [NSString stringWithFormat:@"%d",num - 1];
        if (num - 1 <= 0) {
            badgeValue = nil;
        }
        itemAllRemind.badgeValue = badgeValue;
        if (weakSelf.isCanReloadDate == YES) {
            [tableView reloadData];
            if (self.allModel.count == 0) {
                [self addTishiLabel];
            }else{
                [self removeTishiLabel];
            }
        }
    }];
                                             
    UITableViewRowAction *checkRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:NSLocalizedString(@"ignore", @"Ignore") handler:^(UITableViewRowAction * action, NSIndexPath *indexPath) {
        [weakSelf.fileDictionary setObject:[NSNumber numberWithInteger:RemindImageType_Done] forKey:kImageType];
        [weakSelf.fileDictionary setObject:@"NO" forKey:kOpenRemind];
        NSDate *noticDate  = [weakSelf.fileDictionary objectForKey:kNoticeDate];
        [weakSelf removeLocalNotification:noticDate fileKey:weakSelf.fileKey];
        [weakSelf.someDayDictionary setObject:weakSelf.fileDictionary forKey:weakSelf.fileKey];
        [weakSelf.voicesDictionary setObject:weakSelf.someDayDictionary forKey:weakSelf.someDayKey];
        [weakSelf.voicesDictionary writeToFile:Voice_PlistPath atomically:YES];
        AppDelegate * appD = [UIApplication sharedApplication].delegate;
        UITabBarController * tabarController = appD.tabarController;
        UITabBarItem * itemAllRemind = [tabarController.tabBar.items objectAtIndex:1];
        int num = itemAllRemind.badgeValue.intValue;
        NSString * badgeValue = [NSString stringWithFormat:@"%d",num - 1];
        if (num - 1 <= 0) {
            badgeValue = nil;
        }
        itemAllRemind.badgeValue = badgeValue;
        if (weakSelf.isCanReloadDate == YES) {
            [tableView reloadData];
            if (self.allModel.count == 0) {
                [self addTishiLabel];
            }else{
                [self removeTishiLabel];
            }
        }
    }];
//    UITableViewRowAction *emailRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"邮件" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//        SendEmailManager *sendEmailMng = [SendEmailManager sharedInstance];
//        if (![sendEmailMng checkEmailBasement]) {
//            return;
//        }
//        NSString * titleName = [[self.fileDictionary objectForKey:kTitleName] stringByAppendingString:@".caf"];
//        NSString * filePath = [Voice_directory stringByAppendingPathComponent:[weakSelf.fileDictionary objectForKey:kFileName]];
//        NSMutableArray *dataArray = [NSMutableArray array];
//        NSData *data = [NSData dataWithContentsOfFile:filePath];
//        NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
//        [dataDic setObject:data forKey:kEmailDateKey];
//        [dataDic setObject:titleName forKey:kEmailFileNameKey];
//        [dataArray addObject:dataDic];
//        [sendEmailMng sendEmailWithAttachData:dataArray];
//    }];
    checkRowAction.backgroundColor = [UIColor orangeColor];
//    emailRowAction.backgroundColor = [UIColor blueColor];
    deleteRoWAction.backgroundColor = [UIColor redColor];
    NSArray * arr = [NSArray arrayWithObjects:deleteRoWAction,checkRowAction, nil];
    return arr;
    /*
     @"       "
     [UIColor colorWithPatternImage:[UIImage imageNamed:@"delete"]];
     */
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return self.sectionTitle[section];
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
#pragma mark - actions
-(void)addTishiLabel{
    UILabel * tishiLabel = [self.tableView viewWithTag:TiShiLableTag];
    if (tishiLabel==nil) {
        CGRect frame = CGRectMake(0, 25, self.tableView.frame.size.width, 100);
        tishiLabel = [[UILabel alloc]initWithFrame:frame];
        tishiLabel.tag = TiShiLableTag;
        tishiLabel.backgroundColor = [UIColor whiteColor];
        tishiLabel.text = [NSString stringWithFormat:@"NO %@",NSLocalizedString(@"Reminder", @"Reminder")];
        tishiLabel.textColor = [UIColor lightGrayColor];
        tishiLabel.textAlignment = NSTextAlignmentCenter;
        tishiLabel.lineBreakMode = UILineBreakModeCharacterWrap;
        tishiLabel.numberOfLines = 0;
        [self.tableView addSubview:tishiLabel];
        self.tableView.userInteractionEnabled = NO;
    }
}
-(void)removeTishiLabel{
    UILabel * tishiLabel = [self.tableView viewWithTag:TiShiLableTag];
    if (tishiLabel) {
        [tishiLabel removeFromSuperview];
        self.tableView.userInteractionEnabled = YES;
    }
}

-(NSDate *)getFireDateFromDate:(NSDate *)date{
    NSDateFormatter*dateFormat = [[NSDateFormatter alloc]init];
    [dateFormat setDateFormat:@"yyyyMMddHHmmss"];
    NSString *strTime=[dateFormat stringFromDate:date];
    int timeCha = [strTime substringFromIndex:12].intValue;
    NSDate *now=[NSDate date];
    NSTimeInterval timeDouble = [date timeIntervalSinceDate:now];
    long int timeInt = ABS(timeDouble) ;
    long int newTimeInt = timeInt-timeCha+1;
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:newTimeInt];
    return fireDate;
}
-(void)refreshWithControl{
    [self letDataEmpty];
    _allModel = [self allModel];
    [self.tableView reloadData];
    if (self.allModel.count == 0) {
        [self addTishiLabel];
    }else{
        [self removeTishiLabel];
    }
    [self.refreshControl endRefreshing];
}

-(void)directoryDidChange:(DirectoryWatcher *)folderWatcher{
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [weakSelf letDataEmpty];
        [weakSelf allModel];
        weakSelf.isCanReloadDate = YES;
        LOG(@"数据重载");
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tableView reloadData];
            if (self.allModel.count == 0) {
                [self addTishiLabel];
            }else{
                [self removeTishiLabel];
            }
        });
    });
}

-(void)letDataEmpty{
    _voicesDictionary = nil;
    _someDayDictionary = nil;
    _fileDictionary = nil;
    _allRemindDic = nil;
    _allRemindDayKeys = nil;
    _allModel = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)removeLocalNotification:(NSDate *)date fileKey:(NSString *)fileKey{
    NSArray * array = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for(UILocalNotification *notification in array)
    {
        NSDate *dateTemp=[notification.userInfo objectForKey:kNoticeInfoDateKey];
        NSString * noticFileKey = [notification.userInfo objectForKey:kNoticeInfoFileKey];
        if([dateTemp isEqualToDate:date])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
            [UIApplication sharedApplication].applicationIconBadgeNumber -= 1;
            [self addNumForAllremindItem];
        }
        if ([noticFileKey isEqualToString:fileKey]) {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
            [UIApplication sharedApplication].applicationIconBadgeNumber -= 1;
            [self addNumForAllremindItem ];
        }
    }
}
-(void)addNumForAllremindItem{
    AppDelegate * appD = [UIApplication sharedApplication].delegate;
    UITabBarController * tabarController = appD.tabarController;
    UITabBarItem * itemAllRemind = [tabarController.tabBar.items objectAtIndex:1];
    int num = itemAllRemind.badgeValue.intValue;
    NSString * badgeValue = [NSString stringWithFormat:@"%d",num - 1];
    if (num - 1 <= 0) {
        badgeValue = nil;
    }
    itemAllRemind.badgeValue = badgeValue;
}
//屏幕发生旋转
-(void)OrientationDidChange:(NSNotification*)notification{
    UIDeviceOrientation  orient = [UIDevice currentDevice].orientation;
    
    switch (orient)
    {
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:{
//            CGRect frame = self.tableView.frame;
//            frame.size.width = [UIScreen mainScreen].bounds.size.width;
//            self.tableView.frame = frame;
        }
            break;
        case UIDeviceOrientationPortrait:
        case UIDeviceOrientationPortraitUpsideDown:
            break;
        default:
            break;
    }
 LOG(@"%s",__func__);
}
@end
