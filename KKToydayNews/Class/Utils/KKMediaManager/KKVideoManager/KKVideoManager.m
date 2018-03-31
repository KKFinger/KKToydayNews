//
//  KKVideoManager.m
//  KKToydayNews
//
//  Created by finger on 2017/10/14.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKVideoManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "KKVideoInfo.h"
#import "KKMediaAlbumInfo.h"
#import "KKAppTools.h"

@interface KKVideoManager()<PHPhotoLibraryChangeObserver>
@property(nonatomic,strong)PHCachingImageManager *cachingImageManager;
@property(nonatomic,strong)PHAssetCollection *albumCollection;
@property(nonatomic,strong)PHFetchResult *albumAssets;
@end

@implementation KKVideoManager

+ (instancetype)sharedInstance{
    static id sharedInstance;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[[self class] alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc{
    PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
    [photoLibrary unregisterChangeObserver:self];
}

- (id)init{
    self = [super init];
    if (self){
        self.albumAssets = nil ;
        self.albumCollection = nil ;
        self.cachingImageManager = [[PHCachingImageManager alloc] init];
        PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
        [photoLibrary registerChangeObserver:self];
    }
    return self;
}

#pragma mark -- 照片库变动通知

- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(photoLibraryDidChange) object:nil];
        [self performSelector:@selector(photoLibraryDidChange) withObject:nil afterDelay:0.3];
    });
}

- (void)photoLibraryDidChange{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:KKNotifyVideoLibraryDidChange object:nil];
    });
}

#pragma mark -- 用户权限

- (KKPhotoAuthorizationStatus )convertStatusWithPHAuthorizationStatus:(PHAuthorizationStatus)PHStatus{
    switch (PHStatus){
        case PHAuthorizationStatusNotDetermined:
            return KKPhotoAuthorizationStatusNotDetermined;
        case PHAuthorizationStatusDenied:
            return KKPhotoAuthorizationStatusDenied;
        case PHAuthorizationStatusRestricted:
            return KKPhotoAuthorizationStatusRestricted;
        case PHAuthorizationStatusAuthorized:
            return KKPhotoAuthorizationStatusAuthorized;
        default:
            return KKPhotoAuthorizationStatusRestricted;
    }
}

- (KKPhotoAuthorizationStatus)authorizationStatus{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    return [self convertStatusWithPHAuthorizationStatus:status];
}

- (void)requestAuthorization:(void (^)(KKPhotoAuthorizationStatus))handler{
    @weakify(self);
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if(handler){
            @strongify(self);
            handler([self convertStatusWithPHAuthorizationStatus:status]);
        }
    }];
}

#pragma mark -- 初始化相册相关参数,collection 可以是PHAssetCollection对象,也可以是相册id

- (void)initAlbumWithAlbumObj:(NSObject *)collection
                        block:(void(^)(BOOL done ,KKMediaAlbumInfo *albumInfo))hander{
    if (collection == nil ){
        if(hander){
            hander(NO,nil);
        }
    }else{
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeVideo];
        
        if([collection isKindOfClass:[PHAssetCollection class]]){
            self.albumCollection = (PHAssetCollection *)collection;
            self.albumAssets = [PHAsset fetchAssetsInAssetCollection:self.albumCollection options:options];
            KKMediaAlbumInfo *albumInfo = [self getAlbumInfoWithPHAssetCollection:self.albumCollection];
            if(hander){
                hander(YES,albumInfo);
            }
        }else if([collection isKindOfClass:[NSString class]]){
            @weakify(self);
            [self getVideoAlbumCollectionWithAlbumId:(NSString *)collection block:^(PHAssetCollection *collection) {
                @strongify(self);
                self.albumCollection = collection;
                self.albumAssets = [PHAsset fetchAssetsInAssetCollection:self.albumCollection options:options];
                KKMediaAlbumInfo *albumInfo = [self getAlbumInfoWithPHAssetCollection:self.albumCollection];
                if(hander){
                    hander(YES,albumInfo);
                }
            }];
        }
    }
}

