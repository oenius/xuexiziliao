//
//  DTFileTransferTableViewCell.m
//  DataTansfer
//
//  Created by 何少博 on 17/5/31.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTFileTransferTableViewCell.h"
#import "DTDwonTask.h"
#import "DTProgressButton.h"

@interface DTFileTransferTableViewCell ()

@property (nonatomic,strong) UIImageView * myImageView;

@property (nonatomic,strong) UILabel * namelabel;

@property (nonatomic,strong) UILabel * detailLabel;

@property (nonatomic,strong) DTProgressButton * progressBtn;

@end

@implementation DTFileTransferTableViewCell


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews{
    
    self.backgroundColor = [UIColor clearColor];
    
    self.myImageView = [[UIImageView alloc]init];
    self.myImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.myImageView];
    
    self.namelabel = [[UILabel alloc]init];
    self.namelabel.textColor = [UIColor blackColor];
    self.namelabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.namelabel];
    
    self.detailLabel = [[UILabel alloc]init];
    self.detailLabel.textColor = [UIColor blackColor];
    self.detailLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.detailLabel];
    
    self.progressBtn = [[DTProgressButton alloc]initWithFrame:CGRectZero];
    [self.progressBtn setProgress:0.0];
    [self addSubview:self.progressBtn];
    [self.progressBtn addFailedAction:@selector(retryClick) target:self];
    
    [self.myImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(10.0);
        make.left.equalTo(self.mas_left).offset(10.0);
        make.bottom.equalTo(self.mas_bottom).offset(-10.0);
        make.width.equalTo(self.mas_height).offset(-20);
    }];
    
    [self.progressBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.mas_right).offset(-10.0);
        make.width.equalTo(@(30));
        make.height.equalTo(@(30));
    }];
    [self.namelabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.myImageView.mas_top);
        make.left.equalTo(self.myImageView.mas_right).offset(10);
        make.height.equalTo(@(20));
        make.right.equalTo(self.progressBtn.mas_left).offset(-10);
    }];
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.myImageView.mas_bottom);
        make.left.equalTo(self.myImageView.mas_right).offset(10);
        make.height.equalTo(@(20));
        make.right.equalTo(self.progressBtn.mas_left).offset(-10);
    }];
}

-(void)setModel:(DTDwonTask *)model{
    _model = model;
    UIImage * image;
    switch (model.downType) {
        case DTFileTypeContact:
            image = [UIImage imageNamed:@"tongxunlu"];
            break;
        case DTFileTypePhtoto:
            image = [UIImage imageNamed:@"xiangce"];
            break;
        case DTFileTypeVideo:
            image = [UIImage imageNamed:@"shiping"];
            break;
        case DTFileTypeMusic:
            image = [UIImage imageNamed:@"yinyue"];
            break;
        default:
            break;
    }
    self.myImageView.image = image;
    self.namelabel.text = model.name;
    NSString * status ;
    switch (model.status) {
        case DTDwonTaskStatusNotStart:
            status = [DTConstAndLocal Waiting];
            self.progressBtn.statu = DTProgressStatuNone;
            break;
        case DTDwonTaskStatusLoading:
            status = [DTConstAndLocal LoadingResource];
            self.progressBtn.statu = DTProgressStatuLoading;
            break;
        case DTDwonTaskStatusDownloading:
            status = [DTConstAndLocal downloading];
            self.progressBtn.statu = DTProgressStatuDowning;
            break;
        case DTDwonTaskStatusTimeOut:
            status = [DTConstAndLocal Requestimeout];
            self.progressBtn.statu = DTProgressStatuFailed;
            break;
        case DTDwonTaskStatusNotContectServer:
            status = [DTConstAndLocal connectionfailure];
            self.progressBtn.statu = DTProgressStatuFailed;
            break;
        case DTDwonTaskStatusFailed:
            status = [DTConstAndLocal downFaild];
            self.progressBtn.statu = DTProgressStatuFailed;
            break;
        case DTDwonTaskStatusSuccessed:
            status = [DTConstAndLocal downSuccess];
//            self.progressBtn.statu = DTProgressStatuSuccess;
            break;
        case DTDwonTaskStatusPause:
//            status = @"下载暂停";
            break;
        case DTDwonTaskStatusSaveFailed:
            status = [DTConstAndLocal saveFailed];
            self.progressBtn.statu = DTProgressStatuFailed;
            break;
        case DTDwonTaskStatusSaveSuccesse:
            status = [DTConstAndLocal savesuccess];
            self.progressBtn.statu = DTProgressStatuSuccess;
            break;
        default:
            break;
    }
    self.detailLabel.text = status;
    self.progressBtn.progress = model.progress;
 
}

-(void)retryClick{
    if (_model.status == DTDwonTaskStatusSaveSuccesse) {
        return;
    }
    if (self.retryBlock) {
        self.retryBlock(_model);
    }
}



@end
