//
//  STTabBar.m
//  Common
//
//  Created by 何少博 on 17/3/27.
//  Copyright © 2017年 camory. All rights reserved.
//



#import "STTabBar.h"
#import "STBarItem.h"
#import "UIView+st.h"
#import "UIImage+st.h"
//#import "UIButton+st.h"
static NSUInteger const STTabBarItemDefaultSelectedIndex = 0;
static CGFloat const STTabBarButtonItemPadding = 0.0;
static CGFloat const STTabBarButtonItemTopMargin = 0.0;
static CGFloat const STTabBarButtomItemLeftMargin = 0.0;

CGFloat const STTabBarSelectionIndicatorAnimationDuration = 0.3;

@interface STTabBar ()

@property(nonatomic,strong) UIImageView * backgroundImageIvew;

@property(nonatomic,strong) UIImageView * shadowImageView;

@property(nonatomic,strong) UIImageView * selectionIndicatorImageView;

@property(nonatomic,readonly) NSArray * allCustomButtonView;

@property(nonatomic,readonly) CGFloat itemButtonWidth;


@end

@implementation STTabBar

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

-(void)setupSubViews{
    self.shadowImageView = [[UIImageView alloc]init];
    self.shadowImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self addSubview:_shadowImageView];
    
    self.backgroundImageIvew = [[UIImageView alloc]init];
    self.backgroundImageIvew.userInteractionEnabled = YES;
    [self addSubview:self.backgroundImageIvew];
    [self.backgroundImageIvew addConstraintEqualTopToSupview:self];
    [self.backgroundImageIvew addConstraintEqualLeftToSupview:self];
    [self.backgroundImageIvew addConstraintEqualBottomToSupview:self spacing:0.0];
    [self.backgroundImageIvew addConstraintEqualRightToSupview:self];
    
    
    self.selectionIndicatorImageView = [[UIImageView alloc]init];
    self.selectionIndicatorImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.selectionIndicatorImageView.autoresizingMask =  UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:_selectionIndicatorImageView];
    self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
}

-(void)setItems:(NSArray *)items{
    if (_items == items) return;
    _items = items;
    [self setupTabBarItems];
}

-(void)setupTabBarItems{
    [self.items enumerateObjectsUsingBlock:^(STBarItem *itemButton, NSUInteger idx, BOOL * _Nonnull stop) {
        [itemButton.contentView removeFromSuperview];
    }];
    
    __weak typeof(self) weakSelf = self;
    [self.items enumerateObjectsUsingBlock:^(STBarItem *itemButton, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        itemButton.tintColor = strongSelf.tintColor;
        [itemButton setSelectedImage:itemButton.selectedImage withUnselectedImage:itemButton.unselectedImage];
        [itemButton setSelectedTitleAttributes:itemButton.selectedTitleAtt widthUnselectedTitleAttributes:itemButton.unselectedTitleAtt];
        [itemButton addTarget:self action:@selector(selecteButtonItem:) forControlEvents:UIControlEventTouchUpInside];
        [strongSelf addSubview:itemButton.contentView];
        if(STTabBarItemDefaultSelectedIndex == idx) [strongSelf selecteButtonItem:itemButton.contentView];
        itemButton.tag = idx;
    }];
}

- (STBarItem *)tabBarItemForItemButton:(UIButton *)itemButton{
    NSUInteger itemIndex = itemButton.tag;
    NSAssert(itemIndex < self.items.count, @"下表越界");
    return self.items[itemIndex];
}

-(void)selecteButtonItem:(id)sender{
    UIButton * button = (UIButton *)sender;
    
    STBarItem *  item = [self tabBarItemForItemButton:button];
    
    if ([self.delegate respondsToSelector:@selector(tabBar:shouldSelectItem:)]) {
        BOOL should = [self.delegate tabBar:self shouldSelectItem:item];
        if (should == NO) { return; }
    }
    NSLog(@"9999%@",NSStringFromClass([self.selectedItem.contentView class]));
    UIButton * selectedButton = (UIButton *)(self.selectedItem.contentView);
    item.enabled = !item.enabled;
    self.selectedItem.enabled = !selectedButton.isSelected;
    
    CGFloat duration = self.selectionIndicatorAnimable ? STTabBarSelectionIndicatorAnimationDuration : 0.0;
    UIViewAnimationOptions options = (UIViewAnimationCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState);
    
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        self.selectionIndicatorImageView.frame = button.frame;
    } completion:^(BOOL finished) {
        
    }];
    self.selectedItem = item;
    if ([self.delegate respondsToSelector:@selector(tabBar:didSelectItem:)]) {
        [self.delegate tabBar:self didSelectItem:item];
    }
    
}

