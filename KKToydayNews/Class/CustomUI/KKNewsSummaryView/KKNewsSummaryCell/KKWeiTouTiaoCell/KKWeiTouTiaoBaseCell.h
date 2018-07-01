//
//  KKWeiTouTiaoBaseCell.h
//  KKToydayNews
//
//  Created by finger on 2018/4/15.
//  Copyright © 2018年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKSummaryDataModel.h"
#import "KKWeiTouTiaoHeadView.h"
#import "KKWeiTouTiaoBarView.h"
#import "TYAttributedLabel.h"

#define maxImageCount 9 //最大的图片个数
#define perRowImages 3 //每行
#define HeadViewHeight 40
#define vInterval 10 //各个控件的垂直距离
#define BarViewHeight 35
#define space 5.0
#define imageWidthHeight ((([UIScreen mainScreen].bounds.size.width - 2 * kkPaddingNormal) - 2 * space) / perRowImages)
#define descLabelHeight 13

static UIFont *contentTextFont = nil ;

@protocol KKWeiTouTiaoCellDelegate<KKCommonDelegate>
- (void)showWTTDetailView:(KKSummaryContent *)item;
@end

@interface KKWeiTouTiaoBaseCell : UITableViewCell<KKCommonDelegate,KKWeiTouTiaoHeadViewDelegate>
@property(nonatomic,weak)id<KKWeiTouTiaoCellDelegate>delegate;
@property(nonatomic,weak)NSIndexPath *indexPath;
@property(nonatomic,readonly)UIView *bgView ;
@property(nonatomic,readonly)KKWeiTouTiaoHeadView *header ;
@property(nonatomic,readonly)KKWeiTouTiaoBarView *barView ;
@property(nonatomic,readonly)TYAttributedLabel *contentTextView;
@property(nonatomic,readonly)UILabel *posAndReadCountLabel;
@property(nonatomic,readonly)UIImageView *positionView ;
+ (CGFloat)fetchHeightWithItem:(KKSummaryContent *)item ;
- (void)refreshWithItem:(KKSummaryContent *)item ;
//重置cell中图片的隐藏，index == -1 ，设置全部，否则设置对应索引的图片
- (void)resetImageViewHidden:(BOOL)hidden index:(NSInteger)index;
//获取对应索引的的CGRect
- (CGRect)fetchImageFrameWithIndex:(NSInteger)index ;
//获取对应索引的的UIImage
- (UIImage *)fetchImageWithIndex:(NSInteger)index ;
@end
