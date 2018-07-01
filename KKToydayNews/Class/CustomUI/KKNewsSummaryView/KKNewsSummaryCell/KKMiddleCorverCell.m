//
//  KKMiddleCorverCell.m
//  KKToydayNews
//
//  Created by finger on 2017/9/17.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKMiddleCorverCell.h"

#define space 5.0
#define imageWidth ((([UIScreen mainScreen].bounds.size.width - 2 * kkPaddingNormal) - 2 * space) / 3.0)
#define KKTitleWidth ([UIScreen mainScreen].bounds.size.width - 3 * kkPaddingNormal - imageWidth)
#define LineSpace 3

@interface KKMiddleCorverCell ()
@property(nonatomic,strong)UIImageView *smallImgView ;
@end

@implementation KKMiddleCorverCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.selectionStyle = UITableViewCellSelectionStyleNone ;
        [self awakeFromNib];
    }
    return self;
}

- (void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self.contentView addSubview:self.bgView];
    [self.bgView addSubview:self.titleLabel];
    [self.bgView addSubview:self.smallImgView];
    [self.bgView addSubview:self.newsTipBtn];
    [self.bgView addSubview:self.leftBtn];
    [self.bgView addSubview:self.descLabel];
    [self.bgView addSubview:self.shieldBtn];
    [self.bgView addSubview:self.splitView];
    
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.smallImgView).mas_offset(-descLabelHeight/2.0);
        make.left.mas_equalTo(self.bgView).mas_offset(kkPaddingNormal);
        make.width.mas_equalTo(KKTitleWidth);
        make.height.mas_equalTo(0);
    }];
    
    [self.smallImgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView).mas_offset(kkPaddingLarge);
        make.right.mas_equalTo(self.bgView).mas_offset(-kkPaddingNormal);
        make.width.mas_equalTo(imageWidth);
        make.height.mas_equalTo(3 * KKTitleFont.lineHeight + 4 * LineSpace);
    }];
    
    [self.shieldBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.smallImgView).mas_offset(-space-imageWidth);
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.width.mas_equalTo(descLabelHeight);
        make.height.mas_equalTo(descLabelHeight);
    }];
    
    [self.leftBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.centerY.mas_equalTo(self.shieldBtn);
        make.width.mas_offset(leftBtnSize.width);
        make.height.mas_equalTo(leftBtnSize.height);
    }];
    
    [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftBtn.mas_right).mas_offset(space);
        make.centerY.mas_equalTo(self.shieldBtn);
        make.right.mas_lessThanOrEqualTo(self.shieldBtn.mas_left).mas_offset(-kkPaddingNormal);
        make.height.mas_equalTo(descLabelHeight);
    }];
    
    self.newsTipBtn.layer.cornerRadius = newsTipBtnHeight/2.0 ;
    [self.newsTipBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.smallImgView).mas_offset(-space);
        make.bottom.mas_equalTo(self.smallImgView).mas_offset(-space);
        make.width.mas_equalTo(35);
        make.height.mas_equalTo(newsTipBtnHeight);
    }];
    
    [self.splitView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.bottom.mas_equalTo(self.bgView);
        make.width.mas_equalTo(self.bgView).mas_offset(-2 * kkPaddingNormal);
        make.height.mas_equalTo(1.0);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark -- 界面刷新

- (void)refreshWithItem:(KKSummaryContent *)item{
    self.item = item ;
    
    [KKMiddleCorverCell initAttriTextData:item];
    
    NSString *url = item.middle_image.url;
    if(!url.length){
        url = @"";
    }
    @weakify(self);
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache queryCacheOperationForKey:url done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
        @strongify(self);
        if(image){
            [self.smallImgView setImage:image];
        }else{
            [self.smallImgView kk_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageWithColor:[UIColor grayColor]] animate:YES];
        }
    }];
    
    NSString *publishTime = [NSString stringIntervalSince1970RuleOne:item.publish_time.longLongValue];
    NSString *commentCnt = [[NSNumber numberWithLong:item.comment_count.longLongValue]convert];
    self.descLabel.text = [NSString stringWithFormat:@"%@  %@评论  %@",item.source,commentCnt,publishTime];
    
    CGFloat titleHeight = item.textContainer.attriTextHeight;
    self.titleLabel.textContainer = item.textContainer;
    
    if(titleHeight >= 3 * KKTitleFont.lineHeight + 3 * item.textContainer.linesSpacing){
        
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.smallImgView).mas_offset(0);
            make.height.mas_equalTo(3 * KKTitleFont.lineHeight + 3 * item.textContainer.linesSpacing);
        }];
        
        [self.shieldBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.smallImgView).mas_offset(0);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(5);
        }];
        
    }else{
        
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.smallImgView).mas_offset(-descLabelHeight/2.0-3);
            make.height.mas_equalTo(titleHeight);
        }];
        
        [self.shieldBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.smallImgView).mas_offset(-space-imageWidth);
            make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(3);
        }];
    }
    
    self.newsTipBtn.hidden = YES ;
    if([item.has_video boolValue]||
       [item.has_mp4_video boolValue]||
       [item.has_m3u8_video boolValue]){
        NSString *duration = [NSString getHHMMSSFromSS:item.video_duration];
        self.newsTipBtn.hidden = NO  ;
        [self.bgView bringSubviewToFront:self.newsTipBtn];
        [self.newsTipBtn setTitle:[NSString stringWithFormat:@"%@",duration] forState:UIControlStateNormal];
        
        NSInteger newsTipWidth = [self fetchNewsTipWidth];
        [self.newsTipBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(newsTipWidth + 15) ;
        }];
    }else{
        BOOL gallaryStyle = [item.gallary_style boolValue] ;
        self.newsTipBtn.hidden = !gallaryStyle;
        if(gallaryStyle){
            NSInteger picCnt = [item.gallary_image_count integerValue];
            [self.bgView bringSubviewToFront:self.newsTipBtn];
            [self.newsTipBtn setTitle:[NSString stringWithFormat:@"%ld图",picCnt] forState:UIControlStateNormal];
            
            NSInteger newsTipWidth = [self fetchNewsTipWidth];
            [self.newsTipBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(newsTipWidth + 15) ;
            }];
        }
    }
    
    NSInteger width = 0 ;
    BOOL isAd = item.ad_id.length;
    if(isAd){
        [self.leftBtn setTitle:@"广告" forState:UIControlStateNormal];
        [self.leftBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.leftBtn.layer setBorderColor:[UIColor blueColor].CGColor];
        width = leftBtnSize.width ;
    }else{
        BOOL isHot = [item.hot boolValue];
        if(isHot){
            [self.leftBtn setTitle:@"热门" forState:UIControlStateNormal];
            [self.leftBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
            [self.leftBtn.layer setBorderColor:[UIColor redColor].CGColor];
            width = leftBtnSize.width ;
        }
    }
    [self.leftBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
    }];
    [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftBtn.mas_right).mas_offset(width > 0 ? space : 0);
    }];
}

