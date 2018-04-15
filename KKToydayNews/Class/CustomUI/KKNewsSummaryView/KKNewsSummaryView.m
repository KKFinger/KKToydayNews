//
//  KKNewsSummaryView.m
//  KKToydayNews
//
//  Created by finger on 2017/8/12.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKNewsSummaryView.h"
#import "KKFetchNewsTool.h"
#import "KKSummaryDataModel.h"
#import "KKArticleModal.h"
#import "KKSmallCorverCell.h"
#import "KKLargeCorverCell.h"
#import "KKMiddleCorverCell.h"
#import "KKWeiTouTiaoCellNine.h"
#import "KKWeiTouTiaoCellOne.h"
#import "KKWeiTouTiaoCellThree.h"
#import "KKRefreshView.h"
#import "KKTextImageCell.h"
#import "KKVideoCell.h"
#import "KKCommentModal.h"
#import "KKNormalNewsDetailView.h"
#import "KKLoadingView.h"
#import "KKDragableNavBaseView.h"
#import "KKImageNewsDetail.h"
#import "KKAVPlayerView.h"
#import "KKVideoNewsDetail.h"
#import "KKTextImageDetailView.h"
#import "KKPictureCell.h"
#import "KKImageBrowser.h"
#import "KKWeiTouTiaoDetailView.h"
#import "KKPersonalInfoView.h"

static NSString *smallCellIdentifier = @"smallCellIdentifier";
static NSString *largeCellIdentifier = @"largeCellIdentifier";
static NSString *middleCellIdentifier = @"middleCellIdentifier";
static NSString *textImageCellIdentifier = @"textImageCellIdentifier";
static NSString *videoCellIdentifier = @"videoCellIdentifier";
static NSString *pictureCellIdentifier = @"pictureCellIdentifier";
static NSString *vipUserCellIdentifier1 = @"vipUserCellIdentifier1";
static NSString *vipUserCellIdentifier3 = @"vipUserCellIdentifier3";
static NSString *vipUserCellIdentifier9 = @"vipUserCellIdentifier9";

@interface KKNewsSummaryView ()<UITableViewDataSource,UITableViewDelegate,KKCommonDelegate,KKWeiTouTiaoCellDelegate>
@property(nonatomic)UILabel *refreshTipLabel;
@property(nonatomic)UITableView *tableView;
@property(nonatomic)KKLoadingView *loadingView ;
@property(nonatomic)KKAVPlayerView *videoPlayView;
@property(nonatomic,weak)NSIndexPath *selIndexPath;
@end

@implementation KKNewsSummaryView

- (id)initWithSectionItem:(KKSectionItem *)item{
    self = [super init];
    if(self){
        self.sectionItem = item ;
        [self setupUI];
    }
    return self ;
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self addSubview:self.refreshTipLabel];
    [self addSubview:self.tableView];
    [self addSubview:self.loadingView];
    [self addSubview:self.noDataView];
    
    [self.refreshTipLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self);
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(30);
    }];
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(self);
    }];
    [self.loadingView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    [self.noDataView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
}

#pragma mark -- 刷新数据

- (void)refreshData:(BOOL)header shouldShowTips:(BOOL)showTip{
    [self.loadingView setHidden:self.dataArray.count];
    [[KKFetchNewsTool shareInstance]fetchSummaryWithSectionItem:self.sectionItem success:^(KKSummaryDataModel *model) {
        NSMutableArray *insertArray = [NSMutableArray arrayWithCapacity:0];
        if(model.contentArray.count){
            if(header){
                NSRange range = NSMakeRange(0,[model.contentArray count]);
                [self.dataArray insertObjects:model.contentArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
                if(self.dataArray.count > 30){
                    NSInteger delCount = self.dataArray.count - 30 ;
                    for(NSInteger i = 0 ; i < delCount ; i++){
                        [self.dataArray removeLastObject];
                    }
                    [CATransaction begin];
                    [CATransaction setDisableActions:YES];
                    [self.tableView reloadData];
                    [CATransaction commit];
                }else{
                    for(NSInteger i = 0 ; i < model.contentArray.count ; i++){
                        [insertArray safeAddObject:[NSIndexPath indexPathForRow:i inSection:0]];
                    }
                }
            }else{
                NSInteger fromIndex = self.dataArray.count;
                NSInteger lastItemIndex = self.dataArray.count - 1;
                [self.dataArray addObjectsFromArray:model.contentArray];
                if(self.dataArray.count > 30){
                    NSInteger delCount = self.dataArray.count - 30 ;
                    for(NSInteger i = 0 ; i < delCount ; i++){
                        [self.dataArray safeRemoveObjectAtIndex:0];
                        lastItemIndex -- ;
                    }
                    [CATransaction begin];
                    [CATransaction setDisableActions:YES];
                    [self.tableView reloadData];
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:lastItemIndex inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                    [CATransaction commit];
                }else{
                    for(NSInteger i = 0; i < model.contentArray.count ; i++){
                        [insertArray safeAddObject:[NSIndexPath indexPathForRow:(fromIndex + i) inSection:0]];
                    }
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView.mj_footer endRefreshing];
            [self.tableView.mj_header endRefreshing];
            
            if(insertArray.count){
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                [self.tableView insertRowsAtIndexPaths:insertArray withRowAnimation:UITableViewRowAnimationNone];
                [CATransaction commit];
            }
            
            [self.loadingView setHidden:YES];
            [self.noDataView setHidden:self.dataArray.count];
            
            NSInteger total = [model.total_number integerValue];
            if(total > 0){
                self.refreshTipLabel.text = model.tips.display_info;
            }else{
                self.refreshTipLabel.text = @"没有更多更新";
            }
            
            if(showTip){
                [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(self).mas_offset(self.refreshTipLabel.height);
                }];
                [UIView animateWithDuration:0.3 animations:^{
                    [self layoutIfNeeded];
                }];
                
                [self performSelector:@selector(showRefreshTipParam:) withObject:@[@(NO),@(YES)] afterDelay:2.0];
            }
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshTipLabel setText:@"网络不给力"];
            [self.tableView.mj_footer endRefreshing];
            [self.tableView.mj_header endRefreshing];
            [self.loadingView setHidden:YES];
            [self.noDataView setHidden:self.dataArray.count];
            [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self).mas_offset(self.refreshTipLabel.height);
            }];
            [UIView animateWithDuration:0.3 animations:^{
                [self layoutIfNeeded];
            }];
            
            [self performSelector:@selector(showRefreshTipParam:) withObject:@[@(NO),@(YES)] afterDelay:2.0];
        });
    }];
    
