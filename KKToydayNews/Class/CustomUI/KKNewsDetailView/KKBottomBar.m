//
//  KKBottomBar.m
//  KKToydayNews
//
//  Created by finger on 2017/9/24.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKBottomBar.h"
#import "KKTextView.h"
#import "KKInputView.h"
#import "KKBadgeView.h"

#define TextViewHeight 30

@interface KKBottomBar ()<KKInputViewDelegate>
@property(nonatomic,readwrite)KKTextView *textView;
@property(nonatomic)KKBadgeView *commentView;
@property(nonatomic)KKBadgeView *favoriteView;
@property(nonatomic)KKBadgeView *diggView;//点赞
@property(nonatomic)KKBadgeView *shareView;
@property(nonatomic)KKInputView *inputView;
@property(nonatomic,readwrite)UIView *splitView;

@property(nonatomic,assign)KKBottomBarType barType;

@end

@implementation KKBottomBar

- (instancetype)init{
    self = [super init];
    if(self){
        self.barType = KKBottomBarTypeNewsDetail;
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithBarType:(KKBottomBarType)barType{
    self = [super init];
    if(self){
        self.barType = barType;
        [self setupUI];
    }
    return self;
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self addSubview:self.textView];
    [self addSubview:self.splitView];
    if(self.barType == KKBottomBarTypePersonalComment ||
       self.barType == KKBottomBarTypeNewsDetail){
        [self addSubview:self.shareView];
        if(self.barType == KKBottomBarTypeNewsDetail){
            [self addSubview:self.commentView];
            [self addSubview:self.favoriteView];
        }else{
            [self addSubview:self.diggView];
        }
    }
    
    NSInteger intervalSpace = 30.0 ;
    NSInteger buttonWidth = 23;
    NSInteger buttonHeight = 23;
    
    if(self.barType == KKBottomBarTypePersonalComment ||
       self.barType == KKBottomBarTypeNewsDetail){
        [self.shareView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self).mas_offset(-8);
            make.centerY.mas_equalTo(self);
            make.width.mas_equalTo(buttonWidth);
            make.height.mas_equalTo(buttonHeight);
        }];
        
        if(self.barType == KKBottomBarTypeNewsDetail){
            [self.favoriteView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.shareView.mas_left).mas_offset(-intervalSpace);
                make.centerY.mas_equalTo(self.shareView);
                make.width.mas_equalTo(buttonWidth);
                make.height.mas_equalTo(buttonHeight);
            }];
            
            [self.commentView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.favoriteView.mas_left).mas_offset(-intervalSpace);
                make.centerY.mas_equalTo(self.shareView);
                make.width.mas_equalTo(buttonWidth);
                make.height.mas_equalTo(buttonHeight);
            }];
        }else{
            [self.diggView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(self.shareView.mas_left).mas_offset(-intervalSpace);
                make.centerY.mas_equalTo(self.shareView);
                make.width.mas_equalTo(buttonWidth);
                make.height.mas_equalTo(buttonHeight);
            }];
        }
    }
    
    [self.splitView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self);
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(1.0);
    }];
    
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).mas_offset(8);
        if(self.barType == KKBottomBarTypeNewsDetail){
            make.right.mas_equalTo(self.commentView.mas_left).mas_offset(-20);
            make.centerY.mas_equalTo(self.shareView);
        }else if(self.barType == KKBottomBarTypePersonalComment){
            make.right.mas_equalTo(self.diggView.mas_left).mas_offset(-20);
            make.centerY.mas_equalTo(self.shareView);
        }else{
            make.right.mas_equalTo(self).mas_offset(-kkPaddingNormal);
            make.centerY.mas_equalTo(self);
        }
        make.height.mas_equalTo(30);
    }];
}


#pragma mark -- 显示键盘

- (void)showKeyboardView{
    [self.inputView showKeyBoard];
}

#pragma mark -- 分享

- (void)shareNews{
    if(self.delegate && [self.delegate respondsToSelector:@selector(shareNews)]){
        [self.delegate shareNews];
    }
}

#pragma mark -- 收藏

- (void)favarite{
    if(self.delegate && [self.delegate respondsToSelector:@selector(favoriteNews:callback:)]){
        BOOL favotite = !self.favoriteView.tag;
        [self.delegate favoriteNews:favotite callback:^(BOOL suc) {
            if(suc){
                self.favoriteView.tag = favotite ;
                if(favotite){
                    self.favoriteView.image = [UIImage imageNamed:@"love_video_press_20x20_"];
                }else{
                    self.favoriteView.image = [UIImage imageNamed:@"love_video_20x20_"];
                }
            }
        }];
    }
}

