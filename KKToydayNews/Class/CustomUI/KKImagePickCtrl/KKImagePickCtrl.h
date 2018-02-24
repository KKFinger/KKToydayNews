//
//  KKImagePickCtrl.h
//  KKToydayNews
//
//  Created by finger on 2017/8/4.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KKImagePickCtrl : UIViewController

@property(nonatomic,strong)UIImage *image ;
@property(nonatomic,assign)CGFloat selViewHeight ;

@property(nonatomic, copy) void(^rstImageHandler)(UIImage *image);
@property(nonatomic, copy) void(^cancelHandler)();

- (id)initWithImage:(UIImage *)image selViewHeight:(CGFloat)selViewHeight;

@end