//        //本地测试数据
//        KKCommonDataModel *model = [KKCommonDataModel mj_objectWithKeyValues:kkNewsSummaryData()];
//        if(model.contentArray.count){
//            if(header){
//                NSRange range = NSMakeRange(0,[model.contentArray count]);
//                [self.dataArray insertObjects:model.contentArray atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
//            }else{
//                [self.dataArray addObjectsFromArray:model.contentArray];
//            }
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.tableView.mj_footer endRefreshing];
//            [self.tableView.mj_header endRefreshing];
//            [self.tableView reloadData];
//            [self.loadingView setHidden:self.dataArray.count];
//            NSInteger total = [model.total_number integerValue];
//            if(total > 0){
//                self.refreshTipLabel.text = model.tips.display_info;
//            }else{
//                self.refreshTipLabel.text = @"没有更多更新";
//            }
//            if(showTip){
//                [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
//                    make.top.mas_equalTo(self).mas_offset(self.refreshTipLabel.height);
//                }];
//                [UIView animateWithDuration:0.3 animations:^{
//                    [self layoutIfNeeded];
//                }];
//    
//                [self performSelector:@selector(showRefreshTipParam:) withObject:@[@(NO),@(YES)] afterDelay:2.0];
//            }
//        });
}

//开始下拉刷新
- (void)beginPullDownUpdate{
    if(![self.tableView.mj_header isRefreshing]){
        [self.tableView.mj_header beginRefreshing];
    }
}

- (void)showRefreshTipParam:(NSArray *)array{
    [self showRefreshTip:[[array safeObjectAtIndex:0]boolValue] animate:[[array safeObjectAtIndex:1]boolValue]];
}

- (void)showRefreshTip:(BOOL)isShow animate:(BOOL)animate{
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).mas_offset(isShow ? self.refreshTipLabel.height : 0);
    }];
    if(animate){
        [UIView animateWithDuration:0.3 animations:^{
            [self layoutIfNeeded];
        }];
    }
}

#pragma mark-- 是否需要移除视频播放

- (void)stopVideoIfNeed{
    if(self.videoPlayView){
        [self.videoPlayView destoryVideoPlayer];
        self.videoPlayView = nil ;
    }
}

