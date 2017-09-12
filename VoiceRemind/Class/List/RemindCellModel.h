//
//  RemindCellModel.h
//  VoiceRemind
//
//  Created by 何少博 on 16/8/25.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VoiceRemindENUM.h"

/*
 录音文件存储plist数据结构
 
 {
        key(某一天) = value(字典)
                        {
                            key(文件名) = value(字典，文件属性)
                                                {
                                                    key(标题) = value
                                                    key(文件名) = value
                                                    key(标题) = value
                                                    key() = value
                                                }
                             key 2   = vlaue 2
                             key 3   = vlaue 3
                             key 4   = vlaue 4
                             .................
 
                        }
 
        key 2   = vlaue 2
        key 3   = vlaue 3
        key 4   = vlaue 4
        .................
 
 }
 
 */

@interface RemindCellModel : NSObject

@property (strong,nonatomic)NSString * fileName;
@property (strong,nonatomic)NSString * remindTime;
@property (strong,nonatomic)NSString * titleName;
@property (strong,nonatomic)NSString * timeLength;
@property (strong,nonatomic)NSNumber * imageType;
@property (strong,nonatomic)NSDate * noticeDate;
@property (strong,nonatomic)NSString * openRemind;
@property (strong,nonatomic)NSString * remindBody;
@property (strong,nonatomic)NSNumber * repeatType;
@property (strong,nonatomic)NSString * remindMusic;


-(instancetype)initWithDic:(NSDictionary *)dic;
+(instancetype)modelWithDic:(NSDictionary*)dic;

@end
