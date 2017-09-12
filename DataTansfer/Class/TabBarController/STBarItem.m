//
//  STBarItem.m
//  STTabBarController
//
//  Created by 何少博 on 17/3/24.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//





#import "STBarItem.h"
#import "UIImage+st.h"
static CGFloat const STBarBadgeViewPopAnimationDuration     = 0.4f;
static CGFloat const STBarBadgeViewFadeAnimationDuration    = 0.15f;
static UIOffset const STBarBadgeViewDefaultCenterOffset = (UIOffset){ 15.0f , 8.0f };
static CGSize const STBarBadgeViewMinmumSize = (CGSize){ 32.0f , 32.0f };





#pragma mark - STBarButton @interface
@interface STBarButton : UIButton



@property (nonatomic,weak) STBarItem *tabBarItem;

@end

#pragma mark - STBarItem @interface
@interface STBarItem ()<CAAnimationDelegate>

@property (nonatomic,assign) STBarItemType itemType;

@property (nonatomic,strong) UIView * itemView;

@property (nonatomic,strong) UIButton * itemButton;

@property (nonatomic,strong) UIButton * badgeButton;

@property (nonatomic,strong) UIView *contentView;

@property (nonatomic,strong)UIImage *selectedImage;

@property (nonatomic,strong)UIImage *unselectedImage;

@property (nonatomic,strong)NSDictionary *selectedTitleAtt;

@property (nonatomic,strong)NSDictionary *unselectedTitleAtt;

//---------------------------------------------------------------
//暂未处理
@property (nonatomic,copy)   NSString     *badgeValue;
@property (nonatomic,strong) UIImage      *badgeBackgroundImage;
@property (nonatomic,assign) NSDictionary *badgeTextAttributeds;
@property (nonatomic,assign) UIEdgeInsets  badgeInsets;
@property (nonatomic,assign) CGSize badgeSize;

- (void)setBadgeValue:(NSString *)badgeValue animated:(BOOL)animated;
//---------------------------------------------------------------





@end


#pragma mark - STBarItem @@implementation
@implementation STBarItem



-(UIView *)contentView{
    if (self.itemType == STBarItemTypeButton) {
        return self.itemButton;
    }
    return self.itemView;
}


-(UIEdgeInsets)imageInsets{
    return  self.itemButton.imageEdgeInsets;
}

-(void)setImageInsets:(UIEdgeInsets)imageInsets{
    [self.itemButton setImageEdgeInsets:imageInsets];
}
-(NSInteger)tag{
    return self.contentView.tag;
}
-(void)setTag:(NSInteger)tag{
    self.contentView.tag = tag;
}

- (void)setEnabled:(BOOL)enabled{
    
    [self.itemButton setSelected:enabled];
    
}

- (BOOL)isEnabled{
    return self.itemButton.isSelected;
}

- (NSString *)title{
    return [self.itemButton titleForState:UIControlStateNormal];
}

- (void)setTitle:(NSString *)title{
    [self.itemButton setTitle:title forState:UIControlStateNormal];
}

- (UIImage *)image{
    return [self.itemButton imageForState:UIControlStateNormal];
}

- (void)setImage:(UIImage *)image{
    [self.itemButton setImage:image forState:UIControlStateNormal];
}

-(void)setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets{
    [self.itemButton setTitleEdgeInsets:titleEdgeInsets];
}

-(UIEdgeInsets)titleEdgeInsets{
    return self.itemButton.titleEdgeInsets;
}

-(void)setTitleTextAttributes:(NSDictionary<NSString *,id> *)attributes forState:(UIControlState)state{
    UIFont * font = attributes[NSFontAttributeName];
    if (!font) {font = [UIFont systemFontOfSize:10];}
    
    UIColor * color = attributes[NSForegroundColorAttributeName];
    if (!color) {color = [UIColor blackColor];}
    
    [self.itemButton.titleLabel setFont:font];
    [self.itemButton setTitleColor:color forState:state];
    [self.itemButton setTitleShadowColor:[attributes[NSShadowAttributeName] shadowColor] forState:state];
    [self.itemButton.titleLabel setShadowOffset:[attributes[NSShadowAttributeName] shadowOffset]];
}


- (void)setSelectedImage:(UIImage *)selectedImage withUnselectedImage:(UIImage *)unselectedImage{
    UIColor * tintColor = self.tintColor ? self.tintColor : [UIColor colorWithRed:0.0 green:122/255.0 blue:1.0 alpha:1.0];
    if (selectedImage == nil) {
        selectedImage = [unselectedImage imageWithColor:tintColor];
    }
    
    [self.itemButton setImage:selectedImage forState:UIControlStateSelected];
    [self.itemButton setImage:unselectedImage forState:UIControlStateNormal];
    self.selectedImage = selectedImage;
    self.unselectedImage = unselectedImage;
}

