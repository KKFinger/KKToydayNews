//
//  KKPersonalModel.h
//  KKToydayNews
//
//  Created by finger on 2017/11/18.
//  Copyright © 2017年 finger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KKPersonalTopic:KKModalBase
@property(nonatomic,copy)NSString *url;
@property(nonatomic,copy)NSString *is_default;
@property(nonatomic,copy)NSString *show_name;
@property(nonatomic,copy)NSString *type;
@end

@interface KKPersonalInfo:KKModalBase
@property(nonatomic,copy)NSString *is_followed;
//@property(nonatomic,copy)NSString *current_user_id;
//@property(nonatomic,copy)NSString *article_limit_enable;
//@property(nonatomic,copy)NSString *verified_agency;
@property(nonatomic,copy)NSString *is_following;
@property(nonatomic,copy)NSString *pgc_like_count;
@property(nonatomic,copy)NSString *user_verified;
@property(nonatomic,copy)NSArray<KKPersonalTopic*> *topic;//top_tab
@property(nonatomic,copy)NSString *is_blocking;
@property(nonatomic,copy)NSString *user_id;
//@property(nonatomic,copy)NSString *area;
//@property(nonatomic,copy)NSString *apply_auth_entry_title;
@property(nonatomic,copy)NSString *share_url;
//@property(nonatomic,copy)NSString *show_private_letter;
@property(nonatomic,copy)NSString *followers_count;
//@property(nonatomic,copy)NSArray *medals;
//@property(nonatomic,copy)NSString *status;
@property(nonatomic,copy)NSString *media_id;
@property(nonatomic,copy)NSString *desc;
//@property(nonatomic,copy)NSString *apply_auth_url;
@property(nonatomic,copy)NSString *bg_img_url;
@property(nonatomic,copy)NSString *verified_content;
@property(nonatomic,copy)NSString *screen_name;
//@property(nonatomic,copy)NSString *visit_count_recent;
//@property(nonatomic,copy)NSString *is_blocked;
@property(nonatomic,copy)NSString *user_auth_info;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,copy)NSString *big_avatar_url;
@property(nonatomic,copy)NSString *gender;
//@property(nonatomic,copy)NSString *industry;
@property(nonatomic,copy)NSString *ugc_publish_media_id;
@property(nonatomic,copy)NSString *avatar_url;
@property(nonatomic,copy)NSString *followings_count;
@end

@interface KKPersonalModel : KKModalBase
@property(nonatomic,copy)NSString *message;
@property(nonatomic)KKPersonalInfo *info ;//data
@end
