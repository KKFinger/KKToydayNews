//
//  KKGalleryVideoPreview.m
//  KKToydayNews
//
//  Created by finger on 2017/10/24.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKGalleryVideoPreview.h"
#import "KKVideoManager.h"
#import "KKGalleryVideoPreviewCell.h"
#import "KKXiaoShiPingPlayer.h"

static NSString *cellReuseIdentifier = @"cellReuseIdentifier";

#define ImageHorizPading 20 //每张图片之间的间距
#define ImageItemWith (UIDeviceScreenWidth + ImageHorizPading)

@interface KKGalleryVideoPreview ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic)UICollectionView *collectView;
@property(nonatomic)UIButton *closeBtn;
@property(nonatomic)UIButton *doneBtn;
@property(nonatomic)UIButton *playBtn;
@property(nonatomic,strong)CAGradientLayer *topGradient;

@property(nonatomic,weak)NSArray<KKVideoInfo *> *videoArray;
@property(nonatomic,copy)NSString *albumId;
@property(nonatomic,assign)NSInteger selIndex;
@property(nonatomic,assign)BOOL showView;

@property(nonatomic,assign)UIStatusBarStyle barStyle;

@end

@implementation KKGalleryVideoPreview

- (instancetype)initWithVideoArray:(NSArray<KKVideoInfo *> *)videoArray selIndex:(NSInteger)selIndex albumId:(NSString *)albumId{
    self = [super init];
    if(self){
        self.selIndex = selIndex;
        self.videoArray = videoArray;
        self.albumId = albumId;
        self.dragViewBg.alpha = 0;
        self.showView = YES ;
        self.dragContentView.backgroundColor = [UIColor blackColor];
        self.barStyle = [[UIApplication sharedApplication]statusBarStyle];
        self.dragContentView.alpha = 0 ;
        if(!self.albumId.length){
            self.albumId = [[KKVideoManager sharedInstance]getCameraRollAlbumId];
        }
    }
    return self ;
}

#pragma mark -- 视图的显示和消失

- (void)viewWillAppear{
    [super viewWillAppear];
    [self setupUI];
    [self showEnterAnimate];
    [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillDisappear{
    [super viewWillDisappear];
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication]setStatusBarStyle:self.barStyle];
}

- (void)viewDidAppear{
    [super viewDidAppear];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.topGradient.frame = CGRectMake(0, 0, self.width, 100);
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self.dragContentView addSubview:self.collectView];
    [self.dragContentView addSubview:self.closeBtn];
    [self.dragContentView addSubview:self.doneBtn];
    [self.dragContentView addSubview:self.playBtn];
    [self.dragContentView.layer insertSublayer:self.topGradient below:self.closeBtn.layer];
    
    [self.collectView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.left.height.mas_equalTo(self.dragContentView);
        make.width.mas_equalTo(ImageItemWith);
    }];
    
    [self.closeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.dragContentView).mas_offset(iPhoneX ? KKStatusBarHeight : 15);
        make.left.mas_equalTo(self.dragContentView).mas_offset(0);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    [self.doneBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.dragContentView).mas_offset(-kkPaddingNormal);
        make.centerY.mas_equalTo(self.closeBtn);
        make.size.mas_equalTo(CGSizeMake(44, 30));
    }];
    
    [self.playBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.dragContentView);
    }];
}

#pragma mark -- 显示动画

