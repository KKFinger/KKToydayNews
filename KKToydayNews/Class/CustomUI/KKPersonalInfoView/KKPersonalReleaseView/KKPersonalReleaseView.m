//
//  KKPersonalReleaseView.m
//  KKToydayNews
//
//  Created by finger on 2017/11/19.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKPersonalReleaseView.h"
#import "KKProsonalSummaryView.h"
#import "KKIndicatorView.h"

static NSInteger baseTag = 1000000;
static CGFloat topIndexViewHeight = 38;

@interface KKPersonalReleaseView()<UIScrollViewDelegate,KKIndicatorViewDelegate>
@property(nonatomic)KKIndicatorView *topIndexView ;
@property(nonatomic)UIScrollView *contentView;
@property(nonatomic)NSString *userId;
@property(nonatomic)NSString *mediaId;
@end

@implementation KKPersonalReleaseView

- (instancetype)initWithTopicArray:(NSArray<KKPersonalTopic *> *)array userId:(NSString *)userId{
    self = [super init];
    if(self){
        self.topicArray = array;
        self.userId = userId;
        [self setupUI];
    }
    return self ;
}

- (instancetype)init{
    self = [super init];
    if(self){
        [self setupUI];
    }
    return self ;
}

- (void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

#pragma mark -- 初始化UI

- (void)setupUI{
    [self addSubview:self.topIndexView];
    [self addSubview:self.contentView];
    [self.topIndexView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self);
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(topIndexViewHeight);
    }];
    [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topIndexView.mas_bottom);
        make.left.mas_equalTo(self);
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(self).mas_offset(-topIndexViewHeight);
    }];
}

- (void)setTopicArray:(NSArray<KKPersonalTopic *> *)array userId:(NSString *)userId mediaId:(NSString *)mediaId{
    self.userId = userId;
    self.mediaId = mediaId;
    self.topicArray = array;
}

#pragma mark -- UIScrollViewDelegate

//结束拉拽视图
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    CGPoint offset = scrollView.contentOffset;
    NSInteger index = (offset.x + UIDeviceScreenWidth /2 ) / UIDeviceScreenWidth;
    self.topIndexView.selectedIndex = index;
}

//完全停止滚动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    NSInteger index = offset.x / UIDeviceScreenWidth;
    self.topIndexView.selectedIndex = index;
}

#pragma mark -- @property setter

- (void)setTopicArray:(NSArray<KKPersonalTopic *> *)topicArray{
    _topicArray = topicArray;
    for(UIView *view in self.contentView.subviews){
        if([view isKindOfClass:[KKProsonalSummaryView class]]){
            [view removeFromSuperview];
        }
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    for(KKPersonalTopic *topic in topicArray){
        [array safeAddObject:topic.show_name];
    }
    self.topIndexView.titleArray = array;
    
    NSInteger index = 0 ;
    for(KKPersonalTopic *topic in topicArray){
        KKProsonalSummaryView *view = [[KKProsonalSummaryView alloc]initWithTopic:topic userId:self.userId mediaId:self.mediaId];
        [view setTag:baseTag + index];
        [view setCanScroll:NO];
        
        @weakify(self);
        [view setCanScrollCallback:^(BOOL canScroll) {
            @strongify(self);
            if(self.canScrollCallback){
                self.canScrollCallback(canScroll);
            }
        }];
        
        [self.contentView addSubview:view];
        [view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView);
            make.left.mas_equalTo(self.contentView).mas_offset(index * UIDeviceScreenWidth);
            make.width.mas_equalTo(UIDeviceScreenWidth);
            make.height.mas_equalTo(self.contentView);
        }];
        index ++ ;
    }
    
    [self.contentView setContentSize:CGSizeMake(UIDeviceScreenWidth * topicArray.count,0)];
}

#pragma mark -- KKIndicatorViewDelegate

- (void)selectIndex:(NSInteger)index title:(NSString *)title{
    [self.contentView setContentOffset:CGPointMake(index * UIDeviceScreenWidth, 0) animated:YES];
}

#pragma mark -- @property setter

- (void)setCanScroll:(BOOL)canScroll{
    for(NSInteger i = 0 ; i < self.topicArray.count ; i ++){
        KKProsonalSummaryView *view = [self.contentView viewWithTag:baseTag + i];
        view.canScroll = canScroll ;
    }
}

#pragma mark -- @property getter

- (UIScrollView *)contentView{
    if(!_contentView){
        _contentView = ({
            UIScrollView *view = [UIScrollView new];
            view.delegate = self;
            view.showsVerticalScrollIndicator = NO ;
            view.showsHorizontalScrollIndicator = NO ;
            view.pagingEnabled = YES ;
            view.bounces = NO ;
            view.tag = KKViewTagPersonInfoScrollView;
            if(IOS11_OR_LATER){
                KKAdjustsScrollViewInsets(view);
            }
            view;
        });
    }
    return _contentView;
}

- (KKIndicatorView *)topIndexView{
    if(!_topIndexView){
        _topIndexView = ({
            KKIndicatorView *view = [[KKIndicatorView alloc]init];
            view.normalColor = KKColor(102.0, 102.0, 102.0, 1.0);
            view.selectedColor = [UIColor redColor];
            view.bottomLineColor = view.selectedColor ;
            view.delegate = self;
            view.bottomLinePadding = 0 ;
            view.bottomLineHeight = 1.5;
            view.btnWith = 60 ;
            view.titleFont = [UIFont systemFontOfSize:16];
            view.borderType = KKBorderTypeTop | KKBorderTypeBottom;
            view.borderColor = [[UIColor grayColor]colorWithAlphaComponent:0.3];
            view.borderThickness = 0.4 ;
            view;
        });
    }
    return _topIndexView;
}
@end
