//
//  TextureChooseView.h
//  InstaMessage
//
//  Created by 何少博 on 16/8/2.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TextureChooseViewDelegate;

@interface TextureChooseView : UIView

@property (nonatomic,weak) id<TextureChooseViewDelegate> delegate;

@end


@protocol TextureChooseViewDelegate <NSObject>

-(void)textureChooseView:(TextureChooseView*)textureChooseView chooseImageWithName:(NSString *)imageName;
-(void)textureChooseViewCancelButtonClick:(TextureChooseView*)textureChooseView;
-(void)textureChooseViewDoneButtonClick:(TextureChooseView*)textureChooseView;

@end