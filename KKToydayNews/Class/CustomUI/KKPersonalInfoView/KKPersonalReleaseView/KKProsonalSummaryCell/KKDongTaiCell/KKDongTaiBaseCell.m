//
//  KKDongTaiBaseCell.m
//  KKToydayNews
//
//  Created by finger on 2017/11/29.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKDongTaiBaseCell.h"

@implementation KKDongTaiBaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

+ (CGFloat)fetchHeightWith:(KKDongTaiObject *)obj{
    return 0 ;
}

- (void)refreshWith:(KKDongTaiObject *)obj{
    
}

@end
