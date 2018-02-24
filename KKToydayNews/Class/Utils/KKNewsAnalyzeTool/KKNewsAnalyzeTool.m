//
//  KKNewsAnalyzeTool.m
//  KKToydayNews
//
//  Created by finger on 2017/10/2.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKNewsAnalyzeTool.h"
#import "KKAppTools.h"

@implementation KKNewsAnalyzeTool

+ (void)fetchHtmlStringWithUrl:(NSString *)urlStr complete:(void(^)(NSString *htmlString))complete{
    if(!urlStr.length){
        if(complete){
            complete(@"");
        }
        return ;
    }
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession]dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(!error && data.length){
            NSString *dataStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSString *htmlString = [self pasrseNewsDetail:dataStr];
            if(!htmlString.length){
                htmlString = [self pasrseNewsDetail2:dataStr];
            }
            if(!htmlString.length){
                htmlString = [self pasrseNewsDetail3:dataStr];
            }
            if(complete){
                complete(htmlString);
            }
        }else{
            if(complete){
                complete(nil);
            }
        }
    }];
    [task resume];
}

+ (void)fetchImageItemWithUrl:(NSString *)urlStr complete:(void(^)(NSArray<KKImageItem *> *imageArray))complete{
    if(!urlStr.length){
        if(complete){
            complete(nil);
        }
        return ;
    }
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession]dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if(!error && data.length){
            NSString *dataStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            NSArray<KKImageItem *> *array = [self pasrseGallary:dataStr];
            if(complete){
                complete(array);
            }
        }else{
            if(complete){
                complete(nil);
            }
        }
    }];
    [task resume];
}

//一般格式的新闻
+ (NSString *)pasrseNewsDetail:(NSString *)newsContent{
    if(!newsContent.length){
        return @"";
    }
    
    NSString *rstString = [newsContent copy];
    NSString *lt = @"&lt;";
    NSString *gt = @"&gt;";
    NSString *qout = @"&quot;";
    
    NSRange range = [rstString rangeOfString:@"articleInfo"];
    if(range.location == NSNotFound){
        return @"";
    }
    rstString = [rstString substringFromIndex:range.location + range.length];
    
    range = [rstString rangeOfString:@"content"];
    if(range.location == NSNotFound){
        return @"";
    }
    rstString = [rstString substringFromIndex:range.location + range.length];
    
    range = [rstString rangeOfString:@"'"];
    if(range.location == NSNotFound){
        return @"";
    }
    rstString = [rstString substringFromIndex:range.location + range.length];
    
    range = [rstString rangeOfString:@"'"];
    if(range.location == NSNotFound){
        return @"";
    }
    rstString = [rstString substringToIndex:range.location];
    
    rstString = [rstString stringByReplacingOccurrencesOfString:lt withString:@"<"];
    rstString = [rstString stringByReplacingOccurrencesOfString:gt withString:@">"];
    rstString = [rstString stringByReplacingOccurrencesOfString:qout withString:@"\""];
    
    NSString *htmlString = [NSString stringWithFormat:@"<html> \n"
                            "<head> \n"
                            "<style type=\"text/css\"> \n"
                            "body {font-size:18px;}\n"
                            "</style> \n"
                            "</head> \n"
                            "<body>"
                            "<script type='text/javascript'>"
                            "window.onload = function(){\n"
                            "var $img = document.getElementsByTagName('img');\n"
                            "for(var p in  $img){\n"
                            "$img[p].style.width = '100%%';\n"
                            "$img[p].style.height ='auto'\n"
                            "}\n"
                            "}"
                            "</script>%@"
                            "</body>"
                            "</html>",rstString];
    
    return htmlString;
}

+ (NSString *)pasrseNewsDetail2:(NSString *)newsContent{
    if(!newsContent.length){
        return @"";
    }
    
    NSString *rstString = [newsContent copy];
    NSString *lt = @"&lt;";
    NSString *gt = @"&gt;";
    NSString *qout = @"&quot;";
    
    NSRange range = [rstString rangeOfString:@"<article>"];
    if(range.location == NSNotFound){
        return @"";
    }
    rstString = [rstString substringFromIndex:range.location + range.length];
    
    range = [rstString rangeOfString:@"</article>"];
    if(range.location == NSNotFound){
        return @"";
    }
    rstString = [rstString substringToIndex:range.location];
    
    rstString = [rstString stringByReplacingOccurrencesOfString:lt withString:@"<"];
    rstString = [rstString stringByReplacingOccurrencesOfString:gt withString:@">"];
    rstString = [rstString stringByReplacingOccurrencesOfString:qout withString:@"\""];
    
    NSString *htmlString = [NSString stringWithFormat:@"<html> \n"
                            "<head> \n"
                            "<style type=\"text/css\"> \n"
                            "body {font-size:18px;}\n"
                            "</style> \n"
                            "</head> \n"
                            "<body>"
                            "<script type='text/javascript'>"
                            "window.onload = function(){\n"
                            "var $img = document.getElementsByTagName('img');\n"
                            "for(var p in  $img){\n"
                            "$img[p].style.width = '100%%';\n"
                            "$img[p].style.height ='auto'\n"
                            "}\n"
                            "}"
                            "</script>%@"
                            "</body>"
                            "</html>",rstString];
    
    return htmlString;
}

