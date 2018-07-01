//
//  KKTextImageDetailHeadView.m
//  KKToydayNews
//
//  Created by finger on 2017/10/10.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKTextImageDetailHeadView.h"
#import "KKButton.h"
#import "KKImageBrowser.h"
#import "TYAttributedLabel.h"

#define TextViewWidth (UIDeviceScreenWidth - 2 * kkPaddingNormal)

@interface KKTextImageDetailHeadView ()
@property(nonatomic)TYAttributedLabel *textLabel;
@property(nonatomic)UIButton *diggBtn;
@property(nonatomic)UIButton *disDiggBtn;
@property(nonatomic)UILabel *label;
@property(nonatomic)UIView *sortTypeView;
@property(nonatomic)UIButton *hotBtn;
@property(nonatomic)UIButton *timeBtn;
@property(nonatomic)UIView *splitView;
@property(nonatomic)UIView *bottomSplitView;
@property(nonatomic,readwrite)UIImageView *contentImageView;
@property(nonatomic,weak)KKSummaryContent *item ;
@end

@implementation KKTextImageDetailHeadView

- (instancetype)init{
    if(self = [super init]){
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    [self addSubview:self.textLabel];
    [self addSubview:self.contentImageView];
    [self addSubview:self.diggBtn];
    [self addSubview:self.disDiggBtn];
    [self addSubview:self.label];
    [self addSubview:self.sortTypeView];
    [self addSubview:self.bottomSplitView];
    [self.sortTypeView addSubview:self.hotBtn];
    [self.sortTypeView addSubview:self.splitView];
    [self.sortTypeView addSubview:self.timeBtn];
    
    CGFloat btnHeight = 30 ;
    
    [self.textLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).mas_offset(kkPaddingNormal);
        make.left.mas_equalTo(self).mas_offset(kkPaddingNormal);
        make.width.mas_equalTo(TextViewWidth);
        make.height.mas_equalTo(0);
    }];
    
    [self.contentImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textLabel.mas_bottom).mas_offset(5);
        make.left.mas_equalTo(self.textLabel);
        make.width.mas_equalTo(self.textLabel);
        make.height.mas_equalTo(0);
    }];
    
    [self.diggBtn.layer setCornerRadius:btnHeight/2.0];
    [self.diggBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_centerX).mas_offset(-25);
        make.top.mas_equalTo(self.contentImageView.mas_bottom).mas_offset(25);
        make.height.mas_equalTo(btnHeight);
    }];
    
    [self.disDiggBtn.layer setCornerRadius:btnHeight/2.0];
    [self.disDiggBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_centerX).mas_offset(25);
        make.top.mas_equalTo(self.contentImageView.mas_bottom).mas_offset(25);
        make.height.mas_equalTo(btnHeight);
    }];
    
    [self.label mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.textLabel);
        make.bottom.mas_equalTo(self).mas_offset(-10);
        make.height.mas_equalTo(20);
    }];
    
    self.sortTypeView.layer.cornerRadius = 10 ;
    [self.sortTypeView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).mas_offset(-kkPaddingNormal);
        make.centerY.mas_equalTo(self.label);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(65);
    }];
    
    [self.hotBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.sortTypeView);
        make.top.mas_equalTo(self.sortTypeView);
        make.width.mas_equalTo(self.sortTypeView).multipliedBy(0.5);
        make.height.mas_equalTo(self.sortTypeView);
    }];
    
    [self.splitView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(0.7);
        make.height.mas_equalTo(10);
        make.centerY.mas_equalTo(self.sortTypeView);
        make.left.mas_equalTo(self.hotBtn.mas_right);
    }];
    
    [self.timeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.sortTypeView);
        make.top.mas_equalTo(self.sortTypeView);
        make.width.mas_equalTo(self.sortTypeView).multipliedBy(0.5);
        make.height.mas_equalTo(self.sortTypeView);
    }];
    
    [self.bottomSplitView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(0.5);
        make.bottom.mas_equalTo(self);
        make.left.mas_equalTo(self);
    }];
}

#pragma mark -- 数据刷新

