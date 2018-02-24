//
//  KKBadgeView.m
//  KKToydayNews
//
//  Created by finger on 2017/9/24.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKBadgeView.h"

@interface KKBadgeView ()
@property(nonatomic)UIImageView *imageView;
@property(nonatomic)UILabel *badgeLabel;
@end

@implementation KKBadgeView

- (instancetype)init{
    self = [super init];
    if(self){
        self.badgeBgColor = [UIColor redColor];
        self.badgeTextColor = [UIColor whiteColor];
        self.badgeFont = [UIFont systemFontOfSize:7];
        self.layer.masksToBounds = NO ;
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    [self addSubview:self.imageView];
    [self addSubview:self.badgeLabel];
    [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self);
        make.centerY.mas_equalTo(self);
        make.width.height.mas_equalTo(self);
    }];
    [self.badgeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.imageView.mas_centerX);
        make.top.mas_equalTo(self.imageView);
        make.height.mas_equalTo(self.badgeLabel.font.lineHeight);
    }];
}

- (void)setBadge:(NSInteger)badge{
    NSString *text = [[NSNumber numberWithInteger:badge]convert];
    self.badgeLabel.text = text;
    if(badge <= 0){
        self.badgeLabel.hidden = YES ;
    }else{
        self.badgeLabel.hidden = NO ;
    }
    
    NSDictionary *dic = @{NSFontAttributeName:self.badgeLabel.font};
    CGSize size = [text boundingRectWithSize:CGSizeMake(MAXFLOAT, self.badgeLabel.font.lineHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
    if(size.width < 10){
        size.width = 10 ;
    }
    [self.badgeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(size.width + 5);
    }];
}

- (void)setImage:(UIImage *)image{
    self.imageView.image = image;
}

- (void)setBadgeFont:(UIFont *)badgeFont{
    _badgeFont = badgeFont;
    self.badgeLabel.font = badgeFont;
    self.badgeLabel.layer.cornerRadius = self.badgeFont.lineHeight / 2.0 ;
}

- (void)setBadgeBgColor:(UIColor *)badgeBgColor{
    self.badgeLabel.backgroundColor = badgeBgColor;
}

- (void)setBadgeTextColor:(UIColor *)badgeTextColor{
    self.badgeLabel.textColor = badgeTextColor;
}

- (void)setShowBadge:(BOOL)showBadge{
    self.badgeLabel.hidden = showBadge;
}

- (UILabel *)badgeLabel{
    if(!_badgeLabel){
        _badgeLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = self.badgeTextColor;
            view.textAlignment = NSTextAlignmentCenter;
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view.font = self.badgeFont;
            view.layer.cornerRadius = self.badgeFont.lineHeight / 2.0 ;
            view.layer.masksToBounds = YES ;
            view.hidden = YES ;
            view ;
        });
    }
    return _badgeLabel;
}

- (UIImageView *)imageView{
    if(!_imageView){
        _imageView = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFit;
            view;
        });
    }
    return _imageView;
}

@end
