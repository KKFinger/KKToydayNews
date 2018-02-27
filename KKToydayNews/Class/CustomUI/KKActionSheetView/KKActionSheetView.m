//
//  KKActionSheetView.m
//  KKToydayNews
//
//  Created by finger on 2017/11/27.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKActionSheetView.h"
#import "KKActionSheetCell.h"
#import "KKActionSheetHeadView.h"

static NSString *cellReuseIdentifier = @"cellReuseIdentifier";

static CGFloat headerViewHeight = 35 ;
static CGFloat itemHeight = 55 ;
static CGFloat lrPadding = 10;
static CGFloat cancelInterval = 5;//取消按钮与上部分的间距
static CGFloat cornerRadius = 15 ;

@interface KKActionSheetView ()<UITableViewDelegate,UITableViewDataSource,KKActionSheetCellDelegate>
@property(nonatomic)UIView *contentView;
@property(nonatomic)UITableView *tableView;
@property(nonatomic)KKActionSheetHeadView *headView;
@property(nonatomic)UIButton *cancelBtn;
@property(nonatomic)NSArray *contentArray;
@property(nonatomic)NSString *title;
@property(nonatomic,copy)selectedCallback selectedCallback ;
@property(nonatomic)CGFloat contentViewHeight;
@property(nonatomic)CGFloat contentViewWidth;
@end

@implementation KKActionSheetView

- (instancetype)initWithTitle:(NSString *)title contentArray:(NSArray *)contentArray callback:(selectedCallback)callback{
    self = [super initWithFrame:[[UIScreen mainScreen]bounds]];
    if(self){
        self.title = title;
        self.contentArray = contentArray;
        self.selectedCallback = callback;
        self.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
        
        @weakify(self);
        [self addTapGestureWithBlock:^(UIView *gestureView) {
            @strongify(self);
            [self hideActionSheet];
        }];
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(changeRotate:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
        
        [self setupUI];
    }
    return self ;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.frame = [[UIScreen mainScreen]bounds];
    [self layoutContentView];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.tableView];
    [self.contentView addSubview:self.cancelBtn];
    
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.width.mas_equalTo(self.contentViewWidth);
        make.bottom.mas_equalTo(self);
        make.height.mas_equalTo(0);
    }];
    
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.width.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.cancelBtn.mas_top).mas_offset(-cancelInterval);
    }];
    
    self.headView.title = self.title ;

    [self.cancelBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.contentView).mas_offset(-cancelInterval);
        make.left.mas_equalTo(self.contentView);
        make.width.mas_equalTo(self.contentView);
        make.height.mas_equalTo(itemHeight);
    }];
    
    [self layoutContentView];
}

#pragma mark -- UI布局

- (void)layoutContentView{
    self.contentViewHeight = 2 * cancelInterval ;
    self.contentViewWidth = MIN([[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height) - 2 * lrPadding;
    self.contentViewHeight += (self.contentArray.count + 1) * itemHeight;
    
    if(self.title.length){
        self.contentViewHeight += headerViewHeight;
    }
    
    if(self.contentViewHeight > self.height - 30){
        self.contentViewHeight = self.height - 30 ;
    }
    
    if(self.contentView.superview == nil){
        return ;
    }
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.contentViewWidth);
        make.height.mas_equalTo(self.contentViewHeight);
    }];
}

#pragma mark -- UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.contentArray.count ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return itemHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(self.title.length){
        return headerViewHeight;
    }
    return 0 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    KKActionSheetCell *cell = [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    cell.delegate = self ;
    cell.title = [self.contentArray safeObjectAtIndex:indexPath.row];
    return cell ;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if(self.title.length){
        self.headView.frame = CGRectMake(0, 0, self.contentViewWidth, headerViewHeight);
        return self.headView;
    }
    return nil;
}

#pragma mark -- KKActionSheetCellDelegate

- (void)selectWithTitle:(NSString *)title{
    if(self.selectedCallback){
        self.selectedCallback(title);
    }
    [self hideActionSheet];
}

#pragma mark -- 显示&消失

- (void)showActionSheet{
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).mas_offset(self.contentViewHeight);
    }];
    [self layoutIfNeeded];
    
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).mas_offset(0);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    }];
}

- (void)hideActionSheet{
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self).mas_offset(self.contentViewHeight);
    }];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0 ;
        [self layoutIfNeeded];
    }completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark -- 横竖屏发生变化

- (void)changeRotate:(NSNotification *)notification {
    self.frame = [[UIScreen mainScreen]bounds];
    [self layoutContentView];
}

#pragma mark -- @property

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = ({
            UITableView *view = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
            view.delegate = self;
            view.dataSource = self ;
            view.separatorColor = [UIColor clearColor];
            view.separatorInset = UIEdgeInsetsZero;
            view.layoutMargins = UIEdgeInsetsZero;
            view.layer.cornerRadius = cornerRadius;
            view.layer.masksToBounds = YES ;
            view.bounces = NO ;
            view.backgroundColor = [UIColor clearColor];
            [view registerClass:[KKActionSheetCell class] forCellReuseIdentifier:cellReuseIdentifier];
            
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

- (UIView *)contentView{
    if(!_contentView){
        _contentView = ({
            UIView *view = [UIView new];
            view ;
        });
    }
    return _contentView;
}

- (KKActionSheetHeadView *)headView{
    if(!_headView){
        _headView = ({
            KKActionSheetHeadView *view = [KKActionSheetHeadView new];
            view.backgroundColor = [UIColor clearColor];
            view ;
        });
    }
    return _headView;
}

- (UIButton *)cancelBtn{
    if(!_cancelBtn){
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_cancelBtn setTitleColor:KKColor(16, 131, 254, 1.0) forState:UIControlStateNormal];
        [_cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [_cancelBtn setBackgroundColor:[UIColor whiteColor]];
        [_cancelBtn addTarget:self action:@selector(hideActionSheet) forControlEvents:UIControlEventTouchUpInside];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn.layer setCornerRadius:cornerRadius];
    }
    return _cancelBtn;
}

@end
