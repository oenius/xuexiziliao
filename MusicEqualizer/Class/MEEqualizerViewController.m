//
//  MEEqualizerViewController.m
//  MusicEqualizer
//
//  Created by 何少博 on 16/12/28.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "MEEqualizerViewController.h"
#import "MEAudioPlayer.h"
#import "MEEqualizerScrollView.h"
#import "METemporaryPlayListView.h"
#import "MEUserDefaultManager.h"
#import "MECoreDataManager.h"
#import "MBProgressHUD.h"
#import "MEEqualizerListViewController.h"
#import "UIImage+x.h"
#import "UIColor+x.h"
@interface MEEqualizerViewController ()<MEAudioPlayerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *playModelBtn;

@property (weak, nonatomic) IBOutlet UIButton *lastMusicBtn;

@property (weak, nonatomic) IBOutlet UIButton *pauseBtn;

@property (weak, nonatomic) IBOutlet UIButton *nextMusicBtn;

@property (weak, nonatomic) IBOutlet UIButton *tempListBtn;

@property (weak, nonatomic) IBOutlet UISlider *musicProgressSlider;

@property (weak, nonatomic) IBOutlet UILabel *currentTimeLabel;

@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolBar;

@property (weak, nonatomic) IBOutlet UILabel *totleTimeLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (weak, nonatomic) IBOutlet UIView *equalizerView;

@property (weak, nonatomic) IBOutlet MEEqualizerScrollView *equalizerScollView;

@property (weak, nonatomic) IBOutlet UIView *detailContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;

@property (strong,nonatomic) UIView * maskView;

@property (strong,nonatomic) METemporaryPlayListView * tempListView;
//是唯一的
@property (copy, nonatomic) NSString * currentMusicDescribe_ID;

@property (strong,nonatomic)MEAudioPlayer * player;

@end

@implementation MEEqualizerViewController

-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil player:(MEAudioPlayer*)player{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.player = player;
        self.player.delegate = self;
    }
    return self;
}
-(instancetype)initWithPlayer:(MEAudioPlayer*)player{
    self = [super init];
    if (self) {
        self.player = player;
        self.player.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupInit];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}
-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    self.bottomConstraint.constant = contentInsets.bottom;
}