- (void)showEnterAnimate{
    NSString *idString = [self.videoArray safeObjectAtIndex:self.selIndex].localIdentifier;
    [[KKVideoManager sharedInstance]getVideoCorverWithLocalIdentifier:idString needImageSize:CGSizeMake(150, 150) isNeedDegraded:NO block:^(KKVideoInfo *item) {
        UIImage *image = item.videoCorver;
        CGRect frame = CGRectMake(0, 0, UIDeviceScreenWidth, UIDeviceScreenHeight);
        
        CGRect fromRect = [self.oriView convertRect:self.oriFrame toView:self.dragContentView];
        UIImageView *imageView = [YYAnimatedImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.layer.masksToBounds = YES ;
        imageView.image = image;
        imageView.frame = fromRect;
        [self.dragContentView addSubview:imageView];
        
        //collectView的偏移必须放在这里，原因不详
        [self.collectView setContentOffset:CGPointMake(self.selIndex * ImageItemWith, 0)];
        
        [UIView animateWithDuration:0.3 animations:^{
            imageView.frame = frame;
            self.dragViewBg.alpha = 1;
            self.dragContentView.alpha = 1;
        }completion:^(BOOL finished) {
            [imageView removeFromSuperview];
            self.topGradient.hidden = NO;
            self.doneBtn.hidden = NO ;
            self.playBtn.hidden = NO ;
            self.closeBtn.hidden = NO ;
            self.collectView.hidden = NO;
        }];
    }];
}

#pragma mark -- UICollectionViewDelegate,UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.videoArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    KKGalleryVideoPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    NSString *idString = [self.videoArray safeObjectAtIndex:indexPath.row].localIdentifier;
    [[KKVideoManager sharedInstance]getVideoCorverWithLocalIdentifier:idString needImageSize:CGSizeMake(150, 150) isNeedDegraded:NO block:^(KKVideoInfo *item) {
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.corverImage = item.videoCorver;
        });
    }];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(ImageItemWith, UIDeviceScreenHeight);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.showView = !self.showView;
    self.closeBtn.hidden = !self.showView;
    self.doneBtn.hidden = !self.showView;
    self.playBtn.hidden = !self.showView;
    self.topGradient.hidden = !self.showView;
    [[UIApplication sharedApplication]setStatusBarHidden:!self.showView withAnimation:NO];
    KKGalleryVideoPreviewCell *cell = (KKGalleryVideoPreviewCell *)[self.collectView cellForItemAtIndexPath:indexPath];
    KKVideoInfo *videoInfo = [self.videoArray safeObjectAtIndex:indexPath.row];
    cell.playUrl = videoInfo.filePath;
    if(self.showView){
        [cell.videoPlayView pause];
    }else{
        [cell.videoPlayView resume];
    }
}

//设置水平间距 (同一行的cell的左右间距）
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

//垂直间距 (同一列cell上下间距)
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    self.enableHorizonDrag = NO ;
    self.enableVerticalDrag = NO ;
    self.enableFreedomDrag = NO ;
    
    CGPoint offset = self.collectView.contentOffset;
    CGFloat progress = offset.x / (CGFloat)ImageItemWith;
    NSInteger index = offset.x / (CGFloat)ImageItemWith;
    
    //设置上下、当前三张图片的透明度
    NSInteger nextIndex = index + 1 ;
    if(nextIndex < self.videoArray.count){
        KKGalleryVideoPreviewCell *cell = (KKGalleryVideoPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:nextIndex inSection:0]];
        [cell setAlpha:fabs(progress-index)];
    }
    
    KKGalleryVideoPreviewCell *cell = (KKGalleryVideoPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    [cell setAlpha:1 - fabs((progress-index))];
    
    NSInteger perIndex = index - 1 ;
    if(perIndex >= 0){
        KKGalleryVideoPreviewCell *cell = (KKGalleryVideoPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:perIndex inSection:0]];
        [cell setAlpha:fabs((index - progress))];
    }
}

//结束拉拽视图
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    CGPoint offset = self.collectView.contentOffset;
    NSInteger index = offset.x / ImageItemWith;
    if(index < 0 || index >= self.videoArray.count){
        return ;
    }
}

