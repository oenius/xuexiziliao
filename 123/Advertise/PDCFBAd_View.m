//
//  PDCFBAd_View.m
//  NativeAdSample
//
//  Created by 何驱之 on 2017/5/8.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "PDCFBAd_View.h"

static float margin = 8;
static float spacing = 6;

@interface PDCFBAd_View (){
    float width;
    float height;
}

@property (strong, nonatomic) FBNativeAd *nativeAd;
@property (strong, nonatomic) UIViewController *showViewController;

@end

@implementation PDCFBAd_View

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        width = frame.size.width;
        height = frame.size.height;
        
        [self addSubview:self.adIconImageView];
        [self addSubview:self.adChoicesView];
        [self addSubview:self.adTitleLabel];
        [self addSubview:self.sponsoredLabel];
        
        [self addSubview:self.adCoverMediaView];

        [self addSubview:self.adCallToActionButton];
        [self addSubview:self.adSocialContextLabel];
        [self addSubview:self.adBodyLabel];
    }
    return self;
}

- (UIImageView *)adIconImageView{
    if (!_adIconImageView) {
        _adIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(margin, 15, 60, 60)];
        _adIconImageView.layer.cornerRadius = _adIconImageView.frame.size.height/5;
        _adIconImageView.layer.masksToBounds = YES;
    }
    return _adIconImageView;
}

- (FBAdChoicesView *)adChoicesView{
    if (!_adChoicesView) {
        _adChoicesView = [[FBAdChoicesView alloc] initWithFrame:CGRectMake(width - 120, 0, 120, 15)];
        _adChoicesView.backgroundShown = NO;
    }
    return _adChoicesView;
}

- (UILabel *)adTitleLabel{
    if (!_adTitleLabel) {
        _adTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(_adIconImageView.frame.origin.x + _adIconImageView.frame.size.width + spacing, margin + 6, width - (_adIconImageView.frame.size.width + spacing*2 + margin), 24)];
        _adTitleLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:12];
        _adTitleLabel.numberOfLines = 2;
        _adTitleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _adTitleLabel;
}

- (UILabel *)sponsoredLabel{
    if (!_sponsoredLabel) {
        _sponsoredLabel = [[UILabel alloc] initWithFrame:CGRectMake(_adIconImageView.frame.origin.x + _adIconImageView.frame.size.width + spacing, 15 + _adTitleLabel.frame.size.height, width - (_adIconImageView.frame.size.width + spacing*2 +margin*2), 24)];
        _sponsoredLabel.font = [UIFont fontWithName:@"GeezaPro" size:10];
        _sponsoredLabel.textColor = [UIColor colorWithRed:85/255. green:85/255. blue:85/255. alpha:1.];
    }
    return _sponsoredLabel;
}

- (UIButton *)adCallToActionButton{
    if (!_adCallToActionButton) {
        _adCallToActionButton = [[UIButton alloc] initWithFrame:CGRectMake(width - 100 - margin, height - margin - 40, 100, 40)];
        _adCallToActionButton.backgroundColor = [UIColor colorWithRed:91/255. green:147/255. blue:252/255. alpha:1.];
        _adCallToActionButton.layer.cornerRadius = 4;
        _adCallToActionButton.layer.masksToBounds = YES;
        [_adCallToActionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _adCallToActionButton.titleLabel.font = [UIFont fontWithName:@"GeezaPro" size:12];
    }
    return _adCallToActionButton;
}

- (UILabel *)adBodyLabel{
    if (!_adBodyLabel) {
        CGFloat bodyLabelHeight = 20;
        _adBodyLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, height - margin - bodyLabelHeight, width - (_adCallToActionButton.frame.size.width + spacing*2 + margin*2), bodyLabelHeight)];
        _adBodyLabel.font = [UIFont fontWithName:@"GeezaPro" size:12];
        _adBodyLabel.numberOfLines = 3;
        _adBodyLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _adBodyLabel.numberOfLines = 1;
        _adBodyLabel.textColor = [UIColor colorWithRed:85/255. green:85/255. blue:85/255. alpha:1.];
    }
    return _adBodyLabel;
}

- (UILabel *)adSocialContextLabel{
    if (!_adSocialContextLabel) {
        CGFloat socialLabelHeight = 20;
        _adSocialContextLabel = [[UILabel alloc] initWithFrame:CGRectMake(margin, height - margin - socialLabelHeight - spacing - 20, width - margin*2, socialLabelHeight)];
        _adSocialContextLabel.numberOfLines = 1;
        _adSocialContextLabel.textColor = [UIColor colorWithRed:85/255. green:85/255. blue:85/255. alpha:1.];
        _adSocialContextLabel.font = [UIFont fontWithName:@"GeezaPro" size:12];
    }
    return _adSocialContextLabel;
}