#pragma mark -- 获取系统视频分组的id

- (NSString*)getCameraRollAlbumId{
    PHFetchResult *collectionsResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (int i = 0; i < collectionsResult.count; i++){
        PHAssetCollection *collection = collectionsResult[i];
        NSInteger assetSubType = collection.assetCollectionSubtype ;
        if (assetSubType == PHAssetCollectionSubtypeSmartAlbumVideos){
            return collection.localIdentifier;
        }
    }
    return nil ;
}

#pragma mark -- 获取视频分组对应的PHAssetCollection

- (void)getVideoAlbumCollectionWithAlbumId:(NSString *)albumId block:(void(^)(PHAssetCollection *collection))handler{
    PHAssetCollection *collection = [self getCollectionWithAlbumId:albumId];
    handler(collection);
}

- (PHAssetCollection *)getCollectionWithAlbumId:(NSString *)albumId{
    PHFetchResult *smartAlbumsResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    if (smartAlbumsResult != nil){
        NSInteger albumCount = smartAlbumsResult.count;
        if ( albumCount > 0 ){
            for (int i = 0; i < albumCount; i++){
                PHAssetCollection *collection = smartAlbumsResult[i];
                if ([collection.localIdentifier isEqualToString:albumId]){
                    return collection;
                }
            }
        }
    }
    //自定义
    PHFetchResult *customAlbumsResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    if (customAlbumsResult != nil){
        NSInteger albumCount = customAlbumsResult.count;
        if (albumCount >0 ){
            for (int i = 0; i < albumCount; i++){
                PHAssetCollection *collection = customAlbumsResult[i];
                if ([collection.localIdentifier isEqualToString:albumId]){
                    return collection;
                }
            }
        }
    }
    return nil ;
}

#pragma mark -- 获取视频分组列表

- (void)getVideoAlbumListWithBlock:(void(^)(NSArray<KKMediaAlbumInfo *>* albumList))handler{
    NSMutableArray<KKMediaAlbumInfo*> *array = [[NSMutableArray<KKMediaAlbumInfo*> alloc] initWithCapacity:0];
    //获取系统相册
    PHFetchResult *smartAlbumsResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    if (smartAlbumsResult != nil){
        NSInteger albumCount = smartAlbumsResult.count;
        if (albumCount >0 ){
            for (int i = 0; i < albumCount; i++){
                PHAssetCollection *collection = smartAlbumsResult[i];
                NSString *albumTitle = collection.localizedTitle;
                NSInteger assetSubType = collection.assetCollectionSubtype ;
                
                if (albumTitle == nil){
                    continue;
                }
                
                if([[[UIDevice currentDevice]systemVersion]floatValue] >= 9.0){
                    
                    if(assetSubType == PHAssetCollectionSubtypeSmartAlbumTimelapses ||
                       assetSubType == PHAssetCollectionSubtypeSmartAlbumSlomoVideos ||
                       assetSubType == PHAssetCollectionSubtypeSmartAlbumBursts ||
                       assetSubType == PHAssetCollectionSubtypeSmartAlbumAllHidden  ||
                       assetSubType == PHAssetCollectionSubtypeSmartAlbumPanoramas ||
                       assetSubType == PHAssetCollectionSubtypeSmartAlbumFavorites ||
                       assetSubType == PHAssetCollectionSubtypeSmartAlbumSelfPortraits ){
                        continue ;
                    }
                    
                }else{
                    
                    if(assetSubType == PHAssetCollectionSubtypeSmartAlbumTimelapses ||
                       assetSubType == PHAssetCollectionSubtypeSmartAlbumSlomoVideos ||
                       assetSubType == PHAssetCollectionSubtypeSmartAlbumBursts ||
                       assetSubType == PHAssetCollectionSubtypeSmartAlbumAllHidden  ||
                       assetSubType == PHAssetCollectionSubtypeSmartAlbumPanoramas ||
                       assetSubType == PHAssetCollectionSubtypeSmartAlbumFavorites){
                        continue ;
                    }
                }
                
                KKMediaAlbumInfo *info = [self getAlbumInfoWithPHAssetCollection:collection];
                if (info != nil){
                    [array safeAddObject:info];
                }
            }
        }
    }
    
    //自定义相册
    PHFetchResult *customAlbumsResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    
    if (customAlbumsResult != nil){
        NSInteger albumCount = customAlbumsResult.count;
        if (albumCount >0 ){
            for (int i = 0; i < albumCount ; i++){
                PHAssetCollection *collection = customAlbumsResult[i];
                NSString *albumTitle = collection.localizedTitle;
                
                if (albumTitle == nil){
                    continue;
                }
                
                KKMediaAlbumInfo *info = [self getAlbumInfoWithPHAssetCollection:collection];
                if (info != nil){
                    [array safeAddObject:info];
                }
            }
        }
    }
    if(handler){
        handler(array);
    }
}