//完全停止滚动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint offset = self.collectView.contentOffset;
    NSInteger index = offset.x / (CGFloat)ImageItemWith;
    if(index < 0 || index >= self.videoArray.count){
        return ;
    }
    
    if(self.selIndex != index){
        self.showView = NO;
        self.closeBtn.hidden = !self.showView;
        self.doneBtn.hidden = !self.showView;
        self.playBtn.hidden = !self.showView;
        self.topGradient.hidden = !self.showView;
        
        KKGalleryVideoPreviewCell *cell = (KKGalleryVideoPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        KKXiaoShiPingPlayer *view = cell.videoPlayView;
        KKVideoInfo *videoInfo = [self.videoArray safeObjectAtIndex:index];
        view.playUrl = videoInfo.filePath;
        [view startPlayVideo];
    }
    self.selIndex = index ;
    
    KKGalleryVideoPreviewCell *cell = (KKGalleryVideoPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selIndex inSection:0]];
    [cell setAlpha:1.0];
    
    NSInteger nextIndex = self.selIndex + 1 ;
    if(nextIndex < self.videoArray.count){
        KKGalleryVideoPreviewCell *cell = (KKGalleryVideoPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:nextIndex inSection:0]];
        [cell setAlpha:1.0];
    }
    
    NSInteger perIndex = self.selIndex - 1 ;
    if(perIndex >= 0){
        KKGalleryVideoPreviewCell *cell = (KKGalleryVideoPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:perIndex inSection:0]];
        [cell setAlpha:1.0];
    }
    
    self.enableHorizonDrag = (index == 0);
    self.enableVerticalDrag = YES ;
    self.enableFreedomDrag = NO ;
    
    if(self.videoIndexChange){
        self.videoIndexChange(self.selIndex, ^(CGRect oriFrame) {
            self.oriFrame = oriFrame;
        });
    }
}

#pragma mark -- 开始、拖拽中、结束拖拽

- (void)dragBeginWithPoint:(CGPoint)pt{
    self.enableFreedomDrag = YES ;
    if(self.alphaViewIfNeed){
        self.alphaViewIfNeed(self.enableFreedomDrag&&!self.defaultHideAnimateWhenDragFreedom,self.selIndex);
    }
}

- (void)dragingWithPoint:(CGPoint)pt{
    self.collectView.scrollEnabled = NO ;
    self.collectView.bounces = NO ;
    if(self.enableFreedomDrag){
        self.closeBtn.hidden = YES;
        self.doneBtn.hidden = YES;
        self.playBtn.hidden = YES;
        self.topGradient.hidden = YES;
        self.dragContentView.backgroundColor = [UIColor clearColor];
        
        KKGalleryVideoPreviewCell *cell = (KKGalleryVideoPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selIndex inSection:0]];
        KKXiaoShiPingPlayer *view = cell.videoPlayView;
        view.layer.transform = CATransform3DMakeScale(self.dragViewBg.alpha,self.dragViewBg.alpha,0);
    }
    
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:NO];
}

- (void)dragEndWithPoint:(CGPoint)pt shouldHideView:(BOOL)hideView{
    KKGalleryVideoPreviewCell *cell = (KKGalleryVideoPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selIndex inSection:0]];
    KKXiaoShiPingPlayer *view = cell.videoPlayView;
    
    self.collectView.bounces = YES ;
    self.collectView.scrollEnabled = YES ;
    
    if(self.enableFreedomDrag){
        if(!hideView){
            self.dragContentView.backgroundColor = [UIColor blackColor];
            self.closeBtn.hidden = !self.showView;
            self.doneBtn.hidden = !self.showView;
            self.playBtn.hidden = !self.showView;
            self.topGradient.hidden = !self.showView;
            [[UIApplication sharedApplication]setStatusBarHidden:!self.showView withAnimation:NO];
            
            [UIView animateWithDuration:0.3 animations:^{
                view.layer.transform = CATransform3DIdentity;
                self.dragContentView.alpha = 1.0 ;
            }completion:^(BOOL finished) {
            }];
        }else{
            [self hideViewAnimate];
        }
    }else{
        self.dragContentView.backgroundColor = [UIColor blackColor];
        if(self.alphaViewIfNeed){
            self.alphaViewIfNeed(!hideView,self.selIndex);
        }
    }
    
    self.enableFreedomDrag = NO ;
    self.enableHorizonDrag = (self.selIndex == 0) ;
    self.enableVerticalDrag = YES ;
}

