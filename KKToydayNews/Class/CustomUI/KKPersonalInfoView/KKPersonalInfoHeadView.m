//
//  KKPersonalInfoHeadView.m
//  KKToydayNews
//
//  Created by finger on 2017/11/18.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKPersonalInfoHeadView.h"

static CGFloat userHeadWH = 60 ;
static CGFloat labelHeight = 18;
static CGFloat showAllLabelWidth = 30;
static CGFloat bgViewHeightOffset = 150;

@interface KKPersonalInfoHeadView()
@property(nonatomic)UIImageView *bgImageView;
@property(nonatomic,readwrite)UIImageView *userHeadView;
@property(nonatomic)UIButton *privateLatterBtn;
@property(nonatomic)UIButton *concernBtn;
@property(nonatomic)UILabel *userNameLabel;
@property(nonatomic)UIImageView *ttLogo;
@property(nonatomic)UILabel *verifiedLabel;
@property(nonatomic)UILabel *descLabel;
@property(nonatomic)UILabel *fansCernsLabel;
@property(nonatomic)UILabel *showAllDescLabel;
@property(nonatomic)CGFloat descTextHeight;
@end

@implementation KKPersonalInfoHeadView

- (instancetype)init{
    self = [super init];
    if(self){
        [self setupUI];
    }
    return self;
}

- (void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self addSubview:self.bgImageView];
    [self addSubview:self.userHeadView];
    [self addSubview:self.privateLatterBtn];
    [self addSubview:self.concernBtn];
    [self addSubview:self.userNameLabel];
    [self addSubview:self.ttLogo];
    [self addSubview:self.verifiedLabel];
    [self addSubview:self.descLabel];
    [self addSubview:self.showAllDescLabel];
    [self addSubview:self.fansCernsLabel];
    
    [self.bgImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.mas_equalTo(self).priority(998);
        make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-bgViewHeightOffset);
    }];
    
    [self.userHeadView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgImageView.mas_bottom);
        make.left.mas_equalTo(self).mas_offset(kkPaddingNormal).priority(998);
        make.size.mas_equalTo(CGSizeMake(userHeadWH, userHeadWH));
    }];
    
    [self.privateLatterBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.concernBtn.mas_left).mas_offset(-kkPaddingNormal);
        make.top.mas_equalTo(self.bgImageView.mas_bottom).mas_offset(5);
        make.height.mas_equalTo(30);
        
    }];
    
    [self.concernBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).mas_offset(-kkPaddingNormal);
        make.centerY.mas_equalTo(self.privateLatterBtn);
        make.size.mas_equalTo(CGSizeMake(50, 25));
    }];
    
    [self.userNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.userHeadView);
        make.top.mas_equalTo(self.userHeadView.mas_bottom).mas_offset(kkPaddingNormal);
        make.height.mas_equalTo(labelHeight);
    }];
    
    [self.ttLogo mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.userNameLabel.mas_right).mas_offset(kkPaddingNormal);
        make.centerY.mas_equalTo(self.userNameLabel);
    }];
    
    [self.verifiedLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.userNameLabel.mas_bottom).mas_offset(kkPaddingNormal);
        make.left.mas_equalTo(self.userNameLabel);
        make.right.mas_equalTo(self).mas_offset(-kkPaddingNormal);
        make.height.mas_equalTo(labelHeight);
    }];
    
    [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.verifiedLabel.mas_bottom).mas_offset(kkPaddingNormal);
        make.left.mas_equalTo(self.userNameLabel);
        make.right.mas_equalTo(self.showAllDescLabel.mas_left);
        make.height.mas_equalTo(labelHeight);
    }];
    
    [self.showAllDescLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.descLabel);
        make.right.mas_equalTo(self).mas_offset(-kkPaddingNormal);
        make.height.mas_equalTo(self.descLabel);
        make.width.mas_equalTo(0);
    }];
    
    [self.fansCernsLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.descLabel.mas_bottom).mas_offset(kkPaddingNormal);
        make.left.mas_equalTo(self.userNameLabel);
        make.height.mas_equalTo(labelHeight);
    }];
    
    [self layoutIfNeeded];
}

#pragma mark -- 发私信

- (void)sendPrivateMsg{
    
}

#pragma mark -- 关注/取消关注