- (void)refreshWithItem:(KKSummaryContent *)item{
    self.item = item;
    
    self.textLabel.textContainer = item.textContainer;
    [self.textLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(item.textContainer.attriTextHeight);
    }];
    
    NSString *diggCount = [[NSNumber numberWithLong:item.digg_count.longLongValue]convert];
    NSString *buryCount = [[NSNumber numberWithLong:item.bury_count.longLongValue]convert];
    CGFloat width1 = [diggCount sizeWithAttributes:@{NSFontAttributeName:self.diggBtn.titleLabel.font}].width;
    CGFloat width2 = [buryCount sizeWithAttributes:@{NSFontAttributeName:self.disDiggBtn.titleLabel.font}].width;
    CGFloat width = MAX(width1,width2);
    
    [self.diggBtn setTitle:diggCount forState:UIControlStateNormal];
    [self.diggBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width + 50);
    }];
    
    [self.disDiggBtn setTitle:buryCount forState:UIControlStateNormal];
    [self.disDiggBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width + 50);
    }];
    
    if(item.large_image.url){
        self.contentImageView.yy_imageURL = [NSURL URLWithString:item.large_image.url];
        CGFloat imageW = TextViewWidth;
        CGFloat imageH = imageW / (item.large_image.width / item.large_image.height);
        [self.contentImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.textLabel.mas_bottom).mas_offset(5);
            make.height.mas_equalTo(imageH);
        }];
        self.frame = CGRectMake(0, 0, UIDeviceScreenWidth, item.textContainer.attriTextHeight + imageH + 130);
    }else{
        [self.contentImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.textLabel.mas_bottom).mas_offset(0);
            make.height.mas_equalTo(0);
        }];
        self.frame = CGRectMake(0, 0, UIDeviceScreenWidth, item.textContainer.attriTextHeight + 130);
    }
    
}

#pragma mark -- 点赞/踩按钮

- (void)btnClicked:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag ;
    if(tag == KKBarButtonTypeUpvote){
        
    }else if(tag == KKBarButtonTypeBury){
        
    }
}

- (void)sortCommentClicked:(id)sender{
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag ;
    self.hotBtn.selected = !self.hotBtn.selected;
    self.timeBtn.selected = !self.timeBtn.selected;
    if(self.delegate && [self.delegate respondsToSelector:@selector(sortCommentByType:)]){
        [self.delegate sortCommentByType:tag];
    }
}

- (void)showImageBrowserView:(NSArray *)imageArray oriRect:(CGRect)oriRect{
    self.contentImageView.alpha = 0;
    
    KKImageBrowser *browser = [[KKImageBrowser alloc]initWithImageArray:imageArray oriView:self oriFrame:oriRect];
    browser.topSpace = 0 ;
    browser.defaultHideAnimateWhenDragFreedom = NO ;
    browser.frame = CGRectMake(0, 0, UIDeviceScreenWidth, UIDeviceScreenHeight);
    browser.showImageWithUrl = NO ;
    
    @weakify(browser);
    [browser setHideImageAnimate:^(UIImage *image,CGRect fromFrame,CGRect toFrame){
        @strongify(browser);
        UIImageView *imageView = [YYAnimatedImageView new];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.frame = fromFrame ;
        imageView.layer.masksToBounds = YES ;
        [self addSubview:imageView];
        [UIView animateWithDuration:0.3 animations:^{
            imageView.frame = toFrame;
        }completion:^(BOOL finished) {
            [imageView removeFromSuperview];
            [browser removeFromSuperview];
            self.contentImageView.alpha = 1.0;
        }];
    }];
    
    [browser setAlphaViewIfNeed:^(BOOL alphaView,NSInteger index){
        self.contentImageView.alpha = !alphaView ;
    }];
    
    [[UIApplication sharedApplication].keyWindow addSubview:browser];
    [browser viewWillAppear];
}

#pragma mark -- @property

- (TYAttributedLabel *)textLabel{
    if(!_textLabel){
        _textLabel = ({
            TYAttributedLabel *view = [TYAttributedLabel new];
            view.textColor = [UIColor blackColor];
            view.font = [UIFont systemFontOfSize:16];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByCharWrapping;
            view.numberOfLines = 0 ;
            view ;
        });
    }
    return _textLabel;
}

