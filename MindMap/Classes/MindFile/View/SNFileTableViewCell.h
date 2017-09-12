//
//  SNFileTableViewCell.h
//  MindMap
//
//  Created by 何少博 on 2017/8/19.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SNFileModel;

@interface SNFileTableViewCell : UITableViewCell
@property (nonatomic , weak) IBOutlet UILabel *fileNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *createDataLabel;
@property (nonatomic, weak) IBOutlet UILabel *fileSizeLabel;
@property (nonatomic, weak) IBOutlet UIImageView *myImageView;
@property (weak, nonatomic) IBOutlet UILabel *itemCountLabel;
@property (strong, nonatomic) SNFileModel *model;
@property (copy, nonatomic) void(^iCloudStatusBtnClickedBlock)(SNFileModel *model);

-(void)configCellWithFilePath:(NSString *)filePath;
+(CGFloat)cellHeight;
@end
