//
//  KKSummaryDataModel.m
//  KKToydayNews
//
//  Created by finger on 2017/9/7.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKSummaryDataModel.h"

@implementation KKFilterWords
@end


@implementation KKUrlList

- (void)setUrl:(NSString *)url{
    _url = url ;
    if(![_url containsString:@"http:"] && ![_url containsString:@"https:"]){
        _url = [NSString stringWithFormat:@"http:%@",_url];
    }
    _url = [_url stringByReplacingOccurrencesOfString:@"\\" withString:@""];
}

@end

@implementation KKImageItem

+ (NSDictionary *)mj_objectClassInArray{
    return @{ @"url_list" : [KKUrlList class] };
}

- (void)setUrl:(NSString *)url{
    _url = url ;
    if(![_url containsString:@"http:"] && ![_url containsString:@"https:"]){
        _url = [NSString stringWithFormat:@"http:%@",_url];
    }
    _url = [_url stringByReplacingOccurrencesOfString:@"\\" withString:@""];
}

@end



@implementation KKMediaInfo
@end


@implementation KKVideoDetailInfo
@end

@implementation KKVideoList

@end

@implementation KKVideoItem

- (void)setMain_url:(NSString *)main_url{
    _main_url = main_url;
    if(!_main_url.length){
        _main_url = @"";
    }
    NSData *data = [[NSData alloc]initWithBase64EncodedString:_main_url options:NSDataBase64DecodingIgnoreUnknownCharacters];
    _main_url = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if(!_main_url.length){
        _main_url = @"";
    }
    if(![_main_url containsString:@"http:"] && ![_main_url containsString:@"https:"]){
        _main_url = [NSString stringWithFormat:@"http:%@",_main_url];
    }
    _main_url = [_main_url stringByReplacingOccurrencesOfString:@"\\" withString:@""];
}

- (void)setBackup_url_1:(NSString *)backup_url_1{
    _backup_url_1 = backup_url_1;
    if(!backup_url_1.length){
        backup_url_1 = @"";
    }
    NSData *data = [[NSData alloc]initWithBase64EncodedString:backup_url_1 options:NSDataBase64DecodingIgnoreUnknownCharacters];
    backup_url_1 = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    if(!backup_url_1.length){
        backup_url_1 = @"";
    }
    if(![backup_url_1 containsString:@"http:"] && ![backup_url_1 containsString:@"https:"]){
        backup_url_1 = [NSString stringWithFormat:@"http:%@",backup_url_1];
    }
    backup_url_1 = [backup_url_1 stringByReplacingOccurrencesOfString:@"\\" withString:@""];
}

@end

@implementation KKVideoPlayInfo
@end


@implementation KKAuthInfo
@end



@implementation KKUserInfo
+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"description_":@"description"};
}
@end


@implementation KKUserInfoNew
+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"description_":@"description"};
}
@end



@implementation KKAdInfo
+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"description_":@"description"};
}
@end



@implementation KKSummaryContent

+ (NSDictionary *)mj_objectClassInArray{
    return @{ @"filter_words" : [KKFilterWords class],
              @"large_image_list" : [KKImageItem class],
              @"image_list" : [KKImageItem class],
              @"thumb_image_list":[KKImageItem class],
              @"ugc_cut_image_list":[KKImageItem class]};
}

+(NSDictionary *)mj_replacedKeyFromPropertyName{
    return @{@"smallVideo":@"raw_data"};
}

@end


@implementation KKContentDataModel
@end


@implementation KKTipInfo
@end

@implementation KKSmallVideoAction
@end

@implementation KKSmallMusicInfo
@end

@implementation KKSmallVideoPlayInfo
@end

@implementation KKSmallVideoUserInfo
@end

@implementation KKAddressInfo
+ (NSDictionary *)mj_objectClassInArray{
    return @{@"url_list" : [NSString class]};
}
@end


@implementation KKSmallVideoData
+ (NSDictionary *)mj_objectClassInArray{
    return @{@"first_frame_image_list" : [KKImageItem class],
              @"animated_image_list" : [KKImageItem class],
              @"large_image_list":[KKImageItem class],
              @"thumb_image_list":[KKImageItem class]};
}
@end


@implementation KKSummaryDataModel

+ (NSDictionary *)mj_objectClassInArray{
    return @{ @"data" : [KKContentDataModel class] };
}

- (void)setData:(NSMutableArray<KKContentDataModel *> *)data{
    for(KKContentDataModel *modal in data){
        KKSummaryContent *item = [KKSummaryContent mj_objectWithKeyValues:modal.content];
        [self.contentArray addObject:item];
    }
    [data removeAllObjects];
    data = nil ;
}

- (NSMutableArray<KKSummaryContent *> *)contentArray{
    if(!_contentArray){
        _contentArray = [NSMutableArray new];
    }
    return _contentArray;
}

@end
