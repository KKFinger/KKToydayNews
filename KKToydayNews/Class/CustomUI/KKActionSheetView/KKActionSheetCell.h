//
//  KKActionSheetCell.h
//  KKToydayNews
//
//  Created by finger on 2017/11/28.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KKActionSheetCellDelegate <NSObject>
- (void)selectWithTitle:(NSString *)title;
@end

@interface KKActionSheetCell : UITableViewCell
@property(nonatomic,weak)id<KKActionSheetCellDelegate>delegate;
@property(nonatomic)NSString *title;
@end