#pragma mark -- UITableViewDataSource,UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    KKSummaryContent *item = [self.dataArray safeObjectAtIndex:indexPath.row];
    if(item.user){//微头条
        NSInteger imageCount = item.thumb_image_list.count;
        if(imageCount <= 1){
            return [KKWeiTouTiaoCellOne fetchHeightWithItem:item];
        }
        if(imageCount == 9){
            return [KKWeiTouTiaoCellNine fetchHeightWithItem:item];
        }
        return [KKWeiTouTiaoCellThree fetchHeightWithItem:item];
    }else if([self.sectionItem.category isEqualToString:@"essay_joke"]||
             [self.sectionItem.category isEqualToString:@"image_funny"] ||
             [self.sectionItem.category isEqualToString:@"image_ppmm"] ||
             [self.sectionItem.category isEqualToString:@"image_wonderful"]){//笑话、趣图、街拍、美图
        return [KKTextImageCell fetchHeightWithItem:item];
    }else if([self.sectionItem.category isEqualToString:@"video"]){//视频
        return [KKVideoCell fetchHeightWithItem:item];
    }else if([self.sectionItem.category isEqualToString:@"组图"]){
        return [KKPictureCell fetchHeightWithItem:item];
    }else{
        if([item.has_video boolValue] ||
           [item.has_m3u8_video boolValue] ||
           [item.has_mp4_video boolValue]){
            if(item.large_image_list.count){
                return [KKLargeCorverCell fetchHeightWithItem:item];
            }else{
                return [KKMiddleCorverCell fetchHeightWithItem:item];
            }
        }else{
            if((![item.has_image boolValue] && !item.large_image_list.count)){//无图的新闻、大图的新闻、图片共用KKLargeCorverCell
                return [KKLargeCorverCell fetchHeightWithItem:item];
            }else{
                if(item.image_list.count >= 3){
                    return [KKSmallCorverCell fetchHeightWithItem:item];
                }else{
                    if(item.large_image_list.count){
                        return [KKLargeCorverCell fetchHeightWithItem:item];
                    }else{
                        return [KKMiddleCorverCell fetchHeightWithItem:item];
                    }
                }
            }
        }
    }
    return 0 ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    KKSummaryContent *item = [self.dataArray safeObjectAtIndex:indexPath.row];
    UITableViewCell *cell = nil;
    if(item.user){//微头条
        NSInteger imageCount = item.thumb_image_list.count;
        if(imageCount <= 1){
            cell = [tableView dequeueReusableCellWithIdentifier:vipUserCellIdentifier1];
        }else if(imageCount >= 9){
            cell = [tableView dequeueReusableCellWithIdentifier:vipUserCellIdentifier9];
        }else{
            cell = [tableView dequeueReusableCellWithIdentifier:vipUserCellIdentifier3];
        }
        [((KKWeiTouTiaoBaseCell *)cell) refreshWithItem:item];
        [((KKWeiTouTiaoBaseCell *)cell) setDelegate:self];
        [((KKWeiTouTiaoBaseCell *)cell) setIndexPath:indexPath];
    }else if([self.sectionItem.category isEqualToString:@"essay_joke"] ||
             [self.sectionItem.category isEqualToString:@"image_funny"] ||
             [self.sectionItem.category isEqualToString:@"image_ppmm"] ||
             [self.sectionItem.category isEqualToString:@"image_wonderful"]){//笑话、趣图、街拍、美图
        cell = [tableView dequeueReusableCellWithIdentifier:textImageCellIdentifier];
        [((KKTextImageCell *)cell) refreshWithItem:item];
        [((KKTextImageCell *)cell) setDelegate:self];
        [((KKTextImageCell *)cell) setIndexPath:indexPath];
    }else if([self.sectionItem.category isEqualToString:@"video"]){//视频
        cell = [tableView dequeueReusableCellWithIdentifier:videoCellIdentifier];
        [((KKVideoCell *)cell) refreshWithItem:item];
        [((KKVideoCell *)cell) setDelegate:self];
    }else if([self.sectionItem.category isEqualToString:@"组图"]){
        cell = [tableView dequeueReusableCellWithIdentifier:pictureCellIdentifier];
        [((KKPictureCell *)cell) refreshWithItem:item];
        [((KKPictureCell *)cell) setDelegate:self];
        [((KKPictureCell *)cell) setIndexPath:indexPath];
    }else{//混合类型的新闻版块(版块中含有视频、图片、纯文字等类型的新闻)
        if([item.has_video boolValue] ||//视频类新闻排版
           [item.has_m3u8_video boolValue] ||
           [item.has_mp4_video boolValue]){
            if(item.large_image_list.count){//大图排版
                cell = [tableView dequeueReusableCellWithIdentifier:largeCellIdentifier];
                [((KKLargeCorverCell *)cell) refreshWithItem:item];
                [((KKLargeCorverCell *)cell) setDelegate:self];
            }else{//左边文字，右边图片、视频排版
                cell = [tableView dequeueReusableCellWithIdentifier:middleCellIdentifier];
                [((KKMiddleCorverCell *)cell) refreshWithItem:item];
                [((KKMiddleCorverCell *)cell) setDelegate:self];
            }
        }else{
            if((![item.has_image boolValue] &&
                !item.large_image_list.count)){
                //无图的新闻、大图的新闻、图片共用KKLargeCorverCell
                cell = [tableView dequeueReusableCellWithIdentifier:largeCellIdentifier];
                [((KKLargeCorverCell *)cell) refreshWithItem:item];
                [((KKLargeCorverCell *)cell) setDelegate:self];
            }else{
                if(item.image_list.count >= 3){//三张图片并排排版
                    cell = [tableView dequeueReusableCellWithIdentifier:smallCellIdentifier];
                    [((KKSmallCorverCell *)cell) refreshWithItem:item];
                    [((KKSmallCorverCell *)cell) setDelegate:self];
                }else{
                    if(item.large_image_list.count){//单张大图排版
                        cell = [tableView dequeueReusableCellWithIdentifier:largeCellIdentifier];
                        [((KKLargeCorverCell *)cell) refreshWithItem:item];
                        [((KKLargeCorverCell *)cell) setDelegate:self];
                    }else{//左边文字，右边图片、视频排版
                        cell = [tableView dequeueReusableCellWithIdentifier:middleCellIdentifier];
                        [((KKMiddleCorverCell *)cell) refreshWithItem:item];
                        [((KKMiddleCorverCell *)cell) setDelegate:self];
                    }
                }
            }
        }
    }
    
    return cell ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    KKSummaryContent *contentItem = [self.dataArray safeObjectAtIndex:indexPath.row];
    self.selIndexPath = indexPath ;
    if([contentItem.gallary_style boolValue]){//图片浏览
        [self showImageNewsDetailView:contentItem oriRect:CGRectZero oriImage:nil];
    }else if([self.sectionItem.category isEqualToString:@"组图"]){
        KKPictureCell *cell = (KKPictureCell *)[tableView cellForRowAtIndexPath:indexPath];
        CGRect frame = [cell.bgView convertRect:cell.largeImgView.frame toView:self.tableView];
        [self showImageNewsDetailView:contentItem oriRect:frame oriImage:cell.largeImgView.image];
    }else if([contentItem.has_video boolValue] ||
             [contentItem.has_mp4_video boolValue] ||
             [contentItem.has_m3u8_video boolValue]){//视频
        [self showVideoDetailView:contentItem smallType:KKSamllVideoTypeDetail];
    }else if(contentItem.user){//微头条
        [self showWTTDetailView:contentItem];
    }else if([self.sectionItem.category isEqualToString:@"essay_joke"] ||
             [self.sectionItem.category isEqualToString:@"image_funny"] ||
             [self.sectionItem.category isEqualToString:@"image_ppmm"] ||
             [self.sectionItem.category isEqualToString:@"image_wonderful"]){//笑话、趣图、街拍、美图
        [self showTextImageDetailView:contentItem];
    }else{
        [self showNormalNewsWith:contentItem sectionItem:self.sectionItem];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(nonnull UITableViewCell *)cell forRowAtIndexPath:(nonnull NSIndexPath *)indexPath{
//    [cell flyInOutAnimateForIndexPath:indexPath];
}

#pragma mark -- KKCommonDelegate

- (void)shieldBtnClicked:(KKSummaryContent *)item{
}

- (void)clickImageWithItem:(KKSummaryContent *)item rect:(CGRect)rect fromView:(UIView *)fromView image:(UIImage *)image indexPath:(NSIndexPath *)indexPath{
    self.selIndexPath = indexPath ;
    if([item.gallary_style boolValue]){//图片浏览
        [self showImageNewsDetailView:item oriRect:rect oriImage:image];
    }else if([self.sectionItem.category isEqualToString:@"组图"]){
        CGRect frame = [fromView convertRect:rect toView:self.tableView];
        [self showImageNewsDetailView:item oriRect:frame oriImage:image];
    }else if([self.sectionItem.category isEqualToString:@"image_funny"] ||
             [self.sectionItem.category isEqualToString:@"image_ppmm"] ||
             [self.sectionItem.category isEqualToString:@"image_wonderful"]){
        CGRect frame = [fromView convertRect:rect toView:self.tableView];
        KKImageItem *imgItem = [KKImageItem new];
        imgItem.url = item.large_image.url;
        imgItem.image = image;
        [self showImageBrowserView:@[imgItem] oriRect:frame];
    }else if([item.has_video boolValue] ||
             [item.has_mp4_video boolValue] ||
             [item.has_m3u8_video boolValue]){//视频
        if(item.large_image_list.count){//大图排版
            KKSamllVideoType smallType = KKSamllVideoTypeOther ;
            if([self.sectionItem.category isEqualToString:@"video"]){
                smallType = KKSamllVideoTypeVideoCatagory;
            }
            [self playVideoInSmall:item oriView:fromView oriRect:rect smallType:smallType];
        }else{//左边文字，右边图片、视频排版
            [self showVideoDetailView:item smallType:KKSamllVideoTypeDetail];
        }
    }else if(item.user){//微头条
        self.selIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
        KKWeiTouTiaoBaseCell *cell = (KKWeiTouTiaoBaseCell *)[self.tableView cellForRowAtIndexPath:self.selIndexPath];
        CGRect frame = [fromView convertRect:rect toView:self.tableView];
        NSArray *imageArray = item.large_image_list;
        for(NSInteger i = 0 ; i < imageArray.count ; i++){
            KKImageItem *item = [imageArray safeObjectAtIndex:i];
            item.image = [cell fetchImageWithIndex:i];
        }
        if(imageArray.count){
            [self showWTTImageBrowserView:imageArray oriRect:frame selIndex:indexPath.section];
        }
    }else{
        [self showNormalNewsWith:item sectionItem:self.sectionItem];
    }
}

- (void)jumpToUserPage:(NSString *)userId{
    KKPersonalInfoView *view = [[KKPersonalInfoView alloc]initWithUserId:userId willDissmissBlock:nil];
    view.topSpace = 0 ;
    view.navContentOffsetY = KKStatusBarHeight / 2.0 ;
    view.navTitleHeight = KKNavBarHeight ;
    
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(UIDeviceScreenWidth, UIDeviceScreenHeight));
    }];
    [view pushIn];
}