#pragma mark -- 获取视频分组信息

- (KKMediaAlbumInfo *)getAlbumInfoWithPHAssetCollection:(PHAssetCollection *)collection{
    if (collection == nil){
        return nil;
    }
    
    PHFetchResult *assetsResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    NSInteger assetsCount = 0;
    if (assetsResult !=nil){
        assetsCount = [assetsResult countOfAssetsWithMediaType:PHAssetMediaTypeVideo];
    }
    
    if (assetsCount == 0){
        return nil;
    }
    
    NSString *albumTitle = collection.localizedTitle;
    NSInteger assetSubType = collection.assetCollectionSubtype ;
    
    KKMediaAlbumInfo *albumInfo = [KKMediaAlbumInfo new];
    
    albumInfo.albumName = albumTitle ;
    albumInfo.albumId = collection.localIdentifier ;
    albumInfo.assetCount = assetsCount ;
    
    //delete content
    BOOL canDeleteItem = [collection canPerformEditOperation:PHCollectionEditOperationDeleteContent];
    albumInfo.canDeleteItem = canDeleteItem;
    
    //rename album title
    BOOL canRename = [collection canPerformEditOperation:PHCollectionEditOperationRename];
    albumInfo.canRename = canRename;
    
    //add item
    if (assetSubType == PHAssetCollectionSubtypeSmartAlbumVideos){
        albumInfo.canAddItem = YES ;
    }else{
        BOOL canAdd = [collection canPerformEditOperation:PHCollectionEditOperationAddContent];
        albumInfo.canAddItem = canAdd ;
    }
    
    //delete album
    BOOL canDelete = [collection canPerformEditOperation:PHCollectionEditOperationDelete];
    albumInfo.canDelete = canDelete;
    
    return albumInfo;
}

#pragma mark -- 获取所有的视频信息

