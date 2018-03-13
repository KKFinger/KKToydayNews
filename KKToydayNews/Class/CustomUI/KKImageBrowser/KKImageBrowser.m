//
//  KKImageBrowser.m
//  KKToydayNews
//
//  Created by finger on 2017/10/13.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKImageBrowser.h"
#import "KKPhotoManager.h"
#import "KKBlockAlertView.h"
#import "KKAppTools.h"
#import "KKImageZoomView.h"
#import "KKGalleryPreviewCell.h"
#import "KKNetworkTool.h"

#define ImageHorizPading 20 //每张图片之间的间距
#define ImageItemWith (UIDeviceScreenWidth + ImageHorizPading)
#define imageCellHeight UIDeviceScreenHeight

static NSString *cellReuseIdentifier = @"cellReuseIdentifier";

@interface KKImageBrowser ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,KKImageZoomViewDelegate>
@property(nonatomic)UICollectionView *collectView;
@property(nonatomic)UILabel *indexLabel;
@property(nonatomic)UIButton *saveBtn;
@property(nonatomic,copy)NSArray<KKImageItem *> *imageArray;
@property(nonatomic,assign)CGRect oriFrame;
@property(nonatomic,weak)UIView *oriView;
@property(nonatomic,weak)KKBlockAlertView *alertView;
@end

@implementation KKImageBrowser

- (instancetype)initWithImageArray:(NSArray<KKImageItem *>*)imageArray oriView:(UIView *)oriView oriFrame:(CGRect)oriFrame{
    self = [super init];
    if(self){
        self.imageArray = imageArray;
        self.oriFrame = oriFrame;
        self.oriView = oriView;
        self.showImageWithUrl = NO ;
        self.selIndex = 0 ;
    }
    return self ;
}

#pragma mark -- 视图的显示和消失

- (void)viewWillAppear{
    [super viewWillAppear];
    [self layoutUI];
    [self showEnterAnimate];
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:NO];
}

- (void)viewWillDisappear{
    [super viewWillDisappear];
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:NO];
}

- (void)viewDidAppear{
    [super viewDidAppear];
}

- (void)dealloc{
}

#pragma mark -- 设置UI

- (void)layoutUI{
    [self.dragContentView setBackgroundColor:[UIColor blackColor]];
    [self.dragContentView addSubview:self.collectView];
    [self.dragContentView addSubview:self.indexLabel];
    [self.dragContentView addSubview:self.saveBtn];
    
    [self.collectView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.height.mas_equalTo(self.dragContentView);
        make.width.mas_equalTo(ImageItemWith);
    }];
    
    [self.indexLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dragContentView).mas_offset(kkPaddingNormal);
        make.bottom.mas_equalTo(self.dragContentView).mas_offset(-kkPaddingNormal);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(25);
    }];
    
    [self.saveBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.dragContentView).mas_offset(-kkPaddingNormal);
        make.bottom.mas_equalTo(self.dragContentView).mas_offset(-kkPaddingNormal);
        make.width.mas_equalTo(40);
        make.height.mas_equalTo(25);
    }];
    
    [self layoutIfNeeded];
    
    self.indexLabel.text = [NSString stringWithFormat:@"%ld/%ld",self.selIndex + 1 , self.imageArray.count];
    
    [self.collectView setContentSize:CGSizeMake(ImageItemWith * self.imageArray.count, UIDeviceScreenHeight)];
    [self.collectView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.selIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

#pragma mark -- 进入视图时的动画

- (void)showEnterAnimate{
    if(!self.showImageWithUrl){
        UIImage *image = [self.imageArray safeObjectAtIndex:self.selIndex].image;
        [self startAnimateWithImage:image];
    }else{
        KKImageItem *item = [self.imageArray safeObjectAtIndex:self.selIndex];
        [[SDWebImageManager sharedManager]cachedImageExistsForURL:[NSURL URLWithString:item.url] completion:^(BOOL isInCache) {
            if(isInCache){
                NSString *key = [[SDWebImageManager sharedManager]cacheKeyForURL:[NSURL URLWithString:item.url]];
                UIImage *image = [[SDWebImageManager sharedManager].imageCache imageFromCacheForKey:key];
                [self startAnimateWithImage:image];
            }else{
                self.collectView.alpha = 1.0 ;
                self.indexLabel.alpha = 1.0 ;
                self.saveBtn.alpha = 1.0 ;
            }
        }];
    }
}

- (void)startAnimateWithImage:(UIImage *)image{
    CGFloat imageW = UIDeviceScreenWidth;
    CGFloat imageH = imageW / (image.size.width / image.size.height);
    CGRect frame = CGRectMake(0, (self.dragContentView.height - imageH) / 2.0, imageW, imageH);
    if(imageH > imageCellHeight){
        frame = CGRectMake(0, 0, imageW, imageH);
    }
    
    CGRect fromRect = [self.oriView convertRect:self.oriFrame toView:self.dragContentView];
    UIImageView *imageView = [YYAnimatedImageView new];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.layer.masksToBounds = YES ;
    imageView.image = image;
    imageView.frame = fromRect;
    [self.dragContentView addSubview:imageView];
    
    [UIView animateWithDuration:0.3 animations:^{
        imageView.frame = frame;
    }completion:^(BOOL finished) {
        [imageView removeFromSuperview];
        self.collectView.alpha = 1.0 ;
        self.indexLabel.alpha = 1.0 ;
        self.saveBtn.alpha = 1.0 ;
    }];
}

#pragma mark -- 保存图片

- (void)saveBtnClicked{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        KKPhotoAuthorizationStatus status = [[KKPhotoManager sharedInstance]authorizationStatus];
        while (status == KKPhotoAuthorizationStatusNotDetermined) {
            usleep(1.0 * 1000.0);
            status = [[KKPhotoManager sharedInstance]authorizationStatus] ;
        }
        if(status == KKPhotoAuthorizationStatusAuthorized){
            dispatch_async(dispatch_get_main_queue(), ^{
                [self saveImageWithUrl:[self.imageArray safeObjectAtIndex:self.selIndex].url];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                KKBlockAlertView *view = [KKBlockAlertView new];
                [view showWithTitle:@"相册权限" message:@"KK头条没有相册权限" cancelButtonTitle:@"知道了" otherButtonTitles:@"去设置" block:^(NSInteger re_code, NSDictionary *userInfo) {
                    if(re_code == 1){
                        [KKAppTools jumpToSetting];
                    }
                }];
            });
        }
    });
}

