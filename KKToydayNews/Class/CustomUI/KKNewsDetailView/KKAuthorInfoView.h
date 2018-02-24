//
//  KKAuthorInfoView.h
//  KKToydayNews
//
//  Created by finger on 2017/9/23.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KKAuthorInfoViewDelegate <NSObject>
@optional
- (void)setConcern:(BOOL)isConcern callback:(void(^)(BOOL isSuc))callback;
- (void)clickedUserHeadWithUserId:(NSString *)userId;
@end

@interface KKAuthorInfoView : UIView
@property(nonatomic,weak)id<KKAuthorInfoViewDelegate>delegate;
@property(nonatomic,assign)CGSize headerSize;
@property(nonatomic,assign)BOOL showDetailLabel;
@property(nonatomic,assign)BOOL showBottomSplit;
@property(nonatomic,assign)BOOL isConcern;
@property(nonatomic,copy)NSString *headUrl;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *detail;
@property(nonatomic,copy)NSString *userId;

@property(nonatomic,readonly)UILabel *nameLabel;
@property(nonatomic,readonly)UILabel *detailLabel;

@end