#pragma mark -- 一般格式的新闻详情

- (void)showNormalNewsWith:(KKSummaryContent *)item sectionItem:(KKSectionItem *)secItem{
    KKNewsBaseInfo *newsInfo = [KKNewsBaseInfo new];
    newsInfo.title = item.title;
    newsInfo.groupId = item.group_id;
    newsInfo.itemId = item.item_id;
    newsInfo.source = item.source;
    newsInfo.articalUrl = item.display_url;
    newsInfo.publicTime = item.publish_time;
    newsInfo.catagory = self.sectionItem.category;
    newsInfo.commentCount = item.comment_count;
    newsInfo.userInfo = item.user_info;
    
    KKNormalNewsDetailView *view = [[KKNormalNewsDetailView alloc]initWithNewsBaseInfo:newsInfo];
    view.topSpace = 0 ;
    view.navContentOffsetY = KKStatusBarHeight / 2.0 ;
    view.navTitleHeight = KKNavBarHeight ;
    
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(UIDeviceScreenWidth, UIDeviceScreenHeight));
    }];
    [view pushIn];
}

#pragma mark -- 图片新闻详情页

- (void)showImageNewsDetailView:(KKSummaryContent *)item oriRect:(CGRect)oriRect oriImage:(UIImage *)image{
    KKNewsBaseInfo *newsInfo = [KKNewsBaseInfo new];
    newsInfo.title = item.title;
    newsInfo.groupId = item.group_id;
    newsInfo.itemId = item.item_id;
    newsInfo.source = item.source;
    newsInfo.articalUrl = item.display_url;
    newsInfo.publicTime = item.publish_time;
    newsInfo.catagory = self.sectionItem.category;
    newsInfo.commentCount = item.comment_count;
    newsInfo.userInfo = item.user_info;
    
    KKImageNewsDetail *browser = [[KKImageNewsDetail alloc]initWithNewsBaseInfo:newsInfo];
    browser.topSpace = 0 ;
    browser.navContentOffsetY = KKStatusBarHeight / 2.0 ;
    browser.navTitleHeight = KKNavBarHeight ;
    browser.oriFrame = oriRect;
    browser.oriView = self.tableView;
    browser.oriImage = image;
    if([self.sectionItem.category isEqualToString:@"组图"]){
        browser.defaultHideAnimateWhenDragFreedom = NO ;
        KKPictureCell *cell = (KKPictureCell *)[self.tableView cellForRowAtIndexPath:self.selIndexPath];
        cell.largeImgView.alpha = 0 ;
    }
    
    @weakify(browser);
    [browser setHideImageAnimate:^(UIImage *image,CGRect formFrame,CGRect toFrame){
        @strongify(browser);
        UIImageView *imageView = [UIImageView new];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.frame = formFrame ;
        imageView.layer.masksToBounds = YES ;
        [self.tableView addSubview:imageView];
        [UIView animateWithDuration:0.3 animations:^{
            imageView.frame = toFrame;
        }completion:^(BOOL finished) {
            [imageView removeFromSuperview];
            [browser removeFromSuperview];
            if([self.sectionItem.category isEqualToString:@"组图"]){
                for(KKPictureCell *cell in self.tableView.visibleCells){
                    cell.largeImgView.alpha = 1.0 ;
                }
            }
        }];
    }];
    
    [browser setAlphaViewIfNeed:^(BOOL alphaView){
        if([self.sectionItem.category isEqualToString:@"组图"]){
            KKPictureCell *cell = (KKPictureCell *)[self.tableView cellForRowAtIndexPath:self.selIndexPath];
            cell.largeImgView.alpha = !alphaView ;
        }
    }];
    
    [[UIApplication sharedApplication].keyWindow addSubview:browser];
    [browser mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(UIDeviceScreenWidth, UIDeviceScreenHeight));
    }];
    [browser popIn];
}

