//
//  KKSectionGroupView.m
//  KKToydayNewsDependency Analysis Warning Group
//
//  Created by finger on 2017/8/9.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKSectionGroupView.h"
#import "KKSectionItem.h"
#import "KKHomeSectionManager.h"
#import "KKSectionItemView.h"

@interface KKSectionGroupView ()<KKSectionItemViewDelegate>

@property(nonatomic,assign)BOOL isFavorite ;

@property(nonatomic,assign)CGFloat viewHeight ;
@property(nonatomic,assign)NSInteger oneLineNum;//一行按钮数目
@property(nonatomic,assign)NSInteger btnWidth;//按钮宽度
@property(nonatomic,assign)NSInteger btnHeight;//按钮高度
@property(nonatomic,assign)CGFloat btnSpace;//按钮之间的水平、垂直距离
@property(nonatomic,strong)NSMutableArray<KKSectionItemView *> *itemViewArray;
@property(nonatomic,weak)KKSectionItemView *curtSelItemView ;

@property(nonatomic,assign)CGPoint longPressPt;//记录长按拖拽时的坐标
@property(nonatomic,weak)KKSectionItemView *longPressItemView;//长按手势选中的视图
@property(nonatomic,assign)BOOL hasFindTargetPos ;//拖拽时是否已经找到对应的插入位置
@property(nonatomic,strong)UILongPressGestureRecognizer *longPressGesture;

@end

@implementation KKSectionGroupView

- (id)initWithFavorite:(BOOL)favorite{
    self = [super init];
    if(self){
        self.oneLineNum = 4 ;
        self.btnHeight = 40 ;
        self.btnWidth = 80 ;
        if(iPhone6){
            self.btnWidth = 78;
        }else if(iPhonePlus){
            self.btnWidth = 85 ;
        }else if(iPhone5){
            self.btnWidth = 65 ;
        }
        self.btnHeight = self.btnWidth / 2;
        self.isFavorite = favorite;
        self.btnSpace = MAX(0,(UIDeviceScreenWidth - self.oneLineNum * self.btnWidth ) / (self.oneLineNum + 1) );
        [self layoutUI];
        [self addGestureRecognizer:self.longPressGesture];
    }
    return self;
}

#pragma mark -- 设置UI

- (void)layoutUI{
    if(self.isFavorite){
        [[KKHomeSectionManager shareInstance]fetchFavSectionWithComplete:^(NSArray<KKSectionItem *> *itemArray) {
            for(KKSectionItem *item in itemArray){
                KKSectionItemView *view = [self crateItemViewWithItem:item isFavorite:self.isFavorite];
                [self.itemViewArray addObject:view];
                [self addSubview:view];
                if([view.sectionItem.category isEqualToString:self.curtSelCatagory]){
                    self.curtSelItemView = view ;
                    self.curtSelItemView.selected = YES ;
                }
            }
            [self adjustView];
            [self calculateViewHeight];
            if(self.delegate && [self.delegate respondsToSelector:@selector(needAdjustView:height:)]){
                [self.delegate needAdjustView:self height:self.viewHeight];
            }
        }];
    }else{
        [[KKHomeSectionManager shareInstance]fetchRecommonSectionWithComplete:^(NSArray<KKSectionItem *> *itemArray) {
            for(KKSectionItem *item in itemArray){
                KKSectionItemView *view = [self crateItemViewWithItem:item isFavorite:self.isFavorite];
                [self.itemViewArray addObject:view];
                [self addSubview:view];
            }
            [self adjustView];
            [self calculateViewHeight];
            if(self.delegate && [self.delegate respondsToSelector:@selector(needAdjustView:height:)]){
                [self.delegate needAdjustView:self height:self.viewHeight];
            }
        }];
    }
}

#pragma mark -- 调整视图

- (void)adjustView{
    NSInteger index = 0 ;
    for(KKSectionItemView *view in self.itemViewArray){
        CGFloat startX = (index % self.oneLineNum ) * (self.btnWidth + self.btnSpace) + self.btnSpace;
        CGFloat startY = (index / self.oneLineNum) * (self.btnHeight + self.btnSpace) + self.btnSpace ;
        [view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).mas_offset(startX);
            make.top.mas_equalTo(self).mas_equalTo(startY);
            make.size.mas_equalTo(CGSizeMake(self.btnWidth, self.btnHeight));
        }];
        index ++ ;
    }
}

#pragma mark -- 计算视图的高度

- (NSInteger)calculateViewHeight{
    NSInteger count = self.itemViewArray.count;
    NSInteger numLine = 0;
    if(count <= self.oneLineNum){
        numLine = 1 ;
    }else{
        if(count % self.oneLineNum == 0){
            numLine = count / self.oneLineNum;
        }else{
            numLine = (count / self.oneLineNum) + 1 ;
        }
    }
    
    self.viewHeight = self.btnHeight * numLine + (numLine + 1) * self.btnSpace;
    
    return self.viewHeight ;
}

#pragma mark -- 长按手势

