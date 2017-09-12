//
//  SNNodeAsset.h
//  MindMap
//
//  Created by 何少博 on 2017/8/10.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SNNodeView;
@interface SNNodeAsset : NSObject<NSCoding>

@property (copy, nonatomic) NSString *displayName;
@property (copy, nonatomic) NSString *mapPath;
@property (copy, nonatomic) NSString *assetPath;
@property (strong, nonatomic) UIColor *bgColor;
@property (strong, nonatomic) UIImage *thumb;
@property (strong, nonatomic) NSDate *modifiedDate;
@property (strong, nonatomic) NSDate *creatDate;


-(instancetype)initWithAssetPath:(NSString *)path;
-(void)setupWithPath:(NSString *)path;
-(NSArray *)load;
-(void)resetAssetPathWithName:(NSString *)name;
-(NSData *)save:(NSArray<SNNodeView *> *)nodes autoReName:(BOOL) autoReName;
-(NSData *)saveSelf;


@end