#pragma mark -- 趣图、美图、街拍

- (void)showImageBrowserView:(NSArray *)imageArray oriRect:(CGRect)oriRect{
    KKImageBrowser *browser = [[KKImageBrowser alloc]initWithImageArray:imageArray oriView:self.tableView oriFrame:oriRect];
    browser.topSpace = 0 ;
    browser.showImageWithUrl = NO ;
    browser.frame = CGRectMake(0, 0, UIDeviceScreenWidth, UIDeviceScreenHeight);
    if([self.sectionItem.category isEqualToString:@"image_funny"] ||
       [self.sectionItem.category isEqualToString:@"image_ppmm"] ||
       [self.sectionItem.category isEqualToString:@"image_wonderful"]){
        browser.defaultHideAnimateWhenDragFreedom = NO ;
    }
    
    @weakify(browser);
    [browser setHideImageAnimate:^(UIImage *image,CGRect fromFrame,CGRect toFrame){
        @strongify(browser);
        UIImageView *imageView = [YYAnimatedImageView new];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.frame = fromFrame ;
        imageView.layer.masksToBounds = YES ;
        [self.tableView addSubview:imageView];
        [UIView animateWithDuration:0.3 animations:^{
            imageView.frame = toFrame;
        }completion:^(BOOL finished) {
            [imageView removeFromSuperview];
            [browser removeFromSuperview];
            if([self.sectionItem.category isEqualToString:@"image_funny"] ||
               [self.sectionItem.category isEqualToString:@"image_ppmm"] ||
               [self.sectionItem.category isEqualToString:@"image_wonderful"]){
                for(KKTextImageCell *cell in self.tableView.visibleCells){
                    cell.contentImageView.alpha = 1.0 ;
                }
            }
        }];
    }];
    
    [browser setAlphaViewIfNeed:^(BOOL alphaView,NSInteger index){
        if([self.sectionItem.category isEqualToString:@"image_funny"] ||
           [self.sectionItem.category isEqualToString:@"image_ppmm"] ||
           [self.sectionItem.category isEqualToString:@"image_wonderful"]){
            KKTextImageCell *cell = (KKTextImageCell *)[self.tableView cellForRowAtIndexPath:self.selIndexPath];
            cell.contentImageView.alpha = !alphaView ;
        }
    }];
    
    [[UIApplication sharedApplication].keyWindow addSubview:browser];
    [browser viewWillAppear];
}