- (void)saveImageWithUrl:(NSString *)url{
    if(!url.length){
        url = @"";
    }
    
    [self.dragContentView showActivityViewWithImage:@"liveroom_rotate_55x55_"];
    
    NSString *albumId = [[KKPhotoManager sharedInstance]createAlbumIfNeedWithName:KKNewsAlbumName];
    [[SDWebImageManager sharedManager]loadImageWithURL:[NSURL URLWithString:url] options:SDWebImageContinueInBackground progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        if(data){
            [[KKPhotoManager sharedInstance]addImageData:data toAlbumId:albumId block:^(BOOL suc) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(suc){
                        [self promptMessage:@"保存成功"];
                    }else{
                        [self promptMessage:@"保存失败"];
                    }
                    [self.dragContentView hiddenActivity];
                });
            }];
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self promptMessage:@"保存失败"];
                [self.dragContentView hiddenActivity];
            });
        }
    }];
}

#pragma mark -- UICollectionViewDelegate,UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imageArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    KKImageItem *item = [self.imageArray safeObjectAtIndex:indexPath.row];
    KKGalleryPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    cell.conetntImageView.zoomViewDelegate = self;
    if(self.showImageWithUrl){
        [cell showImageWithUrl:item.url placeHolder:item.image];
    }else{
        cell.image = item.image;
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(ImageItemWith, UIDeviceScreenHeight);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
}

//设置水平间距 (同一行的cell的左右间距）
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

//垂直间距 (同一列cell上下间距)
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark -- KKImageZoomViewDelegate

- (void)tapImageZoomView{
    KKGalleryPreviewCell *cell = (KKGalleryPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selIndex inSection:0]];
    KKImageZoomView *view = cell.conetntImageView;
    UIImageView *imageView = view.imageView;
    
    if(view.zoomScale != 1.0){
        return ;
    }
    
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:NO];
    
    self.dragViewBg.alpha = 0;
    self.dragContentView.backgroundColor = [UIColor clearColor];
    self.indexLabel.alpha = 0.0;
    self.saveBtn.alpha = 0.0;
    
    UIImage *image = [self.imageArray safeObjectAtIndex:self.selIndex].image;
    if(image){
        imageView.hidden = YES ;
        CGRect frame = [self.dragContentView convertRect:imageView.frame toView:self.oriView];
        if(self.alphaViewIfNeed){
            self.alphaViewIfNeed(YES,self.selIndex);
        }
        if(self.hideImageAnimate){
            self.hideImageAnimate(image,frame,self.oriFrame);
        }
    }else{
        imageView.hidden = NO ;
        [self popOutToTop:self.dragContentView.top < 0];
    }
}

