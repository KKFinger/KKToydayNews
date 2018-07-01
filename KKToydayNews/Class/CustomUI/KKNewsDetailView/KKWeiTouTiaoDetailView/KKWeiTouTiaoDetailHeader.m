//
//  KKWeiTouTiaoDetailHeader.m
//  KKToydayNews
//
//  Created by finger on 2017/11/11.
//  Copyright © 2017年 finger. All rights reserved.
//

#define maxImageCount 9 //最大的图片个数
#define perRowImages 3 //每行
#define HeadViewHeight 40
#define space 5.0
#define imageWidthHeight ((([UIScreen mainScreen].bounds.size.width - 2 * kkPaddingNormal) - 2 * space) / perRowImages)
#define ContentTextFont [UIFont systemFontOfSize:(iPhone5)?15:17]
#define descLabelHeight 13
#define vInterval 10 //各个控件的垂直距离

#import "KKWeiTouTiaoDetailHeader.h"
#import "KKAuthorInfoView.h"
#import "KKImageBrowser.h"
#import "KKPersonalInfoView.h"
#import "TYAttributedLabel.h"

@interface KKWeiTouTiaoDetailHeader()<KKCommonDelegate,KKAuthorInfoViewDelegate>
@property(nonatomic)UIView *bgView ;
@property(nonatomic)TYAttributedLabel *contentTextView;
@property(nonatomic)UILabel *posAndReadCountLabel;
@property(nonatomic)UIImageView *positionView ;

@property(nonatomic)NSMutableArray<UIImageView *> *imageViewArray ;
@property(nonatomic,weak)KKSummaryContent *item ;
@property(nonatomic)TYTextContainer *textContainer;
@end

@implementation KKWeiTouTiaoDetailHeader

- (instancetype)init {
    self = [super init];
    if (self){
        self.backgroundColor = KKColor(244, 245, 246, 1.0);
        [self setupUI];
    }
    return self;
}

- (void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

- (void)setupUI {
    [super awakeFromNib];
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.authorView];
    [self.bgView addSubview:self.contentTextView];
    [self.bgView addSubview:self.positionView];
    [self.bgView addSubview:self.posAndReadCountLabel];
    
    for(NSInteger i = 0 ; i < maxImageCount ; i++){
        UIImageView *view = [YYAnimatedImageView new];
        view.contentMode = UIViewContentModeScaleAspectFill;
        view.userInteractionEnabled = YES ;
        @weakify(view);
        @weakify(self);
        [view addTapGestureWithBlock:^(UIView *gestureView) {
            @strongify(view);
            @strongify(self);
            NSArray *imageArray = self.item.large_image_list;
            for(NSInteger i = 0 ; i < imageArray.count ; i++){
                KKImageItem *item = [imageArray safeObjectAtIndex:i];
                item.image = [self.imageViewArray safeObjectAtIndex:i].image;
            }
            CGRect imageFrame = view.frame;
            imageFrame = [self.bgView convertRect:imageFrame toView:self];
            [self showWTTImageBrowserView:imageArray oriRect:imageFrame selIndex:i];
        }];
        [self.bgView addSubview:view];
        [self.imageViewArray addObject:view];
    }
    
    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self);
        make.width.mas_equalTo(self).priority(998);
        make.height.mas_equalTo(self).mas_offset(-space);
    }];

    [self.authorView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView).mas_offset(vInterval);
        make.left.mas_equalTo(self.bgView);
        make.width.mas_equalTo(self.bgView);
        make.height.mas_equalTo(HeadViewHeight);
    }];

    [self.contentTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.authorView.mas_bottom).mas_offset(vInterval);
        make.left.mas_equalTo(self.bgView).mas_offset(kkPaddingNormal);
        make.width.mas_equalTo(self.bgView).mas_offset(-2 * kkPaddingNormal).priority(998);
        make.height.mas_equalTo(1);
    }];

    UIImageView *lastView = nil ;
    for(NSInteger i = 0 ; i < maxImageCount ; i++ ){
        NSInteger row = i / perRowImages ;
        UIImageView *imageView = [self.imageViewArray safeObjectAtIndex:i];
        [imageView mas_updateConstraints:^(MASConstraintMaker *make) {
            if(row == 0){
                make.top.mas_equalTo(self.contentTextView.mas_bottom).mas_offset(vInterval);
            }else{
                UIImageView *view = [self.imageViewArray safeObjectAtIndex:(row -1) * 3]; make.top.mas_equalTo(view.mas_bottom).mas_offset(space);
            }
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

    [self.positionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.bgView).mas_offset(-vInterval);
        make.left.mas_equalTo(self.contentTextView);
        make.width.mas_equalTo(descLabelHeight);
        make.height.mas_equalTo(descLabelHeight);
    }];

    [self.posAndReadCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.positionView);
        make.left.mas_equalTo(self.positionView.mas_right).mas_offset(3).priority(998);
        make.right.mas_equalTo(self.bgView).mas_offset(-kkPaddingNormal);
    }];
}