#pragma mark -- 视频新闻

//跳转到详情页
- (void)showVideoDetailView:(KKSummaryContent *)contentItem smallType:(KKSamllVideoType)smallType{
    NSString *videoId = contentItem.video_detail_info.video_id;
    NSString *title = contentItem.title;
    NSString *playCount = contentItem.video_detail_info.video_watch_count;
    NSString *url = contentItem.video_detail_info.detail_video_large_image.url;
    if(!url.length){
        url = contentItem.image_list.firstObject.url;
    }
    if(!url.length){
        url = @"";
    }
    
    KKNewsBaseInfo *newsInfo = [KKNewsBaseInfo new];
    newsInfo.title = contentItem.title;
    newsInfo.groupId = contentItem.group_id;
    newsInfo.itemId = contentItem.item_id;
    newsInfo.source = contentItem.source;
    newsInfo.articalUrl = contentItem.display_url;
    newsInfo.publicTime = contentItem.publish_time;
    newsInfo.catagory = self.sectionItem.category;
    newsInfo.videoWatchCount = contentItem.video_detail_info.video_watch_count;
    newsInfo.diggCount = contentItem.digg_count;
    newsInfo.buryCount = contentItem.bury_count ;
    newsInfo.commentCount = contentItem.comment_count;
    newsInfo.userInfo = contentItem.user_info;
    
    KKVideoNewsDetail *detailView = [[KKVideoNewsDetail alloc]initWithNewsBaseInfo:newsInfo];
    [[UIApplication sharedApplication].keyWindow addSubview:detailView];
    [detailView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(UIDeviceScreenWidth, UIDeviceScreenHeight));
    }];
    
    if([self.videoPlayView.videoId isEqualToString:videoId]){
        [self.videoPlayView removeFromSuperview];
        [self.videoPlayView setSmallType:smallType];
    }else{
        [self.videoPlayView destoryVideoPlayer];
        self.videoPlayView = [[KKAVPlayerView alloc]initWithTitle:title playCount:playCount coverUrl:url videoId:videoId smallType:smallType];
    }
    [detailView addVideoPlayView:self.videoPlayView];
    [detailView pushIn];
}

