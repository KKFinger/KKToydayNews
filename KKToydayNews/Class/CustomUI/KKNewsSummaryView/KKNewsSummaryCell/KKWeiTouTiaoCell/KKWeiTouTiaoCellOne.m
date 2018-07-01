//
//  KKWeiTouTiaoCellOne.m
//  KKToydayNews
//
//  Created by finger on 2018/4/15.
//  Copyright © 2018年 finger. All rights reserved.
//

#import "KKWeiTouTiaoCellOne.h"

@interface KKWeiTouTiaoCellOne()
@property(nonatomic,weak)KKSummaryContent *item ;
@property(nonatomic)UIImageView *largeImageView;
@end

@implementation KKWeiTouTiaoCellOne

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        self.selectionStyle = UITableViewCellSelectionStyleNone ;
        self.contentView.backgroundColor = KKColor(244, 245, 246, 1.0);
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
    [self.bgView addSubview:self.header];
    [self.bgView addSubview:self.contentTextView];
    [self.bgView addSubview:self.positionView];
    [self.bgView addSubview:self.posAndReadCountLabel];
    [self.bgView addSubview:self.barView];
    [self.bgView addSubview:self.largeImageView];
    
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView);
        make.width.mas_equalTo(self.contentView);
        make.height.mas_equalTo(self.contentView).mas_offset(-space);
    }];
    
    [self.header mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView).mas_offset(vInterval);
        make.left.mas_equalTo(self.bgView);
        make.width.mas_equalTo(self.bgView);
        make.height.mas_equalTo(HeadViewHeight);
    }];
    
    [self.contentTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.header.mas_bottom).mas_offset(vInterval);
        make.left.mas_equalTo(self.bgView).mas_offset(kkPaddingNormal);
        make.width.mas_equalTo(self.bgView).mas_offset(-2 * kkPaddingNormal);
        make.height.mas_equalTo(1);
    }];
    
    [self.largeImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentTextView.mas_bottom).mas_offset(vInterval);
        make.left.mas_equalTo(self.contentTextView);
    }];
    
    [self.positionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.barView.mas_top).mas_offset(-vInterval);
        make.left.mas_equalTo(self.contentTextView);
        make.width.mas_equalTo(descLabelHeight);
        make.height.mas_equalTo(descLabelHeight);
    }];
    
    [self.posAndReadCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.positionView);
        make.left.mas_equalTo(self.positionView.mas_right).mas_offset(3).priority(998);
        make.right.mas_equalTo(self.bgView).mas_offset(-kkPaddingNormal);
    }];
    
    [self.barView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.bgView);
        make.left.mas_equalTo(self.bgView);
        make.width.mas_equalTo(self.bgView);
        make.height.mas_equalTo(BarViewHeight);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark -- 界面刷新

- (void)refreshWithItem:(KKSummaryContent *)item{
    self.item = item ;
    
    [KKWeiTouTiaoCellOne initAttriTextData:item];
    
    self.header.headUrl = item.user.avatar_url;
    self.header.name = item.user.screen_name;
    self.header.desc = item.user.verified_content;
    self.header.isFollow = [item.user.is_following boolValue];
    
    CGFloat textHeight = item.textContainer.attriTextHeight;
    self.contentTextView.textContainer = item.textContainer ;
    [self.contentTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(textHeight);
    }];
    
    NSInteger imageCount = item.thumb_image_list.count;
    if(imageCount <= 0){
        self.largeImageView.hidden = YES ;
    }else{
        KKImageItem *imageItem = item.ugc_cut_image_list.firstObject;
        if(imageItem.cellHeight <= 0 || imageItem.cellWidth <= 0){
            CGFloat width = [UIScreen mainScreen].bounds.size.width / 2.0 ;
            CGFloat height = width / (imageItem.width / imageItem.height) ;
            imageItem.cellWidth = width;
            imageItem.cellHeight = height;
        }
        self.largeImageView.hidden = NO ;
        [self.largeImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(imageItem.cellWidth);
            make.height.mas_equalTo(imageItem.cellHeight);
        }];
        
        NSString *url = imageItem.url ;
        if(!url.length){
            url = @"";
        }
        YYImageCache *imageCache = [YYImageCache sharedCache];
        [imageCache getImageForKey:url withType:YYImageCacheTypeMemory|YYImageCacheTypeDisk withBlock:^(UIImage * _Nullable image, YYImageCacheType type) {
            if(image){
                [self.largeImageView setImage:image];
            }else{
                [self.largeImageView yy_setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageWithColor:[UIColor grayColor]]];
            }
        }];
    }
    
    NSString *position = [item.position objectForKey:@"position"];
    NSString *readCount = [[NSNumber numberWithLong:item.read_count.longLongValue]convert];
    if(!position.length){
        [self.positionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
        [self.posAndReadCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.positionView.mas_right).mas_offset(0);
        }];
        [self.posAndReadCountLabel setText:[NSString stringWithFormat:@"%@人阅读",readCount]];
    }else{
        [self.positionView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(13);
        }];
        [self.posAndReadCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.positionView.mas_right).mas_offset(space);
        }];
        [self.posAndReadCountLabel setText:[NSString stringWithFormat:@"%@   %@人阅读",position,readCount]];
    }
    
    NSString *shareCount = item.forward_info[@"forward_count"];
    self.barView.upVoteCount = [[NSNumber numberWithLong:item.digg_count.longLongValue]convert];
    self.barView.commentCount = [[NSNumber numberWithLong:item.comment_count.longLongValue]convert];
    self.barView.shareCount = [[NSNumber numberWithLong:shareCount.longLongValue]convert]; ;
}

