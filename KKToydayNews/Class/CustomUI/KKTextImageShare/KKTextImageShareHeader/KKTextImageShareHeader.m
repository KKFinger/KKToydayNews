//
//  KKTextImageShareHeader.m
//  KKToydayNews
//
//  Created by finger on 2017/10/22.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKTextImageShareHeader.h"
#import "KKTextView.h"
#import "KKGalleryImageCell.h"
#import "KKPhotoManager.h"
#import "KKImageGalleryView.h"

static CGFloat space = 3.0 ;
static CGFloat lrPadding = kkPaddingNormal ;
static NSString *cellReuseIdentifier = @"cellReuseIdentifier";
static CGFloat textViewHeight = 130;
static CGFloat cellWH = 0;
static CGFloat splitViewHeight = 8 ;
static NSInteger maxImageCount = 9 ;

@interface KKTextImageShareHeader()<UICollectionViewDelegate,UICollectionViewDataSource,UIScrollViewDelegate,KKGalleryImageCellDelegate>
@property(nonatomic)KKTextView *textView;
@property(nonatomic)UIView *splitView;
@property(nonatomic)UICollectionView *collectView;
@property(nonatomic,readwrite)NSMutableArray<KKPhotoInfo *> *dataArray;
@end

@implementation KKTextImageShareHeader

- (instancetype)init{
    self = [super init];
    if(self){
        KKPhotoInfo *item = [KKPhotoInfo new];
        item.image = [UIImage imageNamed:@"introduct_add_picture"];
        item.isPlaceholderImage = YES ;
        [self.dataArray safeAddObject:item];
        
        [self setupUI];
    }
    return self;
}

- (void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self setBackgroundColor:[UIColor whiteColor]];
    
    [self addSubview:self.textView];
    [self addSubview:self.collectView];
    [self addSubview:self.splitView];
    
    textViewHeight = 120;
    cellWH = (UIDeviceScreenWidth - 2 * space - 2 * lrPadding) / 3.0;
    
    [self.textView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).mas_offset(lrPadding).priority(998);
        make.right.mas_equalTo(self).mas_offset(-lrPadding).priority(998);
        make.top.mas_equalTo(self);
        make.height.mas_equalTo(textViewHeight).priority(998);
    }];
    [self.collectView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textView.mas_bottom);
        make.left.mas_equalTo(self.textView);
        make.right.mas_equalTo(self.textView);
        make.bottom.mas_equalTo(self.splitView.mas_top);
    }];
    
    [self.splitView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self);
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(splitViewHeight).priority(998);
    }];
}

#pragma mark -- 获取高度

- (CGFloat)fetchHeaderHeight{
    NSInteger row = 0;
    NSInteger count = MIN(self.dataArray.count, maxImageCount);
    if(count % 3 == 0){
        row = count / 3 ;
    }else{
        row = count / 3 + 1 ;
    }
    return textViewHeight + row * cellWH + (row + 1) * space + splitViewHeight;
}

#pragma mark -- 隐藏键盘

- (void)hideKeyboard{
    [self.textView resignFirstResponder];
}

#pragma mark -- UICollectionViewDelegate,UICollectionViewDataSource

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return MIN(self.dataArray.count, maxImageCount);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    KKPhotoInfo *item = [self.dataArray safeObjectAtIndex:indexPath.row];
    KKGalleryImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    [cell refreshCell:item cellType:KKGalleryCellTypeDelete disable:NO];
    [cell setDelegate:self];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(cellWH, cellWH);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    KKPhotoInfo *item = [self.dataArray safeObjectAtIndex:indexPath.row];
    if(item.isPlaceholderImage){
        [self showImageGallery];
    }else{
        
    }
}

//设置水平间距 (同一行的cell的左右间距）
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return space;
}

//垂直间距 (同一列cell上下间距)
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return space;
}

#pragma mark -- KKGalleryImageCellDelegate