-(void)setTopLineColor:(UIColor *)topLineColor{
    _topLineColor = topLineColor;
    [self setNeedsDisplay];
}


-(void)setBackgroundImage:(UIImage *)backgroundImage{
    if (_backgroundImage == backgroundImage) { return ;}
    _backgroundImage = backgroundImage;
    self.backgroundImageIvew.image = backgroundImage;
    self.backgroundImageIvew.frame = self.bounds;
    
}
-(void)setSelectionIndicatorImage:(UIImage *)selectionIndicatorImage{
    if (_selectionIndicatorImage == selectionIndicatorImage) {return;}
    _selectionIndicatorImage = selectionIndicatorImage;
    self.selectionIndicatorImageView.image = selectionIndicatorImage;
}
-(void)setTintColor:(UIColor *)tintColor{
    if (_tintColor == tintColor) {
        return;
    }
    _tintColor = tintColor;
}

-(void)setSelectedImageTintColor:(UIColor *)selectedImageTintColor{
    if (_selectedImageTintColor == selectedImageTintColor) {
        return;
    }
    _selectedImageTintColor = selectedImageTintColor;
}
-(void)setShadowImage:(UIImage *)shadowImage{
    if (_shadowImage == shadowImage) {
        return;
    }
    _shadowImage = shadowImage;
    self.shadowImageView.image = shadowImage;
}

-(NSArray *)allCustomButtonView{
    NSPredicate * pre = [NSPredicate predicateWithFormat:@"SELF.itemType = %d",STBarItemTypeCustomView];
    return [self.items filteredArrayUsingPredicate:pre];
}
-(CGFloat)itemButtonWidth{
    
    __block CGFloat customViewWidth = 0.0;
    NSArray * customViews = [self allCustomButtonView];
    [customViews enumerateObjectsUsingBlock:^(STBarItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        customViewWidth += item.contentView.bounds.size.width;
    }];
    CGFloat tabBarWidth = self.bounds.size.width;
    
    CGFloat itemButtonWidth = (tabBarWidth - customViewWidth - (STTabBarButtonItemPadding*self.items.count-1)-STTabBarButtomItemLeftMargin*2)/(self.items.count-customViews.count);
    return itemButtonWidth;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    CGFloat itemButtonWidth = self.itemButtonWidth;
    CGSize barSize = self.bounds.size;
    __block CGFloat itemButtonOffsetX = STTabBarButtomItemLeftMargin;
    
    [self.items enumerateObjectsUsingBlock:^(STBarItem *item, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *itemContentView = item.contentView;
        [itemContentView sizeToFit];
        CGFloat itemButtonOffsetY = STTabBarButtonItemTopMargin;
        
        CGRect frame = CGRectZero;
        CGFloat offsetLength = itemButtonWidth;
        
        if (item.itemType == STBarItemTypeButton) {
            frame = CGRectMake(itemButtonOffsetX, itemButtonOffsetY, itemButtonWidth, barSize.height);
            offsetLength = itemButtonWidth + STTabBarButtonItemPadding;
        }
        else if (item.itemType == STBarItemTypeCustomView){
            frame = CGRectMake(itemButtonOffsetX, itemButtonOffsetY, itemButtonWidth, barSize.height);
            offsetLength = itemContentView.bounds.size.width + STTabBarButtonItemPadding;
        }
        itemContentView.frame = frame;
//        if (item.itemType == STBarItemTypeButton) {
//            UIButton * itemButton = (UIButton *)itemContentView;
//            [itemButton setTitlePosition:TitlePositionBottom];
//        }
        itemButtonOffsetX += offsetLength;
        
    }];
    NSLog(@"%@",NSStringFromClass([self.selectedItem.contentView class]));
    self.selectionIndicatorImageView.frame = self.selectedItem.contentView.frame;
    
    [self.shadowImageView sizeToFit];
    
    CGFloat Y = -CGRectGetHeight(self.shadowImageView.bounds);
    CGFloat W = self.shadowImageView.bounds.size.width;
    CGFloat H = self.shadowImageView.bounds.size.height;
    self.shadowImageView.frame = CGRectMake(0,Y,W,H);
    
    
}


-(void)drawRect:(CGRect)rect{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat r,g,b,a;
    UIColor * tintColor = self.topLineColor ? self.topLineColor : [UIColor lightGrayColor];
    CGContextSetLineWidth(context,1.0);
    [tintColor getRed:&r green:&g blue:&b alpha:&a];
    CGContextSetRGBStrokeColor(context, r, g, b, a);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context,rect.size.width, 0);
    CGContextStrokePath(context);
}


@end





















