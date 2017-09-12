//
//  DTInvitedInstallViewController.m
//  DataTansfer
//
//  Created by 何少博 on 17/6/8.
//  Copyright © 2017年 shaobo.He. All rights reserved.
//

#import "DTInvitedInstallViewController.h"

@interface DTInvitedInstallViewController ()

@property (nonatomic,strong) UIImageView * imageView;

@property (nonatomic,strong) UIImage * QRImage;

@property (nonatomic,strong) UILabel * label;

@end

@implementation DTInvitedInstallViewController


-(instancetype)initWithQRImage:(UIImage *)image{
    self = [super init];
    if (self) {
        self.QRImage = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubViews];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithHexString:@"08c364"];
    self.view.layer.contents  = (__bridge id _Nullable)([UIImage imageNamed:@"tongxunlubg"].CGImage);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:(UIBarButtonItemStylePlain) target:self action:@selector(back)];
    NSDictionary * normal = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    self.navigationController.navigationBar.titleTextAttributes  = normal;
    self.title = [DTConstAndLocal anzhuang];
}


-(void)setupSubViews{
    self.imageView = [[UIImageView alloc]init];
    self.imageView.contentMode = UIViewContentModeCenter;
    self.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.imageView.layer.borderWidth = 1;
    self.imageView.image = self.QRImage;
    [self.view addSubview:self.imageView];
    
    _label = [[UILabel alloc]init];
    _label.text = [DTConstAndLocal saomiao];
    _label.textColor = [UIColor blackColor];
    _label.adjustsFontSizeToFitWidth = YES;
    _label.numberOfLines = 6;
    _label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_label];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
        make.width.equalTo(@(200));
        make.height.equalTo(@(200));
    }];
    
    [_label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom);
        make.left.equalTo(self.view.mas_left).offset(30);
        make.right.equalTo(self.view.mas_right).offset(-30);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}


-(void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    [_label mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottom).offset(-contentInsets.bottom);
    }];
}

@end