#pragma mark -- 界面刷新

- (void)refreshWithItem:(KKSummaryContent *)item callback:(void(^)(CGFloat viewHeight))callback{
    self.item = item ;
    
    [self initAttriTextData:item];
    
    self.authorView.headUrl = item.user.avatar_url;
    self.authorView.name = item.user.screen_name;
    self.authorView.detail = item.user.verified_content;
    self.authorView.userId = item.user.user_id;
    
    self.contentTextView.textContainer = self.textContainer ;
    [self.contentTextView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.textContainer.attriTextHeight);
    }];
    
    NSInteger imageCount = item.thumb_image_list.count;
    if(!imageCount){
        for(UIImageView *view in self.imageViewArray){
            [view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
        }
    }else{
        for(UIImageView *view in self.imageViewArray){
            [view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
        }
        if(imageCount == 1){
            KKImageItem *imageItem = item.ugc_cut_image_list.firstObject;
            CGFloat width = [UIScreen mainScreen].bounds.size.width - 2 * kkPaddingNormal ;
            CGFloat height = width / (imageItem.width / imageItem.height) ;
            
            UIImageView *view = self.imageViewArray.firstObject ;
            [view mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(width);
                make.height.mas_equalTo(height);
            }];

            NSString *url = imageItem.url;
            if(!url.length){
                url = @"";
            }
            YYImageCache *imageCache = [YYImageCache sharedCache];
            UIImage *image = [imageCache getImageForKey:url withType:YYImageCacheTypeMemory];
            if(image){
                [view setImage:image];
            }else{
                [imageCache getImageForKey:url withType:YYImageCacheTypeDisk withBlock:^(UIImage * _Nullable image, YYImageCacheType type) {
                    if(image){
                        [view setImage:image];
                    }else{
                        [view yy_setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageWithColor:[UIColor grayColor]]];
                    }
                }];
            }
        }else{
            for(NSInteger i = 0 ; i < imageCount; i++){
                NSString *url = [item.thumb_image_list safeObjectAtIndex:i].url;
                if(!url.length || [url isKindOfClass:[NSNull class]]){
                    url = @"";
                }
                UIImageView *view = [self.imageViewArray safeObjectAtIndex:i];
                [view mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.width.mas_equalTo(imageWidthHeight);
                    make.height.mas_equalTo(imageWidthHeight);
                }];
                
                YYImageCache *imageCache = [YYImageCache sharedCache];
                UIImage *image = [imageCache getImageForKey:url withType:YYImageCacheTypeMemory];
                if(image){
                    [view setImage:image];
                }else{
                    [imageCache getImageForKey:url withType:YYImageCacheTypeDisk withBlock:^(UIImage * _Nullable image, YYImageCacheType type) {
                        if(image){
                            [view setImage:image];
                        }else{
                            [view yy_setImageWithURL:[NSURL URLWithString:url] placeholder:[UIImage imageWithColor:[UIColor grayColor]]];
                        }
                    }];
                }
            }
        }
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
    
    if(callback){
        callback([self fetchViewHeight]);
    }
}

- (CGFloat)fetchViewHeight{
    NSInteger imageCont = self.item.thumb_image_list.count;
    if(imageCont == 0){
        return HeadViewHeight + self.textContainer.attriTextHeight + descLabelHeight + 4 * vInterval + space;
    }else if(imageCont == 1){
        KKImageItem *imageItem = self.item.ugc_cut_image_list.firstObject;
        CGFloat width = [UIScreen mainScreen].bounds.size.width - 2 * kkPaddingNormal ;
        CGFloat height = width / (imageItem.width / imageItem.height) ;
        return HeadViewHeight + self.textContainer.attriTextHeight + descLabelHeight + space + height + 5 * vInterval;
    }
    
    NSInteger row = 0;
    if(self.item.thumb_image_list.count % perRowImages){
        row = self.item.thumb_image_list.count / perRowImages + 1;
    }else{
        row = self.item.thumb_image_list.count / perRowImages;
    }
    return HeadViewHeight + self.textContainer.attriTextHeight + descLabelHeight + 5 * vInterval + row * imageWidthHeight + row * space;
}

#pragma mark -- KKUserBarViewDelegate

- (void)clickButtonWithType:(KKBarButtonType)type{
    
}

#pragma mark -- KKAuthorInfoViewDelegate

- (void)setConcern:(BOOL)isConcern callback:(void (^)(BOOL))callback{
    if(callback){
        callback(YES);
    }
}

- (void)clickedUserHeadWithUserId:(NSString *)userId{
    KKPersonalInfoView *view = [[KKPersonalInfoView alloc]initWithUserId:userId willDissmissBlock:^{
        
    }];
    view.topSpace = 0 ;
    view.navContentOffsetY = KKStatusBarHeight / 2.0 ;
    view.navTitleHeight = KKNavBarHeight ;
    
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(UIDeviceScreenWidth, UIDeviceScreenHeight));
    }];
    [view pushIn];
}

