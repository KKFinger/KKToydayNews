//
//  KKEditRecordCorverView.m
//  KKToydayNews
//
//  Created by finger on 2017/11/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKEditRecordCorverView.h"
#import "KKRecordCorverSlider.h"
#import "KKAVPlayer.h"
#import "KKFetchVideoCorverTool.h"

static CGFloat topViewHeight = 55 ;

@interface KKEditRecordCorverView()<KKRecordCorverSliderDelegate>
@property(nonatomic)UIButton *backBtn;
@property(nonatomic)UILabel *titleLabel;
@property(nonatomic)UIButton *doneBtn;
@property(nonatomic)UIImageView *recCorverView;
@property(nonatomic)KKRecordCorverSlider *sliderView;
@property(nonatomic)KKVideoInfo *videoInfo;
@end

@implementation KKEditRecordCorverView

- (instancetype)initWithVideoInfo:(KKVideoInfo *)videoInfo{
    self = [super init];
    if(self){
        self.enableFreedomDrag = NO ;
        self.enableHorizonDrag = YES ;
        self.enableVerticalDrag = YES ;
        self.videoInfo = videoInfo;
        
        @weakify(self);
        [[KKFetchVideoCorverTool sharedInstance]setupEnvWithFilePath:videoInfo.filePath];
        [KKFetchVideoCorverTool fetchCorverWithFilePath:videoInfo.filePath seconds:0 callback:^(UIImage *movieImage) {
            @strongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.recCorverView.image = movieImage ;
                self.sliderView.selImage = movieImage;
            });
        }];
    }
    return self ;
}

- (void)viewWillAppear{
    [super viewWillAppear];
    [self setupUI];
}

- (void)layoutSubviews{
    [super layoutSubviews];
}

- (void)viewWillDisappear{
    [super viewWillDisappear];
}

#pragma mark -- UI

- (void)setupUI{
    [self.dragContentView setBackgroundColor:[UIColor whiteColor]];
    [self.dragContentView addSubview:self.backBtn];
    [self.dragContentView addSubview:self.titleLabel];
    [self.dragContentView addSubview:self.doneBtn];
    [self.dragContentView addSubview:self.recCorverView];
    [self.dragContentView addSubview:self.sliderView];
    
    [self.backBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dragContentView).mas_offset(5);
        make.centerY.mas_equalTo(self.dragContentView.mas_top).mas_offset(topViewHeight / 2.0 + 8);
    }];
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.dragContentView);
        make.centerY.mas_equalTo(self.backBtn);
    }];
    
    [self.doneBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.dragContentView).mas_offset(-kkPaddingNormal);
        make.centerY.mas_equalTo(self.backBtn);
    }];
    
    [self.recCorverView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.dragContentView);
        make.top.mas_equalTo(self.dragContentView).mas_offset(topViewHeight).priority(998);
        make.size.mas_equalTo(CGSizeMake(UIDeviceScreenWidth, UIDeviceScreenWidth));
    }];
    
    [self.sliderView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.recCorverView.mas_bottom);
        make.left.right.mas_equalTo(self.dragContentView);
        make.bottom.mas_equalTo(self.dragContentView);
    }];
    
    [self layoutIfNeeded];
}

#pragma mark -- 返回按钮

- (void)backBtnClicked{
    [self pushOutToRight:YES];
}

#pragma mark -- 完成按钮

- (void)doneBtnClicked{
    [self pushOutToRight:YES];
}

#pragma mark -- KKRecordCorverSliderDelegate

- (void)seekToPosition:(CGFloat)position{
    @weakify(self);
    [[KKFetchVideoCorverTool sharedInstance]asyncCopyCorverWithPosition:position callback:^(UIImage *image){
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.recCorverView.image = image;
            self.sliderView.selImage = image ;
        });
    }];
}

#pragma mark -- @property

- (UIButton *)backBtn{
    if(!_backBtn){
        _backBtn = ({
            UIButton *view = [UIButton new];
            [view setImage:[UIImage imageNamed:@"lefterbackicon_titlebar_24x24_"] forState:UIControlStateNormal];
            [view addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            view;
        });
    }
    return _backBtn;
}

- (UIButton *)doneBtn{
    if(!_doneBtn){
        _doneBtn = ({
            UIButton *view = [UIButton new];
            [view setTitle:@"确定" forState:UIControlStateNormal];
            [view setTitleColor:KKColor(0, 128, 216, 1) forState:UIControlStateNormal];
            [view addTarget:self action:@selector(doneBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            view;
        });
    }
    return _doneBtn;
}

- (UILabel *)titleLabel{
    if(!_titleLabel){
        _titleLabel = ({
            UILabel *view = [UILabel new];
            view.text = @"编辑视频封面";
            view.textColor = [UIColor blackColor];
            view.textAlignment = NSTextAlignmentCenter;
            view.lineBreakMode = NSLineBreakByCharWrapping;
            view ;
        });
    }
    return _titleLabel;
}

- (UIImageView *)recCorverView{
    if(!_recCorverView){
        _recCorverView = ({
            UIImageView *view = [UIImageView new];
            view.contentMode = UIViewContentModeScaleAspectFit;
            view.backgroundColor = [UIColor blackColor];
            view ;
        });
    }
    return _recCorverView;
}

- (KKRecordCorverSlider *)sliderView{
    if(!_sliderView){
        _sliderView = ({
            KKRecordCorverSlider *view = [[KKRecordCorverSlider alloc]initWithVideoInfo:self.videoInfo];;
            view.delegate = self ;
            view ;
        });
    }
    return _sliderView;
}

@end
