//
//  KKRelateVideoCell.m
//  KKToydayNews
//
//  Created by finger on 2017/9/17.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKRelateVideoCell.h"

#define space 5.0
#define imageWidth ((([UIScreen mainScreen].bounds.size.width - 2 * kkPaddingNormal) - 2 * space) / 3.0)
#define KKTitleWidth ([UIScreen mainScreen].bounds.size.width - 3 * kkPaddingNormal - imageWidth)

@interface KKRelateVideoCell ()
@property(nonatomic,strong)UIImageView *smallImgView ;
@end

@implementation KKRelateVideoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.selectionStyle = UITableViewCellSelectionStyleNone ;
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.titleLabel];
    [self.bgView addSubview:self.smallImgView];
    [self.bgView addSubview:self.newsTipBtn];
    [self.bgView addSubview:self.descLabel];
    
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.smallImgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView).mas_offset(kkPaddingLarge);
        make.right.mas_equalTo(self.bgView).mas_offset(-kkPaddingNormal);
        make.width.mas_equalTo(imageWidth);
        make.height.mas_equalTo(3 * KKTitleFont.lineHeight + 5);
    }];
    
    self.newsTipBtn.layer.cornerRadius = newsTipBtnHeight/2.0 ;
    [self.newsTipBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.smallImgView).mas_offset(-space);
        make.bottom.mas_equalTo(self.smallImgView).mas_offset(-space);
        make.width.mas_equalTo(35);
        make.height.mas_equalTo(newsTipBtnHeight);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark -- 界面刷新

- (void)refreshWithItem:(KKSummaryContent *)item{
    self.item = item ;
    
    [KKRelateVideoCell initAttriTextData:item];
    
    NSString *url = item.middle_image.url;
    if(!url.length){
        url = @"";
    }
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    UIImage *image = [imageCache imageFromCacheForKey:url] ;
    if(image){
        [self.smallImgView setImage:image];
    }else{
        @weakify(imageCache);
        [imageCache diskImageExistsWithKey:url completion:^(BOOL isInCache) {
            @strongify(imageCache);
            if(isInCache){
                [self.smallImgView setImage:[imageCache imageFromCacheForKey:url]];
            }else{
                [self.smallImgView kk_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageWithColor:[UIColor grayColor]] animate:YES];
            }
        }];
    }
    
    [self.smallImgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(3 * KKTitleFont.lineHeight + 3 * item.textContainer.linesSpacing);
    }];
    
    NSString *userName = item.user_info.name;
    NSString *playCount = [[NSNumber numberWithLong:item.video_detail_info.video_watch_count.longLongValue]convert];
    self.descLabel.text = [NSString stringWithFormat:@"%@  %@次播放",userName,playCount];
    
    self.titleLabel.textContainer = item.textContainer;
    
    CGFloat titleHeight = item.textContainer.attriTextHeight;
    if(titleHeight >= 2 * KKTitleFont.lineHeight + 2 * item.textContainer.linesSpacing){
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.smallImgView).mas_offset(space-5);
            make.left.mas_equalTo(self.bgView).mas_offset(kkPaddingNormal);
            make.width.mas_equalTo(KKTitleWidth);
            make.height.mas_equalTo(2 * KKTitleFont.lineHeight + 2 * item.textContainer.linesSpacing);
        }];
        [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.titleLabel);
            make.bottom.mas_equalTo(self.smallImgView);
            make.width.mas_equalTo(self.titleLabel);
            make.height.mas_equalTo(descLabelHeight);
        }];
    }else{
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.smallImgView).mas_offset(-space);
            make.left.mas_equalTo(self.bgView).mas_offset(kkPaddingNormal);
            make.width.mas_equalTo(KKTitleWidth);
            make.height.mas_equalTo(titleHeight);
        }];
        
        [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.titleLabel);
            make.top.mas_equalTo(self.titleLabel.mas_bottom);
            make.width.mas_equalTo(self.titleLabel);
            make.height.mas_equalTo(descLabelHeight);
        }];
    }
    
    NSString *duration = [NSString getHHMMSSFromSS:item.video_duration];
    self.newsTipBtn.hidden = NO  ;
    [self.bgView bringSubviewToFront:self.newsTipBtn];
    [self.newsTipBtn setTitle:[NSString stringWithFormat:@"%@",duration] forState:UIControlStateNormal];
    
    NSInteger newsTipWidth = [self fetchNewsTipWidth];
    [self.newsTipBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(newsTipWidth + 15) ;
    }];
}

+ (CGFloat)fetchHeightWithItem:(KKSummaryContent *)item{
    [KKRelateVideoCell initAttriTextData:item];
    return 2 * kkPaddingLarge + 3 * KKTitleFont.lineHeight + 3 * item.textContainer.linesSpacing;
}

#pragma mark -- 初始化标题文本

+ (void)initAttriTextData:(KKSummaryContent *)content{
    if(content.textContainer == nil ){
        TYTextContainer *item = [TYTextContainer new];
        item.linesSpacing = 2 ;
        item.textColor = [UIColor kkColorBlack];
        item.lineBreakMode = NSLineBreakByTruncatingTail;
        item.text = content.title;
        item.font = KKTitleFont ;
        item.numberOfLines = 2;
        content.textContainer = [item createTextContainerWithTextWidth:KKTitleWidth];
    }
}

#pragma mark -- @property

- (UIImageView *)smallImgView{
    if(!_smallImgView){
        _smallImgView = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFill ;
            view.layer.masksToBounds = YES ;
            view.userInteractionEnabled = YES ;
            @weakify(view);
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(view);
                @strongify(self);
                if(self.delegate && [self.delegate respondsToSelector:@selector(clickImageWithItem:rect:fromView:image:indexPath:)]){
                    [self.delegate clickImageWithItem:self.item rect:view.frame fromView:self.bgView image:view.image indexPath:nil];
                }
            }];
            view ;
        });
    }
    return _smallImgView;
}

@end
