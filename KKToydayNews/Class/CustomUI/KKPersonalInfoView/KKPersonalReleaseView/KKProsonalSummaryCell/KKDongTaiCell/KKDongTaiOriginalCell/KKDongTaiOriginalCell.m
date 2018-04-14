//
//  KKDongTaiOriginalCell.m
//  KKToydayNews
//
//  Created by finger on 2017/11/24.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKDongTaiOriginalCell.h"
#import "KKDongTaiBarView.h"

static CGFloat headViewWH = 40 ;
static CGFloat vIntervael = kkPaddingNormal;//各个控件之间的垂直距离
static CGFloat newsContentHeight = 60 ;
static CGFloat splitViewHeight = 5 ;

#define newsSummaryWidth (UIDeviceScreenWidth - 4 * kkPaddingNormal - newsContentHeight)
#define BarViewHeight 35

@interface KKDongTaiOriginalCell ()<KKCommonDelegate>
@property(nonatomic)UIImageView *headView;
@property(nonatomic)UILabel *nameLabel;
@property(nonatomic)UILabel *dateLabel;
@property(nonatomic)UIButton *moreBtn;
@property(nonatomic)UILabel *titleLabel;
@property(nonatomic)UIView *newContentBgView;
@property(nonatomic)UIImageView *newsImageView;
@property(nonatomic)UIButton *playBtn;
@property(nonatomic)UILabel *newsSummaryLabel;
@property(nonatomic)UILabel *detailLabel;
@property(nonatomic)KKDongTaiBarView *barView ;
@property(nonatomic)UIView *splitView ;
@end

@implementation KKDongTaiOriginalCell

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
    [self.contentView addSubview:self.headView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.dateLabel];
    [self.contentView addSubview:self.moreBtn];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.newContentBgView];
    [self.newContentBgView addSubview:self.newsImageView];
    [self.newContentBgView addSubview:self.playBtn];
    [self.newContentBgView addSubview:self.newsSummaryLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.barView];
    [self.contentView addSubview:self.splitView];
    
    [self.headView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).mas_offset(vIntervael);
        make.left.mas_equalTo(self.contentView).mas_offset(kkPaddingNormal);
        make.size.mas_equalTo(CGSizeMake(headViewWH, headViewWH));
    }];
    
    [self.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.headView.mas_right).mas_offset(kkPaddingNormal);
        make.bottom.mas_equalTo(self.headView.mas_centerY).mas_offset(-1.5);
        make.right.mas_lessThanOrEqualTo(self.moreBtn.mas_left).mas_offset(-5);
    }];
    
    [self.dateLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.nameLabel);
        make.top.mas_equalTo(self.headView.mas_centerY).mas_offset(1.5);
    }];
    
    [self.moreBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.headView);
        make.right.mas_equalTo(self.contentView).mas_offset(-kkPaddingNormal);
        make.size.mas_equalTo(CGSizeMake(20, 20));
    }];
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).mas_offset(kkPaddingNormal);
        make.right.mas_equalTo(self.contentView).mas_equalTo(-kkPaddingNormal);
        make.top.mas_equalTo(self.headView.mas_bottom).mas_offset(vIntervael);
    }];
    
    [self.newContentBgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(vIntervael);
        make.right.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(newsContentHeight);
    }];
    
    [self.newsImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(self.newContentBgView);
        make.width.mas_equalTo(newsContentHeight);
    }];
    
    [self.playBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.newsImageView);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.newsSummaryLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.newsImageView.mas_right).mas_offset(kkPaddingNormal);
        make.centerY.mas_equalTo(self.newsImageView);
        make.width.mas_equalTo(newsSummaryWidth);
    }];
    
    [self.detailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).mas_offset(kkPaddingNormal);
        make.right.mas_equalTo(self.contentView).mas_offset(-kkPaddingNormal);
        make.top.mas_equalTo(self.newContentBgView.mas_bottom).mas_offset(kkPaddingNormal);
    }];
    
    [self.barView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.detailLabel.mas_bottom).mas_offset(vIntervael);
        make.left.mas_equalTo(self.contentView);
        make.width.mas_equalTo(self.contentView);
        make.height.mas_equalTo(BarViewHeight);
    }];
    
    [self.splitView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.contentView);
        make.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(splitViewHeight);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