//小屏播放
- (void)playVideoInSmall:(KKSummaryContent *)contentItem oriView:(UIView *)oriView oriRect:(CGRect)oriRect smallType:(KKSamllVideoType)smallType{
    NSString *videoId = contentItem.video_detail_info.video_id;
    NSString *title = contentItem.title;
    NSString *playCount = contentItem.video_detail_info.video_watch_count;
    NSString *url = contentItem.video_detail_info.detail_video_large_image.url;
    if(!url.length){
        url = contentItem.image_list.firstObject.url;
    }
    if(!url.length){
        url = @"";
    }
    CGRect frame = [oriView convertRect:oriRect toView:self.tableView];
    [self.videoPlayView destoryVideoPlayer];
    self.videoPlayView = [[KKAVPlayerView alloc]initWithTitle:title playCount:playCount coverUrl:url videoId:videoId smallType:smallType];
    self.videoPlayView.originalFrame = frame ;
    self.videoPlayView.originalView = oriView;
    [self.tableView addSubview:self.videoPlayView];
}

#pragma mark -- 段子详情

- (void)showTextImageDetailView:(KKSummaryContent *)item{
    KKTextImageDetailView *view = [[KKTextImageDetailView alloc]initWithContentItem:item sectionItem:self.sectionItem];
    view.topSpace = 0 ;
    view.navContentOffsetY = KKStatusBarHeight / 2.0 ;
    view.navTitleHeight = KKNavBarHeight ;
    
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(UIDeviceScreenWidth, UIDeviceScreenHeight));
    }];
    [view pushIn];
}

#pragma mark -- KKWeiTouTiaoCellDelegate

- (void)showWTTDetailView:(KKSummaryContent *)item{
    KKWeiTouTiaoDetailView *view = [[KKWeiTouTiaoDetailView alloc]initWithContentItem:item sectionItem:self.sectionItem];
    view.topSpace = 0 ;
    view.navContentOffsetY = KKStatusBarHeight / 2.0 ;
    view.navTitleHeight = KKNavBarHeight ;
    
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(UIDeviceScreenWidth, UIDeviceScreenHeight));
    }];
    [view pushIn];
}

#pragma mark -- 微头条图片浏览
/**
 微头条图片浏览

 @param imageArray 图片数组，KKImageItem
 @param oriRect 点击图片的原始frame
 @param selIndex 点击的图片
 */