-(void)setSelectedTitleAttributes:(NSDictionary *)s_attributes widthUnselectedTitleAttributes:(NSDictionary *)u_attributes{
    UIColor * tintColor = self.tintColor ? self.tintColor : [UIColor colorWithRed:0.0 green:122/255.0 blue:1.0 alpha:1.0];
    
    s_attributes = s_attributes ? s_attributes : [self defaultAttributes:tintColor];
    u_attributes = u_attributes ? u_attributes : [self defaultAttributes:[UIColor blackColor]];
    
    [self setTitleTextAttributes:u_attributes forState:UIControlStateNormal];
    [self setTitleTextAttributes:s_attributes forState:(UIControlStateSelected)];
    self.selectedTitleAtt = s_attributes;
    self.unselectedTitleAtt = u_attributes;
}

-(NSDictionary *)defaultAttributes:(UIColor *)color{
  
    NSDictionary * attributes = @{NSFontAttributeName : [UIFont systemFontOfSize:10],
                                  NSForegroundColorAttributeName : color
                                  };
    return attributes;
}



- (NSDictionary *)titleTextAttributesForState:(UIControlState)state{
    
    NSShadow *titleShadow = [[NSShadow alloc] init];
    titleShadow.shadowColor = [self.itemButton titleShadowColorForState:state];
    titleShadow.shadowOffset = self.itemButton.titleLabel.shadowOffset;
    NSDictionary * attributes = @{NSFontAttributeName : self.itemButton.titleLabel.font,
                           NSShadowAttributeName: titleShadow,
                           NSForegroundColorAttributeName : [self.itemButton titleColorForState:state],
                           };
    return attributes;
}

- (instancetype)init
{
    return [self initWithTitle:nil image:nil];
}
-(instancetype)initWithTitle:(NSString *)title image:(UIImage *)image{
    self = [super init];
    if (self) {
        _itemType = STBarItemTypeButton;
        
        STBarButton * button = [STBarButton buttonWithType:UIButtonTypeCustom];
        _itemButton = button;
        
        button.tabBarItem = self;
        [button setTitle:title forState:UIControlStateNormal];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [button setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
        [button setAdjustsImageWhenDisabled:NO];
        [button setAdjustsImageWhenHighlighted:NO];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:10]];
        button.titleLabel.adjustsFontSizeToFitWidth = YES;
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        [button setImage:image forState:UIControlStateNormal];
        self.unselectedImage = image;
    }
    return self;
}

-(instancetype)initWithCustomView:(UIView *)customView{
    self = [super init];
    if (self) {
        _itemType = STBarItemTypeCustomView;
        _itemView = customView;
    }
    return self;
}


- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents{
    [self.itemButton addTarget:target action:action forControlEvents:controlEvents];
}

- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents{
    [self.itemButton removeTarget:target action:action forControlEvents:controlEvents];
}

- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
    [self.itemButton sendAction:action to:target forEvent:event];
}

- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents{
    [self.itemButton sendActionsForControlEvents:controlEvents];
}

-(CAAnimation *)popAnimation{
    
    CAKeyframeAnimation * scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    NSValue * value1 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.2, 0.2, 1.0)];
        NSValue * value2 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)];
        NSValue * value3 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
    scaleAnimation.values = @[value1,value2,value3];
    scaleAnimation.keyTimes = @[@(0.0f),@(0.3f),@(0.5f)];
    
    CAKeyframeAnimation *opcaityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opcaityAnimation.values = @[@(0.0f),@(0.1f),@(1.0f)];
    opcaityAnimation.keyTimes = @[@(0.0f),@(0.1f),@(0.4f)];
    
    CAAnimationGroup * group = [CAAnimationGroup animation];
    group.animations = @[scaleAnimation,opcaityAnimation];
    group.duration = STBarBadgeViewPopAnimationDuration;
    group.fillMode = kCAFillModeForwards;
    group.removedOnCompletion = NO;
    
    return group;
}

-(CAAnimation *)hideAniamtion{
    CAKeyframeAnimation *opcatityAnimatioin = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    opcatityAnimatioin.values = @[@(0.0f),@(1.0f)];
    opcatityAnimatioin.keyTimes = @[@(1.0f),@(0.0f)];
    opcatityAnimatioin.duration = STBarBadgeViewFadeAnimationDuration;
    opcatityAnimatioin.fillMode = kCAFillModeForwards;
    opcatityAnimatioin.removedOnCompletion = NO;
    
    return opcatityAnimatioin;
}


-(CGSize)badgeSize{
    [self.badgeButton sizeToFit];
    CGSize bageSize = self.badgeButton.bounds.size;
    
    if (bageSize.width < STBarBadgeViewMinmumSize.width)
        bageSize.width = STBarBadgeViewMinmumSize.width;
    
    if (bageSize.height < STBarBadgeViewMinmumSize.height)
        bageSize.height = STBarBadgeViewMinmumSize.height;
    
    bageSize.width = bageSize.width - self.badgeInsets.right;
    bageSize.height = bageSize.height - self.badgeInsets.bottom;
    
    return  bageSize;
}

