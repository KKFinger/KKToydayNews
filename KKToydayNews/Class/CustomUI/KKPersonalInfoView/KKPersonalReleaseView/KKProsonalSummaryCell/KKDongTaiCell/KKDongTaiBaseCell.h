//
//  KKDongTaiBaseCell.h
//  KKToydayNews
//
//  Created by finger on 2017/11/29.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKDongTaiModel.h"

#define contentTextFont [UIFont systemFontOfSize:15]
#define detailFont [UIFont systemFontOfSize:11]
#define contentTextColor [UIColor blackColor]

@protocol KKDongTaiCellDelegate <KKCommonDelegate>
- (void)showMoreView;
- (void)clickImageWithItem:(KKDongTaiObject *)item rect:(CGRect)rect fromView:(UIView *)fromView image:(UIImage *)image indexPath:(NSIndexPath *)indexPath;
@end

@interface KKDongTaiBaseCell : UITableViewCell
@property(nonatomic,weak)id<KKDongTaiCellDelegate>delegate;
+ (CGFloat)fetchHeightWith:(KKDongTaiObject *)obj;
- (void)refreshWith:(KKDongTaiObject *)obj;
@end
