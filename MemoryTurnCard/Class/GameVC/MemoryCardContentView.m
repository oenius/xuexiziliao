//
//  MemoryCardContentView.m
//  MemoryTurnCard
//
//  Created by 何少博 on 16/10/24.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#define kDefault -100

#import "MemoryCardContentView.h"
#import "GameButton.h"
#import "ImageManage.h"
#import "ViewAnimation.h"
@interface MemoryCardContentView ()
//0->(2x2),1->(2x3),3->(2x4),4->(3x4),5->(4x4),6->(4x5)

@property (nonatomic,copy) succeedBlock block;

@property (nonatomic,assign) BOOL isAnimationing;
@property (nonatomic,assign) NSInteger hardLevel;
@property (nonatomic,assign) NSInteger lastBtnTag;
@property (nonatomic,assign) NSInteger currBtnTag;
@property (nonatomic,assign) NSInteger openCardFlag;
@property (nonatomic,assign) GameImageType imageTyepe;
//@property (nonatomic,strong) NSArray * imagePathArray;
@property (nonatomic,strong) NSArray * imageNameArray;
@property (nonatomic,strong) NSMutableArray * subViewsBtn;
@property (nonatomic,strong) UIImage * backImage;
@property (nonatomic,strong) NSMutableArray * frameArray;;
@property (nonatomic,assign) BOOL isFirst;
@property (nonatomic,assign) float leftX;
@property (nonatomic,assign) float topY;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,assign) BOOL onceFlag;
@end

@implementation MemoryCardContentView
#pragma mark - 初始化方法
-(instancetype)initWithFrame:(CGRect)frame dardLevel:(NSInteger)hardLevel imageType:(GameImageType)imageType succeedBlock:(succeedBlock)block{
    self = [super initWithFrame:frame];
    if (self) {
        _hardLevel = hardLevel;
        _imageTyepe = imageType;
        _block = block;
        _openCardFlag = 0;
        _lastBtnTag = kDefault;
        _currBtnTag = kDefault;
        _isFirst = YES;
        _onceFlag = YES;
        _index = 0;
        [self addCardBtn];
    }
    return self;
}

-(instancetype)initWithHardLevel:(NSInteger)hardLevel imageType:(GameImageType)imageType succeedBlock:(succeedBlock)block{
    self = [super init];
    if (self) {
        _hardLevel = hardLevel;
        _imageTyepe = imageType;
        _block = block;
        _openCardFlag = 0;
        _lastBtnTag = kDefault;
        _currBtnTag = kDefault;
        _isFirst = YES;
        _onceFlag = YES;
        _index = 0;
        [self addCardBtn];
    }
    return self;
}

#pragma mark - 加载数据

-(UIImage *)backImage{
    if (_backImage == nil) {
        switch (_imageTyepe) {
            case GameImageTypeFruit:
                _backImage = [UIImage imageNamed:@"cardbackground"];
                break;
            case GameImageTypeAnimal:
                _backImage = [UIImage imageNamed:@"cardbackground"];
                break;
            case GameImageTypeABC:
                _backImage = [UIImage imageNamed:@"cardbackground"];
                break;
            case GameImageTypeOther:
                _backImage = [UIImage imageNamed:@"cardbackground"];
                break;
            default:
                break;
        }
    }
    return _backImage;
}

-(NSArray *)imageNameArray{
    if (_imageNameArray == nil) {
        NSArray * array = [NSArray arrayWithArray:[ImageManage imageNameWithType:_imageTyepe]];
        NSInteger count = [self subViewCount:_hardLevel]/2;
        //随机取出要的个数
        NSMutableSet *randomSet = [[NSMutableSet alloc] init];
        while ([randomSet count] < count) {
            int seed = arc4random() % [array count];
            [randomSet addObject:[array objectAtIndex:seed]];
        }
        //复制一份
        NSMutableArray * doublearray = [NSMutableArray arrayWithArray:randomSet.allObjects];
        [doublearray addObjectsFromArray:randomSet.allObjects];
        //打乱顺序
        _imageNameArray = [doublearray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            int seed = arc4random_uniform(2);
            if (seed) {
                return [obj1 compare:obj2];
            } else {
                return [obj2 compare:obj1];
            }
        }];
    }
    return _imageNameArray;
}

//-(NSArray *)imagePathArray{
//    if (_imagePathArray == nil) {
//        NSMutableArray * pathArray = [NSMutableArray array];
//        for (NSString * name in self.imageNameArray) {
//            NSString * imagePath = [[NSBundle mainBundle]pathForResource:name ofType:nil];
//            [pathArray addObject:imagePath];
//        }
//        _imagePathArray = pathArray;
//    }
//    return _imagePathArray;
//}

