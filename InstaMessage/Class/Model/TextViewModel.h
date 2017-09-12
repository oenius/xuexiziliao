//
//  TextViewModel.h
//  InstaMessage
//
//  Created by 何少博 on 16/8/1.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TextViewModel : NSObject

@property (nonatomic,strong)NSString * imageName;
@property (nonatomic,strong)NSNumber * acrionTag;

-(instancetype)initWithDictionary:(NSDictionary*)dictionary;
+(instancetype)textViewModelWithDictionary:(NSDictionary *)dictionary;
@end