- (void)getVideoInfoListWithBlock:(void(^)(BOOL , NSArray<KKVideoInfo *>* infoArray))handler{
    if (self.albumAssets == nil){
        if(handler){
            handler(NO,nil);
        }
    }
    NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:0];
    NSInteger assertCnt = self.albumAssets.count ;
    
    if(assertCnt){
        for (int i = 0 ; i < assertCnt ; i ++){
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [self getVideoInfoWithAsset:self.albumAssets[i] index:i block:^(BOOL done, KKVideoInfo *videoInfo){
                if (done){
                    if(videoInfo){
                        [list safeAddObject:videoInfo];
                    }
                }
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
        
        [list sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2){
            
            KKVideoInfo *info1 = (KKVideoInfo *)obj1;
            KKVideoInfo *info2 = (KKVideoInfo *)obj2;
            
            NSDate *date1 = info1.createDate;
            NSDate *date2 = info2.createDate;;
            
            NSComparisonResult result = [date1 compare:date2];
            if(result == NSOrderedDescending){
                result = NSOrderedAscending ;
            }else if(result == NSOrderedAscending){
                result = NSOrderedDescending ;
            }
            
            return result;
            
        }];
        
        if(handler){
            handler(YES,list);
        }
        
    }else{
        if(handler){
            handler(YES,@[]);
        }
    }
}

#pragma mark -- 根据索引获取视频信息

- (void)getVideoInfoWithIndex:(NSInteger)index block:(void(^)(BOOL done , KKVideoInfo *videoInfo))handler{
    if(index < 0 || index > self.albumAssets.count){
        if(handler){
            handler(NO,nil);
        }
        return ;
    }
    
    PHAsset *asset = [self.albumAssets objectAtIndex:index];
    
    [self getVideoInfoWithAsset:asset index:index block:^(BOOL done, KKVideoInfo *videoInfo) {
        if(handler){
            handler(done,videoInfo);
        }
    }];
}

#pragma mark -- 根据视频id获取视频信息

- (void)getVideoInfoWithIdentifier:(NSString *)identifier block:(void(^)(BOOL done , KKVideoInfo *videoInfo))handler{
    PHAsset *aseet = [PHAsset fetchAssetsWithLocalIdentifiers:@[identifier] options:nil].firstObject ;
    if(aseet){
        [self getVideoInfoWithAsset:aseet index:0 block:^(BOOL done, KKVideoInfo *videoInfo) {
            if(handler){
                handler(done,videoInfo);
            }
        }];
    }else{
        if(handler){
            handler(NO,nil);
        }
    }
}

- (void)getVideoInfoWithIdentifierArrat:(NSArray *)identifierArray block:(void(^)(BOOL done , NSArray<KKVideoInfo *> *videoInfos))handler{
    NSMutableArray *array = [[NSMutableArray alloc]init];
    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithLocalIdentifiers:identifierArray options:nil];
    NSInteger rstCount = fetchResult.count ;
    if(rstCount){
        __block NSInteger cnt = 0 ;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        for(NSInteger i = 0 ; i < rstCount ; i ++){
            PHAsset *asset = [fetchResult objectAtIndex:i];
            [self getVideoInfoWithAsset:asset index:i block:^(BOOL done, KKVideoInfo *videoInfo) {
                [array addObject:videoInfo];
                if(++cnt == rstCount){
                    dispatch_semaphore_signal(semaphore);
                }
            }];
        }
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        if(handler){
            handler(YES,array);
        }
        
    }else{
        if(handler){
            handler(NO,nil);
        }
    }
}

#pragma mark -- 根据PHAsset获取视频信息

- (void)getVideoInfoWithAsset:(PHAsset *)asset
                        index:(NSInteger)index
                        block:(void(^)(BOOL done , KKVideoInfo *videoInfo))handler{
    @try {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        [self.cachingImageManager requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable avasset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            
            if (![avasset isKindOfClass:[AVURLAsset class]]){
                if(handler){
                    handler(YES,nil);
                }
                return ;
            }
            
            AVURLAsset *urlAsset = (AVURLAsset *)avasset;
            
            NSString *filePath = [[urlAsset URL] path];
            
            if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
                
                NSError *error = nil;
                
                NSDictionary *fileDic = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
                
                if (fileDic != nil){
                    KKVideoInfo *videoInfo = [KKVideoInfo new];
                    
                    long long size = [fileDic fileSize];
                    NSString *fileSize = [KKAppTools formatSizeFromByte:size];
                    NSTimeInterval seconds = urlAsset.duration.value / urlAsset.duration.timescale;
                    NSString *duration = [NSString getHHMMSSFromSS:[NSString stringWithFormat:@"%f",seconds]];
                    NSDate *createDate = [asset creationDate];
                    NSDate *modifyDate = [asset modificationDate];
                    NSString *localIdentifier = asset.localIdentifier;
                    
                    videoInfo.filePath = filePath;
                    videoInfo.fileName = [filePath lastPathComponent];
                    videoInfo.fileSize = size ;
                    videoInfo.formatSize = fileSize;
                    videoInfo.duration = seconds;
                    videoInfo.formatDuration = duration;
                    videoInfo.createDate = createDate;
                    videoInfo.modifyDate = modifyDate;
                    videoInfo.localIdentifier =  localIdentifier;
                    videoInfo.itemIndex = index ;
                    
                    //视频封面，太耗时，暂时舍弃
                    /*AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
                     imageGenerator.appliesPreferredTrackTransform = YES;
                     imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
                     imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
                     NSError * error = nil;
                     CMTime time = CMTimeMake(0, 10);
                     CMTime actualTime;
                     CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];*/
                    
                    if(handler){
                        handler(YES,videoInfo);
                    }
                }else{
                    if(handler){
                        handler(NO,nil);
                    }
                }
            }
        }];
    }@catch (NSException *exception) {
        if(handler){
            handler(NO,nil);
        }
    }
}

