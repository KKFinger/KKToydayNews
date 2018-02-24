//
//  KKGalleryVideoPreviewCell.m
//  KKToydayNews
//
//  Created by finger on 2017/10/27.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKGalleryVideoPreviewCell.h"

@interface KKGalleryVideoPreviewCell()<KKXiaoShiPingPlayerDelegate>
@property(nonatomic)KKXiaoShiPingPlayer *videoPlayView;
@end

@implementation KKGalleryVideoPreviewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self setupUI];
    }
    return self;
}

#pragma mark -- 设置UI

- (void)setupUI{
    [self.contentView addSubview:self.videoPlayView];
    [self.videoPlayView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.mas_equalTo(self.contentView);
        make.width.mas_equalTo(UIDeviceScreenWidth);
    }];
}

#pragma mark -- KKXiaoShiPingPlayerDelegate

- (void)videoDidPlaying{
    
}

#pragma mark -- @property setter

- (void)setPlayUrl:(NSString *)playUrl{
    self.videoPlayView.playUrl = playUrl;
}

- (void)setCorverImage:(UIImage *)corverImage{
    self.videoPlayView.corverImage = corverImage;
}

#pragma mark -- @property getter

- (KKXiaoShiPingPlayer *)videoPlayView{
    if(!_videoPlayView){
        _videoPlayView = ({
            KKXiaoShiPingPlayer *view = [KKXiaoShiPingPlayer new];
            view.delegate = self ;
            view.netType = KKNetworkTypeLocal;
            view ;
        });
    }
    return _videoPlayView;
}

@end
