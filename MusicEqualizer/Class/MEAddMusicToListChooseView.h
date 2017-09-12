//
//  MEAddMusicToListChooseView.h
//  MusicEqualizer
//
//  Created by 何少博 on 17/1/6.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MEList;

typedef void(^ChooseListBlock)(MEList * list);

@interface MEAddMusicToListChooseView : UIView

-(instancetype)initWithFrame:(CGRect)frame chooseMusicCallBack:(ChooseListBlock)block;

@end