-(void)setupInit{
    self.edgesForExtendedLayout  = UIRectEdgeNone;
    self.equalizerScollView.player = self.player;
    ;
    if (self.player.currentEqulizer) {
        [self.equalizerScollView setSliderValueWithEqualier:self.player.currentEqulizer];
        self.title = [self fixEqualizerName:self.player.currentEqulizer.name];
    }else{
        NSArray * array = [[MEUserDefaultManager defaultManager]getTempEQValuesAndName];
        [self.equalizerScollView setSliderValueWithNumberArray:array];
        self.title = array.lastObject;
    }
    
    __weak typeof(self) weakSelf = self;
    [self.equalizerScollView setEQAfterFisrtChangedCallBack:^(BOOL isChanged) {
        weakSelf.title = MEL_Customize;
    }];
    self.musicProgressSlider.maximumValue = self.player.duration;
    self.musicProgressSlider.minimumValue = 0;
    self.totleTimeLabel.text = [self secondToTimeSting:self.player.duration];
    self.musicProgressSlider.value = self.player.currentTime;
    
    self.currentTimeLabel.text = [self secondToTimeSting:self.player.currentTime];
    MEAudioPlayerPlayModel playModel = [[MEUserDefaultManager defaultManager] getPlayModel];
    MEMusic * currentMusic = self.player.currentMusic;
    self.detailLabel.text = [NSString stringWithFormat:@"%@ - %@",currentMusic.name,currentMusic.singer];
    [self changePlayBtnImageWithPlayModel:playModel];
    
    if (self.player.playing){
        [self.pauseBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }else{
        [self.pauseBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
    
    UIImage *minImage = [UIImage createCircleImageWithColor:[UIColor colorWithHexString:@"a20707"] andX:6 andY:6];
    UIImage *maxImage = [UIImage createCircleImageWithColor:[UIColor blackColor] andX:6 andY:6];
    
    UIImage *imageMin = [minImage stretchableImageWithLeftCapWidth:minImage.size.width/2 topCapHeight:minImage.size.height/2];
    UIImage *imageMax = [maxImage  stretchableImageWithLeftCapWidth:maxImage.size.width/2 topCapHeight:maxImage.size.height/2];
    
    [self.musicProgressSlider setThumbImage:[UIImage imageNamed:@"circle"] forState:UIControlStateNormal];
    [self.musicProgressSlider setMinimumTrackImage:imageMin forState:UIControlStateNormal];
    [self.musicProgressSlider setMaximumTrackImage:imageMax forState:UIControlStateNormal];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"goback"]style:UIBarButtonItemStylePlain target:self action:@selector(dismissSelf)];
    
    UIBarButtonItem * moreItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"equalizer"] style:UIBarButtonItemStylePlain target:self action:@selector(moreItemClick:)];
    UIBarButtonItem * saveItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"save"] style:UIBarButtonItemStylePlain target:self action:@selector(saveItemClick:)];
    self.navigationItem.rightBarButtonItems = @[moreItem,saveItem];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"efefef"];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"a20707"];
    NSDictionary * normal = @{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"efefef"]};
    self.navigationController.navigationBar.titleTextAttributes = normal;
    self.navigationController.navigationBar.translucent = YES;
    
    self.detailContentView.layer.cornerRadius = 5;
    self.detailContentView.layer.masksToBounds = YES;
    
    self.equalizerView.layer.cornerRadius = 3;
    self.equalizerView.layer.masksToBounds = YES;
    self.equalizerView.clipsToBounds = NO;
    self.view.backgroundColor = [UIColor colorWithRed:25.0/255.0 green:25.0/255.0 blue:25.0/255.0 alpha:1];
    [self.equalizerView insertSubview:self.equalizerScollView atIndex:0];
    
}
#pragma mark - actions
-(void)dismissSelf{
    NSArray * values = [self.equalizerScollView getCurrentSliderValues];
    [self setTempEQWithValues:(NSArray *)values];
    [[MEUserDefaultManager defaultManager] setADFlagAddOne];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)moreItemClick:(UIBarButtonItem *)sender{
    
    MEEqualizerListViewController * list = [[MEEqualizerListViewController alloc]init];
    __weak typeof(self) weakSelf = self;
    [list EQSelectedCallBack:^(MEEqualizer *equalizer) {
        LOG(@"%@",equalizer);
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.equalizerScollView setSliderValueWithEqualier:equalizer];
             weakSelf.title = [self fixEqualizerName:equalizer.name];
        });
        [weakSelf.player setEqualizer:equalizer];
        [[MEUserDefaultManager defaultManager] setCurrentEQID:equalizer.eq_id];
       
    }];
    [self.navigationController pushViewController:list animated:YES];
}

-(void)saveItemClick:(UIBarButtonItem *)sender{
    NSArray * EQArray = [self.equalizerScollView getCurrentSliderValues];
    [self remindAndSaveEQ:EQArray];
}

- (IBAction)pauseBtnClick:(UIButton *)sender {

    if (self.player.playing) {
        [self.player pause];
    }else{
        [self.player play];
    }
    LOG(@"musicListcount:%ld \n index: %ld ",(unsigned long)self.player.musicList.count,(long)self.player.currentIndex);
}

- (IBAction)playListBtnClick:(UIButton *)sender {
    [self addTempListView];
}

- (IBAction)playModelBtnClick:(UIButton *)sender {
    switch (self.player.playModel) {
        case MEAudioPlayerPlayModelOrder:
            self.player.playModel  = MEAudioPlayerPlayModelRandom;
            break;
        case MEAudioPlayerPlayModelRandom:
            self.player.playModel  = MEAudioPlayerPlayModelSingle;
            break;
        case MEAudioPlayerPlayModelSingle:
            self.player.playModel  = MEAudioPlayerPlayModelOrder;
            break;
        default:
            self.player.playModel  = MEAudioPlayerPlayModelOrder;
            break;
    }
    
    [[MEUserDefaultManager defaultManager]setPlayModel:self.player.playModel];
}

- (IBAction)lastMusicBtnClick:(UIButton *)sender {
    [self.player lastMusic];
}

