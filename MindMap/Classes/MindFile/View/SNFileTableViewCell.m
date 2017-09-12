//
//  SNFileTableViewCell.m
//  MindMap
//
//  Created by 何少博 on 2017/8/19.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNFileTableViewCell.h"
#import "NSFileManager+x.h"
#import "NSString+x.h"
#import "SNFileModel.h"
#import "SNNodeAsset.h"
#import "UIImage+SN.h"
@interface SNFileTableViewCell ()

@property (strong, nonatomic) NSDateFormatter *dateFormate;

@end

static UIImage * _blurImage  = nil;

@implementation SNFileTableViewCell

+(CGFloat)cellHeight{
    return 100;
}

-(NSDateFormatter *)dateFormate{
    if (_dateFormate == nil) {
        _dateFormate = [[NSDateFormatter alloc]init];
        [_dateFormate setTimeStyle:NSDateFormatterNoStyle];
        [_dateFormate setDateStyle:NSDateFormatterMediumStyle];
    }
    return _dateFormate;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor  = [UIColor clearColor];
}

-(void)setModel:(SNFileModel *)model{
    _model = model;
    self.fileNameLabel.text = model.name;
    self.createDataLabel.text = [self.dateFormate stringFromDate:model.creatDate];
    if (model.fileType == SNFileTypeFolder) {
        if (model.subPaths.count == 0) {
            self.itemCountLabel.text = @"";
        }else{
           self.itemCountLabel.text = [NSString stringWithFormat:@"%d", (int)model.subPaths.count];
        }
        
        self.myImageView.image = [UIImage imageNamed:@"pic"];
    }else{
        self.itemCountLabel.text = @"";
        if (_blurImage == nil) {
            UIImage * oriImage = [UIImage imageNamed:@"thumbMap"];
            _blurImage = [UIImage coreBlurImage:oriImage  withBlurNumber:5];
        }
        self.myImageView.image = _blurImage;
    }
    UIButton * iCloudStatusButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
    [iCloudStatusButton addTarget:self action:@selector(iCloudStatusButtonClick:) forControlEvents:(UIControlEventTouchUpInside)];
    if (model.iCloudStatus == SNFileiCloudStatusNotDownload) {
        [iCloudStatusButton setImage:[UIImage  imageNamed:@"download"] forState:(UIControlStateNormal)];
        self.accessoryView = iCloudStatusButton;
        self.itemCountLabel.text = @"";
    }
    else if (model.iCloudStatus == SNFileiCloudStatusNotUpload){
        [iCloudStatusButton setImage:[UIImage  imageNamed:@"upload"] forState:(UIControlStateNormal)];
        self.accessoryView = iCloudStatusButton;
        self.itemCountLabel.text = @"";
    }
    else if (model.iCloudStatus == SNFileiCloudStatusNormal){
        self.accessoryView = nil;
        if (model.fileType == SNFileTypeFolder) {
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }else{
            self.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    
    model.thumImage = model.nodeAsset.thumb;
    if (model.thumImage) {
        self.myImageView.image = model.thumImage;
    }
   
}
- (IBAction)iCloudStatusButtonClick:(id)sender {
    if (self.iCloudStatusBtnClickedBlock) {
        self.iCloudStatusBtnClickedBlock(_model);
    }
}



-(void)configCellWithFilePath:(NSString *)dirPath{
    self.fileNameLabel.text = [dirPath lastPathComponent];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
