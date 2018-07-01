//
//  KKWeiTouTiaoCellThree.m
//  KKToydayNews
//
//  Created by finger on 2018/4/15.
//  Copyright © 2018年 finger. All rights reserved.
//

#import "KKWeiTouTiaoCellThree.h"

@interface KKWeiTouTiaoCellThree()
@property(nonatomic)NSMutableArray *imageViewArray ;
@property(nonatomic)UIButton *moreImageView;
@property(nonatomic,weak)KKSummaryContent *item ;
@end

@implementation KKWeiTouTiaoCellThree

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
    [self.bgView addSubview:self.moreImageView];
    [self.bgView addSubview:self.barView];
    
    for(NSInteger i = 0 ; i < perRowImages ; i++){
        UIImageView *view = [YYAnimatedImageView new];
        view.contentMode = UIViewContentModeScaleAspectFill;
        view.userInteractionEnabled = YES ;
        view.layer.borderWidth = 0.5;
        view.layer.borderColor = [[UIColor grayColor]colorWithAlphaComponent:0.1].CGColor;
        @weakify(view);
        @weakify(self);
        [view addTapGestureWithBlock:^(UIView *gestureView) {
            @strongify(view);
            @strongify(self);
            if(self.delegate && [self.delegate respondsToSelector:@selector(clickImageWithItem:rect:fromView:image:indexPath:)]){
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.indexPath.row inSection:i];
                [self.delegate clickImageWithItem:self.item rect:view.frame fromView:self.bgView image:view.image indexPath:indexPath];
            }
        }];
        [self.bgView addSubview:view];
        [self.imageViewArray addObject:view];
    }
    
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
    
    UIImageView *lastView = nil ;
    for(NSInteger i = 0 ; i < perRowImages ; i++ ){
        UIImageView *imageView = [self.imageViewArray safeObjectAtIndex:i];
        [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentTextView.mas_bottom).mas_offset(vInterval);
            if(i % 3 == 0){
                make.left.mas_equalTo(self.contentTextView);
            }else{
                make.left.mas_equalTo(lastView.mas_right).mas_offset(space);
            }
            make.width.mas_equalTo(imageWidthHeight);
            make.height.mas_equalTo(imageWidthHeight);
        }];
        lastView = imageView ;
    }
    
    lastView = [self.imageViewArray safeObjectAtIndex:perRowImages-1];
    [self.moreImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(lastView);
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
    
    [KKWeiTouTiaoCellThree initAttriTextData:item];
    
    self.header.headUrl = item.user.avatar_url;
    self.header.name = item.user.screen_name;
    self.header.desc = item.user.verified_content;
    self.header.isFollow = [item.user.is_following boolValue];
    
    CGFloat textHeight = item.textContainer.attriTextHeight;
    self.contentTextView.textContainer = item.textContainer ;
    [self.contentTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(textHeight);
    }];
    
    YYImageCache *imageCache = [YYImageCache sharedCache];
    
    NSInteger imageCount = item.thumb_image_list.count;
    NSInteger count = MIN(perRowImages,imageCount);
    for(NSInteger i = 0 ; i < perRowImages ; i++){
        if(i < count){
            NSString *url = [item.thumb_image_list safeObjectAtIndex:i].url;
            if(!url.length || [url isKindOfClass:[NSNull class]]){
                url = @"";
            }
            UIImageView *view = [self.imageViewArray safeObjectAtIndex:i];
            view.hidden = NO ;
            
            [imageCache getImageForKey:url withType:YYImageCacheTypeMemory|YYImageCacheTypeDisk withBlock:^(UIImage * _Nullable image, YYImageCacheType type) {
                if(image){
                    [view setImage:image];
                }else{
                    [view yy_setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageWithColor:[UIColor grayColor]]];
                }
            }];
        }else{
            UIImageView *view = [self.imageViewArray safeObjectAtIndex:i];
            view.hidden = YES ;
            view.image = nil ;
        }
    }
    
    NSInteger diff = imageCount - perRowImages ;
    if(diff > 0){
        self.moreImageView.hidden = NO ;
        [self.moreImageView setTitle:[NSString stringWithFormat:@"+%ld",diff] forState:UIControlStateNormal];
        [self.bgView bringSubviewToFront:self.moreImageView];
    }else{
        self.moreImageView.hidden = YES ;
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
    [KKWeiTouTiaoCellThree initAttriTextData:item];
    if(item.itemCellHeight <= 0){
        item.itemCellHeight = HeadViewHeight + item.textContainer.attriTextHeight + descLabelHeight + BarViewHeight + space + imageWidthHeight + 5 * vInterval ;
    }
    return item.itemCellHeight;
}

#pragma mark -- 初始化标题文本

+ (void)initAttriTextData:(KKSummaryContent *)content{
    if(content.textContainer == nil ){
        if(!contentTextFont){
            contentTextFont = [UIFont systemFontOfSize:(iPhone5)?15:17];
        }
        TYTextContainer *item = [TYTextContainer new];
        item.linesSpacing = 3 ;
        item.textColor = [UIColor kkColorBlack];
        item.text = content.content;
        item.font = contentTextFont ;
        item.lineBreakMode = NSLineBreakByTruncatingTail;
        item.numberOfLines = 6 ;
        content.textContainer = [item createTextContainerWithTextWidth:[UIScreen mainScreen].bounds.size.width - 2 * kkPaddingNormal];
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
    NSInteger imageCount = self.item.thumb_image_list.count;
    if(index == -1){
        NSInteger count = MIN(perRowImages,imageCount);
        for(NSInteger i = 0 ; i < count ; i++){
            UIImageView *view = [self.imageViewArray safeObjectAtIndex:i];
            view.hidden = hidden ;
        }
    }else{
        NSInteger count = MIN(perRowImages,imageCount);
        if(index < count){
            UIImageView *view = [self.imageViewArray safeObjectAtIndex:index];
            view.hidden = hidden ;
        }
    }
}

#pragma mark -- 获取对应索引的的CGRect

- (CGRect)fetchImageFrameWithIndex:(NSInteger)index{
    UIImageView *view = [self.imageViewArray safeObjectAtIndex:index];
    if(index < perRowImages){
        return view.frame ;
    }else{
        UIImageView *view = [self.imageViewArray safeObjectAtIndex:0];
        return view.frame;
    }
    return view.frame;
}

#pragma mark -- 获取对应索引的的UIImage

- (UIImage *)fetchImageWithIndex:(NSInteger)index{
    UIImageView *view = [self.imageViewArray safeObjectAtIndex:index];
    return view.image ;
}

#pragma mark -- @property

- (NSMutableArray *)imageViewArray{
    if(!_imageViewArray){
        _imageViewArray = [NSMutableArray new];
    }
    return _imageViewArray;
}

- (UIButton *)moreImageView{
    if(!_moreImageView){
        _moreImageView = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            view.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
            [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [view.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [view addTarget:self action:@selector(showMoreImage) forControlEvents:UIControlEventTouchUpInside];
            view ;
        });
    }
    return _moreImageView;
}

@end
