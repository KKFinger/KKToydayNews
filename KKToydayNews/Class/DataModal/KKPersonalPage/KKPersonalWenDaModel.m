//
//  KKPersonalWenDaModel.m
//  KKToydayNews
//
//  Created by finger on 2017/11/18.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKPersonalWenDaModel.h"

@implementation KKPersonalQAContentModel
+ (NSDictionary *)mj_objectClassInArray{
    return @{@"thumb_image_list":[KKImageItem class],
             @"large_image_list":[KKImageItem class]
             };
}
@end

@implementation KKPersonalAnswerModel
@end

@implementation KKPersonalQuestionModel
@end

@implementation KKPersonalQAModel
@end

@implementation KKPersonalWenDaModel

+ (NSDictionary *)mj_objectClassInArray{
    return @{@"answer_question":[KKPersonalQAModel class]};
}

@end
