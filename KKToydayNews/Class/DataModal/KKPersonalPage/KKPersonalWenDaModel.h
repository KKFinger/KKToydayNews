//
//  KKPersonalWenDaModel.h
//  KKToydayNews
//
//  Created by finger on 2017/11/18.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKModalBase.h"

@interface KKPersonalQAContentModel : KKModalBase
@property(nonatomic,copy)NSString *text;
@property(nonatomic,copy)NSArray *pic_uri_list;
@property(nonatomic,copy)NSArray<KKImageItem *> *thumb_image_list;
@property(nonatomic,copy)NSArray<KKImageItem *> *large_image_list;
@end

@interface KKPersonalQuestionModel : KKModalBase
@property(nonatomic)KKPersonalQAContentModel *content;
@property(nonatomic,copy)NSString *tag_name;
@property(nonatomic,copy)NSString *create_time;
@property(nonatomic,copy)NSString *normal_ans_count;
@property(nonatomic)KKUserInfoNew *user;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *qid;
@property(nonatomic,copy)NSString *nice_ans_count;
@property(nonatomic,copy)NSString *tag_id;
@property(nonatomic,copy)NSDictionary *fold_reason;

//标题富文本
@property(nonatomic)TYTextContainer *textContainer;

@end

@interface KKPersonalAnswerModel : KKModalBase
@property(nonatomic,copy)NSString *show_time;
@property(nonatomic)KKPersonalQAContentModel *content_abstract;
@property(nonatomic)KKUserInfoNew *user;
@property(nonatomic,copy)NSString *ans_url;
@property(nonatomic,copy)NSString *ansid;
@property(nonatomic,copy)NSString *is_show_bury;
@property(nonatomic,copy)NSString *wap_url;
@property(nonatomic,copy)NSString *is_buryed;
@property(nonatomic,copy)NSString *bury_count;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *is_delete;
@property(nonatomic,copy)NSString *digg_count;
@property(nonatomic,copy)NSString *content;
@property(nonatomic,copy)NSString *brow_count;
@property(nonatomic,copy)NSString *is_digg;
@property(nonatomic,copy)NSString *schema;

//标题富文本
@property(nonatomic)TYTextContainer *textContainer;

@end

@interface KKPersonalQAModel : KKModalBase
@property(nonatomic)KKPersonalAnswerModel *answer;
@property(nonatomic)KKPersonalQuestionModel *question;
@end

@interface KKPersonalWenDaModel : KKModalBase
@property(nonatomic,copy)NSString *cursor;
@property(nonatomic,copy)NSString *err_no;
@property(nonatomic,copy)NSArray<KKPersonalQAModel *> *answer_question;
@end
