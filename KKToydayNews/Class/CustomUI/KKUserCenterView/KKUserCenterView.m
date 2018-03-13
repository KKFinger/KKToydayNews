//
//  KKUserCenterView.m
//  KKToydayNews
//
//  Created by lzp on 2017/12/19.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKUserCenterView.h"
#import "KKUserHeaderView.h"

static NSString *cellReuseIdentifier = @"cellReuseIdentifier";

@interface KKUserCenterView()<UITableViewDelegate,UITableViewDataSource,KKUserHeaderViewDelegate>
@property(nonatomic)UITableView *tabelView ;
@property(nonatomic)KKUserHeaderView *headView;
@property(nonatomic,assign)CGFloat headerViewHeight ;
@end

@implementation KKUserCenterView

- (void)viewWillAppear{
    [super viewWillAppear];
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setupUI];
}

#pragma mark -- 设置UI

- (void)setupUI{
    self.headerViewHeight = 230;
    if(iPhoneX){
        self.headerViewHeight = 250 ;
    }
    
    [self.dragContentView addSubview:self.tabelView];
    [self.tabelView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.dragContentView);
    }];
    
    self.headView.frame = CGRectMake(0, -self.headerViewHeight, UIDeviceScreenWidth, self.headerViewHeight);
    [self.tabelView addSubview:self.headView];
}

#pragma mark -- UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(section == 0){
        return 2 ;
    }
    if(section == 1){
        return 2 ;
    }
    if(section == 2){
        return 3 ;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
    return 44 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellReuseIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator ;
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            cell.textLabel.text = @"消息通知";
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.textLabel.textColor = [UIColor blackColor];
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"私信";
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.textLabel.textColor = [UIColor blackColor];
        }
    }else if(indexPath.section == 1){
        if(indexPath.row == 0){
            cell.textLabel.text = @"头条商城";
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.textLabel.textColor = [UIColor blackColor];
            
            cell.detailTextLabel.text = @"邀请好友得200元现金奖励";
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            cell.detailTextLabel.textColor = [UIColor grayColor];
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"京东特供";
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.textLabel.textColor = [UIColor blackColor];
            
            cell.detailTextLabel.text = @"新人领188元红包";
            cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
            cell.detailTextLabel.textColor = [UIColor grayColor];
        }
    }else if(indexPath.section == 2){
        if(indexPath.row == 0){
            cell.textLabel.text = @"我要爆料";
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.textLabel.textColor = [UIColor blackColor];
        }else if(indexPath.row == 1){
            cell.textLabel.text = @"用户反馈";
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.textLabel.textColor = [UIColor blackColor];
        }else if(indexPath.row == 2){
            cell.textLabel.text = @"系统设置";
            cell.textLabel.font = [UIFont systemFontOfSize:15];
            cell.textLabel.textColor = [UIColor blackColor];
        }
    }
    return cell ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.00001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return [[UIView alloc]initWithFrame:CGRectMake(0, 0, UIDeviceScreenWidth, 10)];
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetY = scrollView.contentOffset.y;
    if (offsetY < - self.headerViewHeight) {
        CGRect frame = self.headView.frame;
        frame.origin.y = offsetY;
        frame.size.height = -offsetY;
        self.headView.frame = frame;
    }
}

#pragma mark -- KKUserHeaderViewDelegate

- (void)backController{
    if(self.showViewType == KKShowViewTypeNone){
        [self startHide];
    }else if(self.showViewType == KKShowViewTypePush){
        [self pushOutToRight:YES];
    }else if(self.showViewType == KKShowViewTypePopup){
        [self popOutToTop:NO];
    }
}

#pragma mark -- 开始、拖拽中、结束拖拽

- (void)dragBeginWithPoint:(CGPoint)pt{
}

- (void)dragingWithPoint:(CGPoint)pt{
    self.tabelView.scrollEnabled = NO ;
}

- (void)dragEndWithPoint:(CGPoint)pt shouldHideView:(BOOL)hideView{
    self.tabelView.scrollEnabled = YES ;
}

#pragma mark -- @property

- (UITableView *)tabelView{
    if(!_tabelView){
        _tabelView = ({
            UITableView *view = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
            view.delegate = self ;
            view.dataSource =self;
            view.separatorStyle = UITableViewCellSeparatorStyleSingleLine ;
            view.tableFooterView = [UIView new];
            view.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
            view.estimatedRowHeight = 0;
            view.estimatedSectionHeaderHeight = 0;
            view.estimatedSectionFooterHeight = 0;
            view.tag = KKViewTagUserCenterView;
            view.separatorColor = [[UIColor grayColor]colorWithAlphaComponent:0.2];
            view.contentInset = UIEdgeInsetsMake(self.headerViewHeight, 0, 0, 0);
            view.contentOffset = CGPointMake(0, -self.headerViewHeight);
            [view registerClass:[UITableViewCell class] forCellReuseIdentifier:cellReuseIdentifier];
            
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
    return _tabelView;
}

- (KKUserHeaderView *)headView{
    if(!_headView){
        _headView = ({
            KKUserHeaderView *view = [KKUserHeaderView new];
            view.delegate = self ;
            view.backgroundColor = [UIColor whiteColor];
            view ;
        });
    }
    return _headView;
}

@end