- (void)deleteImage:(KKGalleryImageCell *)cell{
    NSIndexPath *path = [self.collectView indexPathForCell:cell];
    KKPhotoInfo *item = [self.dataArray safeObjectAtIndex:path.row];
    item.isSelected = NO ;
    [self.dataArray safeRemoveObjectAtIndex:path.row];
    [UIView performWithoutAnimation:^{
        [self.collectView reloadData];
    }];
    if(self.delegate && [self.delegate respondsToSelector:@selector(needAdjustHeaderHeight)]){
        [self.delegate needAdjustHeaderHeight];
    }
}

#pragma mark -- UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self.textView resignFirstResponder];
}

#pragma mark -- 显示图片选择视图

- (void)showImageGallery{
    KKImageGalleryView *view = [KKImageGalleryView new];
    view.topSpace = KKStatusBarHeight ;
    view.navContentOffsetY = 0 ;
    view.navTitleHeight = 50 ;
    view.contentViewCornerRadius = 10 ;
    view.cornerEdge = UIRectCornerTopRight|UIRectCornerTopLeft;
    view.navView.selCount = [NSString stringWithFormat:@"%ld",self.dataArray.count-1];
    view.curtSelCount = self.dataArray.count - 1 ;
    view.limitSelCount = maxImageCount ;
    
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(UIDeviceScreenWidth, UIDeviceScreenHeight));
    }];
    
    [view setSelectImageCallback:^(KKPhotoInfo *item,BOOL isSelect,void(^canSelect)(BOOL canSelect,NSInteger selCount)){
        if(isSelect){
            NSInteger count = self.dataArray.count;
            if(count < maxImageCount + 1){
                if(item.identifier.length && item.albumId.length){
                    [[KKPhotoManager sharedInstance]getImageWithAlbumID:item.albumId imageLocalIdentifier:item.identifier needImageSize:UIDeviceScreenSize isNeedDegraded:NO sort:NSOrderedDescending block:^(KKPhotoInfo *item) {
                        [self.dataArray safeInsertObj:item atIndex:count - 1];
                        if(canSelect){
                            canSelect(YES,self.dataArray.count-1);
                        }
                    }];
                }else{
                    [self.dataArray safeInsertObj:item atIndex:count - 1];
                    if(canSelect){
                        canSelect(YES,self.dataArray.count-1);
                    }
                }
            }else{
                [[UIApplication sharedApplication].keyWindow promptMessage:@"最多只能添加9张图片"];
                if(canSelect){
                    canSelect(NO,self.dataArray.count-1);
                }
            }
        }else{
            for(NSInteger i = 0 ; i < self.dataArray.count ; i++){
                KKPhotoInfo *_item = [self.dataArray safeObjectAtIndex:i];
                if([item.identifier isEqualToString:_item.identifier]){
                    [self.dataArray safeRemoveObjectAtIndex:i];
                    break ;
                }
            }
            if(canSelect){
                canSelect(YES,self.dataArray.count-1);
            }
        }
        [UIView performWithoutAnimation:^{
            [self.collectView reloadData];
        }];
        
        if(self.delegate && [self.delegate respondsToSelector:@selector(needAdjustHeaderHeight)]){
            [self.delegate needAdjustHeaderHeight];
        }
    }];
    
    [view setGetCurtSelArray:^NSArray *(){
        return self.dataArray;
    }];
    
    [view startShow];
}

#pragma mark -- @property setter

- (void)setImageArray:(NSArray *)imageArray{
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:imageArray];
}

#pragma mark -- @property getter

- (KKTextView *)textView{
    if(!_textView){
        _textView = ({
            KKTextView *view = [KKTextView new];
            view.placeholder = @"分享新鲜事";
            view ;
        });
    }
    return _textView;
}

- (UICollectionView *)collectView{
    if(!_collectView){
        _collectView = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
            UICollectionView *view = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
            view.delegate= self;
            view.dataSource= self;
            view.backgroundColor = [UIColor whiteColor];
            [view registerClass:[KKGalleryImageCell class] forCellWithReuseIdentifier:cellReuseIdentifier];
            view;
        });
    }
    return _collectView;
}

- (UIView *)splitView{
    if(!_splitView){
        _splitView = ({
            UIView *view = [UIView new];
            view.backgroundColor = KKColor(244, 245, 246, 1);
            view ;
        });
    }
    return _splitView;
}

- (NSMutableArray *)dataArray{
    if(!_dataArray){
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

@end
