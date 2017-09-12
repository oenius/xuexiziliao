//
//  MESongsTableViewCell.m
//  MusicEqualizer
//
//  Created by 何少博 on 16/12/27.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#import "MESongsTableViewCell.h"
#import "UIColor+x.h"


@interface MESongsTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *myImageView;

@property (weak, nonatomic) IBOutlet UILabel *songsNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *singerNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *detailBtn;

@property (weak, nonatomic) IBOutlet UIButton *favoriteBtn;

@property (weak, nonatomic) IBOutlet UIButton *addToListBtn;

@property (weak, nonatomic) IBOutlet UIButton *nextBtn;

@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;

@property (weak, nonatomic) IBOutlet UIButton *isiPodBtn;


@property (copy,nonatomic) ActionsCallBack block;

@property (assign, nonatomic) BOOL isHiddenDetailMenu;

@end

@implementation MESongsTableViewCell


+(NSString *)className{
    
    return NSStringFromClass(self);
}

-(void)setMusicModel:(MEMusic *)musicModel{
    _musicModel = musicModel;
    _myImageView.image = [UIImage imageWithData:musicModel.image];
    _songsNameLabel.text = musicModel.name;
    _singerNameLabel.text = musicModel.singer;
    if (musicModel.isFavorite) {
        [_favoriteBtn setImage:[UIImage imageNamed:@"favorite_choosed"] forState:UIControlStateNormal];
    }else{
        [_favoriteBtn setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
    }
    if (musicModel.isEditState) {
        [self setActionBtnHidden:NO];
    }else{
        [self setActionBtnHidden:YES];
    }
    if (!musicModel.isiPod) {
        self.isiPodBtn.hidden = YES;
    }
}
-(void)setIsFavorive:(BOOL)isfavorite{
    if (isfavorite) {
        [_favoriteBtn setImage:[UIImage imageNamed:@"favorite_choosed"] forState:UIControlStateNormal];
    }else{
        [_favoriteBtn setImage:[UIImage imageNamed:@"favorite"] forState:UIControlStateNormal];
    }
}
-(void)setActionBtnHidden:(BOOL)hidden{
    self.favoriteBtn.hidden = hidden;
    self.addToListBtn.hidden = hidden;
    self.nextBtn.hidden = hidden;
    self.deleteBtn.hidden = hidden;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.isHiddenDetailMenu = YES;
    [self setActionBtnHidden:YES];
    self.myImageView.layer.cornerRadius = 55.0/2;
    self.myImageView.layer.masksToBounds = YES;
    
    self.isiPodBtn.layer.cornerRadius = 2;
    self.isiPodBtn.layer.masksToBounds = YES;
    self.isiPodBtn.layer.borderColor = [UIColor whiteColor].CGColor;
    self.isiPodBtn.layer.borderWidth = 1;
    
    self.backgroundColor = [UIColor colorWithHexString:@"191919"];
   
}

-(void)layoutSubviews{
    [super layoutSubviews];
    LOG(@"layoutSubviews");
    UIView * selecView = [[UIView alloc]initWithFrame:self.bounds];
    selecView.backgroundColor = [UIColor blackColor];
    self.selectedBackgroundView = selecView;
    self.highlighted = NO;
}

-(void)cellActionsCallBackBlock:(ActionsCallBack)block{
    self.block = block;
}

- (IBAction)detailBtnClick:(UIButton *)sender {
    self.isHiddenDetailMenu  = !self.isHiddenDetailMenu;
    
    if (self.block) {
        self.block(MESongsCellActionTypeDetail,self);
    }
}

- (IBAction)favoriteBtnClick:(UIButton *)sender {
    if (self.block) {
        self.block(MESongsCellActionTypeFavorite,self);
    }
}

- (IBAction)addToListBtnClick:(UIButton *)sender {
    if (self.block) {
        self.block(MESongsCellActionTypeAddToList,self);
    }
}

- (IBAction)nextPlayBtnClick:(UIButton *)sender {
    if (self.block) {
        self.block(MESongsCellActionTypeNextPlay,self);
    }
}

- (IBAction)deleteBtnClick:(UIButton *)sender {
    if (self.block) {
        self.block(MESongsCellActionTypeDelete,self);
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