- (IBAction)nextMusicBtnClick:(UIButton *)sender {
    [self.player nextMusic];
}

- (IBAction)musicProgressValueChanged:(UISlider *)sender {
    self.currentTimeLabel.text = [self secondToTimeSting:sender.value];
}
-(IBAction)musicProgressSliderTouchEnd:(UISlider*)sender{
    BOOL isPlay = self.player.playing;
    [self.player setPlayTime:sender.value];
    if (!isPlay) {
        [self.player pause];
    }
}

#pragma mark - player delegate

-(void)audioPlayer:(MEAudioPlayer *)player updateTime:(CGFloat)currentTime mucsicID:(NSString *)currentMusicDescribe_ID{
    if (self.musicProgressSlider.isTracking) { return;}
    
    if (![self.currentMusicDescribe_ID isEqualToString:currentMusicDescribe_ID]) {
        self.currentMusicDescribe_ID = currentMusicDescribe_ID;
        self.musicProgressSlider.maximumValue = player.duration;
        self.musicProgressSlider.minimumValue = 0;
        MEMusic * currentMusic = self.player.currentMusic;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.detailLabel.text = [NSString stringWithFormat:@"%@ - %@",currentMusic.name,currentMusic.singer];
            self.totleTimeLabel.text = [self secondToTimeSting:player.duration];
        });
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.musicProgressSlider.value = currentTime;
        self.currentTimeLabel.text = [self secondToTimeSting:currentTime];
    });
    
    LOG(@"%@--%g",[self class],currentTime);
}


-(void)audioPlayer:(MEAudioPlayer *)player playModelChanged:(MEAudioPlayerPlayModel)playModel{
    [self changePlayBtnImageWithPlayModel:playModel];
}

-(void)audioPlayer:(MEAudioPlayer *)player playOrPauseChanged:(BOOL)isPause{
    if (isPause) {
        [self.pauseBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }else{
        [self.pauseBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
}
-(void)audioPlayerPlayCompleted:(MEAudioPlayer *)player{
    
}
#pragma mark - Other 

-(void)setTempEQWithValues:(NSArray *)values{
    NSString * name;
    if (self.title) {
        name = self.title;
    }else{
        name = MEL_Customize;
    }
    [[MEUserDefaultManager defaultManager] setTempEQValues:values andName:name];
}

-(void)remindAndSaveEQ:(NSArray <NSNumber *>*)EQArray{
    
    NSString * title = MEL_Save;
    NSString * messge = MEL_EnterName;
    NSString * placeHolder = messge;
    
    
    __weak typeof(self) weakSelf = self;
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:title message:messge preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:MEL_Cancel style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) { }];
    
    UIAlertAction * OK = [UIAlertAction actionWithTitle:MEL_OK style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField * textField = alertController.textFields.firstObject;
        if(nil == textField.text || textField.text.length == 0){
            [weakSelf newNameCannotBeNil];
            return ;
        }else{
            MEEqualizer * equalizer = [[MECoreDataManager defaultManager] saveEqualizerWithEQArray:EQArray andName:textField.text];
            [[MEUserDefaultManager defaultManager] setCurrentEQID:equalizer.eq_id];
            if (equalizer) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.title = textField.text;
                    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakSelf.view animated:YES];
                    hud.mode = MBProgressHUDModeText;
                    hud.label.text = MEL_SaveSuccess;
                    [hud hideAnimated:YES afterDelay:1.5];
                });
            }
         }
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = placeHolder;
    }];
    [alertController addAction:cancel];
    [alertController addAction:OK];
    [self presentViewController:alertController animated:YES completion:nil];
}
//字符串为空的提示
-(void)newNameCannotBeNil{
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:MEL_Prompt message:MEL_NotBeNull preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * ok = [UIAlertAction actionWithTitle:MEL_OK style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:ok];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

-(void)changePlayBtnImageWithPlayModel:(MEAudioPlayerPlayModel)playModel{
    switch (playModel) {
        case MEAudioPlayerPlayModelOrder:
            [self.playModelBtn setImage:[UIImage imageNamed:@"order"] forState:UIControlStateNormal];
            break;
        case MEAudioPlayerPlayModelRandom:
            [self.playModelBtn  setImage:[UIImage imageNamed:@"suiji"] forState:UIControlStateNormal];
            break;
        case MEAudioPlayerPlayModelSingle:
            [self.playModelBtn  setImage:[UIImage imageNamed:@"Single"] forState:UIControlStateNormal];
            break;
        default:
            [self.playModelBtn  setImage:[UIImage imageNamed:@"order"] forState:UIControlStateNormal];
            break;
    }
}

-(void)addTempListView{
    if (self.tempListView) {
        [self removeTemoListView];
    }else{
        self.maskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - self.bottomToolBar.bounds.size.height)];
        self.maskView.backgroundColor = [UIColor clearColor];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeTemoListView)];
        [self.maskView addGestureRecognizer:tap];
        [self.view addSubview:self.maskView];
       
        CGFloat width = self.view.bounds.size.width / 4 * 3;
        CGFloat height = self.view.bounds.size.height / 3 * 2;
        CGFloat X = self.view.bounds.size.width ;
        CGFloat Y = self.view.bounds.size.height - height - self.bottomToolBar.bounds.size.height;
        _tempListView = [[METemporaryPlayListView alloc]initWithFrame:CGRectMake(X, Y, width, height)];
        [self.view addSubview:_tempListView];
        CGFloat new_X = self.view.bounds.size.width - width;
        CGRect newFrame = CGRectMake(new_X, Y, width, height);
        [UIView animateWithDuration:0.3 animations:^{
            _tempListView.frame = newFrame;
        }];
    }
}
-(void)removeTemoListView{
    if (self.tempListView) {
        CGFloat width = self.view.bounds.size.width / 4 * 3;
        CGFloat height = self.view.bounds.size.height / 3 * 2;
        CGFloat X = self.view.bounds.size.width;
        CGFloat Y = self.view.bounds.size.height - height - self.bottomToolBar.bounds.size.height;
        CGRect newFrame = CGRectMake(X, Y, width, height);
        [UIView animateWithDuration:0.3 animations:^{
            _tempListView.frame = newFrame;
        } completion:^(BOOL finished) {
            [self.tempListView removeFromSuperview];
            [self.maskView removeFromSuperview];
            self.maskView = nil;
            self.tempListView = nil;
        }];
    }
}

