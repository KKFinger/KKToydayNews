//
//  KKMediaGralleryNavView.h
//  KKToydayNews
//
//  Created by finger on 2017/10/23.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KKMediaGralleryNavViewDelegate <NSObject>
@optional
- (void)showOrHideAlbumList:(BOOL)isShow;
- (void)closeGralleryView;
- (void)selectComplete;
@end

@interface KKMediaGralleryNavView : UIView
@property(nonatomic,weak)id<KKMediaGralleryNavViewDelegate>delegate;
@property(nonatomic,copy)NSString *albumName;
@property(nonatomic,copy)NSString *selCount;
@property(nonatomic,assign)BOOL isShowAlbumList;
@property(nonatomic,assign)BOOL showSelCount;
@property(nonatomic,assign)BOOL showDoneBtn;
@property(nonatomic,assign)BOOL enableAlbumChange;//是否允许更换相册
@end