- (void)getVideoInfoWithAsset:(PHAsset *)asset
                        block:(void(^)(BOOL done , KKVideoInfo *videoInfo))handler
{
    @try {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        [self.cachingImageManager requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable avasset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
            
            if (![avasset isKindOfClass:[AVURLAsset class]]){
                if(handler){
                    handler(YES,nil);
                }
                return ;
            }
            
            AVURLAsset *urlAsset = (AVURLAsset *)avasset;
            
            NSString *filePath = [[urlAsset URL] path];
            
            if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
                
                NSError *error = nil;
                
                NSDictionary *fileDic = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
                
                if (fileDic != nil){
                    KKVideoInfo *videoInfo = [KKVideoInfo new];
                    
                    long long size = [fileDic fileSize];
                    NSString *fileSize = [KKAppTools formatSizeFromByte:size];
                    NSTimeInterval seconds = urlAsset.duration.value / urlAsset.duration.timescale;
                    NSString *duration = [NSString getHHMMSSFromSS:[NSString stringWithFormat:@"%f",seconds]];
                    NSDate *createDate = [asset creationDate];
                    NSDate *modifyDate = [asset modificationDate];
                    NSString *localIdentifier = asset.localIdentifier;
                    
                    videoInfo.filePath = filePath;
                    videoInfo.fileName = [filePath lastPathComponent];
                    videoInfo.fileSize = size ;
                    videoInfo.formatSize = fileSize;
                    videoInfo.duration = seconds;
                    videoInfo.formatDuration = duration;
                    videoInfo.createDate = createDate;
                    videoInfo.modifyDate = modifyDate;
                    videoInfo.localIdentifier =  localIdentifier;
                    
                    //视频封面，太耗时，暂时舍弃
                    /*AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:urlAsset];
                     imageGenerator.appliesPreferredTrackTransform = YES;
                     imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
                     imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
                     NSError * error = nil;
                     CMTime time = CMTimeMake(0, 10);
                     CMTime actualTime;
                     CGImageRef cgImage = [imageGenerator copyCGImageAtTime:time actualTime:&actualTime error:&error];*/
                    
                    if(handler){
                        handler(YES,videoInfo);
                    }
                }
            }
        }];
    }@catch (NSException *exception) {
        if(handler){
            handler(NO,nil);
        }
    }
}

#pragma mark -- 获取指定索引范围的视频信息

