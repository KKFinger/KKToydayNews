//
//  UIImageView+URL.h
//  TXMedicalCircle
//
//  Created by kkfinger on 2018/5/15.
//  Copyright © 2018年 kkfinger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UIImageView(YYURL) 
- (void)YYSetImageWithUrl:(NSString *_Nullable)url placeholder:(UIImage *)placeholder circleImage:(BOOL)circleImage completed:(nullable SDExternalCompletionBlock)completedBlock;
@end