#pragma mark -- 获取cell的高度

+ (CGFloat)fetchHeightWith:(KKDongTaiObject *)obj{
    [KKDongTaiOriginalCell initAttriTextData:obj];
    return 5 * vIntervael + headViewWH + newsContentHeight + splitViewHeight + detailFont.lineHeight + BarViewHeight + obj.attriTextData.attriTextHeight;
}

#pragma mark -- 数据刷新

- (void)refreshWith:(KKDongTaiObject *)obj{
    
    [KKDongTaiOriginalCell initAttriTextData:obj];
    
    NSString *avatarUrl = obj.user.avatar_url;
    if(!avatarUrl.length){
        avatarUrl = @"";
    }
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache queryCacheOperationForKey:avatarUrl done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
        if(image){
            self.headView.image = image ;
        }else{
            [self.headView setCornerImageWithURL:[NSURL URLWithString:avatarUrl] placeholder:[UIImage imageWithColor:[UIColor grayColor]]];
        }
    }];
    
    NSString *url = obj.origin_group.thumb_url;
    if(!url.length){
        url = @"";
    }
    [imageCache queryCacheOperationForKey:url done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
        if(image){
            [self.newsImageView setImage:image];
        }else{
            [self.newsImageView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageWithColor:[UIColor grayColor]]];
        }
    }];
    
    self.nameLabel.text = obj.user.screen_name;
    self.dateLabel.text = [NSString stringIntervalSince1970RuleTwo:obj.create_time.longLongValue];
    
    self.titleLabel.attributedText = obj.attriTextData.attriText;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(obj.attriTextData.attriTextHeight);
    }];
    
    NSString *readCount = [[NSNumber numberWithLongLong:obj.read_count.longLongValue]convert];
    NSString *diggCount = [[NSNumber numberWithLongLong:obj.digg_count.longLongValue]convert];
    NSString *commentCount = [[NSNumber numberWithLongLong:obj.comment_count.longLongValue]convert];
    self.detailLabel.text = [NSString stringWithFormat:@"%@ 阅读  %@赞  %@评论",readCount,diggCount,commentCount];
    
    self.newsSummaryLabel.attributedText = obj.origin_group.attriTextData.attriText;
    self.newsSummaryLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.newsSummaryLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(obj.origin_group.attriTextData.attriTextHeight);
    }];
    
    self.playBtn.hidden = ![obj.origin_group.media_type isEqualToString:@"2"];
    
    NSString *shareCount = obj.forward_num;
    self.barView.upVoteCount = [[NSNumber numberWithLong:obj.digg_count.longLongValue]convert];
    self.barView.commentCount = [[NSNumber numberWithLong:obj.comment_count.longLongValue]convert];
    self.barView.shareCount = [[NSNumber numberWithLong:shareCount.longLongValue]convert]; ;
}

#pragma mark -- 更多按钮点击

- (void)moreBtnClicked{
    if(self.delegate && [self.delegate respondsToSelector:@selector(showMoreView)]){
        [self.delegate showMoreView];
    }
}

#pragma mark -- KKUserBarViewDelegate

- (void)clickButtonWithType:(KKBarButtonType)type{
    
}

#pragma mark -- 初始化标题文本

