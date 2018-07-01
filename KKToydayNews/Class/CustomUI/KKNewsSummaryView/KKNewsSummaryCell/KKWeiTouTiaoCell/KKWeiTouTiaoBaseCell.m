//
//  KKWeiTouTiaoBaseCell.m
//  KKToydayNews
//
//  Created by finger on 2018/4/15.
//  Copyright © 2018年 finger. All rights reserved.
//

#import "KKWeiTouTiaoBaseCell.h"

@interface KKWeiTouTiaoBaseCell()
@property(nonatomic,readwrite)UIView *bgView ;
@property(nonatomic,readwrite)KKWeiTouTiaoHeadView *header ;
@property(nonatomic,readwrite)KKWeiTouTiaoBarView *barView ;
@property(nonatomic,readwrite)TYAttributedLabel *contentTextView;
@property(nonatomic,readwrite)UILabel *posAndReadCountLabel;
@property(nonatomic,readwrite)UIImageView *positionView ;
@end

@implementation KKWeiTouTiaoBaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

+ (CGFloat)fetchHeightWithItem:(KKSummaryContent *)item {
    return 0 ;
}

- (void)refreshWithItem:(KKSummaryContent *)item {
    
}
//重置cell中图片的隐藏，index == -1 ，设置全部，否则设置对应索引的图片
- (void)resetImageViewHidden:(BOOL)hidden index:(NSInteger)index{
    
}

//获取对应索引的的CGRect
- (CGRect)fetchImageFrameWithIndex:(NSInteger)index{
    return CGRectZero;
}

//获取对应索引的的UIImage
- (UIImage *)fetchImageWithIndex:(NSInteger)index{
    return nil;
}

#pragma mark -- @property

- (UIView *)bgView{
    if(!_bgView){
        _bgView = ({
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor whiteColor];
            view ;
        });
    }
    return _bgView;
}

- (KKWeiTouTiaoHeadView *)header{
    if(!_header){
        _header = ({
            KKWeiTouTiaoHeadView *view = [KKWeiTouTiaoHeadView new];
            view.delegate = self ;
            view ;
        });
    }
    return _header;
}

- (KKWeiTouTiaoBarView *)barView{
    if(!_barView){
        _barView = ({
            KKWeiTouTiaoBarView *view = [KKWeiTouTiaoBarView new];
            view.delegate = self ;
            view.borderType = KKBorderTypeTop;
            view.borderColor = [[UIColor grayColor]colorWithAlphaComponent:0.3];
            view.borderThickness = 0.5 ;
            view;
        });
    }
    return _barView;
}

- (TYAttributedLabel *)contentTextView{
    if(!_contentTextView){
        _contentTextView = ({
            TYAttributedLabel *view = [TYAttributedLabel new];
            view.textColor = [UIColor blackColor];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view.numberOfLines = 0 ;
            view.font = contentTextFont;
            view ;
        });
    }
    return _contentTextView;
}

- (UIImageView *)positionView{
    if(!_positionView){
        _positionView = ({
            UIImageView *view = [UIImageView new];
            view.image = [UIImage imageNamed:@"pgc_discover_28x28_"];
            view ;
        });
    }
    return _positionView ;
}

- (UILabel *)posAndReadCountLabel{
    if(!_posAndReadCountLabel){
        _posAndReadCountLabel = ({
            UILabel *view = [UILabel new];
            [view setTextColor:[UIColor grayColor]];
            [view setTextAlignment:NSTextAlignmentLeft];
            [view setFont:[UIFont systemFontOfSize:11]];
            view ;
        });
    }
    return _posAndReadCountLabel;
}

@end
