//
//  KKVideoCell.m
//  KKToydayNews
//
//  Created by finger on 2017/9/16.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKVideoCell.h"
#import "TYAttributedLabel.h"

#define UserHeaderHeight 30
#define SplitViewHeight 8
#define ButtonWdith 44
#define ButtonHeight 30
#define ImageViewHeight (UIDeviceScreenWidth * 4 / 7.0 )

static UIFont *titleFont = nil ;

@interface KKVideoCell ()
@property(nonatomic,strong,readwrite)UIView *contentMaskView;
@property(nonatomic,strong)UIImageView *largeImgView;
@property(nonatomic,strong)UIImageView *userHeader;
@property(nonatomic,strong)TYAttributedLabel *titleLabel;
@property(nonatomic,strong)UILabel *playCountLabel;
@property(nonatomic,strong)UILabel *userNameLabel;
@property(nonatomic,strong)UIButton *concernBtn;
@property(nonatomic,strong)UIButton *playVideoBtn;
@property(nonatomic,strong)UIButton *commentBtn;
@property(nonatomic,strong)UIButton *moreBtn;
@property(nonatomic,strong)UIButton *durationBtn;
@property(nonatomic,strong)UIView *splitView;
@property(nonatomic,strong)CAGradientLayer *gradientLayer;
@property(nonatomic,weak)KKSummaryContent *item;

@property(nonatomic,assign,readwrite)CGRect imageViewFrame;

@end

@implementation KKVideoCell

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
    [self.contentView addSubview:self.contentMaskView];
    [self.contentMaskView addSubview:self.largeImgView];
    [self.contentMaskView addSubview:self.titleLabel];
    [self.contentMaskView addSubview:self.playCountLabel];
    [self.contentMaskView addSubview:self.playVideoBtn];
    [self.contentMaskView addSubview:self.durationBtn];
    [self.contentMaskView addSubview:self.userHeader];
    [self.contentMaskView addSubview:self.userNameLabel];
    [self.contentMaskView addSubview:self.concernBtn];
    [self.contentMaskView addSubview:self.commentBtn];
    [self.contentMaskView addSubview:self.moreBtn];
    [self.contentMaskView addSubview:self.splitView];
    [self.contentMaskView.layer insertSublayer:self.gradientLayer below:self.titleLabel.layer];
    
    if(iPhone5){
        titleFont = [UIFont systemFontOfSize:17 weight:0.3];
    }else{
        titleFont = [UIFont systemFontOfSize:18 weight:0.3];
    }
    
    self.gradientLayer.frame = CGRectMake(0, 0, UIDeviceScreenWidth, ImageViewHeight);
    
    [self.contentMaskView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.largeImgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentMaskView);
        make.left.mas_equalTo(self.contentMaskView);
        make.width.mas_equalTo(self.contentMaskView);
        make.height.mas_equalTo(ImageViewHeight);
    }];
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.largeImgView).mas_offset(kkPaddingNormal);
        make.left.mas_equalTo(self.largeImgView).mas_offset(kkPaddingNormal);
        make.width.mas_equalTo(self.largeImgView).mas_offset(-2*kkPaddingNormal);
        make.height.mas_equalTo(20);
    }];
    
    [self.playCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.left.mas_equalTo(self.titleLabel);
        make.width.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(20);
    }];
    
    [self.playVideoBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.largeImgView);
        make.width.mas_equalTo(44);
        make.height.mas_equalTo(44);
    }];
    
    self.durationBtn.layer.cornerRadius = 20.0/2.0 ;
    [self.durationBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.largeImgView).mas_offset(-kkPaddingNormal);
        make.right.mas_equalTo(self.largeImgView).mas_offset(-kkPaddingNormal);
        make.width.mas_equalTo(35);
        make.height.mas_equalTo(20);
    }];
    
    [self.userHeader mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.largeImgView.mas_bottom).mas_offset(kkPaddingNormal);
        make.left.mas_equalTo(self.contentMaskView).mas_offset(kkPaddingNormal);
        make.width.mas_equalTo(UserHeaderHeight);
        make.height.mas_equalTo(UserHeaderHeight);
    }];
    
    [self.moreBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.userHeader);
        make.right.mas_equalTo(self.contentMaskView).mas_offset(-10);
        make.height.mas_equalTo(ButtonHeight);
    }];
    
    [self.commentBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.userHeader);
        make.right.mas_equalTo(self.moreBtn.mas_left).mas_offset(-10);
        make.height.mas_equalTo(ButtonHeight);
    }];
    
    [self.concernBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.userHeader);
        make.right.mas_equalTo(self.commentBtn.mas_left).mas_offset(-10);
        make.height.mas_equalTo(ButtonHeight);
    }];
    
    [self.userNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.userHeader.mas_right).mas_offset(5);
        make.width.mas_equalTo(1);
        make.centerY.mas_equalTo(self.userHeader);
        make.height.mas_equalTo(20);
    }];
    
    [self.splitView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.userHeader.mas_bottom).mas_offset(kkPaddingNormal);
        make.width.mas_equalTo(self.contentView);
        make.height.mas_equalTo(SplitViewHeight);
    }];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark -- 界面刷新

