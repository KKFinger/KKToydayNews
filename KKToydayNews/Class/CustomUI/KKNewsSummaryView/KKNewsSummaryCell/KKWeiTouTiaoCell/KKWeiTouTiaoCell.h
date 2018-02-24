//
//  KKWeiTouTiaoCell.h
//  KKToydayNews
//
//  Created by finger on 2017/9/18.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKSummaryDataModel.h"

@protocol KKWeiTouTiaoCellDelegate<KKCommonDelegate>
- (void)showWTTDetailView:(KKSummaryContent *)item;
@end

@interface KKWeiTouTiaoCell : UITableViewCell
@property(nonatomic,weak)id<KKWeiTouTiaoCellDelegate>delegate;
@property(nonatomic,weak)NSIndexPath *indexPath;
@property(nonatomic,readonly)UIView *bgView ;
+ (CGFloat)fetchHeightWithItem:(KKSummaryContent *)item ;
- (void)refreshWithItem:(KKSummaryContent *)item ;
//重置cell中图片的隐藏，index == -1 ，设置全部，否则设置对应索引的图片
- (void)resetImageViewHidden:(BOOL)hidden index:(NSInteger)index;
//获取对应索引的的CGRect
- (CGRect)fetchImageFrameWithIndex:(NSInteger)index ;
//获取对应索引的的UIImage
- (UIImage *)fetchImageWithIndex:(NSInteger)index ;
@end