- (void)getVideoInfoListWithFetchRange:(NSRange )range block:(void(^)(BOOL done , NSArray<KKVideoInfo *>* videoList))handler{
    @try {
        if (self.albumAssets == nil ||
            self.albumAssets.count == 0){
            if(handler){
                handler(NO,nil);
            }
            return;
        }
        
        NSRange _range = range;
        if (range.location >= self.albumAssets.count){
            if(handler){
                handler(NO,nil);
            }
            return ;
        }else if (range.location + range.length > self.albumAssets.count){
            _range = NSMakeRange(range.location, self.albumAssets.count - range.location);
        }
        
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        
        [indexSet addIndexesInRange:_range];
        
        NSArray *fetchAssets = [self.albumAssets objectsAtIndexes:indexSet];
        
        NSMutableArray *list = [[NSMutableArray alloc] initWithCapacity:0];
        
        static int readedCount = 0;
        
        for (int i = 0; i < fetchAssets.count ; i ++){
            [self getVideoInfoWithAsset:fetchAssets[i] index:(i + range.location) block:^(BOOL done, KKVideoInfo *videoInfo) {
                readedCount ++;
                if (done){
                    if (videoInfo){
                        [list safeAddObject:videoInfo];
                    }
                }
                if (readedCount >= fetchAssets.count){
                    if(handler){
                        handler(YES,list);
                    }
                }
            }];
        }
        
    }@catch (NSException *exception) {
        if(handler){
            handler(NO,nil);
        }
    }
}

#pragma mark -- 根据视频分组id、视频标识符(索引、PHAsset、视频id)获取视频信息

- (void)getVideoInfoWithAlbumID:(NSString *)albumId
                       searchId:(id)searchId
                           sort:(NSComparisonResult)comparison
                          Block:(void(^)(BOOL done , KKVideoInfo* videoInfo))handler{
    NSString *theAlbumId = albumId;
    if (theAlbumId == nil){
        if (self.albumCollection && self.albumAssets){
            theAlbumId = self.albumCollection.localIdentifier;
            PHAsset *theAsset = nil;
            if ([searchId isKindOfClass:[NSNumber class]]){
                NSInteger index = [searchId integerValue];
                theAsset = self.albumAssets[index];
            }else if ([searchId isKindOfClass:[PHAsset class]]){
                theAsset = (PHAsset *)searchId;
            }else if ([searchId isKindOfClass:[NSString class]]){
                NSString *localId = (NSString *)searchId;
                theAsset = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:nil].firstObject ;
            }
            if (theAsset){
                [self getVideoInfoWithAsset:theAsset index:-1 block:^(BOOL done, KKVideoInfo *videoInfo) {
                    if(handler){
                        handler(done,videoInfo);
                    }
                }];
            }else{
                if(handler){
                    handler(NO,nil);
                }
            }
        }else{
            if(handler){
                handler(NO,nil);
            }
        }
    }else{
        [self getVideoAlbumCollectionWithAlbumId:theAlbumId block:^(PHAssetCollection *collection){
            if (collection != nil){
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                options.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:(comparison == NSOrderedAscending)?YES:NO]];
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeVideo];
                PHFetchResult *assetsResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
                if (assetsResult){
                    PHAsset *theAsset = nil;
                    if ([searchId isKindOfClass:[NSNumber class]]){
                        NSInteger index = [searchId integerValue];
                        theAsset = assetsResult[index];
                    }else if ([searchId isKindOfClass:[PHAsset class]]){
                        theAsset = (PHAsset *)searchId;
                    }else if ([searchId isKindOfClass:[NSString class]]){
                        NSString *localId = (NSString *)searchId;
                        theAsset = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:nil].firstObject;
                    }
                    if (theAsset){
                        [self getVideoInfoWithAsset:theAsset index:-1 block:^(BOOL done, KKVideoInfo *videoInfo) {
                            if(handler){
                                handler(done,videoInfo);
                            }
                        }];
                    }else{
                        if(handler){
                            handler(NO,nil);
                        }
                    }
                }
            }
        }];
    }
}

#pragma mark -- 获取视频的缩略图

