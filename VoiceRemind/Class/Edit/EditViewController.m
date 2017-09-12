//
//  EditViewController.m
//  VoiceRemind
//
//  Created by 何少博 on 16/8/25.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "EditViewController.h"
#import "SoundPickerView.h"
#import "RepeatTypePickerView.h"
#import "UIView+x.h"
#import "AVRecoder.h"
#import "AppDelegate.h"
#import "UIColor+x.h"
#import "DatePickerTableViewCell.h"
#import "NPCommonConfig.h"
#import <EventKit/EventKit.h>

#define subViewFrame                CGRectMake(0, self.view.frame.size.height-280, self.view.frame.size.width, 280);
#define DatePickerViewTag           520
#define SoundPickerViewTag          1314
#define RepeatTypePickerViewTag     2757


@interface EditViewController ()<
UITableViewDelegate,
UITableViewDataSource,
DatePickerViewDeleagte,
SoundPickerViewDelegate,
RepeatTypePickerViewDelegate,
AVRecoderDelegate
>
@property (weak, nonatomic) IBOutlet UILabel *EditVCTitle;

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIButton *yangshengqiBtn;

@property (weak, nonatomic) IBOutlet UIButton *blackBtn;
@property (weak, nonatomic) IBOutlet UIButton *saveBtn;

@property (weak, nonatomic) IBOutlet UITextField *textFiled;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (strong,nonatomic) NSMutableArray * dataSourceArray;
@property (strong,nonatomic) NSDate * noticeDate;
@property (strong,nonatomic) NSIndexPath * selectIndexPath;
@property (strong,nonatomic) NSMutableDictionary * voicesDictionary;
@property (strong,nonatomic) AVRecoder * playRecoder;
@property (strong,nonatomic) NSMutableArray * detailTextArray;
@property (assign,nonatomic) BOOL saveSuccess;
@property (strong,nonatomic) NSDate * tempDate;

@property (assign,nonatomic) BOOL showCellDatePicker;
@property (assign,nonatomic) BOOL isSecondEdit;

@end

static NSString * cellID = @"cellID";
@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.EditVCTitle.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"Settings", @"Settings"),NSLocalizedString(@"Reminder", @"Reminder")] ;
    self.textFiled.returnKeyType = UIReturnKeyDone;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    self.selectIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView registerNib:[UINib nibWithNibName:@"DatePickerTableViewCell" bundle:nil] forCellReuseIdentifier:cellID];
    self.textFiled.placeholder = NSLocalizedString(@"please input content", @"Please input content");//self.voiceFileName;
    self.titleLabel.text = NSLocalizedString(@"Content", @"Content");
    NSDate *defaultDate  = [NSDate dateWithTimeIntervalSinceNow:5*60];
    if (self.isEditNotFromRecord) {
        self.textFiled.text = self.model.titleName;
        defaultDate = self.model.noticeDate;
    }
    NSString *dateStr  = [NSDateFormatter localizedStringFromDate:defaultDate dateStyle:NSDateFormatterLongStyle timeStyle:NSDateFormatterNoStyle];
    NSString *timeStr = [NSDateFormatter localizedStringFromDate:defaultDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    self.timeLabel.text = timeStr;
    self.dateLabel.text = dateStr;
    if (!self.isEditNotFromRecord) {
        self.model.noticeDate = defaultDate;
        
    }
    self.tempDate = self.model.noticeDate;
    if (self.isEditNotFromRecord) {
        timeStr = [NSDateFormatter localizedStringFromDate:self.model.noticeDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        NSRange range = [self.model.remindMusic rangeOfString:@"."];
        NSString * newName = [self.model.remindMusic substringToIndex:range.location];
        self.detailTextArray = [NSMutableArray arrayWithObjects:
                                timeStr,
                                newName,
                                [self repeatTypeStringModel:self.model],
                                nil];
    }else{
        self.detailTextArray = [NSMutableArray arrayWithObjects:
                                timeStr,
                                @"Beep",
                                NSLocalizedString(@"None", @"None"),
                                nil];
    }
//    if ([self needsShowAdView]) {
//        [self.detailTextArray addObject:@"native"];
//    }
    [self.blackBtn addTarget:self action:@selector(blackBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.blackBtn setTitle:NSLocalizedString(@"common.Cancel", @"Cancel") forState:UIControlStateNormal];
    [self.saveBtn addTarget:self action:@selector(saveBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.saveBtn setTitle:NSLocalizedString(@"common.Done", @"Done") forState:UIControlStateNormal];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidHide) name:UIKeyboardDidHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardDidShow) name:UIKeyboardDidShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sensorStateChange:) name:@"UIDeviceProximityStateDidChangeNotification" object:nil];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (!self.isEditNotFromRecord) {
        NSIndexPath * indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    }
