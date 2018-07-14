//
//  KKTextImageShareCtrl.m
//  KKToydayNews
//
//  Created by finger on 2017/10/22.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKTextImageShareCtrl.h"
#import "KKTextImageShareHeader.h"
#import "KKPhotoManager.h"

static NSString *cellWithIdentifier = @"cellWithIdentifier";

@interface KKTextImageShareCtrl ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,KKTextImageShareHeaderDelegate>
@property(nonatomic)UITableView *tableView;
@property(nonatomic)KKTextImageShareHeader *header;
@property(nonatomic)UIStatusBarStyle style;
@end

@implementation KKTextImageShareCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication]setStatusBarStyle:self.style];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)dealloc{
    [[KKPhotoManager sharedInstance]clear];
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

#pragma mark -- 设置UI

- (void)setupUI{
    //导航栏遮挡视图的问题
    self.extendedLayoutIncludesOpaqueBars = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self.view addSubview:self.tableView];
    self.navigationItem.leftBarButtonItem = [self createLeftItemWithTitle:@"取消"];
    self.navigationItem.rightBarButtonItem = [self createRightItemWithTitle:@"发布"];
    
    [self setStyle:[[UIApplication sharedApplication]statusBarStyle]];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
    
    self.header.height = [self.header fetchHeaderHeight];
    self.tableView.tableHeaderView = self.header;
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

- (UIBarButtonItem *)createLeftItemWithTitle:(NSString *)title{
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    backButton.frame = CGRectMake(0, 0, 44, 20);
    if (title != nil){
        backButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0];
        [backButton setTitle:title forState:UIControlStateNormal];
        [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [backButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    }
    [backButton addTarget:self action:@selector(backCtrl) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    return backItem;
}

- (UIBarButtonItem *)createRightItemWithTitle:(NSString *)title{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    rightButton.frame = CGRectMake(0, 0, 44, 20);
    if (title != nil){
        rightButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0];
        [rightButton setTitle:title forState:UIControlStateNormal];
        [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [rightButton setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    }
    [rightButton addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    
    return backItem;
}

#pragma mark -- 退出视图

- (void)backCtrl{
    [self.header hideKeyboard];
    if([KKAppTools isPushWithCtrl:self]){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -- 取消

- (void)cancelClicked{
    [self.header hideKeyboard];
    if([KKAppTools isPushWithCtrl:self]){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -- UITableViewDelegate,UITableViewDataSource\

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellWithIdentifier];
    cell.imageView.image = [UIImage imageNamed:@"toutiaoquan_release_text_24x24_"];
    cell.textLabel.text = @"深圳市 南山区";
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.header hideKeyboard];
}

#pragma mark -- KKTextImageShareHeaderDelegate

- (void)needAdjustHeaderHeight{
    self.header.height = [self.header fetchHeaderHeight];
    [self.tableView reloadData];
}

#pragma mark -- @property setter

- (void)setImageArray:(NSArray *)imageArray{
    self.header.imageArray = imageArray;
}

#pragma mark -- @property getter

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = ({
            UITableView *view = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
            view.dataSource = self ;
            view.delegate = self ;
            view.backgroundColor = KKColor(244, 245, 246, 1.0);
            view.separatorStyle = UITableViewCellSeparatorStyleNone ;
            view.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, -1)];
            [view registerClass:[UITableViewCell class] forCellReuseIdentifier:cellWithIdentifier];
            
            //iOS11 reloadData界面乱跳bug
            view.estimatedRowHeight = 0;
            view.estimatedSectionHeaderHeight = 0;
            view.estimatedSectionFooterHeight = 0;
            if(IOS11_OR_LATER){
                KKAdjustsScrollViewInsets(view);
            }
            
            view ;
        });
    }
    return _tableView;
}

- (KKTextImageShareHeader *)header{
    if(!_header){
        _header = ({
            KKTextImageShareHeader *view = [KKTextImageShareHeader new];
            view.delegate = self ;
            view ;
        });
    }
    return _header;
}

@end