- (void)concernBtnClicked{
    
}

#pragma mark -- @property setter

- (void)setHeadUrl:(NSString *)headUrl{
    if(!headUrl){
        headUrl = @"";
    }
    [self.userHeadView sd_setImageWithURL:[NSURL URLWithString:headUrl] placeholderImage:[UIImage imageNamed:@"head_default"]];
}

- (void)setUserName:(NSString *)userName{
    self.userNameLabel.text = userName;
}

- (void)setVerified:(NSString *)verified{
    if(verified.length){
        NSString *str = [NSString stringWithFormat:@"头条认证:  %@",verified];
        
        NSRange range = [str rangeOfString:verified];
        
        NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc]initWithString:str];
        
        [attriStr addAttribute:NSForegroundColorAttributeName value:self.verifiedLabel.textColor range:range];
        
        [attriStr addAttribute:NSFontAttributeName value:self.verifiedLabel.font range:range];
        
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        paraStyle.alignment = NSTextAlignmentLeft;
        [attriStr addAttribute:NSParagraphStyleAttributeName value:paraStyle range:NSMakeRange(0, str.length)];
        
        range = [str rangeOfString:@"头条认证:"];
        [attriStr addAttribute:NSForegroundColorAttributeName value:KKColor(245, 203, 0, 1) range:range];
        
        self.verifiedLabel.attributedText = attriStr;
        
    }else{
        self.verifiedLabel.hidden = YES ;
        [self.verifiedLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.verifiedLabel.mas_bottom).mas_offset(0);
        }];
        
        CGFloat heightOffset = self.height - self.bgImageView.height ;
        [self.bgImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self).mas_offset(-heightOffset + labelHeight + kkPaddingNormal);
        }];
        if(self.heightOffsetBlock){
            self.heightOffsetBlock(-labelHeight-kkPaddingNormal);
        }
    }
}

- (void)setDesc:(NSString *)desc{
    if(!desc.length){
        desc = @"这个人很懒，什么都没有留下";
    }
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.alignment = NSTextAlignmentLeft;
    
    NSDictionary *dic = @{NSFontAttributeName:self.descLabel.font,NSParagraphStyleAttributeName:paraStyle};
    CGSize size = [desc boundingRectWithSize:CGSizeMake(UIDeviceScreenWidth - 2 * kkPaddingNormal, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    
    self.descLabel.text = desc ;
    if(size.height > self.descLabel.font.lineHeight){
        self.showAllDescLabel.hidden = NO ;
        [self.showAllDescLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(showAllLabelWidth);
        }];
        self.descLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.descTextHeight = size.height + 3 ;
    }else{
        self.showAllDescLabel.hidden = YES ;
        [self.showAllDescLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
        self.descTextHeight = labelHeight;
        self.descLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
}

- (void)setFans:(NSString *)fans follows:(NSString *)follows{
    NSString *fanStr = [[NSNumber numberWithLongLong:fans.longLongValue]convert];
    NSString *followsStr = [[NSNumber numberWithLongLong:follows.longLongValue]convert];
    NSString *str = [NSString stringWithFormat:@"%@ 关注    %@ 粉丝",fanStr,followsStr];
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc]initWithString:str];
    
    NSRange range = NSMakeRange(0, str.length);
    [attriStr addAttribute:NSForegroundColorAttributeName value:self.fansCernsLabel.textColor range:range];
    [attriStr addAttribute:NSFontAttributeName value:self.fansCernsLabel.font range:range];
    
    range = [str rangeOfString:fanStr];
    [attriStr addAttribute:NSForegroundColorAttributeName value:KKColor(0, 78, 148, 1) range:range];
    [attriStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16 weight:0.3] range:range];
    
    range = [str rangeOfString:followsStr];
    [attriStr addAttribute:NSForegroundColorAttributeName value:KKColor(0, 78, 148, 1) range:range];
    [attriStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16 weight:0.3] range:range];
    
    self.fansCernsLabel.attributedText = attriStr;
}

#pragma mark -- @property getter

- (UIImageView *)bgImageView{
    if(!_bgImageView){
        _bgImageView = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFill;
            view.image = [UIImage imageNamed:@"wallpaper_profile_night"];
            view.layer.masksToBounds = YES ;
            view ;
        });
    }
    return _bgImageView;
}

