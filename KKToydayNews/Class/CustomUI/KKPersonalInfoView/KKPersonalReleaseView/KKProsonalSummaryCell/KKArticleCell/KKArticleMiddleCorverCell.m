//
//  KKArticleMiddleCorverCell.m
//  KKToydayNews
//
//  Created by finger on 2017/9/17.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKArticleMiddleCorverCell.h"

#define space 5.0
#define imageWidth ((([UIScreen mainScreen].bounds.size.width - 2 * kkPaddingNormal) - 2 * space) / 3.0)
#define KKTitleWidth ([UIScreen mainScreen].bounds.size.width - 3 * kkPaddingNormal - imageWidth)
#define splitViewHeight 5

@interface KKArticleMiddleCorverCell ()
@property(nonatomic,strong)UIImageView *smallImgView ;
@property(nonatomic,strong)UILabel *dateLabel;
@property(nonatomic,weak)KKPersonalSummary *summary;
@end

@implementation KKArticleMiddleCorverCell

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
    [self.bgView addSubview:self.dateLabel];
    
    [self.bgView addSubview:self.splitView];
    
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.smallImgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView).mas_offset(kkPaddingLarge);
        make.right.mas_equalTo(self.bgView).mas_offset(-kkPaddingNormal);
        make.width.mas_equalTo(imageWidth);
    }];
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.smallImgView).mas_offset(-descLabelHeight/2.0);
        make.left.mas_equalTo(self.bgView).mas_offset(kkPaddingNormal);
        make.width.mas_equalTo(KKTitleWidth);
        make.height.mas_equalTo(0);
    }];
    
    [self.descLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_lessThanOrEqualTo(self.titleLabel);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(3);
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
        make.left.mas_equalTo(self.bgView);
        make.bottom.mas_equalTo(self.bgView);
        make.width.mas_equalTo(self.bgView);
        make.height.mas_equalTo(splitViewHeight);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark -- 界面刷新

- (void)refreshWithSummary:(KKPersonalSummary *)summary{
    self.summary = summary ;
    
    [KKArticleMiddleCorverCell initAttriTextData:summary];
    
    NSString *url = summary.image_list.firstObject.url;
    if(!url.length){
        url = @"";
    }
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache queryCacheOperationForKey:url done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
        if(image){
            [self.smallImgView setImage:image];
        }else{
            [self.smallImgView kk_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageWithColor:[UIColor grayColor]] animate:YES];
        }
    }];
    
    [self.smallImgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(2 * KKTitleFont.lineHeight + 2 * summary.textContainer.linesSpacing + descLabelHeight);
    }];
    
    self.dateLabel.text = summary.datetime;
    
    NSString *readCount = [[NSNumber numberWithLong:summary.total_read_count.longLongValue]convert];
    self.descLabel.text = [NSString stringWithFormat:@"%@ 阅读",readCount];
    
    CGFloat titleHeight = summary.textContainer.attriTextHeight;
    self.titleLabel.textContainer = summary.textContainer;
    
    if(titleHeight >= 2 * KKTitleFont.lineHeight + 2 * summary.textContainer.linesSpacing){
        
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(2 * KKTitleFont.lineHeight + 2 * summary.textContainer.linesSpacing);
        }];
        
    }else{
        
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(titleHeight);
        }];
    }
    
    self.newsTipBtn.hidden = YES ;
    if([summary.has_video boolValue]||
       [summary.has_mp4_video boolValue]||
       [summary.has_m3u8_video boolValue]){
        NSString *duration = [NSString getHHMMSSFromSS:summary.video_infos.firstObject.duration];
        self.newsTipBtn.hidden = NO  ;
        [self.bgView bringSubviewToFront:self.newsTipBtn];
        [self.newsTipBtn setTitle:[NSString stringWithFormat:@"%@",duration] forState:UIControlStateNormal];
        
        NSInteger newsTipWidth = [self fetchNewsTipWidth];
        [self.newsTipBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(newsTipWidth + 15) ;
        }];
    }else{
        BOOL gallaryStyle = [summary.has_gallery boolValue] ;
        self.newsTipBtn.hidden = !gallaryStyle;
        if(gallaryStyle){
            NSInteger picCnt = [summary.gallery_pic_count integerValue];
            [self.bgView bringSubviewToFront:self.newsTipBtn];
            [self.newsTipBtn setTitle:[NSString stringWithFormat:@"%ld图",picCnt] forState:UIControlStateNormal];
            
            NSInteger newsTipWidth = [self fetchNewsTipWidth];
            [self.newsTipBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(newsTipWidth + 15) ;
            }];
        }
    }
}

+ (CGFloat)fetchHeightWithSummary:(KKPersonalSummary *)summary{
    [KKArticleMiddleCorverCell initAttriTextData:summary];
    return 2 * kkPaddingLarge + 2 * KKTitleFont.lineHeight + 2 * summary.textContainer.linesSpacing + descLabelHeight + splitViewHeight;
}

#pragma mark -- 初始化标题富文本

+ (void)initAttriTextData:(KKPersonalSummary *)summary{
    if(summary.textContainer == nil ){
        TYTextContainer *temp = [TYTextContainer new];
        temp.linesSpacing = 3 ;
        temp.textColor = [UIColor kkColorBlack];
        temp.lineBreakMode = NSLineBreakByTruncatingTail;
        temp.text = summary.title;
        temp.font = KKTitleFont ;
        summary.textContainer = [temp createTextContainerWithTextWidth:KKTitleWidth];
    }
}

#pragma mark -- 计算视频时间字符、图片个数字符等宽度

- (CGFloat)fetchNewsTipWidth{
    if(self.summary.newsTipWidth <= 0 ){
        NSDictionary *dic = @{NSFontAttributeName:self.newsTipBtn.titleLabel.font};
        CGSize size = [self.newsTipBtn.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, newsTipBtnHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
        self.summary.newsTipWidth = size.width;
    }
    return self.summary.newsTipWidth;
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
                    [self.delegate clickImageWithItem:self.summary rect:view.frame fromView:self.bgView image:view.image indexPath:nil];
                }
            }];
            view ;
        });
    }
    return _smallImgView;
}

- (UILabel *)dateLabel{
    if(!_dateLabel){
        _dateLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor kkColorLightgray];
            view.font = KKDescFont;
            view.lineBreakMode = NSLineBreakByWordWrapping;
            view.backgroundColor = [UIColor clearColor];
            view.textAlignment = NSTextAlignmentRight;
            view ;
        });
    }
    return _dateLabel;
}

@end
