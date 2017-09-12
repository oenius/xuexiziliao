//
//  VoiceNoticViewController.m
//  VoiceRemind
//
//  Created by 何少博 on 16/8/30.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "VoiceNoticViewController.h"
#import "AVRecoder.h"
#import "SendEmailManager+x.h"
#import "MBProgressHUD.h"
#import "VoiceRemindENUM.h"
#import "AppDelegate.h"
#import "TimeDelayPickerView.h"
#import "UIView+x.h"
#import "UIColor+x.h"
#import <EventKit/EventKit.h>

#define TimeDelayViewTag 70174

@interface VoiceNoticViewController ()<
AVRecoderDelegate,
TimeDelayPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *reminderLabel;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *timeDelayBtn;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UIButton *yangshengqiBtn;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *delayLabel;

@property (strong,nonatomic) NSMutableDictionary * voicesDictionary;
@property (strong,nonatomic) NSMutableDictionary * someDayDictionary;
@property (strong,nonatomic) NSMutableDictionary * fileDictionary;
@property (strong,nonatomic) AVRecoder * palyRecoder;
@property (strong,nonatomic) NSString * filePath;
@property (strong,nonatomic) NSString * voiceFileName;
@property (strong,nonatomic) NSDate * tempNoticDate;

@property (strong,nonatomic) NSString * titleName;
@property (strong,nonatomic) NSString * remindMusic;
@property (assign,nonatomic) BOOL isTimeDelaystates;

@property (assign,nonatomic) BOOL isDelete;
@end

@implementation VoiceNoticViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delayLabel.text = @"";
    self.contentView.layer.cornerRadius = 8;
    self.contentView.layer.masksToBounds = YES;
    self.contentView.backgroundColor = [UIColor colorWithHexString:@"#f6f6f6"];
    self.timeDelayBtn.backgroundColor = [UIColor colorWithHexString:@"#83cbe4"];
    self.timeDelayBtn.layer.cornerRadius = 5;
    self.timeDelayBtn.layer.masksToBounds = YES;
    [self.timeDelayBtn setTitle:NSLocalizedString(@"Default.Snooze", @"Snooze") forState:UIControlStateNormal];
    self.doneBtn.backgroundColor = [UIColor colorWithHexString:@"#f9723b"];
    self.doneBtn.layer.cornerRadius = 5;
    self.doneBtn.layer.masksToBounds = YES;
    [self.doneBtn setTitle:NSLocalizedString(@"common.Done", @"Done") forState:UIControlStateNormal];
    [self.playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    NSDate *noticDate  = [self.fileDictionary objectForKey:kNoticeDate];
    self.tempNoticDate = noticDate;
    NSString *dateStr  = [NSDateFormatter localizedStringFromDate:noticDate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
    NSString *timeStr = [NSDateFormatter localizedStringFromDate:noticDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    self.timeLabel.text = timeStr;
    self.dateLabel.text = dateStr;
    self.titleLabel.text = [self.fileDictionary objectForKey:kTitleName];
    NSString * fileName = [self.fileDictionary objectForKey:kFileName];
    self.voiceFileName = fileName;
    self.filePath = [Voice_directory stringByAppendingPathComponent:fileName];
    [self.palyRecoder PlayRecoderWithFileUrl:_filePath delegate:self];
    [self.playBtn setImage:[UIImage imageNamed:@"suspended-"]forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sensorStateChange:)
                                                 name:@"UIDeviceProximityStateDidChangeNotification"
                                               object:nil];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.fileDictionary setObject:[NSNumber numberWithInteger:RemindImageType_Done] forKey:kImageType];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}
#pragma mark - 加载数据

-(AVRecoder*)palyRecoder{
    if (_palyRecoder == nil) {
        _palyRecoder = [[AVRecoder alloc]init];
    }
    return _palyRecoder;
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
#pragma mark - actions
-(void)sensorStateChange:(NSNotificationCenter *)notification;
{
    if (![self.palyRecoder playRecodering]) {
        return;
    }
    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗（省电啊）
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
       // NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [self.yangshengqiBtn setImage:[UIImage imageNamed:@"tingTong"] forState:UIControlStateNormal];
    }
    else
    {
       // NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [self.yangshengqiBtn setImage:[UIImage imageNamed:@"yangsheng"] forState:UIControlStateNormal];
    }
}