//兼容环球时报
+ (NSString *)pasrseNewsDetail3:(NSString *)newsContent{
    if(!newsContent.length){
        return @"";
    }
    
    NSString *rstString = [newsContent copy];
    NSString *lt = @"&lt;";
    NSString *gt = @"&gt;";
    NSString *qout = @"&quot;";
    
    NSRange range = [rstString rangeOfString:@"<!-- 信息区 end -->"];
    if(range.location == NSNotFound){
        return @"";
    }
    rstString = [rstString substringFromIndex:range.location + range.length];
    
    range = [rstString rangeOfString:@"<!--正文结束-->"];
    if(range.location == NSNotFound){
        return @"";
    }
    rstString = [rstString substringToIndex:range.location];
    
    rstString = [rstString stringByReplacingOccurrencesOfString:lt withString:@"<"];
    rstString = [rstString stringByReplacingOccurrencesOfString:gt withString:@">"];
    rstString = [rstString stringByReplacingOccurrencesOfString:qout withString:@"\""];
    
    NSString *htmlString = [NSString stringWithFormat:@"<html> \n"
                            "<head> \n"
                            "<style type=\"text/css\"> \n"
                            "body {font-size:18px;}\n"
                            "</style> \n"
                            "</head> \n"
                            "<body>"
                            "<script type='text/javascript'>"
                            "window.onload = function(){\n"
                            "var $img = document.getElementsByTagName('img');\n"
                            "for(var p in  $img){\n"
                            "$img[p].style.width = '100%%';\n"
                            "$img[p].style.height ='auto'\n"
                            "}\n"
                            "}"
                            "</script>%@"
                            "</body>"
                            "</html>",rstString];
    
    return htmlString;
}

//浏览图片形式的新闻解析
+ (NSArray<KKImageItem *>*)pasrseGallary:(NSString *)newsContent{
    if(!newsContent.length){
        return nil;
    }
    
    NSMutableArray<KKImageItem *> *imageInfoArray = [NSMutableArray<KKImageItem *> new];
    NSString *rstString = [newsContent copy];
    NSArray *array = [rstString componentsSeparatedByString:@"<figure>"];
    for(NSInteger i = 1 ; i < array.count ; i++){
        NSString *html = [array safeObjectAtIndex:i];
        NSString *desc = @"";
        NSString *imageUrl = @"";
        NSRange range = [html rangeOfString:@"<figcaption>"];
        if(range.location != NSNotFound){
            desc = [html substringFromIndex:range.location + range.length];
            range = [desc rangeOfString:@"</figcaption>"];
            if(range.location != NSNotFound){
                desc = [desc substringToIndex:range.location];
            }else{
                range = [desc rangeOfString:@"/>"];
                if(range.location != NSNotFound){
                    desc = [desc substringToIndex:range.location];
                }
            }
        }
        
        range = [html rangeOfString:@"<img"];
        if(range.location != NSNotFound){
            imageUrl = [html substringFromIndex:range.location + range.length];
            range = [imageUrl rangeOfString:@"'"];
            if(range.location != NSNotFound){
                imageUrl = [imageUrl substringFromIndex:range.location + range.length];
                range = [imageUrl rangeOfString:@"'"];
                if(range.location != NSNotFound){
                    imageUrl = [imageUrl substringToIndex:range.location];
                }
            }
        }
        KKImageItem *item = [KKImageItem new];
        item.url = imageUrl;
        item.desc = desc;
        [imageInfoArray addObject:item];
    }
    
    if(!imageInfoArray.count){
        return [self pasrseGallary2:newsContent];
    }
    
    return imageInfoArray;
}

+ (NSArray<KKImageItem *>*)pasrseGallary2:(NSString *)newsContent{
    if(!newsContent.length){
        return nil;
    }
    
    NSString *rstString = [newsContent copy];
    NSArray *array = [rstString componentsSeparatedByString:@"BASE_DATA.galleryInfo"];
    NSString *galleryInfo = array.lastObject;
    galleryInfo = [[galleryInfo componentsSeparatedByString:@"siblingList:"]firstObject];
    galleryInfo = [galleryInfo stringByReplacingOccurrencesOfString:@"\\\"" withString:@"\""];
    if(!galleryInfo.length){
        return nil;
    }
    NSRange rangeStart = [galleryInfo rangeOfString:@"\"sub_images\":"];
    if(rangeStart.location == NSNotFound){
        return nil ;
    }
    NSRange rangeEnd = [galleryInfo rangeOfString:@"\"max_img_width\":"];
    if(rangeEnd.location == NSNotFound){
        return nil ;
    }
    
    NSInteger startIndex = rangeStart.location + rangeStart.length ;
    NSInteger endIndex = rangeEnd.location - startIndex - 1;
    NSString *imageSec = [galleryInfo substringWithRange:NSMakeRange(startIndex, endIndex)];
    NSArray *images = [imageSec mj_JSONObject];
    
    rangeStart = [galleryInfo rangeOfString:@"\"sub_abstracts\":"];
    rangeEnd = [galleryInfo rangeOfString:@"\"sub_titles\":"];
    startIndex = rangeStart.location + rangeStart.length ;
    endIndex = rangeEnd.location - 1;
    if(startIndex < 0 || startIndex >= galleryInfo.length || startIndex > endIndex){
        startIndex = 0 ;
    }
    if(endIndex < startIndex || endIndex < 0 || endIndex >= galleryInfo.length){
        endIndex = 0 ;
    }
    NSString *abstractSec = [galleryInfo substringWithRange:NSMakeRange(startIndex, endIndex - startIndex)];
    NSArray *subAbstracts = [abstractSec mj_JSONObject];
    
    NSMutableArray<KKImageItem *> *imageInfoArray  = [NSMutableArray arrayWithCapacity:0];
    
    for(NSInteger i = 0 ; i < images.count ; i++){
        KKImageItem *item = [KKImageItem mj_objectWithKeyValues:[images safeObjectAtIndex:i]];
        item.desc = [KKAppTools replaceUnicode:[subAbstracts safeObjectAtIndex:i]];
        [imageInfoArray safeAddObject:item];
    }
    
    return imageInfoArray;
}

@end