- (void)imageViewDidZoom:(KKImageZoomView *)zoomView{
    
    self.dragContentView.backgroundColor = [UIColor blackColor];
    
    CGFloat zoomScale = zoomView.zoomScale;
    if(zoomScale != zoomView.minimumZoomScale){
        self.enableHorizonDrag = NO ;
        self.enableVerticalDrag = NO ;
    }else{
        self.enableHorizonDrag = (self.selIndex == 0);
        self.enableVerticalDrag = YES ;
    }
    self.enableFreedomDrag = NO ;
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    self.enableHorizonDrag = NO ;
    self.enableVerticalDrag = NO ;
    self.enableFreedomDrag = NO ;
    
    CGPoint offset = self.collectView.contentOffset;
    CGFloat progress = offset.x / (CGFloat)ImageItemWith;
    
    //设置上下、当前三张图片的透明度
    NSInteger nextIndex = self.selIndex + 1 ;
    if(nextIndex < self.imageArray.count){
        KKGalleryPreviewCell *cell = (KKGalleryPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:nextIndex inSection:0]];
        [cell setAlpha:fabs(progress-self.selIndex)];
    }
    
    KKGalleryPreviewCell *cell = (KKGalleryPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selIndex inSection:0]];
    [cell setAlpha:1 - fabs((progress-self.selIndex))];
    
    NSInteger perIndex = self.selIndex - 1 ;
    if(perIndex >= 0){
        KKGalleryPreviewCell *cell = (KKGalleryPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:perIndex inSection:0]];
        [cell setAlpha:fabs((self.selIndex - progress))];
    }
}

//结束拉拽视图
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
}

//完全停止滚动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint offset = self.collectView.contentOffset;
    NSInteger index = offset.x / (CGFloat)ImageItemWith;
    if(index < 0 || index >= self.imageArray.count){
        return ;
    }
    
    self.selIndex = index ;
    
    KKGalleryPreviewCell *cell = (KKGalleryPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selIndex inSection:0]];
    [cell setAlpha:1.0];
    
    NSInteger nextIndex = self.selIndex + 1 ;
    if(nextIndex < self.imageArray.count){
        KKGalleryPreviewCell *cell = (KKGalleryPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:nextIndex inSection:0]];
        [cell setAlpha:1.0];
    }
    
    NSInteger perIndex = self.selIndex - 1 ;
    if(perIndex >= 0){
        KKGalleryPreviewCell *cell = (KKGalleryPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:perIndex inSection:0]];
        [cell setAlpha:1.0];
    }
    
    KKImageZoomView *view = cell.conetntImageView;
    CGFloat zoomScale = view.zoomScale;
    if(zoomScale == view.minimumZoomScale){
        self.enableHorizonDrag = (index == 0);
        self.enableVerticalDrag = YES ;
    }
    self.enableFreedomDrag = NO ;
    
    self.indexLabel.text = [NSString stringWithFormat:@"%ld/%ld",self.selIndex + 1 , self.imageArray.count];
    
    if(self.imageIndexChange){
        self.imageIndexChange(self.selIndex, ^(CGRect oriFrame) {
            self.oriFrame = oriFrame;
        });
    }
}

#pragma mark -- 开始、拖拽中、结束拖拽

- (void)dragBeginWithPoint:(CGPoint)pt{
    self.enableFreedomDrag = NO ;
    KKGalleryPreviewCell *cell = (KKGalleryPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selIndex inSection:0]];
    KKImageZoomView *view = cell.conetntImageView;
    UIImageView *imageView = view.imageView;
    if(view.zoomScale != view.minimumZoomScale){
        return ;
    }
    
    self.enableVerticalDrag = (view.contentSize.height <= cell.height);
    self.enableHorizonDrag = (view.contentSize.height <= cell.height);
    
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:NO];
    
    //只有选中图片且不在缩放的情况下才允许自由拖拽
    CGPoint targetPt = [self.dragContentView convertPoint:pt toView:view];
    if(CGRectContainsPoint(imageView.frame, targetPt) && (view.contentSize.height <= cell.height)){
        self.enableFreedomDrag = YES ;
        view.bounces = NO ;
        view.scrollEnabled = NO ;
    }
    
    if(self.alphaViewIfNeed){
        self.alphaViewIfNeed(self.enableFreedomDrag&&!self.defaultHideAnimateWhenDragFreedom,self.selIndex);
    }
}