- (void)getVideoCorverWithIndex:(NSInteger)index
                  needImageSize:(CGSize)size
                 isNeedDegraded:(BOOL)degraded
                          block:(void(^)(KKVideoInfo *videoInfo))handler{
    if (self.albumAssets.count - 1 < index) {
        return;
    }
    
    PHAsset *asset = [self.albumAssets objectAtIndex:index];
    CGSize theSize = size;
    if (CGSizeEqualToSize(size, CGSizeZero) == YES){
        theSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    }
    
    NSString *localIdentifier = asset.localIdentifier ;
    KKVideoInfo *item = [KKVideoInfo new];
    item.localIdentifier = localIdentifier;
    item.itemIndex = index;
    
    [self.cachingImageManager requestImageForAsset:asset
                                        targetSize:size
                                       contentMode:PHImageContentModeAspectFit
                                           options:nil
                                     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info)
     {
         if (degraded == YES){
             item.videoCorver = result;
             item.fileName = [[info objectForKey:@"PHImageFileURLKey"]lastPathComponent];
             if(handler){
                 handler(item);
             }
         }else{
             //PHImageResultIsDegradedKey  的值为1时，表示为小尺寸的缩略图，此时还在下载原尺寸的图
             BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
             item.videoCorver = result;
             item.fileName = [[info objectForKey:@"PHImageFileURLKey"]lastPathComponent];
             if (isDegraded == NO){
                 if(handler){
                     handler(item);
                 }
             }
         }
     }];
}

- (void)getVideoCorverWithLocalIdentifier:(NSString *)localIdentifier
                            needImageSize:(CGSize)size
                           isNeedDegraded:(BOOL)degraded
                                    block:(void(^)(KKVideoInfo *videoInfo))handler{
    PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil].lastObject;
    CGSize theSize = size;
    if (CGSizeEqualToSize(size, CGSizeZero) == YES){
        theSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
    }
    
    KKVideoInfo *item = [KKVideoInfo new];
    item.localIdentifier = localIdentifier;
    
    [self.cachingImageManager requestImageForAsset:asset
                                        targetSize:size
                                       contentMode:PHImageContentModeAspectFit
                                           options:nil
                                     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info)
     {
         if (degraded == YES){
             item.videoCorver = result;
             item.fileName = [[info objectForKey:@"PHImageFileURLKey"]lastPathComponent];
             if(handler){
                 handler(item);
             }
         }else{
             //PHImageResultIsDegradedKey  的值为1时，表示为小尺寸的缩略图，此时还在下载原尺寸的图
             BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
             item.videoCorver = result;
             item.fileName = [[info objectForKey:@"PHImageFileURLKey"]lastPathComponent];
             if (isDegraded == NO){
                 if(handler){
                     handler(item);
                 }
             }
         }
     }];
}

#pragma mark - 添加

- (void)addVideoToAlbumWithFilePath:(NSString *)filePath albumId:(NSString *)albumId block:(void(^)(BOOL,KKVideoInfo *))block{
    @autoreleasepool {
        __weak typeof(self) weakSelf = self ;
        __block NSString *assetId = nil ;
        
        //异步添加相片
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            
            PHAssetCollection *collection = [weakSelf getCollectionWithAlbumId:albumId];
            
            PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            
            PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:filePath]];
            assetChangeRequest.creationDate = [NSDate date];
            
            PHObjectPlaceholder *assetPlaceholder = [assetChangeRequest placeholderForCreatedAsset];
            
            assetId = assetPlaceholder.localIdentifier ;
            
            if ([collection canPerformEditOperation:PHCollectionEditOperationAddContent]){
                [collectionChangeRequest addAssets:@[assetPlaceholder]];
            }
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
            if (error) {
                if(block){
                    block(NO,nil);
                }
                return;
            }
            
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
            
            [weakSelf getVideoInfoWithAsset:asset block:^(BOOL done, KKVideoInfo *videoInfo) {
                if(block){
                    block(success,videoInfo);
                }
            }];
        }];
    }
}

