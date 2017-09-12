//
//  SNCMFileBaseViewController.m
//  MindMap
//
//  Created by 何少博 on 2017/8/19.
//  Copyright © 2017年 H0oo0H. All rights reserved.
//

#import "SNCMFileBaseViewController.h"
#import "SNFileTableViewCell.h"
#import "NSFileManager+x.h"
#import "NSArray+x.h"
#import "NSString+x.h"
#import "UIAlertController+SN.h"
@interface SNCMFileBaseViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dirListArray;

@end


 static NSString *kFileCellIdentifier = @"kFileCellIdentifier";

@implementation SNCMFileBaseViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupTabelView];
    
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]init];
    backBarItem.title =  NSLocalizedString(@"camera.back", @"camera.back");
    self.navigationItem.backBarButtonItem = backBarItem;
    
    NSMutableArray *buttonItems = [NSMutableArray array];
    UIBarButtonItem *cancelBut = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(canceItemAction)];
    UIBarButtonItem *confirmBut = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"MakeSure",@"MakeSure") style:UIBarButtonItemStylePlain target:self action:@selector(configItemAction)];
    [buttonItems addObject:confirmBut];
    [buttonItems addObject:cancelBut];
    self.navigationItem.rightBarButtonItems = buttonItems;
    if (self.toDir == nil) {
        self.toDir = [SNTools documentPath];
    }

    [self updateDirListFromParentDir:self.toDir];
}


-(void)setupTabelView{
    self.tableView = [[UITableView alloc] init];
    UINib *cellNib = [UINib nibWithNibName:NSStringFromClass([SNFileTableViewCell class]) bundle:nil];
    [self.tableView registerNib:cellNib forCellReuseIdentifier:kFileCellIdentifier];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

-(void)updateDirListFromParentDir:(NSString *)directory{
    NSFileManager *fileMng = [NSFileManager defaultManager];
    NSArray *contentFiles = [fileMng contentsFullPathOfDirectoryAtPath:directory];
    self.dirListArray = [contentFiles subarrayWithBlock:^BOOL(NSString *filePath) {
        return [fileMng isDirectory:filePath];
    }];
    NSLog(@"content files :%@",self.dirListArray);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
#pragma -mark UIbarItemActions

-(void)canceItemAction{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)configItemAction{
    
}

-(void)alertMessage:(NSString *)message{
    [UIAlertController alertMessage:message controller:self okHandler:^(UIAlertAction *okAction) {
        if (self.finishCallBack) {
            self.finishCallBack(message);
        }
    }];
}

#pragma -mark UItableviewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    NSString *filePath = [self.dirListArray objectAtIndex:indexPath.row];
    SNCMFileBaseViewController * vc = [[[self class] alloc]init];
    vc.toDir = filePath;
    vc.fileArray = self.fileArray;
    vc.finishCallBack = self.finishCallBack;
    [self.navigationController pushViewController:vc animated:YES];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma -mark UItableviewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dirListArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SNFileTableViewCell *cell = [tableview dequeueReusableCellWithIdentifier:kFileCellIdentifier];
    NSString *dirPath = [self.dirListArray objectAtIndex:indexPath.row];
    [cell configCellWithFilePath:dirPath];
    return cell;
}
-(void)setAdEdgeInsets:(UIEdgeInsets)contentInsets{
    [super setAdEdgeInsets:contentInsets];
    self.tableView.contentInset = contentInsets;
}
@end