- (void)dragingWithPoint:(CGPoint)pt{
    self.collectView.scrollEnabled = NO ;
    self.collectView.bounces = NO ;
    if(self.enableFreedomDrag){
        self.indexLabel.alpha = 0;
        self.saveBtn.alpha = 0;
        self.dragContentView.backgroundColor = [UIColor clearColor];
        
        KKGalleryPreviewCell *cell = (KKGalleryPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selIndex inSection:0]];
        KKImageZoomView *view = cell.conetntImageView;
        UIImageView *imageView = view.imageView;
        
        view.zoomScale = 1.0;
        view.scrollEnabled = NO ;
        view.bounces = NO ;
        
        imageView.layer.transform = CATransform3DMakeScale(self.dragViewBg.alpha,self.dragViewBg.alpha,0);
    }
}

- (void)dragEndWithPoint:(CGPoint)pt shouldHideView:(BOOL)hideView{
    KKGalleryPreviewCell *cell = (KKGalleryPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selIndex inSection:0]];
    KKImageZoomView *view = cell.conetntImageView;
    UIImageView *imageView = view.imageView;
    
    view.bounces = YES ;
    view.scrollEnabled = YES ;
    
    self.collectView.bounces = YES ;
    self.collectView.scrollEnabled = YES ;
    
    if(view.zoomScale != view.minimumZoomScale){
        return ;
    }
    
    if(self.enableFreedomDrag){
        if(!hideView){
            [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:NO];
            [UIView animateWithDuration:0.3 animations:^{
                imageView.layer.transform = CATransform3DIdentity;
                self.indexLabel.alpha = 1.0;
                self.saveBtn.alpha = 1.0;
                self.collectView.alpha = 1.0;
                self.dragViewBg.alpha = 1.0 ;
            }completion:^(BOOL finished) {
                self.dragContentView.backgroundColor = [UIColor blackColor];
            }];
        }else{
            
            [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:NO];
            
            self.dragViewBg.alpha = 0;
            self.dragContentView.backgroundColor = [UIColor clearColor];
            self.indexLabel.alpha = 0.0;
            self.saveBtn.alpha = 0.0;
            
            UIImage *image = [self.imageArray safeObjectAtIndex:self.selIndex].image;
            if(image){
                imageView.hidden = YES ;
                CGRect frame = [self.dragContentView convertRect:imageView.frame toView:self.oriView];
                if(self.hideImageAnimate){
                    self.hideImageAnimate(image,frame,self.oriFrame);
                }
            }else{
                imageView.hidden = NO ;
                [self popOutToTop:self.dragContentView.top < 0];
            }
        }
    }else{
        [[UIApplication sharedApplication]setStatusBarHidden:!hideView withAnimation:NO];
        if(self.alphaViewIfNeed){
            self.alphaViewIfNeed(!hideView,self.selIndex);
        }
    }
    
    self.enableFreedomDrag = NO ;
    self.enableHorizonDrag = (self.selIndex == 0) ;
    self.enableVerticalDrag = YES ;
}

#pragma mark -- @property

- (UICollectionView *)collectView{
    if(!_collectView){
        _collectView = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
            layout.scrollDirection =  UICollectionViewScrollDirectionHorizontal;
            UICollectionView *view = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
            view.delegate= self;
            view.dataSource= self;
            view.showsHorizontalScrollIndicator = NO ;
            view.showsVerticalScrollIndicator = NO ;
            view.pagingEnabled = YES ;
            view.alpha = 0 ;
            view.tag = KKViewTagImageDetailView;
            view.backgroundColor = [UIColor clearColor];
            [view registerClass:[KKGalleryPreviewCell class] forCellWithReuseIdentifier:cellReuseIdentifier];
            if(IOS11_OR_LATER){
                KKAdjustsScrollViewInsets(view);
            }
            view;
        });
    }
    return _collectView;
}

- (UILabel *)indexLabel{
    if(!_indexLabel){
        _indexLabel = ({
            UILabel *view = [UILabel new];
            view.textColor = [UIColor whiteColor];
            view.textAlignment = NSTextAlignmentCenter;
            view.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
            view.font = [UIFont systemFontOfSize:15];
            view.alpha = 0 ;
            view ;
        });
    }
    return _indexLabel;
}

- (UIButton *)saveBtn{
    if(!_saveBtn){
        _saveBtn = ({
            UIButton *view = [UIButton buttonWithType:UIButtonTypeCustom];
            [view addTapGestureWithTarget:self action:@selector(saveBtnClicked)];
            [view setTitle:@"保存" forState:UIControlStateNormal];
            [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [view.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [view setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
            [view setAlpha:0];
            view ;
        });
    }
    return _saveBtn;
}

@end