+ (CGFloat)fetchHeightWithItem:(KKSummaryContent *)item{
    
    [KKWeiTouTiaoCellOne initAttriTextData:item];
    
    NSInteger imageCount = item.thumb_image_list.count;
    if(imageCount <= 0){
        if(item.itemCellHeight <= 0){
            item.itemCellHeight = HeadViewHeight + item.textContainer.attriTextHeight + descLabelHeight + BarViewHeight + 4 * vInterval + space ;
        }
        return item.itemCellHeight;
    }
    KKImageItem *imageItem = item.ugc_cut_image_list.firstObject;
    if(imageItem.cellWidth <= 0 || imageItem.cellHeight <= 0){
        CGFloat width = [UIScreen mainScreen].bounds.size.width / 2.0 ;
        CGFloat height = width / (imageItem.width / imageItem.height) ;
        imageItem.cellWidth = width;
        imageItem.cellHeight = height;
    }
    if(item.itemCellHeight <= 0){
        item.itemCellHeight = HeadViewHeight + item.textContainer.attriTextHeight + descLabelHeight + BarViewHeight + space + imageItem.cellHeight + 5 * vInterval ;
    }
    return item.itemCellHeight;
}

#pragma mark -- 初始化标题文本

+ (void)initAttriTextData:(KKSummaryContent *)item{
    if(item.textContainer == nil ){
        if(!contentTextFont){
            contentTextFont = [UIFont systemFontOfSize:(iPhone5)?15:17];
        }
        TYTextContainer *temp = [TYTextContainer new];
        temp.linesSpacing = 3 ;
        temp.textColor = [UIColor kkColorBlack];
        temp.lineBreakMode = NSLineBreakByTruncatingTail;
        temp.text = item.content;
        temp.font = contentTextFont ;
        temp.numberOfLines = 6 ;
        item.textContainer = [temp createTextContainerWithTextWidth:[UIScreen mainScreen].bounds.size.width - 2 * kkPaddingNormal];
    }
}

#pragma mark -- 更多图片按钮点击

- (void)showMoreImage{
    if(self.delegate && [self.delegate respondsToSelector:@selector(showWTTDetailView:)]){
        [self.delegate showWTTDetailView:self.item];
    }
}

#pragma mark -- KKUserBarViewDelegate

- (void)clickButtonWithType:(KKBarButtonType)type{
    
}

#pragma mark -- KKUserHeadViewDelegate

- (void)followBtnClicked{
    
}

- (void)shieldBtnClicked{
    
}

- (void)userHeadClicked{
    if(self.delegate && [self.delegate respondsToSelector:@selector(jumpToUserPage:)]){
        [self.delegate jumpToUserPage:self.item.user.user_id];
    }
}

#pragma mark -- 重置cell中图片的隐藏，index == -1 ，设置全部，否则设置对应索引的图片

- (void)resetImageViewHidden:(BOOL)hidden index:(NSInteger)index{
    self.largeImageView.hidden = hidden;
}

#pragma mark -- 获取对应索引的的CGRect

- (CGRect)fetchImageFrameWithIndex:(NSInteger)index{
    return self.largeImageView.frame;
}

#pragma mark -- 获取对应索引的的UIImage

- (UIImage *)fetchImageWithIndex:(NSInteger)index{
    return self.largeImageView.image ;
}

#pragma mark -- @property

- (UIImageView *)largeImageView{
    if(!_largeImageView){
        _largeImageView = ({
            UIImageView *view = [YYAnimatedImageView new];
            view.contentMode = UIViewContentModeScaleAspectFill;
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
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.indexPath.row inSection:0];
                    [self.delegate clickImageWithItem:self.item rect:view.frame fromView:self.bgView image:view.image indexPath:indexPath];
                }
            }];
            view;
        });
    }
    return _largeImageView;
}

@end