- (UIButton *)diggBtn{
    if(!_diggBtn){
        _diggBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setTitle:@"点赞" forState:UIControlStateNormal];
            [view setImage:[UIImage imageNamed:@"like_old_feed_24x24_"] forState:UIControlStateNormal];
            [view setImage:[UIImage imageNamed:@"like_old_feed_press_24x24_"] forState:UIControlStateSelected];
            [view setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [view setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            [view.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [view addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [view.layer setBorderColor:[[UIColor grayColor] colorWithAlphaComponent:0.3].CGColor];
            [view.layer setBorderWidth:0.7];
            [view setTag:KKBarButtonTypeUpvote];
            view ;
        });
    }
    return _diggBtn;
}

- (UIButton *)disDiggBtn{
    if(!_disDiggBtn){
        _disDiggBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setTitle:@"踩" forState:UIControlStateNormal];
            [view setImage:[UIImage imageNamed:@"digdown_video_20x20_"] forState:UIControlStateNormal];
            [view setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [view setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            [view.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [view setTag:KKBarButtonTypeBury];
            [view addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [view.layer setBorderColor:[[UIColor grayColor] colorWithAlphaComponent:0.3].CGColor];
            [view.layer setBorderWidth:0.7];
            view ;
        });
    }
    return _disDiggBtn;
}

- (UILabel *)label{
    if(!_label){
        _label = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor blackColor];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByCharWrapping;
            view.font = [UIFont systemFontOfSize:15];
            view.text = @"评论";
            view ;
        });
    }
    return _label;
}

- (UIView *)sortTypeView{
    if(!_sortTypeView){
        _sortTypeView = ({
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor clearColor];
            view.userInteractionEnabled = YES ;
            view.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.3].CGColor;
            view.layer.borderWidth = 0.7 ;
            view ;
        });
    }
    return _sortTypeView;
}

- (UIButton *)hotBtn{
    if(!_hotBtn){
        _hotBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setTitle:@"热门" forState:UIControlStateNormal];
            [view setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [view setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [view.titleLabel setFont:[UIFont systemFontOfSize:10]];
            [view.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [view setTag:KKSortCommentTypeHot];
            [view setSelected:YES];
            [view addTarget:self action:@selector(sortCommentClicked:) forControlEvents:UIControlEventTouchUpInside];
            view ;
        });
    }
    return _hotBtn;
}

- (UIButton *)timeBtn{
    if(!_timeBtn){
        _timeBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setTitle:@"时间" forState:UIControlStateNormal];
            [view setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [view setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            [view.titleLabel setFont:[UIFont systemFontOfSize:10]];
            [view.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [view setTag:KKSortCommentTypeTime];
            [view setSelected:NO];
            [view addTarget:self action:@selector(sortCommentClicked:) forControlEvents:UIControlEventTouchUpInside];
            view ;
        });
    }
    return _timeBtn;
}

- (UIView *)splitView{
    if(!_splitView){
        _splitView = ({
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor grayColor];
            view ;
        });
    }
    return _splitView;
}

- (UIView *)bottomSplitView{
    if(!_bottomSplitView){
        _bottomSplitView = ({
            UIView *view = [UIView new];
            view.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.2];
            view ;
        });
    }
    return _bottomSplitView;
}

- (UIImageView *)contentImageView{
    if(!_contentImageView){
        _contentImageView = ({
            UIImageView *view = [YYAnimatedImageView new];
            view.contentMode = UIViewContentModeScaleAspectFill ;
            view.layer.masksToBounds = YES ;
            view.userInteractionEnabled = YES ;
            @weakify(view);
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(view);
                @strongify(self);
                KKImageItem *imgItem = [KKImageItem new];
                imgItem.url = self.item.large_image.url;
                imgItem.image = view.image;
                [self showImageBrowserView:@[imgItem] oriRect:view.frame];
            }];
            view ;
        });
    }
    return _contentImageView;
}

@end
