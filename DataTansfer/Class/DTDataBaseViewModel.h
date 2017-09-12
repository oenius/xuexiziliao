//
//  DTDataBaseViewModel.h
//  DataTansfer
//
//  Created by 何少博 on 17/5/18.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSData+DT.h"
#import <Photos/Photos.h>
#import <AddressBook/AddressBook.h>
#import <Contacts/Contacts.h>
//#import <MediaPlayer/MediaPlayer.h>
typedef enum : NSUInteger {
    DTAuthorizationResultYES,
    DTAuthorizationResultNO,
} DTAuthorizationResult;

typedef void(^DTAuthorizationResultBlock)(DTAuthorizationResult result);

@interface DTDataBaseViewModel : NSObject
/** 数据模型总数 */
@property (nonatomic,assign) NSInteger totleCount;
/** 已选择的数据模型个数 */
@property (nonatomic,assign) NSInteger selectedCount;
/** 选择的数据模型数组 */
@property (nonatomic,strong) NSMutableArray * selectedArray;
/** 数据模型数据 */
@property (nonatomic,strong) NSMutableArray * dataArray;
/** 当 dataArray.count == 0 时重新获取设备资源文件 */
-(void)loadDatas;
/** 获取权限 没有权限时会提示取设置权限 */
-(void)authorizationStatus:(DTAuthorizationResultBlock)block;
/** 获得归档后的Data */
+(void)archivedModel:(id)model completed:(void(^)(NSData * data)) completed;


@end
