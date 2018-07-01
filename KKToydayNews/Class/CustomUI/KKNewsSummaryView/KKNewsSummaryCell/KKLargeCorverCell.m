//
//  KKLargeCorverCell.m
//  KKToydayNews
//
//  Created by finger on 2017/9/16.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKLargeCorverCell.h"

#define space 5.0
#define KKTitleWidth ([UIScreen mainScreen].bounds.size.width - 2 * kkPaddingNormal)
#define imageHeight (KKTitleWidth * 3 / 5)

@interface KKLargeCorverCell ()
@property(nonatomic,strong)UIImageView *largeImgView ;
@property(nonatomic,assign,readwrite)CGRect imageViewFrame;
@end

@implementation KKLargeCorverCell

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
    [self.bgView addSubview:self.largeImgView];
    [self.bgView addSubview:self.playVideoBtn];
    [self.bgView addSubview:self.newsTipBtn];
    [self.bgView addSubview:self.leftBtn];
    [self.bgView addSubview:self.descLabel];
    [self.bgView addSubview:self.shieldBtn];
    [self.bgView addSubview:self.splitView];
    
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView).mas_offset(kkPaddingLarge);
        make.left.mas_equalTo(self.bgView).mas_offset(kkPaddingNormal);
        make.width.mas_equalTo(KKTitleWidth);
        make.height.mas_equalTo(0);
    }];
    
    [self.largeImgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(space);
        make.left.mas_equalTo(self.titleLabel);
        make.width.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(imageHeight);
    }];
    
    [self.playVideoBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.largeImgView);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    self.newsTipBtn.layer.cornerRadius = newsTipBtnHeight/2.0 ;
    [self.newsTipBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.largeImgView).mas_offset(-space);
        make.bottom.mas_equalTo(self.largeImgView).mas_offset(-space);
        make.width.mas_equalTo(35);
        make.height.mas_equalTo(newsTipBtnHeight);
    }];
    
    [self.leftBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.largeImgView.mas_bottom).mas_offset(space + 3);
        make.width.mas_offset(leftBtnSize.width);
        make.height.mas_equalTo(leftBtnSize.height);
    }];
    
    [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftBtn.mas_right).mas_offset(space);
        make.centerY.mas_equalTo(self.leftBtn.mas_centerY);
        make.width.mas_equalTo(250);
        make.height.mas_equalTo(descLabelHeight);
    }];
    
    [self.shieldBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.titleLabel);
        make.centerY.mas_equalTo(self.leftBtn);
        make.width.mas_equalTo(descLabelHeight);
        make.height.mas_equalTo(descLabelHeight);
    }];
    
    [self.splitView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.bottom.mas_equalTo(self.bgView);
        make.width.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(1.0);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark -- 界面刷新

- (void)refreshWithItem:(KKSummaryContent *)item{
    self.item = item ;
    
    //初始化标题文本
    [KKLargeCorverCell initAttriTextData:item];
    
    //无图的新闻和大图的新闻共用
    NSInteger imgViewH = imageHeight ;
    if(![item.has_image boolValue] && !item.large_image_list.count){
        imgViewH = 0 ;
    }
    [self.largeImgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(imgViewH);
    }];
    
    NSString *url = item.large_image_list.firstObject.url;
    if(!url.length){
        url = item.image_list.firstObject.url;
    }
    if(!url.length){
        url = @"";
    }
    
    @weakify(self);
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    [imageCache queryCacheOperationForKey:url done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
        @strongify(self);
        if(image){
            [self.largeImgView setImage:image];
        }else{
            [self.largeImgView kk_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageWithColor:[UIColor grayColor]] animate:YES];
        }
    }];
    
    NSString *publishTime = [NSString stringIntervalSince1970RuleOne:item.publish_time.longLongValue];
    NSString *commentCnt = [[NSNumber numberWithLong:item.comment_count.longLongValue]convert];
    self.descLabel.text = [NSString stringWithFormat:@"%@  %@评论  %@",item.source,commentCnt,publishTime];
    
    self.titleLabel.textContainer = item.textContainer;
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.item.textContainer.attriTextHeight);
    }];
    
    self.newsTipBtn.hidden = YES ;
    self.playVideoBtn.hidden = YES ;
    if([item.has_video boolValue]||
       [item.has_mp4_video boolValue]||
       [item.has_m3u8_video boolValue]){
        NSString *duration = [NSString getHHMMSSFromSS:item.video_duration];
        self.newsTipBtn.hidden = NO  ;
        self.playVideoBtn.hidden = NO ;
        [self.bgView bringSubviewToFront:self.newsTipBtn];
        [self.newsTipBtn setTitle:[NSString stringWithFormat:@"%@",duration] forState:UIControlStateNormal];
        
        NSInteger newsTipWidth = [self fetchNewsTipWidth];
        [self.newsTipBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(newsTipWidth + 15) ;
        }];
    }else{
        self.playVideoBtn.hidden = YES ;
        
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
    
    self.imageViewFrame = self.largeImgView.frame;
}

+ (CGFloat)fetchHeightWithItem:(KKSummaryContent *)item{
    
    [self initAttriTextData:item];
    
    //无图的新闻和大图的新闻共用
    NSInteger imgViewH = imageHeight ;
    if(![item.has_image boolValue] && !item.large_image_list.count){
        imgViewH = 0 ;
    }
    if (item.itemCellHeight <= 0) {
        item.itemCellHeight = 2 * kkPaddingLarge + 2 * space + imgViewH + item.textContainer.attriTextHeight + descLabelHeight ;
    }
    return item.itemCellHeight;
}

#pragma mark -- 初始化标题文本

+ (void)initAttriTextData:(KKSummaryContent *)item{
    if(item.textContainer == nil ){
        TYTextContainer *temp = [TYTextContainer new];
        temp.linesSpacing = 3 ;
        temp.textColor = [UIColor kkColorBlack];
        temp.lineBreakMode = NSLineBreakByTruncatingTail;
        temp.text = item.title;
        temp.font = KKTitleFont ;
        temp.numberOfLines = 2 ;
        item.textContainer = [temp createTextContainerWithTextWidth:KKTitleWidth];
    }
}

#pragma mark -- @property

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
                    [self.delegate clickImageWithItem:self.item rect:self.imageViewFrame fromView:self.bgView image:view.image indexPath:nil];
                }
            }];
            view ;
        });
    }
    return _largeImgView;
}

@end