- (void)addVideoFilesToAlbumWithFilePaths:(NSArray *)filePaths albumId:(NSString *)albumId block:(void(^)(BOOL,NSArray *))block{
    @autoreleasepool {
        __weak typeof(self) weakSelf = self ;
        __block NSMutableArray *assetPlaceholderArray = [[NSMutableArray alloc]init];
        __block NSMutableArray *videoInfos = [[NSMutableArray alloc]init];
        //异步添加相片
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            
            PHAssetCollection *collection = [weakSelf getCollectionWithAlbumId:albumId];
            PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            
            for (NSString *filePath in filePaths){
                
                if([[NSFileManager defaultManager]fileExistsAtPath:filePath]){
                    
                    PHAssetChangeRequest *assetChangeRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:[NSURL fileURLWithPath:filePath]];
                    assetChangeRequest.creationDate = [NSDate date];
                    
                    if (assetChangeRequest != nil){
                        [assetPlaceholderArray addObject:[assetChangeRequest placeholderForCreatedAsset]];
                    }
                    
                }
            }
            
            if ([collection canPerformEditOperation:PHCollectionEditOperationAddContent]){
                [collectionChangeRequest addAssets:@[assetPlaceholderArray]];
            }
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            
            if (error) {
                if(block){
                    block(NO,nil);
                }
                return;
            }
            
            for(NSInteger i = 0 ; i < assetPlaceholderArray.count ; i ++){
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                
                PHObjectPlaceholder *placeholder = assetPlaceholderArray[i];
                
                NSString *assetId = placeholder.localIdentifier ;
                
                PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
                
                [weakSelf getVideoInfoWithAsset:asset block:^(BOOL done, KKVideoInfo *videoInfo) {
                    if(videoInfo){
                        [videoInfos addObject:videoInfo];
                    }
                    dispatch_semaphore_signal(semaphore);
                }];
                
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
            
            if(block){
                block(success,videoInfos);
            }
        }];
    }
}

#pragma mark -- 删除

- (void)deleteVideoWithIndexArray:(NSArray*)indexArray block:(void(^)(BOOL suc))handler{
    NSMutableArray *willDeleteAssets = [[NSMutableArray alloc] initWithCapacity:0];
    
    for(NSNumber *index in indexArray){
        PHAsset *asset = [self.albumAssets objectAtIndex:[index integerValue]];
        if(asset){
            [willDeleteAssets addObject:asset];
        }
    }
    
    PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
    if ([self.albumCollection canPerformEditOperation:PHCollectionEditOperationDeleteContent]){
        //delete
        [photoLibrary performChanges:^{
            [PHAssetChangeRequest deleteAssets:willDeleteAssets];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if(handler){
                handler(success);
            }
        }];
        
    }else if ([self.albumCollection canPerformEditOperation:PHCollectionEditOperationRemoveContent]){
        //remove
        [photoLibrary performChanges:^{
            PHAssetCollectionChangeRequest *changeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:self.albumCollection];
            [changeRequest removeAssets:willDeleteAssets];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if(handler){
                handler(success);
            }
        }];
    }else{
        if(handler){
            handler(NO);
        }
    }
}

- (void)deleteVideoWithIdentifierArray:(NSArray*)indentiferArray block:(void(^)(BOOL suc))handler{
    PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
    NSMutableArray *willDeleteAssets = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSString *localId in indentiferArray){
        PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:nil].firstObject;
        if(asset){
            [willDeleteAssets addObject:asset];
        }
    }
    
    if ([self.albumCollection canPerformEditOperation:PHCollectionEditOperationDeleteContent]){
        //delete
        [photoLibrary performChanges:^{
            [PHAssetChangeRequest deleteAssets:willDeleteAssets];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if(handler){
                handler(success);
            }
        }];
        
    }else if ([self.albumCollection canPerformEditOperation:PHCollectionEditOperationRemoveContent]){
        //remove
        [photoLibrary performChanges:^{
            PHAssetCollectionChangeRequest *changeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:self.albumCollection];
            [changeRequest removeAssets:willDeleteAssets];
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if(handler){
                handler(success);
            }
        }];
    }else{
        if(handler){
            handler(NO);
        }
    }
}

@end
