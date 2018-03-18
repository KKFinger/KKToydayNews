//
//  KKPictureCell.m
//  KKToydayNews
//
//  Created by finger on 2017/10/11.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKPictureCell.h"

#define space 5.0
#define KKTitleWidth ([UIScreen mainScreen].bounds.size.width - 2 * kkPaddingNormal)
#define imageHeight ([UIScreen mainScreen].bounds.size.width * 3 / 5)
#define SplitViewHeight 8

@interface KKPictureCell ()
@property(nonatomic,strong,readwrite)UIImageView *largeImgView ;
@end

@implementation KKPictureCell

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
    [self.largeImgView addSubview:self.newsTipBtn];
    [self.bgView addSubview:self.descLabel];
    [self.bgView addSubview:self.shieldBtn];
    [self.bgView addSubview:self.splitView];
    
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.largeImgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView);
        make.left.mas_equalTo(self.bgView);
        make.width.mas_equalTo(self.bgView);
        make.height.mas_equalTo(imageHeight);
    }];
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.largeImgView.mas_bottom).mas_offset(space);
        make.left.mas_equalTo(self.bgView).mas_offset(kkPaddingNormal);
        make.width.mas_equalTo(KKTitleWidth);
        make.height.mas_equalTo(0);
    }];
    
    self.newsTipBtn.layer.cornerRadius = newsTipBtnHeight/2.0 ;
    [self.newsTipBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.largeImgView).mas_offset(-space);
        make.bottom.mas_equalTo(self.largeImgView).mas_offset(-space);
        make.width.mas_equalTo(35);
        make.height.mas_equalTo(newsTipBtnHeight);
    }];
    
    [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(space);
        make.width.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(descLabelHeight);
    }];
    
    [self.shieldBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.titleLabel);
        make.centerY.mas_equalTo(self.descLabel);
        make.width.mas_equalTo(descLabelHeight);
        make.height.mas_equalTo(descLabelHeight);
    }];
    
    [self.splitView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bgView);
        make.bottom.mas_equalTo(self.bgView);
        make.width.mas_equalTo(self.bgView);
        make.height.mas_equalTo(SplitViewHeight);
    }];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark -- 界面刷新

- (void)refreshWithItem:(KKSummaryContent *)item{
    self.item = item ;
    
    [KKPictureCell initAttriTextData:item];
    
    NSString *url = item.large_image_list.firstObject.url;
    if(!url.length){
        url = item.image_list.firstObject.url;
    }
    if(!url.length){
        url = @"";
    }
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    UIImage *image = [imageCache imageFromCacheForKey:url] ;
    if(image){
        [self.largeImgView setImage:image];
    }else{
        @weakify(imageCache);
        [imageCache diskImageExistsWithKey:url completion:^(BOOL isInCache) {
            @strongify(imageCache);
            if(isInCache){
                [self.largeImgView setImage:[imageCache imageFromCacheForKey:url]];
            }else{
                [self.largeImgView kk_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageWithColor:[UIColor grayColor]] animate:YES];
            }
        }];
    }
    [self.largeImgView setAlpha:1.0];
    
    NSString *commentCnt = [[NSNumber numberWithLong:item.comment_count.longLongValue]convert];
    self.descLabel.text = [NSString stringWithFormat:@"%@  %@评论",item.source,commentCnt];
    
    self.titleLabel.attributedText = item.attriTextData.attriText;
    self.titleLabel.lineBreakMode = item.attriTextData.lineBreak;
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(item.attriTextData.attriTextHeight);
    }];
    
    NSInteger picCnt = [item.gallary_image_count integerValue];
    [self.bgView bringSubviewToFront:self.newsTipBtn];
    [self.newsTipBtn setTitle:[NSString stringWithFormat:@"%ld图",picCnt] forState:UIControlStateNormal];
    
    NSInteger newsTipWidth = [self fetchNewsTipWidth];
    [self.newsTipBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(newsTipWidth + 15) ;
    }];
}

+ (CGFloat)fetchHeightWithItem:(KKSummaryContent *)item{
    
    [KKPictureCell initAttriTextData:item];
    
    return kkPaddingLarge + 2 * space + imageHeight + item.attriTextData.attriTextHeight + descLabelHeight + SplitViewHeight;
}

+ (void)initAttriTextData:(KKSummaryContent *)item{
    if(item.attriTextData == nil ){
        item.attriTextData = [KKAttriTextData new];
        item.attriTextData.lineSpace = 3 ;
        item.attriTextData.textColor = [UIColor kkColorBlack];
        item.attriTextData.lineBreak = NSLineBreakByTruncatingTail;
        item.attriTextData.originalText = item.title;
        item.attriTextData.maxAttriTextWidth = KKTitleWidth ;
        item.attriTextData.textFont = KKTitleFont ;
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
    return _largeImgView;
}

@end
