//
//  KKMediaGralleryNavView.m
//  KKToydayNews
//
//  Created by finger on 2017/10/23.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKMediaGralleryNavView.h"

static CGFloat selCountLabelWH = 20 ;

@interface KKMediaGralleryNavView()
@property(nonatomic)UIButton *closeBtn;
@property(nonatomic)UILabel *albumNameLabel;
@property(nonatomic)UILabel *descLabel;
@property(nonatomic)UILabel *selCountLabel;
@property(nonatomic)UIButton *doneBtn;
@end

@implementation KKMediaGralleryNavView

- (instancetype)init{
    self = [super init];
    if(self){
        [self setupUI];
    }
    return self;
}

- (void)dealloc{
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self addSubview:self.closeBtn];
    [self addSubview:self.albumNameLabel];
    [self addSubview:self.descLabel];
    [self addSubview:self.selCountLabel];
    [self addSubview:self.doneBtn];
    
    [self.closeBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self).mas_offset(kkPaddingNormal);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.albumNameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.bottom.mas_equalTo(self.mas_centerY).mas_offset(-1);
    }];
    
    [self.descLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.top.mas_equalTo(self.mas_centerY).mas_offset(1);
    }];
    
    [self.selCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(self.doneBtn.mas_left).mas_offset(-5);
        make.size.mas_equalTo(CGSizeMake(selCountLabelWH, selCountLabelWH));
    }];
    
    [self.doneBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(40,30));
        make.right.mas_equalTo(self).mas_offset(-kkPaddingNormal);
    }];
}

#pragma mark -- 关闭按钮点击事件

- (void)closeBtnClicked{
    if(self.delegate && [self.delegate respondsToSelector:@selector(closeGralleryView)]){
        [self.delegate closeGralleryView];
    }
}

#pragma mark -- 完成按钮点击

- (void)doneBtnClicked{
    if(self.delegate && [self.delegate respondsToSelector:@selector(selectComplete)]){
        [self.delegate selectComplete];
    }
}

#pragma mark -- @property setter

- (void)setAlbumName:(NSString *)albumName{
    if(!albumName.length){
        albumName = @"相机胶卷";
    }
    self.albumNameLabel.text = albumName;
}

- (void)setSelCount:(NSString *)selCount{
    _selCount = selCount;
    self.selCountLabel.text = selCount;
    self.selCountLabel.hidden = (!selCount.length || [selCount isEqualToString:@"0"]);
    [UIView animateWithDuration:0.1 animations:^{
        self.selCountLabel.transform = CGAffineTransformMakeScale(0.9, 0.9);
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.selCountLabel.transform = CGAffineTransformMakeScale(1.2, 1.2);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                self.selCountLabel.transform = CGAffineTransformMakeScale(1.0, 1.0);
            }];
        }];
    }];
}

- (void)setIsShowAlbumList:(BOOL)isShowAlbumList{
    _isShowAlbumList = isShowAlbumList ;
    if(_isShowAlbumList){
        self.descLabel.text = @"轻触这里收起▲";
    }else{
        self.descLabel.text = @"轻触改变相册▼";
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(showOrHideAlbumList:)]){
        [self.delegate showOrHideAlbumList:_isShowAlbumList];
    }
}

- (void)setShowDoneBtn:(BOOL)showDoneBtn{
    self.doneBtn.hidden = !showDoneBtn;
}

- (void)setShowSelCount:(BOOL)showSelCount{
    self.selCountLabel.hidden = !showSelCount;
}

- (void)setEnableAlbumChange:(BOOL)enableAlbumChange{
    self.albumNameLabel.userInteractionEnabled = enableAlbumChange;
    self.descLabel.userInteractionEnabled = enableAlbumChange;
    if(enableAlbumChange){
        self.albumNameLabel.alpha = 1.0;
        self.descLabel.alpha = 1.0;
    }else{
        self.albumNameLabel.alpha = 0.5;
        self.descLabel.alpha = 0.5;
    }
}

#pragma mark -- @property getter

- (UIButton *)closeBtn{
    if(!_closeBtn){
        _closeBtn = ({
            UIButton *view = [UIButton new];
            [view setImage:[UIImage imageNamed:@"button_close"] forState:UIControlStateNormal];
            [view addTarget:self action:@selector(closeBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            view;
        });
    }
    return _closeBtn;
}

- (UILabel *)albumNameLabel{
    if(!_albumNameLabel){
        _albumNameLabel = ({
            UILabel *view = [UILabel new];
            view.textAlignment = NSTextAlignmentCenter;
            view.textColor = [UIColor blackColor];
            view.font = [UIFont systemFontOfSize:15 weight:0.2];
            view.lineBreakMode = NSLineBreakByCharWrapping;
            view.userInteractionEnabled = NO ;
            view.alpha = 0.5;
            view.text = @"相机胶卷";
            
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                self.isShowAlbumList = !self.isShowAlbumList;
            }];
            
            view ;
        });
    }
    return _albumNameLabel;
}

- (UILabel *)descLabel{
    if(!_descLabel){
        _descLabel = ({
            UILabel *view = [UILabel new];
            view.textAlignment = NSTextAlignmentCenter;
            view.textColor = [UIColor blackColor];
            view.font = [UIFont systemFontOfSize:12];
            view.lineBreakMode = NSLineBreakByCharWrapping;
            view.text = @"轻触改变相册▼";
            view.userInteractionEnabled = NO ;
            view.alpha = 0.5;
            
            @weakify(self);
            [view addTapGestureWithBlock:^(UIView *gestureView) {
                @strongify(self);
                self.isShowAlbumList = !self.isShowAlbumList;
            }];
            
            view ;
        });
    }
    return _descLabel;
}

- (UILabel *)selCountLabel{
    if(!_selCountLabel){
        _selCountLabel = ({
            UILabel *view = [UILabel new];
            view.textAlignment = NSTextAlignmentCenter;
            view.textColor = [UIColor whiteColor];
            view.backgroundColor = KKColor(0, 140, 218, 1);
            view.font = [UIFont systemFontOfSize:15];
            view.lineBreakMode = NSLineBreakByCharWrapping;
            view.layer.cornerRadius = selCountLabelWH / 2.0 ;
            view.layer.masksToBounds = YES ;
            view.hidden = YES ;
            view ;
        });
    }
    return _selCountLabel;
}

- (UIButton *)doneBtn{
    if(!_doneBtn){
        _doneBtn = ({
            UIButton *view = [UIButton new];
            [view setTitle:@"完成" forState:UIControlStateNormal];
            [view.titleLabel setFont:[UIFont systemFontOfSize:15]];
            [view setTitleColor:KKColor(0, 140, 218, 1) forState:UIControlStateNormal];
            [view addTarget:self action:@selector(doneBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            view;
        });
    }
    return _doneBtn;
}

@end