-(UIButton *)badgeButton{
    if (nil == _badgeButton) {
        UIButton * bageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _badgeButton = bageButton;
        [bageButton.titleLabel setFont:[UIFont systemFontOfSize:10]];
        bageButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        [bageButton setTitleShadowColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        bageButton.userInteractionEnabled = NO;
        bageButton.contentEdgeInsets = UIEdgeInsetsMake(0, 11, 0, 10);
    }
    return  _badgeButton;
}

-(NSString *)badgeValue{
    return  [self.badgeButton titleForState:UIControlStateNormal];
}
-(void)setBadgeValue:(NSString *)badgeValue{
    [self setBadgeValue:badgeValue animated:NO];
}


-(void)setBadgeValue:(NSString *)badgeValue animated:(BOOL)animated{
    if (badgeValue.length) {
        CGFloat X = CGRectGetMidX(self.contentView.bounds) - self.badgeSize.width/2 + STBarBadgeViewDefaultCenterOffset.horizontal + self.badgeInsets.left;
        CGFloat Y = CGRectGetMidY(self.contentView.bounds) - self.badgeSize.height/2 - STBarBadgeViewDefaultCenterOffset.vertical + self.badgeInsets.top;
        CGRect bageFrame = CGRectMake(X, Y, self.badgeSize.width, self.badgeSize.height);
        
        self.badgeButton.frame = bageFrame;
        
        self.badgeButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;
        self.badgeButton.alpha = 1.0;
        [self.contentView addSubview:self.badgeButton];
        [self.badgeButton.layer removeAnimationForKey:@"hideAnimationKey"];
        if ([self.badgeButton.layer animationForKey:@"popAnimationKey"]&&animated) {
            CAAnimation * hideAnimation = [self hideAniamtion];
            hideAnimation.delegate = self;
            [self.badgeButton.layer addAnimation:hideAnimation forKey:@"hideAnimationKey"];
        }else{
            self.badgeButton.alpha = 0.0;
        }
    }
}
-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)finished{
    if (finished) {
        self.badgeButton.alpha = 0.0;
    }
}



-(void)setBadgeTextAttributeds:(NSDictionary *)badgeTextAttributeds{
    [self.badgeButton setTitleColor:badgeTextAttributeds[NSForegroundColorAttributeName] forState:UIControlStateNormal];
    [self.badgeButton.titleLabel setFont:badgeTextAttributeds[NSFontAttributeName]];
    [self.badgeButton setTitleShadowColor:[badgeTextAttributeds[NSShadowAttributeName] shadowColor] forState:UIControlStateNormal];
    [self.badgeButton.titleLabel setShadowOffset:[badgeTextAttributeds[NSShadowAttributeName] shadowOffset]];
}

-(NSDictionary *)badgeTextAttributeds{
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [self.badgeButton titleShadowColorForState:UIControlStateNormal];
    shadow.shadowOffset = self.badgeButton.titleLabel.shadowOffset;
    
    NSString * title = [self.badgeButton titleForState:UIControlStateNormal];
    UIFont * font = self.badgeButton.titleLabel.font;
    NSDictionary * attributeds  = @{
                                    NSForegroundColorAttributeName:title,
                                    NSFontAttributeName:font,
                                    NSShadowAttributeName:shadow
                                    };
    
    return attributeds;
}

- (UIImage *)badgeBackgroundImage{
    return [self.badgeButton backgroundImageForState:UIControlStateNormal];
}

- (void)setBadgeBackgroundImage:(UIImage *)badgeBackgroundImage{
    [self.badgeButton setBackgroundImage:badgeBackgroundImage forState:UIControlStateNormal];
}


@end


#pragma mark - STBarButton @@implementation
@implementation STBarButton

-(void)setHighlighted:(BOOL)highlighted{
    [super setHighlighted:highlighted];
}

///调整自定义button的iamgeRect
-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGRect imageRect = [super imageRectForContentRect:contentRect];
    NSString * btnTitle = [self titleForState:UIControlStateNormal];
    
    BOOL hasText = btnTitle.length ? YES : NO;
    if (hasText) {
        CGFloat marign = 3.0;
        CGSize buttonSize = self.bounds.size;
        CGFloat width = buttonSize.height / 4 * 3 - marign * 2;
        imageRect.origin.x = (buttonSize.width - width) / 2;
        imageRect.origin.y = marign;
        imageRect.size.width = width;
        imageRect.size.height = width;
    }
    return imageRect;
}
///调整自定义button的titleRect
-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGSize buttonSize = self.bounds.size;
    CGFloat width = buttonSize.width;
    CGFloat height = buttonSize.height / 4;
    CGRect titleRect;
    titleRect.origin.x = 0.0;
    titleRect.origin.y = buttonSize.height / 4 * 3;
    titleRect.size.width = width;
    titleRect.size.height = height;
    return  titleRect;
}

-(void)didMoveToWindow{
    [super didMoveToWindow];

}

@end































