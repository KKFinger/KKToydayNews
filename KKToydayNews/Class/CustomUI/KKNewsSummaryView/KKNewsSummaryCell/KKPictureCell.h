//
//  KKPictureCell.h
//  KKToydayNews
//
//  Created by finger on 2017/10/11.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKNewsCommonCell.h"

@interface KKPictureCell : KKNewsCommonCell
@property(nonatomic,weak)NSIndexPath *indexPath;
@property(nonatomic,strong,readonly)UIImageView *largeImgView ;
@end
