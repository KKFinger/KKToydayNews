//
//  KKSectionCollectionCell.m
//  KKToydayNews
//
//  Created by finger on 2017/8/7.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKSectionCollectionCell.h"

@interface KKSectionCollectionCell()

@end

@implementation KKSectionCollectionCell

+ (CGSize)titleSize:(KKSectionItem *)item{
    if(CGSizeEqualToSize(item.titleSize, CGSizeZero)){
        CGSize size = [item.name boundingRectWithSize:CGSizeMake(MAXFLOAT, 30) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[KKSectionCollectionCell selectedFontSize]]} context:nil].size;
        item.titleSize = CGSizeMake(size.width + 20, 30) ;
    }
    
    return item.titleSize ;
}

+ (CGFloat)normalFontSize{
    return 16.0;
}

+ (CGFloat)selectedFontSize{
    return 18.0;
}

+ (UIColor *)normalColor{
    return [UIColor blackColor];
}

+ (UIColor *)selectedColor{
    return [UIColor redColor];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setUserInterface];
    }
    return self;
}

- (void)setUserInterface{
    [self.contentView addSubview:self.titleLabel];
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
}

- (UILabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = ({
            UILabel *label = [[UILabel alloc]init];
            label.textAlignment = NSTextAlignmentCenter;
            label.textColor = [UIColor blackColor];
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.font = [UIFont systemFontOfSize:[KKSectionCollectionCell normalFontSize]];
            label;
        });
    }
    return _titleLabel ;
}

- (void)setItem:(KKSectionItem *)item{
    self.titleLabel.text = item.name;
    if(CGSizeEqualToSize(item.titleSize, CGSizeZero)){
        CGSize size = [item.name boundingRectWithSize:CGSizeMake(MAXFLOAT, 30) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[KKSectionCollectionCell selectedFontSize]]} context:nil].size;
        item.titleSize = CGSizeMake(size.width + 20, 30) ;
    }
}

- (void)setIsSelected:(BOOL)isSelected{
    if(isSelected){
        self.titleLabel.textColor = [KKSectionCollectionCell selectedColor];
        self.titleLabel.font = [UIFont systemFontOfSize:[KKSectionCollectionCell selectedFontSize]];
    }else{
        self.titleLabel.textColor = [KKSectionCollectionCell normalColor];
        self.titleLabel.font = [UIFont systemFontOfSize:[KKSectionCollectionCell normalFontSize]];
    }
}

@end