- (void)refreshWithItem:(KKSummaryContent *)item{
    self.item = item ;
    
    [KKVideoCell initAttriTextData:item];
    
    NSString *url = item.video_detail_info.detail_video_large_image.url;
    if(!url.length){
        url = item.image_list.firstObject.url;
    }
    if(!url.length){
        url = @"";
    }
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache queryCacheOperationForKey:url done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
        if(image){
            [self.largeImgView setImage:image];
        }else{
            [self.largeImgView kk_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageWithColor:[UIColor grayColor]] animate:YES];
        }
    }];
    
    
    self.titleLabel.textContainer = item.textContainer;
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(item.textContainer.attriTextHeight);
    }];
    
    NSString *playCount = [[NSNumber numberWithLong:item.video_detail_info.video_watch_count.longLongValue]convert];
    self.playCountLabel.text = [NSString stringWithFormat:@"%@次播放",playCount];
    
    self.gradientLayer.frame = CGRectMake(0, 0, UIDeviceScreenWidth, ImageViewHeight);
    
    NSString *duration = [NSString getHHMMSSFromSS:item.video_duration];
    [self.durationBtn setTitle:[NSString stringWithFormat:@"%@",duration] forState:UIControlStateNormal];
    
    NSInteger newsTipWidth = [self fetchNewsTipWidth];
    [self.durationBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(newsTipWidth + 15) ;
    }];
    
    NSString *headerUrl = item.user_info.avatar_url;
    if(!headerUrl.length){
        headerUrl = @"";
    }
    [imageCache queryCacheOperationForKey:headerUrl done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
        if(image){
            [self.userHeader setCornerImage:image];
        }else{
            [self.userHeader setCornerImageWithURL:[NSURL URLWithString:headerUrl] placeholder:[UIImage imageNamed:@"head_default"]];
        }
    }];
    
    NSString *commentCnt = [[NSNumber numberWithLong:item.comment_count.longLongValue]convert];
    [self.commentBtn setTitle:commentCnt forState:UIControlStateNormal];
    
    CGFloat wdith = UIDeviceScreenWidth - self.userHeader.right - self.concernBtn.left;
    self.userNameLabel.text = item.source ;
    [self.userNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(wdith);
    }];
    
    self.imageViewFrame = self.largeImgView.frame;
}

+ (CGFloat)fetchHeightWithItem:(KKSummaryContent *)item{
    if(item.itemCellHeight <= 0){
        item.itemCellHeight = 2 * kkPaddingNormal + UserHeaderHeight + ImageViewHeight + SplitViewHeight;
    }
    return item.itemCellHeight;
}

#pragma mark -- 初始化标题文本

+ (void)initAttriTextData:(KKSummaryContent *)item{
    if(item.textContainer == nil ){
        TYTextContainer *temp = [TYTextContainer new];
        temp.linesSpacing = 1 ;
        temp.textColor = [UIColor whiteColor];
        temp.lineBreakMode = NSLineBreakByWordWrapping;
        temp.text = item.title;
        temp.font = titleFont ;
        item.textContainer = [temp createTextContainerWithTextWidth:[UIScreen mainScreen].bounds.size.width - 2 * kkPaddingNormal];
    }
}

#pragma mark -- 计算视频时间字符、图片个数字符等宽度

- (CGFloat)fetchNewsTipWidth{
    if(self.item.newsTipWidth <= 0 ){
        NSDictionary *dic = @{NSFontAttributeName:self.durationBtn.titleLabel.font};
        CGSize size = [self.durationBtn.titleLabel.text boundingRectWithSize:CGSizeMake(MAXFLOAT, self.durationBtn.width) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size;
        self.item.newsTipWidth = size.width;
    }
    return self.item.newsTipWidth;
}

#pragma mark -- 按钮点击

- (void)buttonClicked:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickButtonWithType:item:)]){
        [self.delegate clickButtonWithType:btn.tag item:self.item];
    }
}