//    [self.textFiled becomeFirstResponder];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (self.saveSuccess == YES) {
        AppDelegate * appD = [UIApplication sharedApplication].delegate;
        UITabBarController * tabarController = appD.tabarController;
        tabarController.selectedViewController=tabarController.viewControllers[1];
    }
}
#pragma mark - 广告

-(BOOL)needLoadNativeAdView{
    if ([self needsShowAdView]) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - 加载
-(NSString *)repeatTypeStringModel:(RemindCellModel *)model{
    NSInteger type = model.repeatType.integerValue;
    NSString * typeString;
    switch (type) {
        case RepeatType_No :
            typeString = NSLocalizedString(@"None", @"None");
            break;
        case RepeatType_Hour :
            typeString = NSLocalizedString(@"Every hour", @"Every hour");
            break;
        case RepeatType_Day :
            typeString = NSLocalizedString(@"Every day", @"Every day");
            break;
        case RepeatType_Week :
            typeString = NSLocalizedString(@"Every week", @"Every week");
            break;
        case RepeatType_Month :
            typeString = NSLocalizedString(@"Every month", @"Every month");
            break;
        case RepeatType_Year :
            typeString = NSLocalizedString(@"Every year", @"Every year");
            break;
        default:
            typeString = NSLocalizedString(@"None", @"None");
            break;
    }
    return typeString;
}

-(RemindCellModel *)model{
    if (_model == nil) {
        _model = [[RemindCellModel alloc]init];
        _model.fileName = self.voiceFileName;
        _model.timeLength = self.timeLength;
        _model.imageType = [NSNumber numberWithInteger:RemindImageType_Ing];
        _model.openRemind = @"YES";
        _model.remindBody = @"";
        _model.remindMusic = @"Beep.m4r";
        _model.repeatType = [NSNumber numberWithInteger:RepeatType_No];
        NSDate *defaultDate  = [NSDate dateWithTimeIntervalSinceNow:5*60];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        [timeFormatter setDateFormat:@"HH:mm"];
        NSString *date = [dateFormatter stringFromDate:defaultDate];
        NSString *time = [timeFormatter stringFromDate:defaultDate];
        NSString * timestring = [NSString stringWithFormat:@"%@ %@",date,time];
        _model.remindTime = timestring;
        _model.noticeDate = defaultDate;
        _model.titleName = self.voiceFileName;
    }
    return _model;
}


-(NSMutableArray *)dataSourceArray{
    if (_dataSourceArray == nil) {
        _dataSourceArray = [NSMutableArray arrayWithObjects:
                            NSLocalizedString(@"Default.Alert.Time", @"Alert time"),
                            NSLocalizedString(@"Default.Alert.Sount", @"Default.Alert.Sount"),
                            NSLocalizedString(@"Repeat", @"Repeat"),
                            nil];
//        if ([self needsShowAdView]) {
//            [_dataSourceArray addObject:@"native"];
//        }
    }
    return _dataSourceArray;
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
-(NSMutableDictionary *)someDayDictionaryWithSomeDayKey:(NSString *)someDayKey{
    return [self.voicesDictionary objectForKey:someDayKey];;
}
-(NSMutableDictionary *)fileDictionaryWithFileKey:(NSString *)fileKey SomeDayKey:(NSString*)someDayKey{
   return [[self someDayDictionaryWithSomeDayKey:someDayKey]objectForKey:fileKey];
}
-(AVRecoder *)playRecoder{
    if (_playRecoder == nil) {
        _playRecoder = [[AVRecoder alloc]init];
    }
    return _playRecoder;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - actions
//-(void)sensorStateChange:(NSNotificationCenter *)notification;
//{
//    if (![self.playRecoder playRecodering]) {
//        return;
//    }
//    //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗
//    if ([[UIDevice currentDevice] proximityState] == YES)
//    {
//        // NSLog(@"Device is close to user");
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
//        [self.yangshengqiBtn setImage:[UIImage imageNamed:@"ting-tong-"] forState:UIControlStateNormal];
//    }
//    else
//    {
//        // NSLog(@"Device is not close to user");
//        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
//        [self.yangshengqiBtn setImage:[UIImage imageNamed:@"yang-sheng-"] forState:UIControlStateNormal];
//    }
//}
- (IBAction)yangshengqiBtnClick:(UIButton *)sender {
    if ([[[AVAudioSession sharedInstance] category] isEqualToString:AVAudioSessionCategoryPlayback])
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        [sender setImage:[UIImage imageNamed:@"ting-tong-"] forState:UIControlStateNormal];
        
    }
    else
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [sender setImage:[UIImage imageNamed:@"yang-sheng-"] forState:UIControlStateNormal];
    }
    
}
-(void)keyBoardDidHide{
    self.tableView.userInteractionEnabled = YES;
}
-(void)keyBoardDidShow{
    self.tableView.userInteractionEnabled = NO;
}

- (IBAction)textFieldExit:(UITextField *)sender {
    [sender resignFirstResponder];
}

- (IBAction)playRecoderBtnClick:(UIButton *)sender {
    if (_playRecoder == nil) {
        NSString * voicePath = [Voice_directory stringByAppendingPathComponent:self.voiceFileName];
        [self.playRecoder PlayRecoderWithFileUrl:voicePath delegate:self];
        [sender setImage:[UIImage imageNamed:@"suspended-"]forState:UIControlStateNormal];
    }
    else if (self.playRecoder.playRecodering) {
        [self.playRecoder pausePlayRecoder];
        [sender setImage:[UIImage imageNamed:@"start-audio"] forState:UIControlStateNormal];
    }else{
        [self.playRecoder resumePlayRecord];
        [sender setImage:[UIImage imageNamed:@"suspended-"]forState:UIControlStateNormal];
    }
}

-(void)removeRecordWithContion{
    if (self.isEditNotFromRecord == NO && self.saveSuccess == NO) {
        NSFileManager * fm = [NSFileManager defaultManager];
        NSString * voicePath = [Voice_directory stringByAppendingPathComponent:self.voiceFileName];
        [fm removeItemAtPath:voicePath error:nil];
    }
}

- (void)blackBtnClick:(UIBarButtonItem *)sender {
    [self removeRecordWithContion];
    self.playRecoder = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)saveBtnClick:(UIBarButtonItem *)sender {
    if (self.textFiled.text == nil||
        self.textFiled.text.length == 0||
        [self.textFiled.text isEqualToString:@""]) {
        self.textFiled.text = NSLocalizedString(@"Voice.Reminder.Body", @"You have a voice reminder");
        
    }
    if (![self.textFiled.text isEqualToString:self.model.titleName]) {
        self.isSecondEdit = YES;
    }
    if (!self.isSecondEdit) {
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
//    if (self.dateView != nil) {
//        self.model.noticeDate = self.dateView.datePickker.date;
//    }
    NSDate *currentDate  = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    double currentDateD = [[dateFormatter stringFromDate:currentDate]substringToIndex:12].doubleValue;
    double chooseDateD = [[dateFormatter stringFromDate:self.model.noticeDate]substringToIndex:12 ].doubleValue;
    if (currentDateD>=chooseDateD) {
        [self alertViewController_OK_NothingWithTitle:NSLocalizedString(@"user.Prompt", @"Prompt") Message:NSLocalizedString(@"Time.Expired", @"The time has expired, please reset") dismiss:NO];
        return;
    }
    
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    NSString * todaykeyOld = self.someDayKey;
    NSString * filekeyOld = self.fileKey;
    if (self.isEditNotFromRecord) {
        NSMutableDictionary * todayVoicesDicOld = [self.voicesDictionary objectForKey:todaykeyOld];
        [todayVoicesDicOld removeObjectForKey:filekeyOld];
        if (todayVoicesDicOld.count == 0) {
            [self.voicesDictionary removeObjectForKey:todaykeyOld];
        }
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
//    self.model.noticeDate = [self getFireDateFromDate:_model.noticeDate];
    self.model.titleName = self.textFiled.text;
    self.model.openRemind = @"YES";
    self.model.imageType = [NSNumber numberWithInteger:RemindImageType_Ing];
    [fileVoicesDic setObject:self.model.titleName forKey:kTitleName];
    [fileVoicesDic setObject:self.model.fileName forKey:kFileName];
    [fileVoicesDic setObject:self.model.timeLength forKey:kTimeLength];
    [fileVoicesDic setObject:self.model.remindTime forKey:kRemindTime];
    [fileVoicesDic setObject:self.model.imageType forKey:kImageType];
    [fileVoicesDic setObject:self.model.noticeDate forKey:kNoticeDate];
    [fileVoicesDic setObject:self.model.openRemind forKey:kOpenRemind];
    [fileVoicesDic setObject:self.model.remindBody forKey:kRemindBody];
    [fileVoicesDic setObject:self.model.repeatType forKey:kRepeatType];
    [fileVoicesDic setObject:self.model.remindMusic forKey:kRemindMusic];
    [todayVoicesDic setObject:fileVoicesDic forKey:filekey];
    [self.voicesDictionary setObject:todayVoicesDic forKey:todaykey];
    BOOL result = [self.voicesDictionary writeToFile:Voice_PlistPath atomically:YES];
    NSString * message = NSLocalizedString(@"save successfully", @"Saved Successfully");
    if (result){
        self.saveSuccess = YES;
        [self removeLocalNotification:self.model.noticeDate fileKey:filekey];
        [self removeLocalNotification:self.tempDate fileKey:filekeyOld];
        if ([self.model.openRemind isEqualToString:@"YES"]) {
            NSCalendarUnit calendarUnit = [self getCalendarUnit:self.model.repeatType.integerValue];
            [self addLocalNotification:self.model.noticeDate repeatInterval:calendarUnit someDayKey:todaykey fileKey:filekey];
        }
    }else{
        message = NSLocalizedString(@"Save failed", @"Save failed");
    }
    [self alertViewController_OK_NothingWithTitle:NSLocalizedString(@"user.Prompt", @"Prompt") Message:message dismiss:result];
    
}


#pragma mark - tableView delegate datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSourceArray.count;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.showCellDatePicker == YES && indexPath.row == 0) {
        return 260;
    }
    if (indexPath.row == 3) {
        return 80;
    }
    return 44;
}
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DatePickerTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [DatePickerTableViewCell viewWithNib:@"DatePickerTableViewCell" owner:nil];
    }
    cell.delegate = self;
    cell.myTitleLabel.text = self.dataSourceArray[indexPath.row];
    cell.myDetailLabel.text = self.detailTextArray[indexPath.row];
