//
//  STBarItem.h
//  STTabBarController
//
//  Created by 何少博 on 17/3/24.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, STBarItemType) {
    STBarItemTypeButton,
    STBarItemTypeCustomView
};

@interface STBarItem : UIBarItem<UIAppearance>

//@property (nonatomic,copy)   NSString     *badgeValue;
//@property (nonatomic,strong) UIImage      *badgeBackgroundImage;
//@property (nonatomic,assign) NSDictionary *badgeTextAttributeds;
//@property (nonatomic,assign) UIEdgeInsets  badgeInsets;
//@property (nonatomic,assign) CGSize badgeSize;
//
//- (void)setBadgeValue:(NSString *)badgeValue animated:(BOOL)animated;

/*
 设置选中图片和未选中时 的图片
 */
- (void)setSelectedImage:(UIImage *)selectedImage withUnselectedImage:(UIImage *)unselectedImage;

-(void)setSelectedTitleAttributes:(NSDictionary *)s_attributes widthUnselectedTitleAttributes:(NSDictionary *)u_attributes;

@property (nonatomic,strong) UIColor * tintColor;

@property (nonatomic,strong,readonly)UIImage *selectedImage;
@property (nonatomic,strong,readonly)UIImage *unselectedImage;

@property (nonatomic,strong,readonly)NSDictionary *selectedTitleAtt;
@property (nonatomic,strong,readonly)NSDictionary *unselectedTitleAtt;

//@property(nonatomic,assign) UIEdgeInsets titleEdgeInsets;

@property (nonatomic, readonly,assign) STBarItemType itemType;
@property (nonatomic,readonly,strong) UIView *contentView;

-(instancetype)initWithTitle:(NSString *)title image:(UIImage *)image;

-(instancetype)initWithCustomView:(UIView *)customView;

- (void)addTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (void)removeTarget:(id)target action:(SEL)action forControlEvents:(UIControlEvents)controlEvents;
- (void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event;
- (void)sendActionsForControlEvents:(UIControlEvents)controlEvents;

@end