#pragma mark -- 点赞

- (void)digg{
    if(self.delegate && [self.delegate respondsToSelector:@selector(diggComment:callback:)]){
        BOOL isDigg = !self.diggView.tag;
        [self.delegate diggComment:isDigg callback:^(BOOL suc) {
            if(suc){
                self.diggView.tag = isDigg ;
                if(isDigg){
                    self.diggView.image = [UIImage imageNamed:@"comment_like_icon_press_16x16_"];
                }else{
                    self.diggView.image = [UIImage imageNamed:@"comment_like_icon_16x16_"];
                }
            }
        }];
    }
}

#pragma mark -- 点击评论视图

- (void)commentViewClick{
    if(self.delegate && [self.delegate respondsToSelector:@selector(showCommentView)]){
        [self.delegate showCommentView];
    }
}

#pragma mark -- KKInputViewDelegate

- (void)endEditWithInputText:(NSString *)inputText{
    if(!inputText.length){
        return ;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(sendCommentWidthText:)]){
        [self.delegate sendCommentWidthText:inputText];
    }
}

- (void)setCommentCount:(NSInteger)commentCount{
    self.commentView.badge = commentCount;
}

#pragma mark -- @property setter

- (void)setOffsetY:(CGFloat)offsetY{
    _offsetY = offsetY;
    [self.shareView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self).mas_offset(offsetY);
    }];
}

#pragma mark -- @property getter

- (KKTextView *)textView{
    if(!_textView){
        _textView = ({
            KKTextView *view = [[KKTextView alloc]init];
            view.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:245.0/255.0 blue:246.0/255.0 alpha:1.0];
            view.placeholderColor = [UIColor colorWithRed:202.0/255.0 green:202.0/255.0 blue:202.0/255.0 alpha:1.0];
            view.placeholder = @"写评论...";
            view.scrollEnabled = NO ;
            view.editable = NO ;
            view.textContainerInset = UIEdgeInsetsMake(5,10,0,-10);
            view.layer.cornerRadius = TextViewHeight / 2 ;
            
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                [self showKeyboardView];
            }];
            view;
        });
    }
    return _textView;
}

- (KKBadgeView *)commentView{
    if(!_commentView){
        _commentView = ({
            KKBadgeView *view = [KKBadgeView new];
            view.image = [UIImage imageNamed:@"comment_video_20x20_"];
            view.userInteractionEnabled = YES ;
            
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                [self commentViewClick];
            }];
            view ;
        });
    }
    return _commentView;
}

- (KKBadgeView *)favoriteView{
    if(!_favoriteView){
        _favoriteView = ({
            KKBadgeView *view = [KKBadgeView new];
            view.image = [UIImage imageNamed:@"love_video_20x20_"];
            view.tag = 0 ;
            view.userInteractionEnabled = YES ;
            
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                [self favarite];
            }];
            view ;
        });
    }
    return _favoriteView;
}

- (KKBadgeView *)shareView{
    if(!_shareView){
        _shareView = ({
            KKBadgeView *view = [KKBadgeView new];
            view.image = [UIImage imageNamed:@"repost_video_20x20_"];
            view.userInteractionEnabled = YES ;
            
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                [self shareNews];
            }];
            
            view ;
        });
    }
    return _shareView;
}

- (KKInputView *)inputView{
    if(!_inputView){
        _inputView = ({
            KKInputView *view = [KKInputView new];
            view.delegate = self ;
            view ;
        });
    }
    return _inputView;
}

- (UIView *)splitView{
    if(!_splitView){
        _splitView = ({
            UIView *view = [UIView new];
            view.backgroundColor = KKColor(244, 245, 246, 1.0);;
            view ;
        });
    }
    return _splitView;
}

- (KKBadgeView *)diggView{
    if(!_diggView){
        _diggView = ({
            KKBadgeView *view = [KKBadgeView new];
            view.image = [UIImage imageNamed:@"comment_like_icon_16x16_"];
            view.tag = 0 ;
            view.userInteractionEnabled = YES ;
            
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                [self digg];
            }];
            
            view ;
        });
    }
    return _diggView;
}

@end
