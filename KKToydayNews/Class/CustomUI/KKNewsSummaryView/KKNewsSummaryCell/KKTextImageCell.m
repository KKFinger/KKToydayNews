//
//  KKTextImageCell.m
//  KKToydayNews
//
//  Created by finger on 2017/9/19.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKTextImageCell.h"
#import "TYAttributedLabel.h"

#define ContentTextFont [UIFont systemFontOfSize:17]
#define space 5.0
#define ButtonWdith 68
#define ButtonHeight 35
#define SplitViewHeight 5
#define ContentTextWidth ([UIScreen mainScreen].bounds.size.width - 2 * kkPaddingNormal)

@interface KKTextImageCell ()
@property(nonatomic)UIView *bgView ;
@property(nonatomic)TYAttributedLabel *contentLabel ;
@property(nonatomic)UIButton *upvoteBtn;
@property(nonatomic)UIButton *buryBtn;
@property(nonatomic)UIButton *favoriteBtn;
@property(nonatomic)UIButton *commentBtn;
@property(nonatomic)UIButton *shareBtn;
@property(nonatomic)UIView *splitView;
@property(nonatomic,readwrite)UIImageView *contentImageView;
@property(nonatomic,weak)KKSummaryContent *item;
@end

@implementation KKTextImageCell

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
    [self.bgView addSubview:self.contentLabel];
    [self.bgView addSubview:self.contentImageView];
    [self.bgView addSubview:self.upvoteBtn];
    [self.bgView addSubview:self.buryBtn];
    [self.bgView addSubview:self.commentBtn];
    [self.bgView addSubview:self.favoriteBtn];
    [self.bgView addSubview:self.shareBtn];
    [self.bgView addSubview:self.splitView];
    
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView).mas_offset(kkPaddingNormal);
        make.left.mas_equalTo(self.bgView).mas_offset(kkPaddingNormal);
        make.width.mas_equalTo(ContentTextWidth);
        make.height.mas_equalTo(1);
    }];
    
    [self.contentImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).mas_offset(space);
        make.left.mas_equalTo(self.contentLabel);
        make.width.mas_equalTo(self.contentLabel);
        make.height.mas_equalTo(0);
    }];
    
    [self.upvoteBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentImageView.mas_bottom).mas_offset(kkPaddingNormal);
        make.left.mas_equalTo(self.contentLabel);
        make.width.mas_equalTo(ButtonWdith);
        make.height.mas_equalTo(ButtonHeight);
    }];
    
    [self.buryBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.upvoteBtn);
        make.left.mas_equalTo(self.upvoteBtn.mas_right).mas_offset(space);
        make.width.mas_equalTo(ButtonWdith);
        make.height.mas_equalTo(ButtonHeight);
    }];
    
    [self.commentBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.upvoteBtn);
        make.left.mas_equalTo(self.buryBtn.mas_right).mas_offset(space);
        make.width.mas_equalTo(ButtonWdith);
        make.height.mas_equalTo(ButtonHeight);
    }];
    
    [self.shareBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.upvoteBtn);
        make.right.mas_equalTo(self).mas_offset(-kkPaddingNormal);
        make.width.mas_equalTo(ButtonHeight);
        make.height.mas_equalTo(ButtonHeight);
    }];
    
    [self.favoriteBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.upvoteBtn);
        make.right.mas_equalTo(self.shareBtn.mas_left).mas_offset(-space);
        make.width.mas_equalTo(ButtonHeight);
        make.height.mas_equalTo(ButtonHeight);
    }];
    
    [self.splitView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.upvoteBtn.mas_bottom).mas_offset(kkPaddingNormal);
        make.width.mas_equalTo(self.contentView);
        make.height.mas_equalTo(SplitViewHeight);
    }];
    
}

#pragma mark -- 界面刷新

- (void)refreshWithItem:(KKSummaryContent *)item{
    self.item = item ;
    
    [KKTextImageCell initAttriTextData:item];
    
    self.contentLabel.textContainer = item.textContainer;
    [self.contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.item.textContainer.attriTextHeight);
    }];
    
    if(item.large_image.url.length){
        CGFloat imageW = ContentTextWidth ;
        CGFloat imageH = imageW / (item.large_image.width  / item.large_image.height);
        
        NSString *url =item.large_image.url;
        if(!url.length){
            url = @"";
        }
        YYImageCache *imageCache = [YYImageCache sharedCache];
        [imageCache getImageForKey:url withType:YYImageCacheTypeMemory|YYImageCacheTypeDisk withBlock:^(UIImage * _Nullable image, YYImageCacheType type) {
            if(image){
                [self.contentImageView setImage:image];
            }else{
                [self.contentImageView yy_setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageWithColor:[UIColor grayColor]]];
            }
        }];
        
        [self.contentImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(imageH);
        }];
        [self.upvoteBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentImageView.mas_bottom).mas_offset(space);
        }];
    }else{
        [self.contentImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        [self.upvoteBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentImageView.mas_bottom).mas_offset(0);
        }];
    }
    self.contentImageView.alpha = 1.0 ;
    
    NSString *diggCount = [[NSNumber numberWithLong:item.digg_count.longLongValue]convert];
    [self.upvoteBtn setTitle:[NSString stringWithFormat:@" %@",diggCount] forState:UIControlStateNormal];
    
    NSString *buryCount = [[NSNumber numberWithLong:item.bury_count.longLongValue]convert];
    [self.buryBtn setTitle:[NSString stringWithFormat:@" %@",buryCount]  forState:UIControlStateNormal];
    
    NSString *commentCount = [[NSNumber numberWithLong:item.comment_count.longLongValue]convert];
    [self.commentBtn setTitle:[NSString stringWithFormat:@" %@",commentCount]  forState:UIControlStateNormal];
    
    self.favoriteBtn.selected = [item.user_repin boolValue] ;
}

