//
//  KKVideoInfoView.m
//  KKToydayNews
//
//  Created by finger on 2017/10/7.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKVideoInfoView.h"
#import "KKButton.h"

#define space 5
#define ShowMoreWH 20
#define LabelHeight 20
#define ButtonWH 30
#define VeritSpace 10
#define TitleWidth (UIDeviceScreenWidth - 2 * kkPaddingNormal - ShowMoreWH - space)

@interface KKVideoInfoView ()
@property(nonatomic)UILabel *titleLabel;
@property(nonatomic)UILabel *showMoreLabel;
@property(nonatomic)UILabel *showMoreMask;
@property(nonatomic)UILabel *playCountLabel;
@property(nonatomic)UIView *descView;
@property(nonatomic)UILabel *publicTimeLabel;
@property(nonatomic)UILabel *descLabel;
@property(nonatomic)KKButton *diggBtn;
@property(nonatomic)KKButton *disDiggBtn;
@property(nonatomic)UILabel *shareToLabel;
@property(nonatomic)UIButton *wxBtn;
@property(nonatomic)UIButton *wxTimeBtn;
@property(nonatomic)UIView *splitViewBottom;

@property(nonatomic,assign)BOOL showDescView;
@property(nonatomic,assign)CGFloat titleHeight;
@property(nonatomic,assign)CGFloat descViewHeight;

@end

@implementation KKVideoInfoView

- (instancetype)init{
    self = [super init];
    if(self){
        [self initUI];
    }
    return self ;
}

- (void)initUI{
    [self addSubview:self.titleLabel];
    [self addSubview:self.showMoreLabel];
    [self addSubview:self.showMoreMask];
    [self addSubview:self.playCountLabel];
    [self addSubview:self.descView];
    [self.descView addSubview:self.publicTimeLabel];
    [self.descView addSubview:self.descLabel];
    [self addSubview:self.diggBtn];
    [self addSubview:self.disDiggBtn];
    [self addSubview:self.shareToLabel];
    [self addSubview:self.wxBtn];
    [self addSubview:self.wxTimeBtn];
    [self addSubview:self.splitViewBottom];
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).mas_offset(kkPaddingNormal);
        make.left.mas_equalTo(self).mas_offset(kkPaddingNormal);
        make.width.mas_equalTo(TitleWidth);
        make.height.mas_equalTo(0);
    }];
    
    [self.showMoreLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).mas_offset(-kkPaddingNormal);
        make.top.mas_equalTo(self.titleLabel).mas_offset(2);
    }];
    
    [self.showMoreMask mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self);
        make.top.mas_equalTo(self.titleLabel);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    [self.playCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.left.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(LabelHeight);
    }];
    
    [self.descView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.top.mas_equalTo(self.playCountLabel.mas_bottom).mas_offset(VeritSpace);
        make.height.mas_equalTo(0);
    }];
    
    [self.publicTimeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.descView);
        make.left.mas_equalTo(self.descView).mas_offset(kkPaddingNormal);
        make.height.mas_equalTo(LabelHeight);
        make.width.mas_equalTo(self.descView).mas_offset(-2 * kkPaddingNormal).priority(998);
    }];
    
    [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.publicTimeLabel.mas_bottom);
        make.left.mas_equalTo(self.publicTimeLabel);
        make.height.mas_equalTo(0);
        make.width.mas_equalTo(self.descView).mas_offset(-2 * kkPaddingNormal).priority(998);
    }];
    
    [self.diggBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.descView.mas_bottom);
        make.left.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(LabelHeight);
    }];
    
    [self.disDiggBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.diggBtn);
        make.left.mas_equalTo(self.diggBtn.mas_right).mas_offset(30);
        make.height.mas_equalTo(LabelHeight);
    }];
    
    [self.wxBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.diggBtn);
        make.right.mas_equalTo(self).mas_offset(-kkPaddingNormal);
        make.height.width.mas_equalTo(ButtonWH);
    }];
    
    [self.wxTimeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.diggBtn);
        make.right.mas_equalTo(self.wxBtn.mas_left).mas_offset(-5);
        make.height.width.mas_equalTo(ButtonWH);
    }];
    
    [self.shareToLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.diggBtn);
        make.right.mas_equalTo(self.wxTimeBtn.mas_left).mas_offset(-5);
        make.height.mas_equalTo(LabelHeight);
    }];
    
    [self.splitViewBottom mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.bottom.mas_equalTo(self);
        make.width.mas_equalTo(self);
        make.height.mas_equalTo(1.0);
    }];
}

#pragma mark -- @property setter

- (void)setTitle:(NSString *)title{
    _title = title;
    NSDictionary *dic = @{NSFontAttributeName:self.titleLabel.font};
    CGSize size = [title boundingRectWithSize:CGSizeMake(TitleWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    if(size.height > 2 * self.titleLabel.font.lineHeight){
        size.height = 2 * self.titleLabel.font.lineHeight ;
    }
    self.titleHeight = size.height + 5;
    self.titleLabel.text = _title;
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.titleHeight);
    }];
}

- (void)setPlayCount:(NSString *)playCount{
    _playCount = playCount;
    self.playCountLabel.text = [NSString stringWithFormat:@"%@次播放",playCount];
}

- (void)setPublicTime:(NSString *)publicTime{
    _publicTime = publicTime;
    self.publicTimeLabel.text = [NSString stringWithFormat:@"%@发布",publicTime];
}

