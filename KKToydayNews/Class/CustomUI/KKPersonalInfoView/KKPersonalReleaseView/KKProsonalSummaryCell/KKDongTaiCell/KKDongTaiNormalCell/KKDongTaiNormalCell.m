//
//  KKDongTaiNormalCell.m
//  KKToydayNews
//
//  Created by finger on 2017/11/24.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKDongTaiNormalCell.h"
#import "TYAttributedLabel.h"

static CGFloat headViewWH = 40 ;
static CGFloat vIntervael = kkPaddingNormal;//各个控件之间的垂直距离
static CGFloat newsContentHeight = 80 ;
static CGFloat splitViewHeight = 5 ;

#define newsSummaryWidth (UIDeviceScreenWidth - 4 * kkPaddingNormal - newsContentHeight)

@interface KKDongTaiNormalCell ()
@property(nonatomic)UIImageView *headView;
@property(nonatomic)UILabel *nameLabel;
@property(nonatomic)UILabel *dateLabel;
@property(nonatomic)UIButton *moreBtn;
@property(nonatomic)UILabel *titleLabel;
@property(nonatomic)UIView *newContentBgView;
@property(nonatomic)UIImageView *newsImageView;
@property(nonatomic)UIButton *playBtn;
@property(nonatomic)TYAttributedLabel *newsSummaryLabel;
@property(nonatomic)UILabel *detailLabel;
@property(nonatomic)UIView *splitView ;
@end

@implementation KKDongTaiNormalCell

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
    [KKDongTaiNormalCell initAttriTextData:obj];
    if(obj.itemCellHeight <= 0){
        obj.itemCellHeight = 5 * vIntervael + headViewWH + newsContentHeight + splitViewHeight + contentTextFont.lineHeight + detailFont.lineHeight ;
    }
    return obj.itemCellHeight;
}

#pragma mark -- 数据刷新

- (void)refreshWith:(KKDongTaiObject *)obj{
    
    [KKDongTaiNormalCell initAttriTextData:obj];
    
    NSString *avatarUrl = obj.user.avatar_url;
    if(!avatarUrl.length){
        avatarUrl = @"";
    }
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache queryCacheOperationForKey:avatarUrl done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
        if(image){
            self.headView.image = image ;
        }else{
            [self.headView sd_setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageWithColor:[UIColor grayColor]]];
        }
    }];
    
    NSString *url = obj.group.thumb_url;
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
    self.titleLabel.text = obj.content_unescape;
    
    NSString *readCount = [[NSNumber numberWithLongLong:obj.read_count.longLongValue]convert];
    NSString *diggCount = [[NSNumber numberWithLongLong:obj.digg_count.longLongValue]convert];
    NSString *commentCount = [[NSNumber numberWithLongLong:obj.comment_count.longLongValue]convert];
    self.detailLabel.text = [NSString stringWithFormat:@"%@ 阅读  %@赞  %@评论",readCount,diggCount,commentCount];
    
    self.newsSummaryLabel.textContainer = obj.group.textContainer;
    [self.newsSummaryLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(obj.group.textContainer.attriTextHeight);
    }];
    
    self.playBtn.hidden = ![obj.group.media_type isEqualToString:@"2"];
}

#pragma mark -- 更多按钮点击

- (void)moreBtnClicked{
    if(self.delegate && [self.delegate respondsToSelector:@selector(showMoreView)]){
        [self.delegate showMoreView];
    }
}

#pragma mark -- 初始化标题文本

+ (void)initAttriTextData:(KKDongTaiObject *)item{
    if(item.group.textContainer == nil ){
        TYTextContainer *temp = [TYTextContainer new];
        temp.linesSpacing = 3 ;
        temp.textColor = contentTextColor;
        temp.lineBreakMode = NSLineBreakByTruncatingTail;
        temp.text = item.group.title;
        temp.font = contentTextFont;
        temp.numberOfLines = 2 ;
        item.group.textContainer = [temp createTextContainerWithTextWidth:newsSummaryWidth];
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
            view.layer.borderWidth = 0.5;
            view.layer.borderColor = [[UIColor grayColor]colorWithAlphaComponent:0.1].CGColor;
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

- (TYAttributedLabel *)newsSummaryLabel{
    if(!_newsSummaryLabel){
        _newsSummaryLabel = ({
            TYAttributedLabel *view = [TYAttributedLabel new];
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