+ (void)initAttriTextData:(KKDongTaiObject *)item{
    if(item.origin_group.attriTextData == nil ){
        item.origin_group.attriTextData = [KKAttriTextData new];
        item.origin_group.attriTextData.lineSpace = 3 ;
        item.origin_group.attriTextData.textColor = contentTextColor;
        item.origin_group.attriTextData.lineBreak = NSLineBreakByCharWrapping;
        item.origin_group.attriTextData.originalText = item.origin_group.title;
        item.origin_group.attriTextData.maxAttriTextWidth = newsSummaryWidth ;
        item.origin_group.attriTextData.textFont = contentTextFont;
        if(item.origin_group.attriTextData.attriTextHeight > 2 * contentTextFont.lineHeight + 2 * item.origin_group.attriTextData.lineSpace){
            item.origin_group.attriTextData.attriTextHeight = 2 * contentTextFont.lineHeight + 2 * item.origin_group.attriTextData.lineSpace ;
        }
    }
    
    if(item.attriTextData == nil ){
        item.attriTextData = [KKAttriTextData new];
        item.attriTextData.lineSpace = 3 ;
        item.attriTextData.textColor = contentTextColor;
        item.attriTextData.lineBreak = NSLineBreakByCharWrapping;
        item.attriTextData.originalText = item.content_unescape;
        item.attriTextData.maxAttriTextWidth = (UIDeviceScreenWidth - 2 * kkPaddingNormal) ;
        item.attriTextData.textFont = contentTextFont;
        if(item.attriTextData.attriTextHeight > 6 * contentTextFont.lineHeight + 6 * item.attriTextData.lineSpace){
            item.attriTextData.attriTextHeight = 6 * contentTextFont.lineHeight + 6 * item.attriTextData.lineSpace ;
        }
    }
}

#pragma mark -- @property

- (UIImageView *)headView{
    if(!_headView){
        _headView = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFill;
            view;
        });
    }
    return _headView;
}

- (UILabel *)nameLabel{
    if(!_nameLabel){
        _nameLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor blackColor];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view.font = [UIFont systemFontOfSize:15];
            view ;
        });
    }
    return _nameLabel;
}

- (UILabel *)dateLabel{
    if(!_dateLabel){
        _dateLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor grayColor];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view.font = [UIFont systemFontOfSize:13];
            view ;
        });
    }
    return _dateLabel;
}

- (UIButton *)moreBtn{
    if(!_moreBtn){
        _moreBtn = ({
            UIButton *view = [UIButton new];
            [view setImage:[UIImage imageNamed:@"More_24x24_"] forState:UIControlStateNormal];
            [view addTarget:self action:@selector(moreBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            view ;
        });
    }
    return _moreBtn;
}

- (UILabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor blackColor];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByCharWrapping;
            view.font = contentTextFont;
            view.numberOfLines = 0 ;
            view ;
        });
    }
    return _titleLabel;
}

- (UIView *)newContentBgView{
    if(!_newContentBgView){
        _newContentBgView = ({
            UIView *view = [UIView new];
            view.backgroundColor = KKColor(244, 245, 246, 1);
            view ;
        });
    }
    return _newContentBgView;
}

- (UIImageView *)newsImageView{
    if(!_newsImageView){
        _newsImageView = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFill;
            view;
        });
    }
    return _newsImageView;
}

- (UIButton *)playBtn{
    if(!_playBtn){
        _playBtn = ({
            UIButton *view = [UIButton new];
            [view setImage:[UIImage imageNamed:@"video_play_icon_44x44_"] forState:UIControlStateNormal];
            view ;
        });
    }
    return _playBtn;
}

- (UILabel *)newsSummaryLabel{
    if(!_newsSummaryLabel){
        _newsSummaryLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor blackColor];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByWordWrapping;
            view.numberOfLines = 0 ;
            view.font = [UIFont systemFontOfSize:14];
            view ;
        });
    }
    return _newsSummaryLabel;
}

- (UILabel *)detailLabel{
    if(!_detailLabel){
        _detailLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor grayColor];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByCharWrapping;
            view.font = detailFont;
            view ;
        });
    }
    return _detailLabel;
}

- (KKDongTaiBarView *)barView{
    if(!_barView){
        _barView = ({
            KKDongTaiBarView *view = [KKDongTaiBarView new];
            view.delegate = self ;
            view.borderType = KKBorderTypeTop;
            view.borderColor = [[UIColor grayColor]colorWithAlphaComponent:0.3];
            view.borderThickness = 0.5 ;
            view;
        });
    }
    return _barView;
}

- (UIView *)splitView{
    if(!_splitView){
        _splitView = ({
            UIView *view = [UIView new];
            view.backgroundColor = KKColor(244, 245, 246, 1);
            view ;
        });
    }
    return _splitView;
}

@end
