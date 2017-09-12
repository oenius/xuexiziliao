//
//  GameButton.h
//  MemoryTurnCard
//
//  Created by 何少博 on 16/10/24.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameButton : UIButton

@property (nonatomic,strong)NSString * imageName;
//@property (nonatomic,strong)NSString * imagePath;

@property (nonatomic,assign)BOOL isOpen;

@end
