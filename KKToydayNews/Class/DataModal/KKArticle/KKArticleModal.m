//
//  KKArticleModal.m
//  KKToydayNews
//
//  Created by finger on 2017/9/20.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKArticleModal.h"

@implementation KKNewsBaseInfo

@end

@implementation KKRelatedNews

@end

@implementation KKAdItem

@end

@implementation KKMixed

+ (NSDictionary *)mj_objectClassInArray{
    return @{ @"filter_words" : [KKFilterWords class] };
}

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"Id":@"id"};
}

@end

@implementation KKLikeAndReward

@end

@implementation KKLabelItem

@end

@implementation KKOrderInfo

+ (NSDictionary *)mj_objectClassInArray{
    return @{ @"labels" : [KKLabelItem class],
              @"related_news":[KKRelatedNews class]};
}

@end

@implementation KKArticleData

+ (NSDictionary *)mj_objectClassInArray{
    return @{ @"filter_words" : [KKFilterWords class],
              @"related_video_toutiao" : [KKSummaryContent class]};
}

- (id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property{
    [super mj_newValueFromOldValue:oldValue property:property];
    if([property.name isEqualToString:@"ordered_info"]){
        NSMutableDictionary *dic = [NSMutableDictionary new];
        NSDictionary *valueDic = (NSDictionary *)oldValue ;
        for(NSDictionary *item in valueDic){
            NSString *key = item[@"name"];
            id value = [item objectForKey:@"data"];
            if([key isEqualToString:@"ad"]){
                value = [item objectForKey:@"ad_data"];
            }
            [dic setObject:value forKey:key];
        }
        return [KKOrderInfo mj_objectWithKeyValues:dic] ;
    }
    return oldValue;
}

@end

@implementation KKArticleModal

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"articleData":@"data"};
}

@end