- (UIImageView *)userHeadView{
    if(!_userHeadView){
        _userHeadView = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFill;
            view.image = [UIImage imageNamed:@"head_default"];
            view.layer.masksToBounds = YES ;
            view.layer.cornerRadius = userHeadWH / 2.0 ;
            view ;
        });
    }
    return _userHeadView;
}

- (UIButton *)privateLatterBtn{
    if(!_privateLatterBtn){
        _privateLatterBtn = ({
            UIButton *view = [UIButton new];
            [view.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [view setTitleColor:KKColor(0, 78, 148, 1) forState:UIControlStateNormal];
            [view setBackgroundColor:[UIColor clearColor]];
            [view setTitle:@"发私信" forState:UIControlStateNormal];
            [view addTarget:self action:@selector(sendPrivateMsg) forControlEvents:UIControlEventTouchUpInside];
            view ;
        });
    }
    return _privateLatterBtn;
}

- (UIButton *)concernBtn{
    if(!_concernBtn){
        _concernBtn = ({
            UIButton *view = [UIButton new];
            [view.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [view setBackgroundColor:KKColor(249, 61, 71, 1)];
            [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [view setTitle:@"关注" forState:UIControlStateNormal];
            [view addTarget:self action:@selector(concernBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [view.layer setCornerRadius:5];
            [view.layer setMasksToBounds:YES];
            view ;
        });
    }
    return _concernBtn;
}

- (UILabel *)userNameLabel{
    if(!_userNameLabel){
        _userNameLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor blackColor];
            view.font = [UIFont systemFontOfSize:17 weight:0.3];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByClipping;
            view ;
        });
    }
    return _userNameLabel;
}

- (UIImageView *)ttLogo{
    if(!_ttLogo){
        _ttLogo = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFill;
            view.image = [UIImage imageNamed:@"toutiaohao_34x14_"];
            view ;
        });
    }
    return _ttLogo;
}

- (UILabel *)verifiedLabel{
    if(!_verifiedLabel){
        _verifiedLabel = ({
            UILabel *view = [UILabel new];
            view.font = [UIFont systemFontOfSize:13];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByClipping;
            view ;
        });
    }
    return _verifiedLabel;
}

- (UILabel *)descLabel{
    if(!_descLabel){
        _descLabel = ({
            UILabel *view = [UILabel new];
            view.font = [UIFont systemFontOfSize:13];
            view.textColor = [UIColor blackColor];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByWordWrapping;
            view.numberOfLines = 0 ;
            view ;
        });
    }
    return _descLabel;
}

- (UILabel *)fansCernsLabel{
    if(!_fansCernsLabel){
        _fansCernsLabel = ({
            UILabel *view = [UILabel new];
            view.font = [UIFont systemFontOfSize:13];
            view.textColor = [[UIColor grayColor]colorWithAlphaComponent:0.5];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByWordWrapping;
            view ;
        });
    }
    return _fansCernsLabel;
}

- (UILabel *)showAllDescLabel{
    if(!_showAllDescLabel){
        _showAllDescLabel = ({
            UILabel *view = [UILabel new];
            view.font = [UIFont systemFontOfSize:13];
            view.textColor = KKColor(0, 78, 148, 1);
            view.text = @"展开";
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByWordWrapping;
            view.hidden = YES ;
            view.layer.masksToBounds = YES ;
            view.userInteractionEnabled = YES ;
            
            @weakify(self);
            @weakify(view);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                @strongify(view);
                [view mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(0);
                }];
                
                CGFloat heightOffset = self.descTextHeight - self.descLabel.height  ;
                
                [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.height.mas_equalTo(self.descTextHeight);
                }];
                self.descLabel.lineBreakMode = NSLineBreakByWordWrapping;
                
                CGFloat bgViewheightOffset = self.height - self.bgImageView.height ;
                [self.bgImageView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.bottom.mas_equalTo(self).mas_offset(-bgViewheightOffset - heightOffset);
                }];
                
                if(self.heightOffsetBlock){
                    self.heightOffsetBlock(heightOffset);
                }
                
                view.hidden = YES ;
            }];
            
            view ;
        });
    }
    return _showAllDescLabel;
}

@end