+ (CGFloat)fetchHeightWithItem:(KKSummaryContent *)item{
    [KKTextImageCell initAttriTextData:item];
    if(item.itemCellHeight <= 0){
        if(item.large_image.url.length){
            CGFloat imageW = ContentTextWidth ;
            CGFloat imageH = imageW / (item.large_image.width / item.large_image.height);
            item.itemCellHeight = 3 * kkPaddingNormal + item.textContainer.attriTextHeight + ButtonHeight + SplitViewHeight + imageH + space;
        }else{
            item.itemCellHeight = 3 * kkPaddingNormal + item.textContainer.attriTextHeight + ButtonHeight + SplitViewHeight  ;
        }
    }
    return item.itemCellHeight;
}

#pragma mark -- 初始化标题文本

+ (void)initAttriTextData:(KKSummaryContent *)item{
    if(item.textContainer == nil ){
        TYTextContainer *temp = [TYTextContainer new];
        temp.linesSpacing = 3 ;
        temp.textColor = [UIColor kkColorBlack];
        temp.lineBreakMode = NSLineBreakByCharWrapping;
        temp.text = item.content;
        temp.font = ContentTextFont ;
        item.textContainer = [temp createTextContainerWithTextWidth:ContentTextWidth];
    }
}

#pragma mark -- 按钮事件

- (void)clickedBtn:(id)sender{
    UIButton *btn = (UIButton *)sender ;
    if(self.delegate && [self.delegate respondsToSelector:@selector(clickButtonWithType:item:)]){
        [self.delegate clickButtonWithType:btn.tag item:self.item];
    }
}

#pragma mark -- @property

- (UIView *)bgView{
    if(!_bgView){
        _bgView = ({
            UIView *view = [UIView new];
            view.backgroundColor = [UIColor whiteColor];
            view ;
        });
    }
    return _bgView;
}

- (TYAttributedLabel *)contentLabel{
    if(!_contentLabel){
        _contentLabel = ({
            TYAttributedLabel *view = [TYAttributedLabel new];
            view.textColor = [UIColor blackColor];
            view.font = ContentTextFont;
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByCharWrapping;
            view.numberOfLines = 0 ;
            view ;
        });
    }
    return _contentLabel;
}

- (UIButton *)upvoteBtn{
    if(!_upvoteBtn){
        _upvoteBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"like_old_feed_24x24_"] forState:UIControlStateNormal];
            [view setImage:[UIImage imageNamed:@"like_old_feed_press_24x24_"] forState:UIControlStateSelected];
            [view setTitleColor:[[UIColor blackColor]colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
            [view.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [view addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
            [view setTag:KKBarButtonTypeUpvote];
            view ;
        });
    }
    return _upvoteBtn;
}

- (UIButton *)commentBtn{
    if(!_commentBtn){
        _commentBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"comment_feed_24x24_"] forState:UIControlStateNormal];
            [view setTitleColor:[[UIColor blackColor]colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
            [view.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [view setTag:KKBarButtonTypeComment];
            [view addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
            view ;
        });
    }
    return _commentBtn;
}

- (UIButton *)shareBtn{
    if(!_shareBtn){
        _shareBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"feed_share_24x24_"] forState:UIControlStateNormal];
            [view setTitleColor:[[UIColor blackColor]colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
            [view.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [view setTag:KKBarButtonTypeShare];
            [view addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
            view ;
        });
    }
    return _shareBtn;
}

- (UIButton *)buryBtn{
    if(!_buryBtn){
        _buryBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"digdown_video_20x20_"] forState:UIControlStateNormal];
            [view setTitleColor:[[UIColor blackColor]colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
            [view.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [view setTag:KKBarButtonTypeBury];
            [view addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
            view ;
        });
    }
    return _buryBtn;
}

- (UIButton *)favoriteBtn{
    if(!_favoriteBtn){
        _favoriteBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view setImage:[UIImage imageNamed:@"love_video_20x20_"] forState:UIControlStateNormal];
            [view setImage:[UIImage imageNamed:@"love_video_press_20x20_"] forState:UIControlStateSelected];
            [view setTitleColor:[[UIColor blackColor]colorWithAlphaComponent:0.5] forState:UIControlStateNormal];
            [view.titleLabel setFont:[UIFont systemFontOfSize:13]];
            [view setTag:KKBarButtonTypeFavorite];
            [view addTarget:self action:@selector(clickedBtn:) forControlEvents:UIControlEventTouchUpInside];
            view ;
        });
    }
    return _favoriteBtn;
}

- (UIView *)splitView{
    if(!_splitView){
        _splitView = ({
            UIView *view = [UIView new];
            view.backgroundColor = KKColor(244, 245, 246, 1.0);
            view ;
        });
    }
    return _splitView;
}

- (UIImageView *)contentImageView{
    if(!_contentImageView){
        _contentImageView = ({
            UIImageView *view = [YYAnimatedImageView new];
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
                    [self.delegate clickImageWithItem:self.item rect:view.frame fromView:self.bgView image:view.image indexPath:self.indexPath];
                    view.alpha = 0 ;
                }
            }];
            view ;
        });
    }
    return _contentImageView;
}

@end