//    if (indexPath.row == 3) {
//        UIView *nativeAdView = [self nativeAdView];
//            nativeAdView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
//            [cell addSubview:nativeAdView];
//        [cell addSubview:nativeAdView];
//    }else{
//        cell.delegate = self;
//        cell.myTitleLabel.text = self.dataSourceArray[indexPath.row];
//        cell.myDetailLabel.text = self.detailTextArray[indexPath.row];
//    }
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DatePickerTableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    NSInteger row = indexPath.row;
    if (row == 0) {//提醒时间
        [self removeRepeatTypeView];
        [self removeSuondPickerView];
        self.showCellDatePicker = !self.showCellDatePicker;
        if (self.showCellDatePicker == YES) {
            cell.datePicker.date = [NSDate dateWithTimeIntervalSinceNow:30*60];
            cell.datePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:3*60];
        }
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (row == 1){//提醒铃声
        [self removeRepeatTypeView];
        [self addSuondPickerView];
    }
    else if (row == 2){//提醒重复
        [self removeSuondPickerView];
        [self addRepeatTypeView];
    }
    self.selectIndexPath = indexPath;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSInteger row = indexPath.row;
//    if (row == 0) {//提醒时间
//        self.selectIndexPath = indexPath;
//        [self removeRepeatTypeView];
//        [self removeSuondPickerView];
//        [self addDatePickerView];
//    }
//    else if (row == 1){//提醒铃声
//        self.selectIndexPath = indexPath;
//        [self removeRepeatTypeView];
//        [self removeDatePickerView];
//        [self addSuondPickerView];
//    }
//    else if (row == 2){//提醒重复
//        self.selectIndexPath = indexPath;
//        [self removeDatePickerView];
//        [self removeSuondPickerView];
//        [self addRepeatTypeView];
//    }
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//}

