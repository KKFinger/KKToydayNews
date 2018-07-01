//
//  KKNewsCommonCell.m
//  KKToydayNews
//
//  Created by finger on 2017/9/17.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKNewsCommonCell.h"

@implementation KKNewsCommonCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

+ (CGFloat)fetchHeightWithItem:(KKSummaryContent *)item{
    return 0 ;
}

- (void)refreshWithItem:(KKSummaryContent *)item{
    
}

#pragma mark -- 按钮点击

- (void)shieldBtnClicked{
    if(self.delegate && [self.delegate respondsToSelector:@selector(shieldBtnClicked:)]){
        [self.delegate shieldBtnClicked:self.item];
    }
}

#pragma mark -- 计算视频时间字符、图片个数字符等宽度

- (CGFloat)fetchNewsTipWidth{
    if(self.item.newsTipWidth <= 0 ){
        NSDictionary *dic = @{NSFontAttributeName:self.newsTipBtn.titleLabel.font};
        CGSize size = [self.newsTipBtn.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, newsTipBtnHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
        self.item.newsTipWidth = size.width;
    }
    return self.item.newsTipWidth;
}

#pragma mark -- @property

- (UIView *)bgView{
    if(!_bgView){
        _bgView = ({
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor clearColor];
            view ;
        });
    }
    return _bgView;
}

- (TYAttributedLabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = ({
            TYAttributedLabel *view = [TYAttributedLabel new];
            view.textColor = [UIColor kkColorBlack];
            view.font = KKTitleFont;
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view.numberOfLines = 0 ;
            view.backgroundColor = [UIColor clearColor];
            view ;
        });
    }
    return _titleLabel;
}

- (UIButton *)leftBtn{
    if(!_leftBtn){
        _leftBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            view.titleLabel.font = [UIFont systemFontOfSize:7];
            view.layer.borderWidth = 0.3;
            view.layer.cornerRadius = 2 ;
            view.layer.masksToBounds = YES ;
            view ;
        });
    }
    return _leftBtn;
}

- (UILabel *)descLabel{
    if(!_descLabel){
        _descLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor kkColorLightgray];
            view.font = KKDescFont;
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view.backgroundColor = [UIColor clearColor];
            view.textAlignment = NSTextAlignmentLeft;
            view ;
        });
    }
    return _descLabel;
}

- (UIButton *)shieldBtn{
    if(!_shieldBtn){
        _shieldBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"shield"] forState:UIControlStateNormal];
            [view addTarget:self action:@selector(shieldBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            view ;
        });
    }
    return _shieldBtn;
}

- (UIButton *)newsTipBtn{
    if(!_newsTipBtn){
        _newsTipBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
            btn.titleLabel.font = KKDescFont ;
            btn.layer.masksToBounds = YES ;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn ;
        });
    }
    return _newsTipBtn;
}

- (UIButton *)playVideoBtn{
    if(!_playVideoBtn){
        _playVideoBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"video_play_icon_44x44_"] forState:UIControlStateNormal];
            [view setUserInteractionEnabled:NO];
            view ;
        });
    }
    return _playVideoBtn;
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

@end