- (void)longPressView:(UILongPressGestureRecognizer *)gesture{
    if(!self.isFavorite){
        return ;
    }
    CGPoint point = [gesture locationInView:self];
    if(gesture.state == UIGestureRecognizerStateBegan){
        self.longPressPt = point ;
        for(KKSectionItemView *view in self.itemViewArray){
            if(CGRectContainsPoint(view.frame, point)){
                if([view.sectionItem.category isEqualToString:@"推荐"]){
                    break ;
                }
                self.isEditState = YES ;
                self.longPressItemView = view ;
                [self bringSubviewToFront:self.longPressItemView];
                [UIView animateWithDuration:0.3 animations:^{
                    self.longPressItemView.transform = CGAffineTransformScale(self.longPressItemView.transform, 1.2, 1.2);
                }];
                if(self.delegate && [self.delegate respondsToSelector:@selector(longPressArise)]){
                    [self.delegate longPressArise];
                }
                break ;
            }
        }
    }else if(gesture.state == UIGestureRecognizerStateEnded){
        [self adjustView];
        [UIView animateWithDuration:0.3 animations:^{
            self.longPressItemView.transform = CGAffineTransformIdentity;
            [self layoutIfNeeded];
        }completion:^(BOOL finished) {
            self.hasFindTargetPos = NO ;
            self.longPressItemView = nil ;
        }];
    }else if(gesture.state == UIGestureRecognizerStateChanged){
        if(!self.longPressItemView){
            return ;
        }
        CGFloat offsetX = point.x - self.longPressPt.x;
        CGFloat offsetY = point.y - self.longPressPt.y;
        CGPoint pt = CGPointMake(self.longPressItemView.centerX + offsetX, self.longPressItemView.centerY + offsetY);
        self.longPressPt = point ;
        [self.longPressItemView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).mas_offset(pt.x - self.btnWidth / 2.0);//必须除以浮点的2.0,如果是整数的2，则会有偏差
            make.top.mas_equalTo(self).mas_offset(pt.y - self.btnHeight / 2.0);
        }];
        if(!self.hasFindTargetPos){
            for(KKSectionItemView *view in self.itemViewArray){
                if([self.longPressItemView.sectionItem.category isEqualToString:view.sectionItem.category]){
                    continue ;
                }
                if(CGRectContainsPoint(view.frame, point)){
                    if([view.sectionItem.category isEqualToString:@"推荐"]){
                        break ;
                    }
                    self.hasFindTargetPos = YES ;
                    
                    NSInteger longPressBtnIndex = [self.itemViewArray indexOfObject:self.longPressItemView];
                    NSInteger targetBtnIndex = [self.itemViewArray indexOfObject:view];
                    [self.itemViewArray removeObjectAtIndex:longPressBtnIndex];
                    [self.itemViewArray insertObject:self.longPressItemView atIndex:targetBtnIndex];
                    
                    //更新用户数据
                    KKSectionItem *item = [[KKHomeSectionManager shareInstance]favItemAtIndex:longPressBtnIndex];
                    [[KKHomeSectionManager shareInstance]removeFavItemAtIndex:longPressBtnIndex];
                    [[KKHomeSectionManager shareInstance]insertFavoriteItem:item atIndex:targetBtnIndex];
                    
                    [self layoutWithLongPress];
                    [UIView animateWithDuration:0.3 animations:^{
                        [self layoutIfNeeded];
                    }completion:^(BOOL finished) {
                        if(self.delegate && [self.delegate respondsToSelector:@selector(userSectionOrderChangeFrom:toIndex:)]){
                            [self.delegate userSectionOrderChangeFrom:longPressBtnIndex toIndex:targetBtnIndex];
                        }
                        self.hasFindTargetPos = NO ;
                    }];
                    break ;
                }
            }
        }
    }
}

- (void)layoutWithLongPress{
    NSInteger index = 0 ;
    for(KKSectionItemView *view in self.itemViewArray){
        if([view.sectionItem.category isEqualToString:self.longPressItemView.sectionItem.category]){
            index ++ ;
            continue ;
        }
        NSInteger startX = (index % self.oneLineNum ) * (self.btnWidth + self.btnSpace) + self.btnSpace;
        NSInteger startY = (index / self.oneLineNum) * (self.btnHeight + self.btnSpace) + self.btnSpace ;
        [view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).mas_offset(startX);
            make.top.mas_equalTo(self).mas_equalTo(startY);
            make.size.mas_equalTo(CGSizeMake(self.btnWidth, self.btnHeight));
        }];
        index ++ ;
    }
}

#pragma mark -- 快速新建按钮

- (KKSectionItemView *)crateItemViewWithItem:(KKSectionItem *)item isFavorite:(BOOL)isFavorite{
    KKSectionItemView *view = [[KKSectionItemView alloc]init];
    view.favorite = isFavorite ;
    view.sectionItem = item;
    view.hideCloseButton = YES ;
    view.layer.cornerRadius = 3;
    view.delegate = self ;
    
    return view ;
}

#pragma mark -- KKSectionItemViewDelegate