- (IBAction)yangshengqiBtnClick:(UIButton *)sender {
    if ([[[AVAudioSession sharedInstance] category] isEqualToString:AVAudioSessionCategoryPlayback])
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [sender setImage:[UIImage imageNamed:@"tingTong"] forState:UIControlStateNormal];
        
    }
    else
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [sender setImage:[UIImage imageNamed:@"yangsheng"] forState:UIControlStateNormal];
    }
    
}

- (IBAction)timeDelayBtnClick:(UIButton *)sender {
    [self addTimeDelayView];
    
    LOG(@"%@",self.noticDate);
    
}
-(void)addTimeDelayView{
    TimeDelayPickerView * timeDelayView  = [self.view viewWithTag:TimeDelayViewTag];
    if (timeDelayView == nil) {
        timeDelayView = [TimeDelayPickerView viewWithNib:@"TimeDelayPickerView" owner:nil];
        timeDelayView.frame = self.view.bounds;
        timeDelayView.delegate = self;
        timeDelayView.tag = TimeDelayViewTag;
        timeDelayView.date = self.noticDate;
        [self.view addSubview:timeDelayView];
    }
}
-(void)removeTimeDelayView{
    TimeDelayPickerView * timeDelayView  = [self.view viewWithTag:TimeDelayViewTag];
    if (timeDelayView != nil) {
        [timeDelayView removeFromSuperview];
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self removeTimeDelayView];
}
- (IBAction)doneBtnClick:(UIButton *)sender {
    if (self.isTimeDelaystates == NO) {
        
        [self.fileDictionary setObject:[NSNumber numberWithInteger:RemindImageType_Done] forKey:kImageType];
        NSMutableDictionary * todayVoicesDic = [self.voicesDictionary objectForKey:self.someDayKey];
        [todayVoicesDic setObject:self.fileDictionary forKey:self.fileKey];
        [self.voicesDictionary setObject:todayVoicesDic forKey:self.someDayKey];
        [self.voicesDictionary writeToFile:Voice_PlistPath atomically:YES];
        AppDelegate * appD = [UIApplication sharedApplication].delegate;
        UITabBarController * tabarController = appD.tabarController;
        UITabBarItem * itemAllRemind = [tabarController.tabBar.items objectAtIndex:1];
        int num = itemAllRemind.badgeValue.intValue;
        NSString * badgeValue = [NSString stringWithFormat:@"%d",num - 1];
        if (num - 1 <= 0) {
            badgeValue = nil;
        }
        itemAllRemind.badgeValue = badgeValue;
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    //++++++++++++++++++++++判断是否有权限，firedate是否合理++++++++++++++++++++++++++++++++++++++++++++++++++++
    if([[UIApplication sharedApplication]currentUserNotificationSettings].types==UIUserNotificationTypeNone) {
        UIAlertController *alertVC=[UIAlertController alertControllerWithTitle:NSLocalizedString(@"user.Prompt", @"Prompt") message:NSLocalizedString(@"notification", @"You have set up not allowing to send notifications. Please turn to stings->notifications and allow our app to receive notification.") preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAct=[UIAlertAction actionWithTitle:NSLocalizedString(@"common.Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
            [userDefault setBool:NO forKey:kIsOpenNotic];
            [userDefault synchronize];
            return ;
        }];
        UIAlertAction *settingAct=[UIAlertAction actionWithTitle:NSLocalizedString(@"Settings", @"Settings") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            if([[UIApplication sharedApplication]currentUserNotificationSettings].types==UIUserNotificationTypeNone)
            {
                NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if([[UIApplication sharedApplication] canOpenURL:url]) {
                    [[UIApplication sharedApplication] openURL:url];
                }
            }
        }];
        [alertVC addAction:cancelAct];
        [alertVC addAction:settingAct];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
    NSDate *currentDate  = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    double currentDateD = [[dateFormatter stringFromDate:currentDate]substringToIndex:12].doubleValue;
    double chooseDateD = [[dateFormatter stringFromDate:self.noticDate]substringToIndex:12 ].doubleValue;
    if (currentDateD>=chooseDateD) {
        [self alertViewController_OK_NothingWithTitle:NSLocalizedString(@"user.Prompt", @"Prompt") Message:NSLocalizedString(@"Time.Expired", @"The time has expired, please reset") dismiss:NO];
        return;
    }
    //++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //-----------------获得数据----------------------
    //添加HUD
    NSString * titleName = [self.fileDictionary objectForKey:kTitleName];
    NSString * fileName = [self.fileDictionary objectForKey:kFileName];
    NSString * timeLength = [self.fileDictionary objectForKey:kTimeLength];
    NSNumber * imageType = [NSNumber numberWithInteger:RemindImageType_Ing];
    NSString * openRemind = @"YES";
    NSDate * noticDate = self.noticDate;
    NSString *dateStr  = [NSDateFormatter localizedStringFromDate:self.noticDate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
    NSString *timeStr = [NSDateFormatter localizedStringFromDate:self.noticDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    NSString * remindTime = [NSString stringWithFormat:@"%@ %@",dateStr,timeStr];
    NSString * remindBody = @"";
    NSNumber * repeatType = [self.fileDictionary objectForKey:kRepeatType];
    NSString * remindMusic = [self.fileDictionary objectForKey:kRemindMusic];
    self.titleName = titleName;
    self.remindMusic = remindMusic;
    //--------------------------------------------
    NSString * todaykeyOld = self.someDayKey;
    NSString * filekeyOld = self.fileKey;
    NSMutableDictionary * todayVoicesDicOld = [self.voicesDictionary objectForKey:todaykeyOld];
    [todayVoicesDicOld removeObjectForKey:filekeyOld];
    if (todayVoicesDicOld.count == 0) {
        [self.voicesDictionary removeObjectForKey:todaykeyOld];
    }
    NSString * todaykey = [[dateFormatter stringFromDate:currentDate]substringToIndex:8];
    NSString * filekey = [[dateFormatter stringFromDate:currentDate]substringToIndex:14];
    NSMutableDictionary * todayVoicesDic = [self.voicesDictionary objectForKey:todaykey];
    if (todayVoicesDic == nil) {
        todayVoicesDic = [NSMutableDictionary dictionary];
    }
    NSMutableDictionary * fileVoicesDic = [todayVoicesDic objectForKey:filekey];
    if (fileVoicesDic == nil) {
        fileVoicesDic = [NSMutableDictionary dictionary];
    }
    [fileVoicesDic setObject:titleName forKey:kTitleName];
    [fileVoicesDic setObject:fileName forKey:kFileName];
    [fileVoicesDic setObject:timeLength forKey:kTimeLength];
    [fileVoicesDic setObject:remindTime forKey:kRemindTime];
    [fileVoicesDic setObject:imageType forKey:kImageType];
    [fileVoicesDic setObject:noticDate forKey:kNoticeDate];
    [fileVoicesDic setObject:openRemind forKey:kOpenRemind];
    [fileVoicesDic setObject:remindBody forKey:kRemindBody];
    [fileVoicesDic setObject:repeatType forKey:kRepeatType];
    [fileVoicesDic setObject:remindMusic forKey:kRemindMusic];
    
    [todayVoicesDic setObject:fileVoicesDic forKey:filekey];
    [self.voicesDictionary setObject:todayVoicesDic forKey:todaykey];
    
    BOOL result = [self.voicesDictionary writeToFile:Voice_PlistPath atomically:YES];
    NSString * message = NSLocalizedString(@"save successfully", @"save successfully");
    if (result) {
        [self removeLocalNotification:self.noticDate fileKey:filekey];
        [self removeLocalNotification:self.tempNoticDate fileKey:filekeyOld];
        NSCalendarUnit calendarUnit = [self getCalendarUnit:repeatType.integerValue];
        [self addLocalNotification:self.noticDate repeatInterval:calendarUnit someDayKey:todaykey fileKey:filekey];
    }else{
        message = NSLocalizedString(@"Save failed", @"Failed to save");
    }
    [self alertViewController_OK_NothingWithTitle:NSLocalizedString(@"user.Prompt", @"Prompt") Message:message dismiss:result];
}


- (void)playBtnClick:(UIButton *)sender {
    if (self.palyRecoder.playRecodering) {
        [self.palyRecoder pausePlayRecoder];
        [sender setImage:[UIImage imageNamed:@"start-audio"] forState:UIControlStateNormal];
    }else{
        [self.palyRecoder resumePlayRecord];
        [sender setImage:[UIImage imageNamed:@"suspended-"]forState:UIControlStateNormal];
    }
}

#pragma mark - AVRecoderDelegate,timeDelayPickerViewDeleagte

-(void)recoderDidFinishPlaying:(AVRecoder *)recoder successfully:(BOOL)flag{
    [_playBtn setImage:[UIImage imageNamed:@"start-audio"] forState:UIControlStateNormal];
}
-(void)timeDelaychoosed:(NSDate *)date string:(NSString *)delayStr{
    if (date != nil) {
        self.noticDate = date;
        self.isTimeDelaystates = YES;
        self.delayLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"Default.Snooze", @"Snooze"),delayStr];
    }else{
        self.delayLabel.text = @"";
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
#pragma mark - 通知相关
-(NSCalendarUnit)getCalendarUnit:(RepeatType)repeatType{
    NSCalendarUnit calendarUnit ;
    switch (repeatType) {
        case RepeatType_No:
            calendarUnit = 0;
            break;
        case RepeatType_Day:
            calendarUnit = NSCalendarUnitDay;
            break;
        case RepeatType_Hour:
            calendarUnit = NSCalendarUnitHour;
            break;
        case RepeatType_Month:
            calendarUnit = NSCalendarUnitMonth;
            break;
        case RepeatType_Week:
            calendarUnit = NSCalendarUnitWeekday;
            break;
        case RepeatType_Year:
            calendarUnit = NSCalendarUnitYear;
            break;
        default:
            calendarUnit = 0;
            break;
    }
    return calendarUnit;
}

-(void)alertViewController_OK_NothingWithTitle:(NSString *)title Message:(NSString *)message dismiss:(BOOL)dismiss{
    UIAlertController * alertCtr = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * OK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (dismiss == YES) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    [alertCtr addAction:OK];
    [self presentViewController:alertCtr animated:YES completion:nil];
}
-(void)addLocalNotification:(NSDate *)date repeatInterval:(NSCalendarUnit)calendarUnit someDayKey:(NSString *)someDayKey fileKey:(NSString *)fileKey{
    
    NSDate *fireDate=[self getFireDateFromDate:date];
    UILocalNotification *localNotif = [[UILocalNotification alloc] init];
    if (localNotif == nil) return;
    localNotif.repeatInterval =calendarUnit;
    localNotif.repeatCalendar = [NSCalendar currentCalendar];
    localNotif.fireDate =fireDate;
    localNotif.timeZone = [NSTimeZone defaultTimeZone];
    //ipod不支持alertTitle方法
    if(![[[UIDevice currentDevice] model] isEqualToString:@"iPod touch"])
    {
        localNotif.alertTitle =@"VoiceRemind";
    }
    localNotif.alertBody = self.titleName;
    localNotif.soundName=self.remindMusic;
    localNotif.alertAction= NSLocalizedString(@"user.Push notification slide to check message", @"check message");
    localNotif.hasAction = YES;
    [UIApplication sharedApplication].applicationIconBadgeNumber += 1;
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjects:@[someDayKey,fileKey,date] forKeys:@[kNoticeInfoSomeDayKey,kNoticeInfoFileKey,kNoticeInfoDateKey]];
    localNotif.userInfo = infoDict;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    
    BOOL  syncCalendar = [[NSUserDefaults standardUserDefaults] boolForKey:kSyncCalendar];
    if (syncCalendar == YES) {
        NSString * fileName = [self.fileDictionary objectForKey:kFileName];
        [self syncCalendarWithStartDate:fireDate title:self.titleName eventID:fileName];
    }
    AppDelegate * appD  = [UIApplication sharedApplication].delegate;
    NSArray * noticA = [[UIApplication sharedApplication] scheduledLocalNotifications];
    UITabBarController * tabrController = appD.tabarController;
    UITabBarItem * itemAllRemind = [tabrController.tabBar.items objectAtIndex:1];
    itemAllRemind.badgeValue = [NSString stringWithFormat:@"%d",noticA.count];
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
#pragma mark - 同步系统日历
-(void)syncCalendarWithStartDate:(NSDate *)startDate title:(NSString*)title eventID:(NSString *)evenID {
    //calshow:后面加时间戳格式，也就是NSTimeInterval
    //    注意这里计算时间戳调用的方法是-
    //    NSTimeInterval nowTimestamp = [[NSDate date] timeIntervalSinceDate:2016];
    
    //    timeIntervalSinceReferenceDate的参考时间是2000年1月1日，
    //    [NSDate date]是你希望跳到的日期。
    
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    //06.07 使用 requestAccessToEntityType:completion: 方法请求使用用户的日历数据库
    
    if ([eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        // the selector is available, so we must be on iOS 6 or newer
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error)
                {
                    //错误细心
                    // display error message here
                }
                else if (!granted)
                {
                    //被用户拒绝，不允许访问日历
                    // display access denied error message here
                    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    if([[UIApplication sharedApplication] canOpenURL:url]) {
                        [[UIApplication sharedApplication] openURL:url];
                    }
                }
                else
                {
                    NSString*appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                    if ([appName length] == 0 || appName == nil)
                    {
                        appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleNameKey];
                    }
                    //创建事件
                    EKEvent *eventNew  = [EKEvent eventWithEventStore:eventStore];
                    eventNew.title  = [NSString stringWithFormat:@"%@:%@",appName,title];
                    //开始时间(必须传)
                    eventNew.startDate = [startDate dateByAddingTimeInterval:60 * 2];
                    //结束时间(必须传)
                    eventNew.endDate   = [startDate dateByAddingTimeInterval:60 * 3];
                    NSString * notes = [NSString stringWithFormat:@"%@-%@",appName,evenID];
                    eventNew.notes = notes;
                    
                    //                    获取日历中的事件
                    EKEventStore* eventStore = [[EKEventStore alloc] init];
                    NSDate* ssdate = [NSDate dateWithTimeIntervalSinceNow:-3600*24*90];//事件段，开始时间
                    NSDate* ssend = [NSDate dateWithTimeIntervalSinceNow:3600*24*90];//结束时间，取中间
                    NSPredicate* predicate = [eventStore predicateForEventsWithStartDate:ssdate
                                                                                 endDate:ssend
                                                                               calendars:nil];//谓语获取，一种搜索方法
                    NSArray* events = [eventStore eventsMatchingPredicate:predicate];//数组里面就是时间段中的EKEvent事件数组
                    //删除原来的
                    for (EKEvent *event in events) {
                        if ([event.notes isEqualToString:notes]) {
                            [eventStore removeEvent:event span:EKSpanThisEvent error:nil];
                            break;
                        }
                    }
                    [eventNew setCalendar:[eventStore defaultCalendarForNewEvents]];
                    [eventStore saveEvent:eventNew span:EKSpanThisEvent error:nil];
                }
            });
        }];
    }
    //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"calshow:"]];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