-(void)alertViewController_OK_NothingWithTitle:(NSString *)title Message:(NSString *)message dismiss:(BOOL)dismiss{
    UIAlertController * alertCtr = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * OK = [UIAlertAction actionWithTitle:NSLocalizedString(@"Sure", @"OK") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (dismiss == YES) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    [alertCtr addAction:OK];
    [self presentViewController:alertCtr animated:YES completion:nil];
}

#pragma mark - datepickerDelegate

-(void)chooseDate:(NSDate *)date H_S:(NSString *)xiaoFen Y_M_D:(NSString *)nianYR{

    self.noticeDate = date;
    self.model.noticeDate = date;
    self.model.remindTime = [NSString stringWithFormat:@"%@ %@",nianYR,xiaoFen];
    DatePickerTableViewCell * cell = [self.tableView cellForRowAtIndexPath:self.selectIndexPath];
    cell.myDetailLabel.text = xiaoFen;
    self.timeLabel.text = xiaoFen;
    self.dateLabel.text = nianYR;
    [self.detailTextArray replaceObjectAtIndex:0 withObject:xiaoFen];
    self.isSecondEdit = YES;
}
#pragma mark - SoundPickerViewDelegate
-(void)chooseSoundNameCaf:(NSString *)namecaf name_:(NSString *)name_ showPinlun:(BOOL)showPinLun{
    DatePickerTableViewCell * cell = [self.tableView cellForRowAtIndexPath:self.selectIndexPath];
    cell.myDetailLabel.text = [NSString stringWithFormat:@"%@",name_];
    self.model.remindMusic = namecaf;
    self.isSecondEdit = YES;
    if ([self needsShowAdView]) {
//        - (BOOL)isThisVersionRated;
//        // 历史版本是否曾经评论过
//        - (BOOL)isAnyVersionRated;
        BOOL isRate = NO;
        if ([[NPCommonConfig shareInstance]isThisVersionRated]&&[[NPCommonConfig shareInstance]isAnyVersionRated]) {
            isRate = YES;
        }
        if (showPinLun == YES&& isRate == NO) {
            BOOL isRatedForThisVersion = [[NPCommonConfig shareInstance] isThisVersionRated];
            if (NO == isRatedForThisVersion) {
                [[NPCommonConfig shareInstance] promptForRating];
            }
        }
    }
}
#pragma mark - RepeatTypePickerViewDelegate
-(void)chooseRepeatType:(RepeatType)repeatType string:(NSString *)stringType{
    DatePickerTableViewCell * cell = [self.tableView cellForRowAtIndexPath:self.selectIndexPath];
    cell.myDetailLabel.text = [NSString stringWithFormat:@"%@",stringType];
    self.model.repeatType = [NSNumber numberWithInteger:repeatType];
    self.isSecondEdit = YES;
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.textFiled resignFirstResponder];
    [self removeRepeatTypeView];
    [self removeSuondPickerView];
}

