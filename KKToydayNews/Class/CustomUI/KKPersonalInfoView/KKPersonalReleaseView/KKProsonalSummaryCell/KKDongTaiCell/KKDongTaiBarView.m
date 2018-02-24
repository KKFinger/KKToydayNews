//
//  KKDongTaiBarView.m
//  KKToydayNews
//
//  Created by finger on 2017/9/18.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKDongTaiBarView.h"

@interface KKDongTaiBarView ()
@property(nonatomic)UIButton *upvoteBtn;
@property(nonatomic)UIButton *commentBtn;
@property(nonatomic)UIButton *shareBtn;
@end

@implementation KKDongTaiBarView

- (instancetype)init{
    self = [super init];
    if(self){
        [self setupUI];
    }
    return self;
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self addSubview:self.upvoteBtn];
    [self addSubview:self.commentBtn];
    [self addSubview:self.shareBtn];
    
    [self.upvoteBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self).mas_offset(kkPaddingNormal);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(35);
    }];
    
    [self.commentBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(35);
    }];
    
    [self.shareBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self).mas_offset(-kkPaddingNormal);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(35);
    }];
}

#pragma mark -- 按钮事件

- (void)clickedBtn:(id)sender{
    UIButton *btn = (UIButton *)sender ;
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickButtonWithType:item:)]){
        [self.delegate clickButtonWithType:btn.tag item:nil];
    }
}

#pragma mark -- @property setter

- (void)setUpVoteCount:(NSString *)upVoteCount{
    _upVoteCount = upVoteCount ;
    [self.upvoteBtn setTitle:upVoteCount forState:UIControlStateNormal];
}

- (void)setCommentCount:(NSString *)commentCount{
    _commentCount = commentCount ;
    [self.commentBtn setTitle:commentCount forState:UIControlStateNormal];
}

- (void)setShareCount:(NSString *)shareCount{
    _shareCount = shareCount;
    [self.shareBtn setTitle:shareCount forState:UIControlStateNormal];
}

#pragma mark -- @property getter

- (UIButton *)upvoteBtn{
    if(!_upvoteBtn){
        _upvoteBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"like_old_feed_24x24_"] forState:UIControlStateNormal];
            [view setImage:[UIImage imageNamed:@"like_old_feed_press_24x24_"] forState:UIControlStateSelected];
            [view setTitleColor:[[UIColor blackColor]colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
            [view.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [view addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
            [view setTag:KKBarButtonTypeUpvote];
            view ;
        });
    }
    return _upvoteBtn;
}

- (UIButton *)commentBtn{
    if(!_commentBtn){
        _commentBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"comment_feed_24x24_"] forState:UIControlStateNormal];
            [view setTitleColor:[[UIColor blackColor]colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
            [view.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [view setTag:KKBarButtonTypeComment];
            [view addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
            view ;
        });
    }
    return _commentBtn;
}

- (UIButton *)shareBtn{
    if(!_shareBtn){
        _shareBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"feed_share_24x24_"] forState:UIControlStateNormal];
            [view setTitleColor:[[UIColor blackColor]colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
            [view.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [view setTag:KKBarButtonTypeShare];
            [view addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
            view ;
        });
    }
    return _shareBtn;
}

@end