#pragma mark -- 初始化标题文本

- (void)initAttriTextData:(KKSummaryContent *)item{
    if(self.textContainer == nil ){
        TYTextContainer *temp = [TYTextContainer new];
        temp.linesSpacing = 3 ;
        temp.textColor = [UIColor kkColorBlack];
        temp.lineBreakMode = NSLineBreakByCharWrapping;
        temp.text = item.content;
        temp.font = ContentTextFont ;
        self.textContainer = [temp createTextContainerWithTextWidth:[UIScreen mainScreen].bounds.size.width - 2 * kkPaddingNormal];
    }
}

#pragma mark -- 微头条图片浏览
/**
 微头条图片浏览
 
 @param imageArray 图片数组，KKImageItem
 @param oriRect 点击图片的原始frame
 @param selIndex 点击的图片
 */
- (void)showWTTImageBrowserView:(NSArray<KKImageItem *> *)imageArray oriRect:(CGRect)oriRect selIndex:(NSInteger)selIndex{
    KKImageBrowser *browser = [[KKImageBrowser alloc]initWithImageArray:imageArray oriView:self.bgView oriFrame:oriRect];
    browser.topSpace = 0 ;
    browser.frame = CGRectMake(0, 0, UIDeviceScreenWidth, UIDeviceScreenHeight);
    browser.defaultHideAnimateWhenDragFreedom = NO ;
    browser.showImageWithUrl = YES ;
    browser.selIndex = selIndex;
    
    @weakify(browser);
    [browser setHideImageAnimate:^(UIImage *image,CGRect fromFrame,CGRect toFrame){
        @strongify(browser);
        UIImageView *imageView = [YYAnimatedImageView new];
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = fromFrame ;
        imageView.layer.masksToBounds = YES ;
        [self.bgView addSubview:imageView];
        [UIView animateWithDuration:0.3 animations:^{
            imageView.frame = toFrame;
        }completion:^(BOOL finished) {
            [imageView removeFromSuperview];
            [browser removeFromSuperview];
            for(UIImageView *imageView in self.imageViewArray){
                imageView.hidden = NO ;
            }
        }];
    }];
    
    [browser setAlphaViewIfNeed:^(BOOL alphaView,NSInteger index){
        for(UIImageView *imageView in self.imageViewArray){
            imageView.hidden = NO ;
        }
        UIImageView *imageView = [self.imageViewArray safeObjectAtIndex:index];
        imageView.hidden = alphaView;
    }];
    
    [browser setImageIndexChange:^(NSInteger imageIndex, void (^updeteOriFrame)(CGRect oriFrame)) {
        UIImageView *imageView = [self.imageViewArray safeObjectAtIndex:imageIndex];
        CGRect imageFrame = imageView.frame;
        imageFrame = [self.bgView convertRect:imageFrame toView:self];
        if(updeteOriFrame){
            updeteOriFrame(imageFrame);
        }
    }];
    
    [[UIApplication sharedApplication].keyWindow addSubview:browser];
    [browser viewWillAppear];
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

- (KKAuthorInfoView *)authorView{
    if(!_authorView){
        _authorView = ({
            KKAuthorInfoView *view = [KKAuthorInfoView new];
            view.delegate = self ;
            view.headerSize = CGSizeMake(35, 35);
            view ;
        });
    }
    return _authorView;
}

- (TYAttributedLabel *)contentTextView{
    if(!_contentTextView){
        _contentTextView = ({
            TYAttributedLabel *view = [TYAttributedLabel new];
            view.textColor = [UIColor blackColor];
            view.font = ContentTextFont;
            view.textAlignment = NSTextAlignmentLeft;
            view.lineBreakMode = NSLineBreakByTruncatingTail;
            view.numberOfLines = 0 ;
            view ;
        });
    }
    return _contentTextView;
}

- (UIImageView *)positionView{
    if(!_positionView){
        _positionView = ({
            UIImageView *view = [UIImageView new];
            view.image = [UIImage imageNamed:@"pgc_discover_28x28_"];
            view.layer.masksToBounds = YES ;
            view ;
        });
    }
    return _positionView ;
}

- (UILabel *)posAndReadCountLabel{
    if(!_posAndReadCountLabel){
        _posAndReadCountLabel = ({
            UILabel *view = [UILabel new];
            [view setTextColor:[UIColor grayColor]];
            [view setTextAlignment:NSTextAlignmentLeft];
            [view setFont:[UIFont systemFontOfSize:11]];
            view ;
        });
    }
    return _posAndReadCountLabel;
}

- (NSMutableArray *)imageViewArray{
    if(!_imageViewArray){
        _imageViewArray = [NSMutableArray new];
    }
    return _imageViewArray;
}

@end