#pragma mark -- 消失动画

- (void)hideViewAnimate{
    KKGalleryVideoPreviewCell *cell = (KKGalleryVideoPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selIndex inSection:0]];
    KKXiaoShiPingPlayer *view = cell.videoPlayView;
    [view destoryVideoPlayer];
    [view setHidden:YES];
    
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication]setStatusBarStyle:self.barStyle];
    
    CGRect frame = [self.dragContentView convertRect:view.frame toView:self.oriView];
    
    self.dragViewBg.alpha = 0;
    self.dragContentView.hidden = YES;
    
    if(self.hideVideoAnimate){
        self.hideVideoAnimate(view.corverImage,frame,self.oriFrame);
    }
}

#pragma mark -- 完成按钮

- (void)doneBtnClicked{
    KKVideoInfo *videoInfo = [self.videoArray safeObjectAtIndex:self.selIndex];
    KKGalleryVideoPreviewCell *cell = (KKGalleryVideoPreviewCell *)[self.collectView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.selIndex inSection:0]];
    KKXiaoShiPingPlayer *view = cell.videoPlayView;
    [view destoryVideoPlayer];
    [view setHidden:YES];
    
    [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:NO];
    [[UIApplication sharedApplication]setStatusBarStyle:self.barStyle];
    
    CGRect frame = [self.dragContentView convertRect:view.frame toView:self.oriView];
    
    videoInfo.videoCorver = view.corverImage;
    
    self.dragViewBg.alpha = 0;
    self.dragContentView.hidden = YES;
    
    if(self.hideVideoAnimate){
        self.hideVideoAnimate(view.corverImage,frame,self.oriFrame);
    }
    
    if(self.selectVideo){
        self.selectVideo(videoInfo);
    }
}

#pragma mark -- @property getter

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
            view.hidden = YES ;
            view.backgroundColor = [UIColor clearColor];
            [view registerClass:[KKGalleryVideoPreviewCell class] forCellWithReuseIdentifier:cellReuseIdentifier];
            view;
        });
    }
    return _collectView;
}

- (UIButton *)closeBtn{
    if(!_closeBtn){
        _closeBtn = ({
            UIButton *view = [UIButton new];
            [view setImage:[UIImage imageNamed:@"quit"] forState:UIControlStateNormal];
            [view addTarget:self action:@selector(hideViewAnimate) forControlEvents:UIControlEventTouchUpInside];
            view.hidden = YES ;
            view ;
        });
    }
    return _closeBtn;
}

- (UIButton *)doneBtn{
    if(!_doneBtn){
        _doneBtn = ({
            UIButton *view = [UIButton new];
            [view setTitle:@"完成" forState:UIControlStateNormal];
            [view.titleLabel setFont:[UIFont systemFontOfSize:17]];
            [view setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [view addTarget:self action:@selector(doneBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [view setHidden:YES];
            view;
        });
    }
    return _doneBtn;
}

- (UIButton *)playBtn{
    if(!_playBtn){
        _playBtn = ({
            UIButton *view = [UIButton new];
            [view setImage:[UIImage imageNamed:@"new_play_video_44x44_"] forState:UIControlStateNormal];
            [view setUserInteractionEnabled:NO];
            [view setHidden:YES];
            view;
        });
    }
    return _playBtn;
}

- (CAGradientLayer *)topGradient{
    if(!_topGradient){
        _topGradient = [CAGradientLayer layer];
        _topGradient.colors = @[(__bridge id)[[UIColor blackColor]colorWithAlphaComponent:0.7].CGColor, (__bridge id)[UIColor clearColor].CGColor];
        _topGradient.startPoint = CGPointMake(0, 0);
        _topGradient.endPoint = CGPointMake(0.0, 1.0);
        _topGradient.hidden = YES ;
    }
    return _topGradient;
}

@end