+ (CGFloat)fetchHeightWithItem:(KKSummaryContent *)item{
    [KKMiddleCorverCell initAttriTextData:item];
    
    if(item.itemCellHeight <= 0){
        if(item.textContainer.attriTextHeight >= 3 * KKTitleFont.lineHeight + 3 * item.textContainer.linesSpacing){
            item.itemCellHeight = 2 * kkPaddingLarge + 3 * KKTitleFont.lineHeight + 3 * item.textContainer.linesSpacing + descLabelHeight + 5;
        }else{
            item.itemCellHeight = 2 * kkPaddingLarge + 3 * KKTitleFont.lineHeight + 4 * item.textContainer.linesSpacing + 5 ;
        }
    }
    return item.itemCellHeight;
}

#pragma mark -- 初始化标题富文本

+ (void)initAttriTextData:(KKSummaryContent *)content{
    if(content.textContainer == nil ){
        TYTextContainer *item = [TYTextContainer new];
        item.linesSpacing = LineSpace ;
        item.textColor = [UIColor kkColorBlack];
        item.lineBreakMode = NSLineBreakByTruncatingTail;
        item.text = content.title;
        item.font = KKTitleFont ;
        item.numberOfLines = 3;
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
            view.layer.borderWidth = 0.5;
            view.layer.borderColor = [[UIColor grayColor]colorWithAlphaComponent:0.1].CGColor;
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