-(NSString *)secondToTimeSting:(NSTimeInterval)time{
    int newTime = time;
    int sec = newTime%60;
    int min = (newTime/60)%60;
    return [NSString stringWithFormat:@"%02d:%02d",min,sec];
//    NSDate * date = [NSDate dateWithTimeIntervalSince1970:time];
//    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
//    
//    if (time/3600 >= 1) {
//        [formatter setDateFormat:@"HH:mm:ss"];
//    }else{
//        [formatter setDateFormat:@"mm:ss"];
//    }
//    return [formatter stringFromDate:date];
}
-(void)dealloc{
    LOG(@"---MEEqualizerViewController - dealloc");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSString *)fixEqualizerName:(NSString * )equalierName{
    NSString * name = equalierName;
    if ([equalierName isEqualToString:@"none"]) {
        name = MEL_none;
    }
    else if ([equalierName isEqualToString:@"Pop"]){
        name = MEL_Pop;
    }
    else if ([equalierName isEqualToString:@"Subwoofer"]){
        name = MEL_MegaBass;
    }
    else if ([equalierName isEqualToString:@"man_voice"]){
        name = MEL_Vocal;
    }
    else if ([equalierName isEqualToString:@"on_site"]){
        name = MEL_Live;
    }
    else if ([equalierName isEqualToString:@"Rock_Roll"]){
        name = MEL_Rock_Roll;
    }
    else if ([equalierName isEqualToString:@"ballad"]){
        name = MEL_Ballad;
    }
    else if ([equalierName isEqualToString:@"Drum & Bass"]){
        name = MEL_Drum_Bass;
    }
    else if ([equalierName isEqualToString:@"Jazz"]){
        name = MEL_Jazz;
    }
    else if ([equalierName isEqualToString:@"classical"]){
        name = MEL_Classic;
    }
    else if ([equalierName isEqualToString:@"Heavy_metals"]){
        name = MEL_HeavyMetal;
    }
    return name;
}

@end