- (FBMediaView *)adCoverMediaView{
    if (!_adCoverMediaView) {
        CGFloat offsizeX = margin;
        CGFloat offsizeY = _adIconImageView.frame.size.height + spacing + 15;
        CGFloat mediaViewWidth = width - margin*2;
        CGFloat mediaViewHeight = height - _adIconImageView.frame.size.height - _adSocialContextLabel.frame.size.height - _adBodyLabel.frame.size.height - margin*2 - spacing*3 - 15;
        
        CGFloat maxMediaHeight = mediaViewWidth/2.0f;
        if (mediaViewHeight > maxMediaHeight) {
            offsizeY = offsizeY + ((mediaViewHeight - maxMediaHeight)/2.0f);
            mediaViewHeight = maxMediaHeight;
        }
        
        _adCoverMediaView = [[FBMediaView alloc] initWithFrame:CGRectMake(offsizeX,  offsizeY, mediaViewWidth,  mediaViewHeight)];
        _adCoverMediaView.layer.cornerRadius = 8;
        _adCoverMediaView.layer.masksToBounds = YES;
    }
    return _adCoverMediaView;
}

- (void)registerInteractionForView:(UIView *)actionView{
    [self.nativeAd unregisterView];
    [self.nativeAd registerViewForInteraction:actionView withViewController:self.showViewController];
}

- (void)loadDataWithFBNaviveAd:(FBNativeAd *)nativeAd controller:(UIViewController *)controller{
    self.nativeAd = nativeAd;
    [self.adCoverMediaView setNativeAd:nativeAd];
    
    __weak typeof(self) weakSelf = self;
    [nativeAd.icon loadImageAsyncWithBlock:^(UIImage *image) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.adIconImageView.image = image;
    }];
    
    // Render native ads onto UIView
    self.adTitleLabel.text = nativeAd.title;
    self.adBodyLabel.text = nativeAd.body;
    self.adSocialContextLabel.text = nativeAd.socialContext;
    self.sponsoredLabel.text = @"Sponsored";
    
    [self.adCallToActionButton setHidden:NO];
    [self.adCallToActionButton setTitle:nativeAd.callToAction
                               forState:UIControlStateNormal];
    
    NSLog(@"Register UIView for impression and click...");
    
    // Wire up UIView with the native ad; the whole UIView will be clickable.
    [nativeAd registerViewForInteraction:self
                      withViewController:controller];
    
    // Or you can replace above call with following function, so you can specify the clickable areas.
    // NSArray *clickableViews = @[self.adCallToActionButton, self.adCoverMediaView];
    // [nativeAd registerViewForInteraction:self.adUIView
    //                   withViewController:self
    //                   withClickableViews:clickableViews];
    
    // Update AdChoices view
    self.adChoicesView.nativeAd = nativeAd;
    self.adChoicesView.corner = UIRectCornerTopRight;
    self.adChoicesView.backgroundShown = NO;
    self.adChoicesView.label.textColor = [UIColor clearColor];
    self.adChoicesView.hidden = NO;
}

- (void)reDrawRectWithHeight:(float)heightMax frameType:(PDCAdFrameType)frameType{
    if (frameType == PDCAdFrameType_Cell) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, heightMax);
        width = self.frame.size.width;
        height = self.frame.size.height;
        
        self.adBodyLabel.hidden = YES;
        self.sponsoredLabel.hidden = YES;
        self.adCoverMediaView.hidden = YES;
        
        self.adIconImageView.frame = CGRectMake(margin, 15, heightMax-margin-15, heightMax-margin-15);
        self.adIconImageView.layer.cornerRadius = _adIconImageView.frame.size.height/5;
        
        self.adChoicesView.frame = CGRectMake(width - 120, 0, 120, 15);
        self.adTitleLabel.frame = CGRectMake(_adIconImageView.frame.origin.x + _adIconImageView.frame.size.width + spacing, margin + 6, width - (_adIconImageView.frame.size.width + spacing*2 + margin), 24);
        self.adSocialContextLabel.frame = CGRectMake(_adIconImageView.frame.origin.x + _adIconImageView.frame.size.width + spacing, 15 + _adTitleLabel.frame.size.height, width - (_adIconImageView.frame.size.width + spacing*2 +margin*2), 24);
        self.adCallToActionButton.frame = CGRectMake(width - 80 - margin, heightMax - margin - 40, 80, 40);
    }
}

@end