//- (IBAction)deleteBtnClick:(UIButton *)sender {
//    NSDate *noticDate  = [self.fileDictionary objectForKey:kNoticeDate];
//    [self.someDayDictionary removeObjectForKey:self.fileKey];
//    if (self.someDayDictionary.count == 0) {
//        [self.voicesDictionary removeObjectForKey:self.someDayKey];
//    }else{
//        [self.voicesDictionary setObject:self.someDayDictionary forKey:self.someDayKey];
//    }
//    [self removeLocalNotification:noticDate];
//    BOOL result1 = [self.voicesDictionary writeToFile:Voice_PlistPath atomically:YES];
//    BOOL result2 = [[NSFileManager defaultManager] removeItemAtPath:self.filePath error:nil];
//    NSString * message = @"删除成功";
//    self.isDelete = YES;
//    if (!(result1&&result2)){
//        message = @"删除失败";
//        self.isDelete = NO;
//    };
//
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    hud.mode = MBProgressHUDModeText;
//    hud.label.text = message;
//    [hud hideAnimated:YES afterDelay:1.5];
//}
//- (IBAction)emailBtnClick:(UIButton *)sender {
//
//    SendEmailManager *sendEmailMng = [SendEmailManager sharedInstance];
//    if (![sendEmailMng checkEmailBasement]) {
//        return;
//    }
//    NSString * titleName = [[self.fileDictionary objectForKey:kTitleName] stringByAppendingString:@".caf"];
//    NSMutableArray *dataArray = [NSMutableArray array];
//    NSData *data = [NSData dataWithContentsOfFile:_filePath];
//    NSMutableDictionary *dataDic = [NSMutableDictionary dictionary];
//    [dataDic setObject:data forKey:kEmailDateKey];
//    [dataDic setObject:titleName forKey:kEmailFileNameKey];
//    [dataArray addObject:dataDic];
//    [sendEmailMng sendEmailWithAttachData:dataArray];
//}

//- (IBAction)shareBtnClick:(UIButton *)sender {
//    NSURL * shareUrl = [NSURL fileURLWithPath:self.filePath];
//    NSArray *activityItem = [NSArray arrayWithObject:shareUrl];
//    UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:activityItem applicationActivities:nil];
//    UIPopoverPresentationController *popover = activity.popoverPresentationController;
//    if (popover) {
//        popover.sourceView = self.shareBtn;
//        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
//    }
//    [self presentViewController:activity animated:YES completion:nil];
//}
@end
