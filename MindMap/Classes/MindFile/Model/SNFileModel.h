//
//  SNFileModel.h
//  MindMap
//
//  Created by 何少博 on 2017/8/19.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SNNodeAsset;

typedef enum : NSUInteger {
    SNFileTypeMindMap,
    SNFileTypeFolder,
} SNFileType;
typedef enum : NSUInteger {
    SNFileiCloudStatusNormal,
    SNFileiCloudStatusNotDownload,
    SNFileiCloudStatusNotUpload,
} SNFileiCloudStatus;




@interface SNFileModel : NSObject
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *filePath;
@property (nonatomic,copy) NSString *mapPath;
@property (nonatomic,copy) NSString *relativePath;
@property (nonatomic,copy) NSString *fileSize;
@property (nonatomic,copy) NSMutableArray *subPaths;
@property (strong, nonatomic) SNNodeAsset *nodeAsset;
@property (strong, nonatomic) UIImage *thumImage;
@property (strong, nonatomic) NSDate *creatDate;
@property (assign, nonatomic) SNFileType fileType;
@property (assign, nonatomic) SNFileiCloudStatus iCloudStatus;

@end
