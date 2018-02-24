//
//  KKSectionTopBarView.m
//  KKToydayNews
//
//  Created by finger on 2017/8/7.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKSectionTopBarView.h"
#import "KKSectionCollectionCell.h"
#import "KKAddMoreView.h"

static NSString * cellIdentifier = @"cellIdentifier";

@interface KKSectionTopBarView()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(nonatomic,strong)UICollectionView *collectionView ;
@property(nonatomic,strong)KKAddMoreView *addMoreView ;
@end

@implementation KKSectionTopBarView

- (id)init{
    self = [super init];
    if(self){
        [self setupUI];
        [self bandingEvent];
    }
    return self ;
}

#pragma mark -- 初始化UI

- (void)setupUI{
    
    [self addSubview:self.collectionView];
    [self addSubview:self.addMoreView];
    
    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    [self.addMoreView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self);
        make.centerY.mas_equalTo(self.centerY);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
}

#pragma mark -- 绑定事件

- (void)bandingEvent{
    @weakify(self);
    [self.addMoreView setAddBtnClickHandler:^{
        @strongify(self);
        if(self.delegate && [self.delegate respondsToSelector:@selector(addMoreSectionClicked)]){
            [self.delegate addMoreSectionClicked];
        }
    }];
}

#pragma mark -- UICollectionViewDelegate && UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1 ;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.sectionItems.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    KKSectionItem *item = [self.sectionItems safeObjectAtIndex:indexPath.row];
    KKSectionCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.item = item ;
    cell.isSelected = (indexPath.row == self.selectedIndex) ;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    KKSectionItem *item = [self.sectionItems safeObjectAtIndex:indexPath.row];
    self.selectedIndex = indexPath.row ;
    self.curtSelCatagory = item.category;
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectedSectionItem:)]){
        [self.delegate selectedSectionItem:item];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    KKSectionItem *item = [self.sectionItems safeObjectAtIndex:indexPath.row];
    return [KKSectionCollectionCell titleSize:item];
}

//设置水平间距 (同一行的cell的左右间距）
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 5;
}

#pragma mark -- @property getter

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = ({
            UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
            layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
            layout.footerReferenceSize = CGSizeMake(30, 30);
            layout.headerReferenceSize = CGSizeMake(8, 30);
            
            UICollectionView *view = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
            [view registerClass:[KKSectionCollectionCell class] forCellWithReuseIdentifier:cellIdentifier];
            view.delegate = self;
            view.dataSource = self;
            view.backgroundColor = [UIColor clearColor];
            view.showsHorizontalScrollIndicator = NO;
            view;
        });
    }
    return _collectionView;
}

- (KKAddMoreView *)addMoreView{
    if(!_addMoreView){
        _addMoreView = ({
            KKAddMoreView *view = [[KKAddMoreView alloc]init];
            view;
        });
    }
    return _addMoreView;
}

#pragma mark -- @property setter

- (void)setSectionItems:(NSArray<KKSectionItem *> *)sectionItems{
    _sectionItems = sectionItems ;
    [self.collectionView reloadData];
    //设置当前选择的板块
    self.curtSelCatagory = self.curtSelCatagory;
}

- (void)setCurtSelCatagory:(NSString *)curtSelCatagory{
    _curtSelCatagory = curtSelCatagory ;
    [self.sectionItems enumerateObjectsUsingBlock:^(KKSectionItem *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj.category isEqualToString:curtSelCatagory]){
            self.selectedIndex = idx ;
            *stop = YES ;
        }
    }];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex{
    
    _selectedIndex = selectedIndex;
    
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:_selectedIndex inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    
    NSArray *array = [self.collectionView indexPathsForVisibleItems];
    for(NSIndexPath *indexPath in array){
        KKSectionCollectionCell *lastSelCell = (KKSectionCollectionCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        if(indexPath.row == _selectedIndex){
            lastSelCell.isSelected = YES ;
        }else{
            lastSelCell.isSelected = NO ;
        }
    }
}

- (void)setHideAddBtn:(BOOL)hideAddBtn{
    self.addMoreView.hidden = hideAddBtn;
    if(hideAddBtn){
        ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).footerReferenceSize = CGSizeMake(8, 30);
    }else{
        ((UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout).footerReferenceSize = CGSizeMake(30, 30);
    }
}

@end
