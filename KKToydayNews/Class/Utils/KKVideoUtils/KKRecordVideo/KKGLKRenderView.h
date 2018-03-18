//
//  KKGLKRenderView.h
//  KKQuickLive
//
//  Created by finger on 2018/3/18.
//  Copyright © 2018年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface KKGLKRenderView : UIView

#pragma mark -- 绘制

- (void)drawCIImage:(CIImage *)ciImage;

@end