#pragma mark - 提醒相关

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
    localNotif.alertBody = self.model.titleName;
    localNotif.soundName=self.model.remindMusic;
    localNotif.alertAction= NSLocalizedString(@"user.Push notification slide to check message", @"check message");//滑动来@“查看通知“
    localNotif.hasAction = YES;
    [UIApplication sharedApplication].applicationIconBadgeNumber += 1;
    NSDictionary *infoDict = [NSDictionary dictionaryWithObjects:@[someDayKey,fileKey,date] forKeys:@[kNoticeInfoSomeDayKey,kNoticeInfoFileKey,kNoticeInfoDateKey]];
    localNotif.userInfo = infoDict;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotif];
    
    BOOL  syncCalendar = [[NSUserDefaults standardUserDefaults] boolForKey:kSyncCalendar];
    if (syncCalendar == YES) {
        [self syncCalendarWithStartDate:fireDate title:self.model.titleName eventID:self.model.fileName];
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
-(void)removeAllNotification{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
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

#pragma mark - 播放完成后调用
-(void)recoderDidFinishPlaying:(AVRecoder *)recoder successfully:(BOOL)flag{
    [_playBtn setImage:[UIImage imageNamed:@"start-audio"] forState:UIControlStateNormal];
}

#pragma mark - add remove SubViews


-(void)addSuondPickerView{
    SoundPickerView * soundView = [self.view viewWithTag:SoundPickerViewTag];
    if (soundView == nil) {
        soundView = [SoundPickerView viewWithNib:NSStringFromClass([SoundPickerView class]) owner:nil];
        soundView.frame = self.view.bounds;
        soundView.delegate = self;
        soundView.tag = SoundPickerViewTag;
        soundView.alpha = 0;
        [self.view addSubview:soundView];
        [UIView animateWithDuration:0.25 animations:^{
            soundView.alpha = 1;
        }];
    }
}

-(void)removeSuondPickerView{
    SoundPickerView * soundView = [self.view viewWithTag:SoundPickerViewTag];
    if (soundView != nil) {
        [UIView animateWithDuration:0.25 animations:^{
            soundView.alpha = 0;
        } completion:^(BOOL finished) {
            soundView.recoderPlay = nil;
            [soundView removeFromSuperview];
        }];
    }
}

-(void)addRepeatTypeView{
    RepeatTypePickerView * repeatView = [self.view viewWithTag:RepeatTypePickerViewTag];
    if (repeatView == nil) {
        repeatView = [RepeatTypePickerView viewWithNib:NSStringFromClass([RepeatTypePickerView class]) owner:nil];
        repeatView.frame = self.view.bounds;
        repeatView.delegate = self;
        repeatView.tag = RepeatTypePickerViewTag;
        repeatView.alpha = 0;
        [self.view addSubview:repeatView];
        [UIView animateWithDuration:0.25 animations:^{
            repeatView.alpha = 1;
        }];
    }
}

-(void)removeRepeatTypeView{
    RepeatTypePickerView * repeatView = [self.view viewWithTag:RepeatTypePickerViewTag];
    if (repeatView != nil) {
        [UIView animateWithDuration:0.25 animations:^{
            repeatView.alpha = 0;
        } completion:^(BOOL finished) {
            [repeatView removeFromSuperview];
        }];
    }
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/*
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
 //                    获取日历中的事件
 //                    EKEventStore* eventStore = [[EKEventStore alloc] init];
 //                    NSDate* ssdate = [NSDate dateWithTimeIntervalSinceNow:-3600*24*90];//事件段，开始时间
 //                    NSDate* ssend = [NSDate dateWithTimeIntervalSinceNow:3600*24*90];//结束时间，取中间
 //                    NSPredicate* predicate = [eventStore predicateForEventsWithStartDate:ssdate
 //                                                                                 endDate:ssend
 //                                                                               calendars:nil];//谓语获取，一种搜索方法
 //                    NSArray* events = [eventStore eventsMatchingPredicate:predicate];//数组里面就是时间段中的EKEvent事件数组
 //                    for (EKEvent *event in events) {
 //                        event.eventIdentifier
 //                        NSLog(@"=================================================================");
 //                        NSLog(@"%@", event.title);
 //                        NSLog(@"%@", event.startDate);
 //                        NSLog(@"=================================================================");
 //                    }
 // access granted
 // ***** do the important stuff here *****
 
 //事件保存到日历
 //06.07 元素
 //title(标题 NSString),
 //location(位置NSString),
 //startDate(开始时间 2016/06/07 11:14AM),
 //endDate(结束时间 2016/06/07 11:14AM),
 //addAlarm(提醒时间 2016/06/07 11:14AM),
 //notes(备注类容NSString)
 //                    NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
 //                    NSString*appName =[infoDict objectForKey:@"CFBundleDisplayName"];
 NSString*appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
 if ([appName length] == 0 || appName == nil)
 {
 appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleNameKey];
 }
 //创建事件
 EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
 event.title  = [NSString stringWithFormat:@"%@:%@",appName,title];;
 //                    event.location = @"北京海淀";
 
 //                    NSDateFormatter *tempFormatter = [[NSDateFormatter alloc]init];
 //                    [tempFormatter setDateFormat:@"dd.MM.yyyy HH:mm"];
 
 //06.07 时间格式
 NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
 [dateFormatter setAMSymbol:@"AM"];
 [dateFormatter setPMSymbol:@"PM"];
 [dateFormatter setDateFormat:@"yyyy/MM/dd hh:mmaaa"];
 //                    NSDate *date = [NSDate date];
 NSString * s = [dateFormatter stringFromDate:startDate];
 NSLog(@"%@",s);
 
 //开始时间(必须传)
 event.startDate = [startDate dateByAddingTimeInterval:60 * 2];
 //结束时间(必须传)
 event.endDate   = [startDate dateByAddingTimeInterval:60 * 3];
 //                    event.endDate   = [[NSDate alloc]init];
 //                    event.allDay = YES;//全天
 //添加提醒
 //第一次提醒  (几分钟后)
 //                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -1.0f]];
 //第二次提醒  ()
 //                    [event addAlarm:[EKAlarm alarmWithRelativeOffset:60.0f * -10.0f * 24]];
 
 //06.07 add 事件类容备注;
 event.notes = [NSString stringWithFormat:@"%@-%@",appName,evenID];;
 [event setCalendar:[eventStore defaultCalendarForNewEvents]];
 NSError *err;
 [eventStore saveEvent:event span:EKSpanThisEvent error:&err];
 }
 });
 }];
 }
 
 
 
 
 //    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"calshow:"]];
 }
 */
@end