- (void)showWTTImageBrowserView:(NSArray<KKImageItem *> *)imageArray oriRect:(CGRect)oriRect selIndex:(NSInteger)selIndex{
    KKImageBrowser *browser = [[KKImageBrowser alloc]initWithImageArray:imageArray oriView:self.tableView oriFrame:oriRect];
    browser.topSpace = 0 ;
    browser.frame = CGRectMake(0, 0, UIDeviceScreenWidth, UIDeviceScreenHeight);
    browser.defaultHideAnimateWhenDragFreedom = NO ;
    browser.showImageWithUrl = YES ;
    browser.selIndex = selIndex;
    
    @weakify(browser);
    [browser setHideImageAnimate:^(UIImage *image,CGRect fromFrame,CGRect toFrame){
        @strongify(browser);
        UIImageView *imageView = [YYAnimatedImageView new];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = fromFrame ;
        imageView.layer.masksToBounds = YES ;
        [self.tableView addSubview:imageView];
        [UIView animateWithDuration:0.3 animations:^{
            imageView.frame = toFrame;
        }completion:^(BOOL finished) {
            [imageView removeFromSuperview];
            [browser removeFromSuperview];
            KKWeiTouTiaoBaseCell *cell = (KKWeiTouTiaoBaseCell *)[self.tableView cellForRowAtIndexPath:self.selIndexPath];
            [cell resetImageViewHidden:NO index:-1];
        }];
    }];
    
    [browser setAlphaViewIfNeed:^(BOOL alphaView,NSInteger index){
        for(KKWeiTouTiaoBaseCell *cell in self.tableView.visibleCells){
            [cell resetImageViewHidden:NO index:-1];
        }
        KKWeiTouTiaoBaseCell *cell = (KKWeiTouTiaoBaseCell *)[self.tableView cellForRowAtIndexPath:self.selIndexPath];
        [cell resetImageViewHidden:alphaView index:index];
    }];
    
    [browser setImageIndexChange:^(NSInteger imageIndex, void (^updeteOriFrame)(CGRect oriFrame)) {
        KKWeiTouTiaoBaseCell *cell = (KKWeiTouTiaoBaseCell *)[self.tableView cellForRowAtIndexPath:self.selIndexPath];
        CGRect imageFrame = [cell fetchImageFrameWithIndex:imageIndex];
        imageFrame = [cell.bgView convertRect:imageFrame toView:self.tableView];
        if(updeteOriFrame){
            updeteOriFrame(imageFrame);
        }
    }];
    
    [[UIApplication sharedApplication].keyWindow addSubview:browser];
    [browser viewWillAppear];
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //超出可视范围，则将播放器移除
    if(self.videoPlayView){
        UIView *oriView = self.videoPlayView.originalView;
        CGRect frame = [oriView convertRect:oriView.frame toView:self.tableView];
        CGFloat top = frame.origin.y ;
        CGFloat bottom = top + frame.size.height ;
        CGFloat offsetY = scrollView.contentOffset.y;
        CGFloat offsetBottom = offsetY + scrollView.height;
        if(offsetY > bottom || offsetBottom < top){
            [self.videoPlayView destoryVideoPlayer];
            self.videoPlayView = nil ;
        }
    }
}

#pragma mark -- @property

- (UITableView *)tableView{
    if(!_tableView){
        _tableView = ({
            UITableView *view = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
            view.dataSource = self ;
            view.delegate = self ;
            view.backgroundColor = KKColor(244, 245, 246, 1.0);
            view.separatorStyle = UITableViewCellSeparatorStyleNone ;
            view.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, -1)];
            [view registerClass:[KKSmallCorverCell class] forCellReuseIdentifier:smallCellIdentifier];
            [view registerClass:[KKLargeCorverCell class] forCellReuseIdentifier:largeCellIdentifier];
            [view registerClass:[KKMiddleCorverCell class] forCellReuseIdentifier:middleCellIdentifier];
            [view registerClass:[KKWeiTouTiaoCellOne class] forCellReuseIdentifier:vipUserCellIdentifier1];
            [view registerClass:[KKWeiTouTiaoCellThree class] forCellReuseIdentifier:vipUserCellIdentifier3];
            [view registerClass:[KKWeiTouTiaoCellNine class] forCellReuseIdentifier:vipUserCellIdentifier9];
            [view registerClass:[KKTextImageCell class] forCellReuseIdentifier:textImageCellIdentifier];
            [view registerClass:[KKVideoCell class] forCellReuseIdentifier:videoCellIdentifier];
            [view registerClass:[KKPictureCell class] forCellReuseIdentifier:pictureCellIdentifier];
            
            @weakify(self);
            view.mj_header = [KKRefreshView headerWithRefreshingBlock:^{
                @strongify(self);
                [self refreshData:YES shouldShowTips:YES];
            }];
            
            MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
                @strongify(self);
                [self refreshData:NO shouldShowTips:NO];
            }];
            [footer setTitle:@"正在努力加载" forState:MJRefreshStateIdle];
            [footer setTitle:@"正在努力加载" forState:MJRefreshStateRefreshing];
            [footer setTitle:@"正在努力加载" forState:MJRefreshStatePulling];
            [footer setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
            [view setMj_footer:footer];
            
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

- (UILabel *)refreshTipLabel{
    if(!_refreshTipLabel){
        _refreshTipLabel = ({
            UILabel *view = [UILabel new];
            view.backgroundColor = KKColor(214, 232, 248, 1.0);
            view.textColor = KKColor(0, 135, 211, 1);
            view.font = [UIFont systemFontOfSize:15];
            view.textAlignment = NSTextAlignmentCenter;
            view ;
        });
    }
    return _refreshTipLabel;
}

- (KKLoadingView *)loadingView{
    if(!_loadingView){
        _loadingView = ({
            KKLoadingView *view = [KKLoadingView new];
            view.hidden = NO ;
            view.backgroundColor = [UIColor whiteColor];
            view ;
        });
    }
    return _loadingView;
}

@end