#pragma mark -- @property

- (UIView *)contentMaskView{
    if(!_contentMaskView){
        _contentMaskView = ({
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor clearColor];
            view ;
        });
    }
    return _contentMaskView;
}

- (TYAttributedLabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = ({
            TYAttributedLabel *view = [TYAttributedLabel new];
            view.textColor = [UIColor whiteColor];
            view.font = KKTitleFont;
            view.lineBreakMode = NSLineBreakByWordWrapping;
            view.numberOfLines = 0 ;
            view.backgroundColor = [UIColor clearColor];
            view ;
        });
    }
    return _titleLabel;
}

- (UIImageView *)largeImgView{
    if(!_largeImgView){
        _largeImgView = ({
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
                    self.imageViewFrame = view.frame;
                    [self.delegate clickImageWithItem:self.item rect:self.imageViewFrame fromView:self.contentMaskView image:view.image indexPath:nil];
                }
            }];
            view ;
        });
    }
    return _largeImgView;
}

- (UIImageView *)userHeader{
    if(!_userHeader){
        _userHeader = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFill ;
            view.layer.masksToBounds = YES ;
            view.userInteractionEnabled = YES ;
            
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                if(self.delegate && [self.delegate respondsToSelector:@selector(jumpToUserPage:)]){
                    NSString *userId = self.item.user_info.user_id;
                    if(!userId.length){
                        userId = self.item.user.user_id;
                    }
                    [self.delegate jumpToUserPage:userId];
                }
            }];
            
            view ;
        });
    }
    return _userHeader;
}

- (UIButton *)moreBtn{
    if(!_moreBtn){
        _moreBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"More_24x24_"] forState:UIControlStateNormal];
            [view setTag:KKBarButtonTypeMore];
            [view addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            view ;
        });
    }
    return _moreBtn;
}

- (UILabel *)playCountLabel{
    if(!_playCountLabel){
        _playCountLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor whiteColor];
            view.font = KKDescFont;
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByWordWrapping;
            view.backgroundColor = [UIColor clearColor];
            view ;
        });
    }
    return _playCountLabel;
}

- (UILabel *)userNameLabel{
    if(!_userNameLabel){
        _userNameLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor blackColor];
            view.font = [UIFont systemFontOfSize:14];
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view.backgroundColor = [UIColor clearColor];
            view ;
        });
    }
    return _userNameLabel;
}

- (UIButton *)concernBtn{
    if(!_concernBtn){
        _concernBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"video_add_24x24_"] forState:UIControlStateNormal];
            [view setTitle:@"关注" forState:UIControlStateNormal];
            [view setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [view.titleLabel setFont:[UIFont systemFontOfSize:11]];
            [view setTag:KKBarButtonTypeConcern];
            [view addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            view ;
        });
    }
    return _concernBtn;
}

- (UIButton *)durationBtn{
    if(!_durationBtn){
        _durationBtn = ({
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
            btn.titleLabel.font = KKDescFont ;
            btn.layer.masksToBounds = YES ;
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn ;
        });
    }
    return _durationBtn;
}

- (UIButton *)commentBtn{
    if(!_commentBtn){
        _commentBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"comment_feed_24x24_"] forState:UIControlStateNormal];
            [view setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [view.titleLabel setFont:[UIFont systemFontOfSize:11]];
            [view setTag:KKBarButtonTypeComment];
            [view addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            view ;
        });
    }
    return _commentBtn;
}

- (UIButton *)playVideoBtn{
    if(!_playVideoBtn){
        _playVideoBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"video_play_icon_44x44_"] forState:UIControlStateNormal];
            [view setUserInteractionEnabled:NO];
            view ;
        });
    }
    return _playVideoBtn;
}

- (UIView *)splitView{
    if(!_splitView){
        _splitView = ({
            UIView *view = [UIView new];
            view.backgroundColor = KKColor(244, 245, 246, 1.0);;
            view ;
        });
    }
    return _splitView;
}

- (CAGradientLayer *)gradientLayer{
    if(!_gradientLayer){
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.colors = @[(__bridge id)[[UIColor blackColor]colorWithAlphaComponent:0.5].CGColor, (__bridge id)[[UIColor blackColor]colorWithAlphaComponent:0.1].CGColor];
        _gradientLayer.startPoint = CGPointMake(0, 0);
        _gradientLayer.endPoint = CGPointMake(0.0, 1.0);
    }
    return _gradientLayer;
}

@end
