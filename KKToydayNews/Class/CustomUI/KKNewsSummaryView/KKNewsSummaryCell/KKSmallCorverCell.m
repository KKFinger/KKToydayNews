//
//  KKSmallCorverCell.m
//  KKToydayNews
//
//  Created by finger on 2017/9/16.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKSmallCorverCell.h"

#define space 5.0
#define KKTitleWidth ([UIScreen mainScreen].bounds.size.width - 2 * kkPaddingNormal)
#define imageWidth ((KKTitleWidth - 2 * space) / 3.0)
#define imageHeight (imageWidth * 3 / 4)

@interface KKSmallCorverCell ()
@property(nonatomic,strong)UIView *imageContentView;
@end

@implementation KKSmallCorverCell

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
    [self.bgView addSubview:self.imageContentView];
    [self.bgView addSubview:self.titleLabel];
    [self.bgView addSubview:self.leftBtn];
    [self.bgView addSubview:self.descLabel];
    [self.bgView addSubview:self.shieldBtn];
    [self.bgView addSubview:self.splitView];
    [self.bgView addSubview:self.newsTipBtn];
    
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView).mas_offset(kkPaddingLarge);
        make.left.mas_equalTo(self.bgView).mas_offset(kkPaddingNormal);
        make.width.mas_equalTo(KKTitleWidth);
        make.height.mas_equalTo(0);
    }];
    
    [self.imageContentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(space);
        make.width.mas_equalTo(KKTitleWidth);
        make.height.mas_equalTo(imageHeight);
    }];
    
    UIImageView *lastView = nil ;
    for(NSInteger i = 0 ; i < 3 ; i++ ){
        UIImageView *view = [self createImageView];
        view.tag = 1000 + i ;
        [self.imageContentView addSubview:view];
        if(i == 0){
            [view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.imageContentView);
                make.left.mas_equalTo(self.imageContentView);
                make.width.mas_equalTo(imageWidth);
                make.height.mas_equalTo(imageHeight);
            }];
        }else{
            [view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(lastView);
                make.left.mas_equalTo(lastView.mas_right).mas_offset(space);
                make.width.mas_equalTo(imageWidth);
                make.height.mas_equalTo(imageHeight);
            }];
        }
        lastView = view ;
    }
    
    self.newsTipBtn.layer.cornerRadius = newsTipBtnHeight/2.0 ;
    [self.newsTipBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(lastView).mas_offset(-space);
        make.bottom.mas_equalTo(lastView).mas_offset(-space);
        make.width.mas_equalTo(35);
        make.height.mas_equalTo(newsTipBtnHeight);
    }];
    
    [self.leftBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.titleLabel);
        make.top.mas_equalTo(lastView.mas_bottom).mas_offset(space + 3);
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
    
    [KKSmallCorverCell initAttriTextData:item];
    
    SDImageCache *imageCache = [SDImageCache sharedImageCache];
    for(NSInteger i = 0 ; i < 3 ; i++){
        NSString *url = [item.image_list safeObjectAtIndex:i].url;
        if(!url.length || [url isKindOfClass:[NSNull class]]){
            url = @"";
        }
        UIImageView *view = [self.bgView viewWithTag:1000+i];
        [imageCache queryCacheOperationForKey:url done:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
            if(image){
                [view setImage:image];
            }else{
                [view kk_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageWithColor:[UIColor grayColor]] animate:YES];
            }
        }];
    }
    
    NSString *publishTime = [NSString stringIntervalSince1970RuleOne:item.publish_time.longLongValue];
    NSString *commentCnt = [[NSNumber numberWithLong:item.comment_count.longLongValue]convert];
    self.descLabel.text = [NSString stringWithFormat:@"%@  %@评论  %@",item.source,commentCnt,publishTime];
    
    self.titleLabel.textContainer = item.textContainer;
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.item.textContainer.attriTextHeight);
    }];
    
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
    [KKSmallCorverCell initAttriTextData:item];
    if(item.itemCellHeight <= 0){
        item.itemCellHeight = 2 * kkPaddingLarge + 2 * space + imageHeight + item.textContainer.attriTextHeight + descLabelHeight ;
    }
    return item.itemCellHeight;
}

#pragma mark -- 初始化标题文本

+ (void)initAttriTextData:(KKSummaryContent *)content{
    if(content.textContainer == nil ){
        TYTextContainer *item = [TYTextContainer new];
        item.linesSpacing = 3 ;
        item.textColor = [UIColor kkColorBlack];
        item.lineBreakMode = NSLineBreakByTruncatingTail;
        item.text = content.title;
        item.font = KKTitleFont ;
        item.numberOfLines = 2 ;
        content.textContainer =[item createTextContainerWithTextWidth:KKTitleWidth];
    }
}

- (UIImageView *)createImageView{
    UIImageView *view = [UIImageView new];
    view.contentMode = UIViewContentModeScaleAspectFill;
    view.layer.masksToBounds = YES ;
    view.layer.borderWidth = 0.5;
    view.layer.borderColor = [[UIColor grayColor]colorWithAlphaComponent:0.1].CGColor;
    return view ;
}

#pragma mark -- 

- (UIView *)imageContentView{
    if(!_imageContentView){
        _imageContentView = ({
            UIView *view = [UIView new];
            view.userInteractionEnabled = YES ;
            @weakify(view);
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(view);
                @strongify(self);
                if(self.delegate && [self.delegate respondsToSelector:@selector(clickImageWithItem:rect:fromView:image:indexPath:)]){
                    [self.delegate clickImageWithItem:self.item rect:view.frame fromView:self.bgView image:nil indexPath:nil];
                }
            }];
            view ;
        });
    }
    return _imageContentView;
}

@end