- (void)clickSectionItemView:(KKSectionItemView *)view{
    if(self.isFavorite){
        if(!self.isEditState){
            if(self.delegate && [self.delegate respondsToSelector:@selector(needJumpToSection:)]){
                [self.delegate needJumpToSection:view.sectionItem];
            }
        }
    }else{
        CGRect frame = view.frame;
        NSInteger index = [self.itemViewArray indexOfObject:view];
        KKSectionItem *item = [self removeItemAtIndex:index animate:YES];
        if(self.delegate && [self.delegate respondsToSelector:@selector(addOrRemoveItem:itemOrgRect:opType:)]){
            [self.delegate addOrRemoveItem:item itemOrgRect:frame opType:KKSectionOpTypeAddToFavSection];
        }
    }
}

- (void)closeBtnClicked:(KKSectionItemView *)view{
    NSInteger index = [self.itemViewArray indexOfObject:view];
    CGRect frame = view.frame;
    KKSectionItem *item = [self removeItemAtIndex:index animate:YES];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(addOrRemoveItem:itemOrgRect:opType:)]){
        [self.delegate addOrRemoveItem:item itemOrgRect:frame opType:KKSectionOpTypeRemoveFromFavSection];
    }
}

#pragma mark -- 删除/添加某个位置的板块

- (KKSectionItem *)removeItemAtIndex:(NSInteger)index animate:(BOOL)animate{
    KKSectionItemView *view = [self.itemViewArray objectAtIndex:index];
    [view removeFromSuperview];
    [self.itemViewArray removeObjectAtIndex:index];
    
    //同步用户数据
    if(self.isFavorite){
        KKSectionItem *item = [[KKHomeSectionManager shareInstance]favItemAtIndex:index];
        [[KKHomeSectionManager shareInstance]removeFavItemAtIndex:index];
        [[KKHomeSectionManager shareInstance]insertRecommonItem:item atIndex:0];
        [[KKHomeSectionManager shareInstance]saveFavSection];
    }else{
        KKSectionItem *item = [[KKHomeSectionManager shareInstance]recommonItemAtIndex:index];
        [[KKHomeSectionManager shareInstance]removeRecommonItemAtIndex:index];
        
        NSInteger index = [[KKHomeSectionManager shareInstance]getFavoriteCount];
        [[KKHomeSectionManager shareInstance]insertFavoriteItem:item atIndex:index];
        [[KKHomeSectionManager shareInstance]saveFavSection];
    }
    
    [self adjustView];
    
    if(animate){
        [UIView animateWithDuration:0.3 animations:^{
            [self layoutIfNeeded];
        }];
    }
    
    return view.sectionItem ;
}

/**
 用户感兴趣的板块和不感兴趣的板块之间的按钮添加，实现了两个板块之间的移动效果
 
 @param index 位置索引
 @param item 插入的板块
 @param rect 初始坐标信息 用于两个板块之间按钮的移动效果
 @param animate 是否需要动画
 */
- (void)addItemAtIndex:(NSInteger)index item:(KKSectionItem *)item initRect:(CGRect)rect animate:(BOOL)animate{
    if(index == -1){//添加到末尾
        index = self.itemViewArray.count;
    }
    
    KKSectionItemView *view = [self crateItemViewWithItem:item isFavorite:self.isFavorite];
    if(self.isFavorite && self.isEditState){
        view.hideCloseButton = NO ;
    }
    
    [self.itemViewArray insertObject:view atIndex:index];
    [self addSubview:view];
    
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).mas_offset(rect.origin.x);
        make.top.mas_equalTo(self).mas_equalTo(rect.origin.y);
        make.size.mas_equalTo(CGSizeMake(rect.size.width, rect.size.height));
    }];
    [self layoutIfNeeded];
    
    [self adjustView];
    
    if(animate){
        [UIView animateWithDuration:0.3 animations:^{
            [self layoutIfNeeded];
        }];
    }
}

#pragma mark -- @property

- (NSMutableArray<KKSectionItemView *> *)itemViewArray{
    if(!_itemViewArray){
        _itemViewArray = [NSMutableArray arrayWithCapacity:0];
    }
    return _itemViewArray;
}

- (UILongPressGestureRecognizer *)longPressGesture{
    if(!_longPressGesture){
        _longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressView:)];
    }
    return _longPressGesture;
}

//设置编辑状态
- (void)setIsEditState:(BOOL)isEditState{
    _isEditState = isEditState;
    if(self.isFavorite){
        for(KKSectionItemView *view in self.itemViewArray){
            if([view.sectionItem.category isEqualToString:@"推荐"]){
                continue ;
            }
            view.hideCloseButton = !_isEditState;
        }
        self.curtSelItemView.selected = !_isEditState ;
    }
}

- (void)setCurtSelCatagory:(NSString *)curtSelCatagory{
    _curtSelCatagory = curtSelCatagory ;
    [self.itemViewArray enumerateObjectsUsingBlock:^(KKSectionItemView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([obj.sectionItem.category isEqualToString:_curtSelCatagory]){
            self.curtSelItemView = obj ;
            self.curtSelItemView.selected = YES ;
            *stop = YES ;
        }
    }];
}

@end