- (void)setDescText:(NSString *)descText{
    _descText = descText;
    NSDictionary *dic = @{NSFontAttributeName:self.descLabel.font};
    CGSize size = [descText boundingRectWithSize:CGSizeMake(TitleWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    self.descViewHeight = size.height + LabelHeight + 15;
    self.descLabel.text = descText;
    [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(size.height + 5);
    }];
}

- (void)setDiggCount:(NSString *)diggCount{
    _diggCount = diggCount;
    if(_diggCount.length){
        [self.diggBtn setTitle:_diggCount forState:UIControlStateNormal];
    }
}

- (void)setDisDiggCount:(NSString *)disDiggCount{
    _disDiggCount = disDiggCount;
    if(_disDiggCount.length){
        [self.disDiggBtn setTitle:_disDiggCount forState:UIControlStateNormal];
    }
}

- (void)setShowDescView:(BOOL)showDescView{
    _showDescView = showDescView;
    CGFloat height = 0 ;
    if(showDescView){
        height = self.descViewHeight;
    }
    [self.descView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    if(self.changeViewHeight){
        self.changeViewHeight(showDescView ? self.height + self.descViewHeight : self.height - self.descViewHeight);
    }
}

#pragma mark -- @property getter

- (CGFloat)viewHeight{
    [self layoutIfNeeded];
    if(self.showDescView){
        return self.titleHeight + LabelHeight + VeritSpace + self.descViewHeight + ButtonWH + 2 * kkPaddingNormal;
    }else{
        return self.titleHeight + LabelHeight + VeritSpace + ButtonWH + 2 * kkPaddingNormal;
    }
    return 0;
}

- (UILabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor blackColor];
            view.textAlignment = NSTextAlignmentLeft;
            view.numberOfLines = 0 ;
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view.font = [UIFont systemFontOfSize:18];
            view;
        });
    }
    return _titleLabel;
}

- (UILabel *)playCountLabel{
    if(!_playCountLabel){
        _playCountLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor grayColor];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByCharWrapping;
            view.font = [UIFont systemFontOfSize:13];
            view;
        });
    }
    return _playCountLabel;
}

- (UILabel *)showMoreLabel{
    if(!_showMoreLabel){
        _showMoreLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor blackColor];
            view.text = @"▼";
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByCharWrapping;
            view.font = [UIFont systemFontOfSize:17];
            view;
        });
    }
    return _showMoreLabel;
}

- (UILabel *)showMoreMask{
    if(!_showMoreMask){
        _showMoreMask = ({
            UILabel *view = [UILabel new];
            view.userInteractionEnabled = YES ;
            
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                self.showDescView = !self.showDescView;
                CGAffineTransform transform = CGAffineTransformRotate(self.showMoreLabel.transform,M_PI);
                [UIView beginAnimations:@"rotate" context:nil ];
                [UIView setAnimationDuration:0.2];
                [UIView setAnimationDelegate:self];
                [self.showMoreLabel setTransform:transform];
                [UIView commitAnimations];
            }];
            view;
        });
    }
    return _showMoreMask;
}

- (UIView *)descView{
    if(!_descView){
        _descView = ({
            UIView *view = [UIView new];
            view.layer.masksToBounds = YES ;
            view ;
        });
    }
    return _descView;
}

- (UILabel *)descLabel{
    if(!_descLabel){
        _descLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor grayColor];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByCharWrapping;
            view.font = [UIFont systemFontOfSize:14];
            view.numberOfLines = 0 ;
            view;
        });
    }
    return _descLabel;
}

- (UILabel *)publicTimeLabel{
    if(!_publicTimeLabel){
        _publicTimeLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor grayColor];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByCharWrapping;
            view.font = [UIFont systemFontOfSize:14];
            view;
        });
    }
    return _publicTimeLabel;
}

- (KKButton *)diggBtn{
    if(!_diggBtn){
        _diggBtn = ({
            KKButton *view = [KKButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"comment_like_icon_night_16x16_"] forState:UIControlStateNormal];
            [view setImage:[UIImage imageNamed:@"comment_like_icon_press_16x16_"] forState:UIControlStateSelected];
            [view.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [view setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [view setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            [view setTitle:@"点赞" forState:UIControlStateNormal];
            [view.titleLabel setTextAlignment:NSTextAlignmentLeft];
            view ;
        });
    }
    return _diggBtn;
}

- (KKButton *)disDiggBtn{
    if(!_disDiggBtn){
        _disDiggBtn = ({
            KKButton *view = [KKButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"digdown_video_night_20x20_"] forState:UIControlStateNormal];
            [view setImage:[UIImage imageNamed:@"digdown_video_press_20x20_"] forState:UIControlStateSelected];
            [view.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [view setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [view setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
            [view setTitle:@"踩" forState:UIControlStateNormal];
            [view.titleLabel setTextAlignment:NSTextAlignmentLeft];
            view ;
        });
    }
    return _disDiggBtn;
}

- (UILabel *)shareToLabel{
    if(!_shareToLabel){
        _shareToLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor blackColor];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByCharWrapping;
            view.text = @"分享到";
            view.font = [UIFont systemFontOfSize:13];
            view;
        });
    }
    return _shareToLabel;
}

- (UIButton *)wxBtn{
    if(!_wxBtn){
        _wxBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"weixinicon_invite_26x26_"] forState:UIControlStateNormal];
            view ;
        });
    }
    return _wxBtn;
}

- (UIButton *)wxTimeBtn{
    if(!_wxTimeBtn){
        _wxTimeBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"weixinicon_invite_26x26_"] forState:UIControlStateNormal];
            view ;
        });
    }
    return _wxTimeBtn;
}

- (UIView *)splitViewBottom{
    if(!_splitViewBottom){
        _splitViewBottom = ({
            UIView *view = [UIView new];
            view.backgroundColor = KKColor(244, 245, 246, 1.0);;
            view ;
        });
    }
    return _splitViewBottom;
}

@end