-(NSMutableArray *)subViewsBtn{
    if (_subViewsBtn == nil) {
        _subViewsBtn = [NSMutableArray array];
    }
    return _subViewsBtn;
}
-(NSMutableArray *)frameArray{
    if (_frameArray==nil) {
        _frameArray = [NSMutableArray array];
    }
    return _frameArray;
}
-(NSInteger)hengZheGeShu:(NSInteger)hardLevel{
    //0->(2x2),1->(2x3),2->(2x4),3->(3x4),4->(4x4),5->(4x5),6(5x6)
    NSInteger count = 0;
    switch (hardLevel) {
        case 0:
        case 1:
        case 2: count = 2; break;
        case 3: count = 3; break;
        case 4:
        case 5: count = 4; break;
        case 6: count = 5; break;
        default:  break;
    }
    return count;
}
-(NSInteger)subViewCount:(NSInteger)hardLevel{
    //0->(2x2),1->(2x3),2->(2x4),3->(3x4),4->(4x4),6->(4x5)
    NSInteger count = 0;
    switch (hardLevel) {
        case 0: count = 4;  break;
        case 1: count = 6;  break;
        case 2: count = 8;  break;
        case 3: count = 12; break;
        case 4: count = 16; break;
        case 5: count = 20; break;
        case 6: count = 30; break;
        default:  break;
    }
    return count;
}
#pragma mark - 布局子控件
-(void)addCardBtn{
    
    NSInteger count = [self subViewCount:_hardLevel];
    for (int i = 0; i < count; i ++ ) {
        GameButton * btn = [[GameButton alloc]init];
        btn.tag = i;
        btn.alpha = 0;
//        btn.imagePath = [self.imagePathArray objectAtIndex:i];
        btn.imageName = [self.imageNameArray objectAtIndex:i];
        [btn setImage:self.backImage forState:UIControlStateNormal];
        [btn setImage:self.backImage forState:UIControlStateHighlighted];
        [btn addTarget:self action:@selector(onCardBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        [self.subViewsBtn addObject:btn];
    }
}
-(void)removeSelfWithAnimation{
    __weak typeof(self) weakSekf = self;
    [UIView animateWithDuration:0.3 animations:^{
        for (int i = 0; i < self.subViewsBtn.count; i ++) {
            GameButton * btn = [self.subViewsBtn objectAtIndex:i];
            btn.center = self.center;
            btn.alpha = 0;
        }
    } completion:^(BOOL finished) {
        [weakSekf removeFromSuperview];
    }];
}

-(void)removeFromSuperview{
    [super removeFromSuperview];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    float Spacing = 10;
    float W = self.bounds.size.width;
    float H = self.bounds.size.height;
    int count = (int)[self subViewCount:_hardLevel];
    int hengCount = (int)[self hengZheGeShu:_hardLevel];
    int shuCount = count/hengCount;
    float btnW = (W - (hengCount + 1)* Spacing)/hengCount;
    float btnH = (H - (shuCount + 1) * Spacing)/shuCount;
    float min = MIN(btnH, btnW);
    float maxWigth = 100.0;
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        maxWigth = 150;
    }
    min = min>maxWigth ? maxWigth : min;
    float topY = (H - shuCount*(min+Spacing)+Spacing)/2;
    float leftX = (W - hengCount*(min+Spacing)+Spacing)/2;
    //布局
    for (int i = 0; i < count; i ++) {
        float x = leftX + (i % hengCount) * (min + Spacing);
        float y = topY + (i / hengCount) * (min + Spacing);
        GameButton * btn = [self.subViewsBtn objectAtIndex:i];
        CGRect frame = CGRectMake(x, y, min, min);
        if (_isFirst) {
            btn.frame = CGRectMake(0,0, min, min) ;
            btn.center = self.center;
            [self.frameArray addObject:NSStringFromCGRect(frame)];
        }else{
            btn.frame = frame;
        }
    }
    //subView会调用两次
    if (_onceFlag == YES) {
        [self performSelector:@selector(cardAnimation) withObject:nil afterDelay:0.5];
        _onceFlag = NO;
    }
}
-(void)cardAnimation{
    
    _isFirst = NO;
    _isAnimationing = YES;
    if (_index == self.subViewsBtn.count) {
        _index = 0;
        _isAnimationing = NO;
        return;
    }
    CGFloat duration = 3.5 / self.subViewsBtn.count;
    if (duration > 0.25) {
        duration = 0.25;
    }
    GameButton * btn = [self.subViewsBtn objectAtIndex:_index];
    CGRect frame = CGRectFromString(self.frameArray[_index]);
    
    [UIView animateWithDuration:duration animations:^{
        btn.frame = frame;
        btn.alpha = 1;
    } completion:^(BOOL finished) {
        _index ++;
        [self cardAnimation];
    }];
}
#pragma mark - actions
-(void)onCardBtnClick:(GameButton*)sender{
    if (_lastBtnTag == kDefault) {
        _lastBtnTag = sender.tag;
    }else{
        _currBtnTag = sender.tag;
    }
    [self turnCard:sender];
    
}
-(void)turnCard:(GameButton*)sender{
    if (sender.isOpen) {
        [sender setImage:self.backImage forState:UIControlStateNormal];
        sender.isOpen = NO;
        [ViewAnimation animationFilpFromRight:sender duration:0.4 completion:nil];
    }else{
        sender.isOpen = YES;
        [sender setImage:[UIImage imageNamed:sender.imageName] forState:UIControlStateNormal];
//         [sender setImage:[UIImage imageWithContentsOfFile:sender.imagePath] forState:UIControlStateNormal];
        [ViewAnimation animationFilpFromLeft:sender duration:0.4 completion:nil];
    }
    [self checkCard];
}
-(void)checkCard{
    
    if (_currBtnTag != kDefault && _lastBtnTag != kDefault) {
        GameButton *lastGameBtn = [self.subViewsBtn objectAtIndex:_lastBtnTag];
        GameButton *currGameBtn = [self.subViewsBtn objectAtIndex:_currBtnTag];
        if ([lastGameBtn.imageName isEqualToString:currGameBtn.imageName]) {
            self.openCardFlag += 1;
        }else{
            self.userInteractionEnabled = NO;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self turnCard:lastGameBtn];
                [self turnCard:currGameBtn];
                self.userInteractionEnabled = YES;
            });
        }
        _currBtnTag = kDefault;
        _lastBtnTag = kDefault;
    }
    NSInteger count = [self subViewCount:_hardLevel]/2;
    if (self.openCardFlag == count) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakSelf.block) {
                weakSelf.block(0);
            }
        });
        
    }
}
-(void)dealloc{
    LOG(@"%s",__func__);
}
@end
