//
//  KKPhotoManager.m
//  KKToydayNews
//
//  Created by finger on 2017/10/14.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKPhotoManager.h"
#import <AssetsLibrary/AssetsLibrary.h>

static NSInteger maxThumbConcurrentCount = 50 ;//最多同时获取的缩略图个数

@interface KKPhotoManager ()<PHPhotoLibraryChangeObserver>
@property(nonatomic)PHCachingImageManager *cachingImageManager;//照片缓存，每次获取照片时先从缓存中查找
//注意，这两个变量只为了提高UICollectionView或者UItableView显示效率,不能用于其他模块的相片获取
@property(nonatomic)PHAssetCollection *albumCollection;//每一个相册对应一个PHAssetCollection
@property(nonatomic)PHFetchResult *albumAssets;//每一个相册的相片集合对应一个PHFetchResult

@property(nonatomic)NSMutableDictionary *imageInfos;

@property(nonatomic)PHImageRequestOptions *fetchThumbOptions;
@property(nonatomic)NSOperationQueue *fetchThumbQueue;

@end

@implementation KKPhotoManager

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
        self.albumAssets = nil;
        self.albumCollection = nil;
        self.cachingImageManager = [[PHCachingImageManager alloc] init];
        self.imageInfos = [NSMutableDictionary new];
        
        self.fetchThumbQueue = [[NSOperationQueue alloc]init];
        self.fetchThumbQueue.maxConcurrentOperationCount = NSIntegerMax ;
        
        self.fetchThumbOptions = [[PHImageRequestOptions alloc]init];
        self.fetchThumbOptions.networkAccessAllowed = YES ;
        self.fetchThumbOptions.resizeMode = PHImageRequestOptionsResizeModeFast ;
        self.fetchThumbOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        
        PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
        [photoLibrary registerChangeObserver:self];
    }
    return self;
}

#pragma mark -- 清理

- (void)clear{
    [self.imageInfos removeAllObjects];
    PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
    [photoLibrary unregisterChangeObserver:self];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:KKNotifyPhotoLibraryDidChange object:nil];
    });
}

#pragma mark -- 用户权限

- (KKPhotoAuthorizationStatus)convertStatusWithPHAuthorizationStatus:(PHAuthorizationStatus)PHStatus{
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
        @strongify(self);
        if(handler){
            handler([self convertStatusWithPHAuthorizationStatus:status]);
        }
    }];
}

#pragma mark -- 获取相机胶卷相册(主相册)的id

- (NSString*)getCameraRollAlbumId{
    PHFetchResult *collectionsResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (int i = 0; i < collectionsResult.count; i++){
        PHAssetCollection *collection = collectionsResult[i];
        NSInteger assetSubType = collection.assetCollectionSubtype ;
        if (assetSubType == PHAssetCollectionSubtypeSmartAlbumUserLibrary){
            return collection.localIdentifier;
        }
    }
    return nil ;
}

#pragma mark -- 相片是否选择

- (BOOL)checkSelStateWithIdentifier:(NSString *)identifier{
    KKPhotoInfo *item = [self.imageInfos objectForKey:identifier];
    return item.isSelected;
}

#pragma mark -- 加载相机胶卷(主相册)中的相片,按相片的创建日期分组

- (void)loadCameraRollWithComparison:(NSComparisonResult)comparison
                               block:(void(^)(NSArray<KKPhotoDateGroup*> *result))handler
{
    NSMutableArray<KKPhotoDateGroup*> *theResult = [NSMutableArray<KKPhotoDateGroup*> arrayWithCapacity:0];
    
    PHFetchResult *collectionsResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    KKPhotoDateGroup *lastGroup = nil ;
    
    for (int i = 0; i < collectionsResult.count; i++){
        PHAssetCollection *collection = collectionsResult[i];
        NSInteger assetSubType = collection.assetCollectionSubtype ;
        if (assetSubType == PHAssetCollectionSubtypeSmartAlbumUserLibrary){
            
            self.albumCollection = collection;
            //降序排列
            //筛选出所有的图片
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:(comparison == NSOrderedAscending)?YES:NO]];
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
            self.albumAssets = [PHAsset fetchAssetsInAssetCollection:collection options:options];
            
            for (int i = 0 ; i <self.albumAssets.count ; i++){
                PHAsset *asset = self.albumAssets[i];
                if (asset == nil || asset.mediaType != PHAssetMediaTypeImage){
                    continue;
                }
                NSString *createDate = [asset.creationDate stringWithFormat:@"yyyy-MM-dd"];
                if (![lastGroup.dateString isEqualToString:createDate]){
                    KKPhotoDateGroup *group = [KKPhotoDateGroup new];
                    group.dateString = createDate;
                    lastGroup = group;
                    [theResult safeAddObject:group];
                }
                [lastGroup.indexArray safeAddObject:[NSString stringWithFormat:@"%d",i]];
                [lastGroup.identifierArray safeAddObject:asset.localIdentifier];
            }
            
            if(handler){
                handler(theResult);
            }
            
            break;
        }
    }
}

- (void)loadCameraRollWithComparison:(NSComparisonResult)comparison
                      withDateFormat:(KKDateFormat)dataFormat
                               block:(void(^)(NSArray<KKPhotoDateGroup*> *result))handler
{
    NSMutableArray<KKPhotoDateGroup*> *theResult = [NSMutableArray<KKPhotoDateGroup*> arrayWithCapacity:0];
    
    PHFetchResult *collectionsResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    
    KKPhotoDateGroup *lastGroup = nil ;
    
    NSString *dataFormatter = nil;
    switch (dataFormat) {
        case KKDateFormatYMD:
            dataFormatter = @"YYYY-MM-dd";
            break;
        case KKDateFormatYM:
            dataFormatter = @"YYYY-MM";
            break;
        case KKDateFormatYear:
            dataFormatter = @"YYYY";
            break;
        default:
            dataFormatter = @"YYYY-MM-dd";
            break;
    }
    
    for (int i = 0; i < collectionsResult.count; i++){
        PHAssetCollection *collection = collectionsResult[i];
        NSInteger assetSubType = collection.assetCollectionSubtype ;
        if (assetSubType == PHAssetCollectionSubtypeSmartAlbumUserLibrary){
            
            self.albumCollection = collection;
            //降序排列
            //筛选出所有的图片
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:(comparison == NSOrderedAscending)?YES:NO]];
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
            self.albumAssets = [PHAsset fetchAssetsInAssetCollection:collection options:options];
            
            for (int i = 0 ; i <self.albumAssets.count ; i++){
                PHAsset *asset = self.albumAssets[i];
                if (asset == nil || asset.mediaType != PHAssetMediaTypeImage){
                    continue;
                }
                NSString *createDate = [asset.creationDate stringWithFormat:dataFormatter];
                if (![lastGroup.dateString isEqualToString:createDate]){
                    KKPhotoDateGroup *group = [KKPhotoDateGroup new];
                    group.dateString = createDate;
                    lastGroup = group;
                    [theResult safeAddObject:group];
                }
                [lastGroup.indexArray safeAddObject:[NSString stringWithFormat:@"%d",i]];
                [lastGroup.identifierArray safeAddObject:asset.localIdentifier];
            }
            if(handler){
                handler(theResult);
            }
            break;
        }
    }
}

#pragma mark -- 重置相册的PHAssetCollection及其对应的相片资源

- (void)resetCollectionWithAlbumId:(NSString *)albumId{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    
    @weakify(self);
    [self getAlbumCollectionWithAlbumId:albumId block:^(PHAssetCollection *collection) {
        @strongify(self);
        self.albumCollection = collection;
        self.albumAssets = [PHAsset fetchAssetsInAssetCollection:self.albumCollection options:options];
    }];
}

#pragma mark -- 初始化相册相关参数,collection 可以是PHAssetCollection对象,也可以是相册id

- (void)initAlbumWithAlbumObj:(NSObject *)collection
                        block:(void(^)(BOOL done ,KKMediaAlbumInfo *albumInfo))hander
{
    if (collection == nil ){
        if(hander){
            hander(NO,nil);
        }
    }else{
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
        
        if([collection isKindOfClass:[PHAssetCollection class]]){
            self.albumCollection = (PHAssetCollection *)collection;
            self.albumAssets = [PHAsset fetchAssetsInAssetCollection:self.albumCollection options:options];
            KKMediaAlbumInfo *albumInfo = [self getAlbumInfoWithPHAssetCollection:self.albumCollection];
            if(hander){
                hander(YES,albumInfo);
            }
        }else if([collection isKindOfClass:[NSString class]]){
            @weakify(self);
            [self getAlbumCollectionWithAlbumId:(NSString *)collection block:^(PHAssetCollection *collection) {
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

#pragma mark -- 加载某个相册中的相片,按相片的创建日期分组

- (void)getAlbumImageWithComparison:(NSComparisonResult)comparison
                           albumObj:(NSObject *)collection
                     withDateFormat:(KKDateFormat)dataFormat
                              block:(void(^)(NSArray<KKPhotoDateGroup*> *result))handler
{
    NSMutableArray<KKPhotoDateGroup*> *theResult = [NSMutableArray<KKPhotoDateGroup*> arrayWithCapacity:0];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:(comparison == NSOrderedAscending)?YES:NO]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    
    @weakify(self);
    [self getAlbumCollectionWithAlbumId:(NSString *)collection block:^(PHAssetCollection *callback){
        @strongify(self);
        self.albumCollection = callback;
        self.albumAssets = [PHAsset fetchAssetsInAssetCollection:self.albumCollection options:options];
        
        KKPhotoDateGroup *lastGroup = nil;
        
        NSString *dataFormatter = nil;
        switch (dataFormat) {
            case KKDateFormatYMD:
                dataFormatter = @"YYYY-MM-dd";
                break;
            case KKDateFormatYM:
                dataFormatter = @"YYYY-MM";
                break;
            case KKDateFormatYear:
                dataFormatter = @"YYYY";
                break;
            default:
                dataFormatter = @"YYYY-MM-dd";
                break;
        }
        for (int i = 0 ; i <self.albumAssets.count ; i++){
            PHAsset *asset = self.albumAssets[i];
            if (asset == nil || asset.mediaType != PHAssetMediaTypeImage){
                continue;
            }
            
            NSString *createDate = [asset.creationDate stringWithFormat:dataFormatter];
            if (![lastGroup.dateString isEqualToString:createDate]){
                KKPhotoDateGroup *group = [KKPhotoDateGroup new];
                group.dateString = createDate;
                lastGroup = group ;
                [theResult safeAddObject:group];
            }
            [lastGroup.indexArray safeAddObject:[NSString stringWithFormat:@"%d",i]];
            [lastGroup.identifierArray safeAddObject:asset.localIdentifier];
        }
        if(handler){
            handler(theResult);
        }
    }];
}

#pragma mark -- 创建相册

-(NSString *)createAlbumIfNeedWithName:(NSString *)name{
    //判断是否已存在
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection * assetCollection in assetCollections) {
        if ([assetCollection.localizedTitle isEqualToString:name]) {
            return assetCollection.localIdentifier;
        }
    }
    
    //创建新的相簿
    __block NSString *assetCollectionLocalIdentifier = nil;
    NSError *error = nil;
    //同步方法
    [[PHPhotoLibrary sharedPhotoLibrary]performChangesAndWait:^{
        // 创建相簿的请求
        assetCollectionLocalIdentifier = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:name].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    
    if (error)return nil;
    
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[assetCollectionLocalIdentifier] options:nil].lastObject.localIdentifier;
}

#pragma mark - 图片缩略图获取，albumCollection和albumAssets在调用之前必须先初始化

//取消所有的缩略图的拉取工作
- (void)cancelAllThumbnailTask{
    [self.fetchThumbQueue cancelAllOperations];
    NSLog(@"取消所有的缩略图的拉取工作");
}

- (void)getThumbnailImageWithIndex:(NSInteger)index
                     needImageSize:(CGSize)size
                    isNeedDegraded:(BOOL)degraded
                             block:(void(^)(KKPhotoInfo *item))handler
{
    if(self.fetchThumbQueue.operationCount >= maxThumbConcurrentCount){
        [self.fetchThumbQueue cancelAllOperations];
        NSLog(@"获取缩略图并发个数过多，取消所有拉取请求");
    }
    
    @weakify(self);
    [self.fetchThumbQueue addOperationWithBlock:^{
        @strongify(self);
        if (self.albumCollection && self.albumAssets){
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [self getThumbnailImageWithAlbumAsset:self.albumAssets
                                            index:index
                                    needImageSize:size
                                   isNeedDegraded:degraded
                                            block:^(KKPhotoInfo *item)
             {
                 if(handler){
                     handler(item);
                 }
                 dispatch_semaphore_signal(semaphore);
             }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }else{
            if(handler){
                handler(nil);
            }
        }
    }];
}

- (void)getThumbnailImageWithAlbumAsset:(PHFetchResult *)assetsResult
                                  index:(NSInteger)index
                          needImageSize:(CGSize)size
                         isNeedDegraded:(BOOL)degraded
                                  block:(void(^)(KKPhotoInfo *item))handler
{
    if (index < assetsResult.count){
        PHAsset *asset = assetsResult[index];
        if(!asset){
            if(handler){
                handler(nil);
            }
            return ;
        }
        
        NSString *localIdentifier = asset.localIdentifier ;
        KKPhotoInfo *item = [self.imageInfos objectForKey:localIdentifier];
        if(!item){
            item = [KKPhotoInfo new];
            item.identifier = asset.localIdentifier;
            [self.imageInfos setObject:item forKey:localIdentifier];
        }
        
        item.imageIndex = index;
        
        [self.cachingImageManager requestImageForAsset:asset
                                            targetSize:size
                                           contentMode:PHImageContentModeAspectFill
                                               options:self.fetchThumbOptions
                                         resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info)
         {
             if (degraded == YES){
                 item.image = result;
                 item.imageName = [[info objectForKey:@"PHImageFileURLKey"]lastPathComponent];
                 if(handler){
                     handler(item);
                 }
             }else{
                 //PHImageResultIsDegradedKey  的值为1时，表示为小尺寸的缩略图，此时还在下载原尺寸的图
                 BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
                 item.image = result;
                 item.imageName = [[info objectForKey:@"PHImageFileURLKey"]lastPathComponent];
                 if (isDegraded == NO){//图片完全加载
                     if(handler){
                         handler(item);
                     }
                 }
             }
         }];
    }else{
        if(handler){
            handler(nil);
        }
    }
}

#pragma mark -- 根据索引获取全屏显示的照片，注意，在照片的尺寸特别大的情况下，加载原图会导致内存暴增而崩溃(原因不明)，需要重新调整获取图片的大小

- (void)getDisplayImageWithIndex:(NSInteger)index
                   needImageSize:(CGSize)size
                  isNeedDegraded:(BOOL)degraded
                           block:(void (^)(KKPhotoInfo *item))handler{
    
    PHAsset *asset = self.albumAssets[index];
    if(!asset){
        if(handler){
            handler(nil);
        }
        return ;
    }
    
    CGSize theSize = size;
    
    //重新调整原图的大小
    if (CGSizeEqualToSize(size, CGSizeZero) == YES){
        CGFloat minRatio = 1.0 ;
        CGFloat scale = [UIScreen mainScreen].scale ;
        CGRect mainScreen = [UIScreen mainScreen].bounds;
        CGFloat targetWidth = 2 * mainScreen.size.width * scale ;
        CGFloat targetHeight = 2 * mainScreen.size.height * scale ;
        if(asset.pixelWidth > targetWidth || asset.pixelHeight > targetHeight){
            minRatio = MIN(targetWidth / asset.pixelWidth, targetHeight / asset.pixelHeight);
        }
        theSize = CGSizeMake(asset.pixelWidth * minRatio,asset.pixelHeight * minRatio);
    }
    
    PHImageRequestOptions *requireOptions = [[PHImageRequestOptions alloc]init];
    requireOptions.networkAccessAllowed = YES ;
    
    NSString *localIdentifier = asset.localIdentifier ;
    KKPhotoInfo *item = [self.imageInfos objectForKey:localIdentifier];
    if(!item){
        item = [KKPhotoInfo new];
        item.identifier = asset.localIdentifier;
        [self.imageInfos setObject:item forKey:localIdentifier];
    }
    
    item.imageIndex = index;
    
    [self.cachingImageManager requestImageForAsset:asset
                                        targetSize:size
                                       contentMode:PHImageContentModeAspectFill
                                           options:requireOptions
                                     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info)
     {
         if (degraded == YES){
             item.image = result;
             item.imageName = [[info objectForKey:@"PHImageFileURLKey"]lastPathComponent];
             if(handler){
                 handler(item);
             }
         }else{
             //PHImageResultIsDegradedKey  的值为1时，表示为小尺寸的缩略图，此时还在下载原尺寸的图
             BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
             item.image = result;
             item.imageName = [[info objectForKey:@"PHImageFileURLKey"]lastPathComponent];
             if (isDegraded == NO){
                 if(handler){
                     handler(item);
                 }
             }
         }
     }];
}

#pragma mark -- 根据相片id获取全屏显示的照片，注意，在照片的尺寸特别大的情况下，加载原图会导致内存暴增而崩溃(原因不明)，需要重新调整获取图片的大小

- (void)getDisplayImageWithIdentifier:(NSString *)identifier
                        needImageSize:(CGSize)size
                       isNeedDegraded:(BOOL)degraded
                                block:(void (^)(KKPhotoInfo *item))handler{
    PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[identifier] options:nil].firstObject;
    if(!asset){
        if(handler){
            handler(nil);
        }
        return ;
    }
    
    CGSize theSize = size;
    
    //重新调整原图的大小
    if (CGSizeEqualToSize(size, CGSizeZero) == YES){
        CGFloat minRatio = 1.0 ;
        CGFloat scale = [UIScreen mainScreen].scale ;
        CGRect mainScreen = [UIScreen mainScreen].bounds;
        CGFloat targetWidth = 2 * mainScreen.size.width * scale ;
        CGFloat targetHeight = 2 * mainScreen.size.height * scale ;
        if(asset.pixelWidth > targetWidth || asset.pixelHeight > targetHeight){
            minRatio = MIN(targetWidth / asset.pixelWidth, targetHeight / asset.pixelHeight);
        }
        theSize = CGSizeMake(asset.pixelWidth * minRatio,asset.pixelHeight * minRatio);
    }
    
    PHImageRequestOptions *requireOptions = [[PHImageRequestOptions alloc]init];
    requireOptions.networkAccessAllowed = YES ;
    
    NSString *localIdentifier = asset.localIdentifier ;
    KKPhotoInfo *item = [self.imageInfos objectForKey:localIdentifier];
    if(!item){
        item = [KKPhotoInfo new];
        item.identifier = asset.localIdentifier;
        [self.imageInfos setObject:item forKey:localIdentifier];
    }
    
    [self.cachingImageManager requestImageForAsset:asset
                                        targetSize:size
                                       contentMode:PHImageContentModeAspectFill
                                           options:requireOptions
                                     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info)
     {
         if (degraded == YES){
             item.image = result;
             item.imageName = [[info objectForKey:@"PHImageFileURLKey"]lastPathComponent];
             if(handler){
                 handler(item);
             }
         }else{
             //PHImageResultIsDegradedKey  的值为1时，表示为小尺寸的缩略图，此时还在下载原尺寸的图
             BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
             item.image = result;
             item.imageName = [[info objectForKey:@"PHImageFileURLKey"]lastPathComponent];
             if (isDegraded == NO){
                 if(handler){
                     handler(item);
                 }
             }
         }
     }];
}

#pragma mark - 获取PHAssetCollection 句柄

- (PHAssetCollection *)getAlbumCollectionWithAlbumId:(NSString *)albumId{
    //获取系统相册
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
    
    //自定义相册
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
    return nil;
}

- (void)getAlbumCollectionWithAlbumId:(NSString *)albumId block:(void(^)(PHAssetCollection *collection))callback{
    PHAssetCollection *collection = [self getAlbumCollectionWithAlbumId:albumId];
    if(callback){
        callback(collection);
    }
}

#pragma mark -- 根据相册的id获取相册的PHFetchResult

- (PHFetchResult *)getAlbumAssetsWithAlbunId:(NSString *)albumId{
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    
    PHAssetCollection *collection = [self getAlbumCollectionWithAlbumId:albumId];
    
    PHFetchResult *assets = [PHAsset fetchAssetsInAssetCollection:collection options:options];
    
    return assets ;
}

#pragma mark -- 获取相册列表信息

- (void)getImageAlbumList:(void (^)(NSArray<KKMediaAlbumInfo*> *))handler{
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
                       assetSubType == PHAssetCollectionSubtypeSmartAlbumAllHidden ||
                       assetSubType == PHAssetCollectionSubtypeSmartAlbumVideos ||
                       assetSubType == PHAssetCollectionSubtypeSmartAlbumPanoramas ||
                       assetSubType == PHAssetCollectionSubtypeSmartAlbumFavorites ||
                       assetSubType == PHAssetCollectionSubtypeSmartAlbumSelfPortraits ){
                        continue ;
                    }
                    
                }else{
                    
                    if(assetSubType == PHAssetCollectionSubtypeSmartAlbumTimelapses ||
                       assetSubType == PHAssetCollectionSubtypeSmartAlbumSlomoVideos ||
                       assetSubType == PHAssetCollectionSubtypeSmartAlbumBursts ||
                       assetSubType == PHAssetCollectionSubtypeSmartAlbumAllHidden ||
                       assetSubType == PHAssetCollectionSubtypeSmartAlbumVideos ||
                       assetSubType == PHAssetCollectionSubtypeSmartAlbumPanoramas ||
                       assetSubType == PHAssetCollectionSubtypeSmartAlbumFavorites){
                        continue ;
                    }
                }
                
                KKMediaAlbumInfo *info = [self getAlbumInfoWithPHAssetCollection:collection];
                if (info != nil && !info.isRecentDelete){
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

#pragma mark -- 相册相关信息

- (KKMediaAlbumInfo *)getAlbumInfoWithPHAssetCollection:(PHAssetCollection *)collection{
    if (collection == nil){
        return nil;
    }
    
    NSInteger assetSubType = collection.assetCollectionSubtype ;
    
    PHFetchResult *assetsResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    NSInteger assetsCount = 0;
    if (assetsResult !=nil){
        assetsCount = [assetsResult countOfAssetsWithMediaType:PHAssetMediaTypeImage];
    }
    
    if(assetsCount == 0){
        return nil;
    }
    
    KKMediaAlbumInfo *info = [KKMediaAlbumInfo new];
    
    info.assetSubType = assetSubType ;
    info.albumName = collection.localizedTitle;
    info.albumId = collection.localIdentifier ;
    info.assetCount = assetsCount ;
    
    if (assetSubType == 1000000201 /*最近删除*/){
        info.canDeleteItem = NO ;
        info.isRecentDelete = YES ;
    }else{
        info.canDeleteItem = [collection canPerformEditOperation:PHCollectionEditOperationDeleteContent];
        info.isRecentDelete = NO ;
    }
    
    //rename album title
    info.canRename = [collection canPerformEditOperation:PHCollectionEditOperationRename];
    
    if (assetSubType == PHAssetCollectionSubtypeSmartAlbumUserLibrary){
        info.canAddItem = YES ;
    }else{
        info.canAddItem = [collection canPerformEditOperation:PHCollectionEditOperationAddContent];
    }
    
    //delete album
    info.canDelete = [collection canPerformEditOperation:PHCollectionEditOperationDelete];
    
    return info;
}

- (void)getAlbumInfoWithAlbumId:(NSString *)albumId block:(void(^)(KKMediaAlbumInfo *info))resultHandler{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @weakify(self);
        [self getAlbumCollectionWithAlbumId:albumId block:^(PHAssetCollection *collection) {
            @strongify(self);
            KKMediaAlbumInfo *info = [self getAlbumInfoWithPHAssetCollection:collection] ;
            if(resultHandler){
                resultHandler(info);
            }
        }];
    });
}

#pragma mark -- 根据相册的id，获取全部图片的id

- (void)getAlbumImageIdentifierWithAlbumId:(NSString *)albumId sort:(NSComparisonResult)comparison block:(void(^)(NSArray *array))handler
{
    [self getAlbumCollectionWithAlbumId:albumId block:^(PHAssetCollection *collection) {
        if (collection != nil){
            NSMutableArray *array = [[NSMutableArray alloc]init];
            
            BOOL isAscending = YES;
            if (comparison == NSOrderedDescending){
                isAscending = NO;
            }
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:isAscending]];
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
            
            if (fetchResult.count == 0){
                if(handler){
                    handler(nil);
                }
                return ;
            }
            
            for (PHAsset *asset in fetchResult){
                if(!asset){
                    continue ;
                }
                
                NSString *identifier = asset.localIdentifier;
                [array safeAddObject:identifier];
            }
            if(handler){
                handler(array);
            }
        }else{
            if(handler){
                handler(nil);
            }
        }
    }];
}

#pragma mark -- 根据相册id和图片索引获取图片

- (void)getImageWithAlbumID:(NSString *)albumID
                      index:(NSInteger)index
              needImageSize:(CGSize)size
             isNeedDegraded:(BOOL)degraded
                       sort:(NSComparisonResult)comparison
                      block:(void (^)(KKPhotoInfo *item))handler
{
    @weakify(self);
    [self getAlbumCollectionWithAlbumId:albumID block:^(PHAssetCollection *collection) {
        @strongify(self);
        if (collection != nil){
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            BOOL isAscending = YES;
            if (comparison == NSOrderedDescending){
                isAscending = NO;
            }
            options.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:isAscending]];
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
            
            if (fetchResult.count == 0){
                if(handler){
                    handler(nil);
                }
                return ;
            }
            
            PHImageRequestOptions *requireOptions = [[PHImageRequestOptions alloc]init];
            requireOptions.networkAccessAllowed = YES ;
            
            PHAsset *asset = fetchResult[index];
            if(!asset){
                if(handler){
                    handler(nil);
                }
                return ;
            }
            
            [self requestImageFromCacheWithAsset:asset
                                          targetSize:size
                                         contentMode:PHImageContentModeAspectFill
                                             options:requireOptions
                                      isNeedDegraded:degraded
                                               block:^(KKPhotoInfo *item)
             {
                 if(handler){
                     handler(item);
                 }
             }];
            
        }else{
            if(handler){
                handler(nil);
            }
        }
    }];
}

#pragma mark -- 根据相片的PHAsset获取图片

- (void)getImageWithAsset:(PHAsset *)asset
            needImageSize:(CGSize)size
           isNeedDegraded:(BOOL)degraded
                    block:(void (^)(KKPhotoInfo *item))handler
{
    if(!asset){
        if(handler){
            handler(nil);
        }
        return ;
    }
    
    CGSize theSize = size;
    
    if (CGSizeEqualToSize(size, CGSizeZero) == YES){
        CGFloat minRatio = 1.0 ;
        CGFloat scale = [UIScreen mainScreen].scale ;
        CGRect mainScreen = [UIScreen mainScreen].bounds;
        CGFloat targetWidth = 2 * mainScreen.size.width * scale ;
        CGFloat targetHeight = 2 * mainScreen.size.height * scale ;
        if(asset.pixelWidth > targetWidth || asset.pixelHeight > targetHeight){
            minRatio = MIN(targetWidth / asset.pixelWidth, targetHeight / asset.pixelHeight);
        }
        
        theSize = CGSizeMake(asset.pixelWidth * minRatio,asset.pixelHeight * minRatio);
    }
    
    PHImageRequestOptions *requireOptions = [[PHImageRequestOptions alloc]init];
    requireOptions.networkAccessAllowed = YES ;
    
    [self requestImageFromCacheWithAsset:asset
                              targetSize:theSize
                             contentMode:PHImageContentModeAspectFill
                                 options:requireOptions
                          isNeedDegraded:degraded
                                   block:^(KKPhotoInfo *item)
     {
         if(handler){
             handler(item);
         }
     }];
}

#pragma mark -- 根据相册id和图片id获取图片

- (void)getImageWithAlbumID:(NSString *)albumID
       imageLocalIdentifier:(NSString *)localIdentifier
              needImageSize:(CGSize)size
             isNeedDegraded:(BOOL)degraded
                       sort:(NSComparisonResult)comparison
                      block:(void (^)(KKPhotoInfo *item))handler
{
    PHAssetCollection *collection = [self getAlbumCollectionWithAlbumId:albumID];
    
    if (collection != nil){
        PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil].firstObject;
        if(!asset){
            if(handler){
                handler(nil);
            }
            return ;
        }
        
        CGSize theSize = size;
        if (CGSizeEqualToSize(size, CGSizeZero) == YES){
            theSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
        }
        
        PHImageRequestOptions *requireOptions = [[PHImageRequestOptions alloc]init];
        requireOptions.networkAccessAllowed = YES ;
        
        [self requestImageFromCacheWithAsset:asset
                                  targetSize:theSize
                                 contentMode:PHImageContentModeAspectFill
                                     options:requireOptions
                              isNeedDegraded:degraded
                                       block:^(KKPhotoInfo *item)
         {
             if(handler){
                 handler(item);
             }
         }];
        
    }else{
        if(handler){
            handler(nil);
        }
    }
}

#pragma mark -- 根据相册的id，获取指定图片id的图片的PHAsset

- (void)getImageAssetWithAlbumID:(NSString *)albumID
            imageIdentifierArray:(NSArray *)identifierArray
                           block:(void(^)(NSArray *))handler
{
    PHAssetCollection *collection = [self getAlbumCollectionWithAlbumId:albumID];
    
    if (collection != nil){
        NSMutableArray *assetArray = [[NSMutableArray alloc]init];
        for(NSString *identifier in identifierArray){
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[identifier] options:nil].firstObject;
            if(!asset){
                continue ;
            }
            
            NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:asset,identifier,nil];
            
            [assetArray safeAddObject:dic];
            
        }
        
        if(handler){
            handler(assetArray);
        }
        
    }else{
        if(handler){
            handler(nil);
        }
    }
}

#pragma mark -- 同步模式，根据相册id，图片索引，获取图片数据

- (KKPhotoInfo *)sycGetImageInfoWithAlbumID:(NSString *)albumId
                                      index:(NSInteger)index
                                       sort:(NSComparisonResult)comparison
{
    __block KKPhotoInfo *imageInfo = nil ;
    
    PHAssetCollection *collection = [self getAlbumCollectionWithAlbumId:albumId];
    
    if (collection != nil){
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:(comparison == NSOrderedAscending)?YES:NO]];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
        PHFetchResult *assetsResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
        
        PHAsset *asset = assetsResult[index];
        if(!asset){
            return nil ;
        }
        
        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc]init];
        requestOptions.synchronous = YES ;
        requestOptions.networkAccessAllowed = YES ;
        
        [self requestImageDataWithAlbumId:albumId
                                    asset:asset
                                  options:requestOptions
                                    block:^(KKPhotoInfo *item)
         {
             imageInfo = item;
         }];
        
    }
    
    return imageInfo ;
}

- (NSArray<KKPhotoInfo *>*)sycGetImageInfoWithAlbumID:(NSString *)albumId
                                           indexArray:(NSArray *)indexArray
                                                 sort:(NSComparisonResult)comparison
{
    __block NSMutableArray<KKPhotoInfo *> *imageInfoArray = [[NSMutableArray<KKPhotoInfo *> alloc]init];
    
    PHAssetCollection *collection = [self getAlbumCollectionWithAlbumId:albumId];
    
    if (collection != nil){
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:(comparison == NSOrderedAscending)?YES:NO]];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
        PHFetchResult *assetsResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
        
        for(int i = 0 ; i < indexArray.count ; i++){
            NSInteger index = [indexArray[i] integerValue];
            PHAsset *asset = assetsResult[index];
            if(!asset){
                continue ;
            }
            
            PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc]init];
            requestOptions.synchronous = YES ;
            requestOptions.networkAccessAllowed = YES ;
            
            [self requestImageDataWithAlbumId:albumId
                                        asset:asset
                                      options:requestOptions
                                        block:^(KKPhotoInfo *item)
             {
                 [imageInfoArray safeAddObject:item];
             }];
        }
    }
    
    return imageInfoArray ;
}

#pragma mark -- 同步模式，根据相册id，图片索引，获取图片数据(NSData)

- (void)sycGetImageDataWithAlbumID:(NSString *)albumID
                             index:(NSInteger)index
                              sort:(NSComparisonResult)comparison
                             block:(void(^)(KKPhotoInfo *item))handler
{
    @weakify(self);
    [self getAlbumCollectionWithAlbumId:albumID block:^(PHAssetCollection *collection) {
        @strongify(self);
        if (collection != nil){
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:(comparison == NSOrderedAscending)?YES:NO]];
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
            PHFetchResult *assetsResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
            
            PHAsset *asset = assetsResult[index];
            if(!asset){
                if(handler){
                    handler(nil);
                }
                return ;
            }
            
            PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc]init];
            requestOptions.synchronous = YES ;
            requestOptions.networkAccessAllowed = YES ;
            
            [self requestImageDataWithAlbumId:albumID
                                            asset:asset
                                          options:requestOptions
                                            block:^(KKPhotoInfo *item)
             {
                 if(handler){
                     handler(item);
                 }
             }];
        }else{
            if(handler){
                handler(nil);
            }
        }
    }];
}

//反向获取图片数据
- (NSArray<KKPhotoInfo *>*)sycReverseGetImageInfoWithAlbumID:(NSString *)albumId
                                                  indexArray:(NSArray *)indexArray
                                                        sort:(NSComparisonResult)comparison
{
    __block NSMutableArray<KKPhotoInfo *> *imageInfoArray = [[NSMutableArray<KKPhotoInfo *> alloc]init];
    
    PHAssetCollection *collection = [self getAlbumCollectionWithAlbumId:albumId];
    
    if (collection != nil){
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:(comparison == NSOrderedAscending)?YES:NO]];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
        PHFetchResult *assetsResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
        
        NSInteger count = assetsResult.count ;
        for(int i = 0 ; i < indexArray.count ; i++){
            NSInteger index = count - [indexArray[i] integerValue] - 1;
            PHAsset *asset = assetsResult[index];
            if(!asset){
                continue ;
            }
            
            PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc]init];
            requestOptions.synchronous = YES ;
            requestOptions.networkAccessAllowed = YES ;
            
            [self requestImageDataWithAlbumId:albumId
                                        asset:asset
                                      options:requestOptions
                                        block:^(KKPhotoInfo *item)
             {
                 [imageInfoArray safeAddObject:item];
             }];
        }
    }
    
    return imageInfoArray ;
}

#pragma mark -- 同步模式，根据相册id，图片id，获取图片数据

- (NSArray<KKPhotoInfo *>*)sycGetImageInfoWithAlbumId:(NSString *)albumId identifierArray:(NSArray *)identifierArray
{
    __block NSMutableArray *imageInfoArray = [[NSMutableArray alloc]init];
    
    for(int i = 0 ; i < identifierArray.count ; i++){
        NSString *identifier = identifierArray[i];
        PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[identifier] options:nil].firstObject;
        if(!asset){
            continue ;
        }
        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc]init];
        requestOptions.synchronous = YES ;
        requestOptions.networkAccessAllowed = YES ;
        
        requestOptions.progressHandler = ^(double progress, NSError *__nullable error, BOOL *stop, NSDictionary *__nullable info){
        };
        
        [self requestImageDataWithAlbumId:albumId
                                    asset:asset
                                  options:requestOptions
                                    block:^(KKPhotoInfo *item)
         {
             [imageInfoArray safeAddObject:item];
         }];
    }
    
    return imageInfoArray ;
}

#pragma mark -- 获取相片的数据(NSData),以数组方式返回

- (void)getImageDataListWithAlbumID:(NSString *)albumID
                         fetchRange:(NSRange)range
                               sort:(NSComparisonResult)comparison
                              block:(void(^)(NSArray<KKPhotoInfo *> *imageList))handler{
    __block NSInteger readCount = 0;
    __block NSMutableArray<KKPhotoInfo *> *array = [[NSMutableArray<KKPhotoInfo *> alloc] initWithCapacity:0];
    
    @weakify(self);
    [self getAlbumCollectionWithAlbumId:albumID block:^(PHAssetCollection *collection) {
        @strongify(self);
        if (collection != nil){
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            BOOL isAscending = YES;
            if (comparison == NSOrderedDescending){
                isAscending = NO;
            }
            options.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:isAscending]];
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
            PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
            
            if (fetchResult != nil){
                NSRange _range = range;
                if (range.location >= fetchResult.count){
                    if(handler){
                        handler(nil);
                    }
                    return ;
                }else if (range.location + range.length > fetchResult.count){
                    _range = NSMakeRange(range.location, fetchResult.count - range.location);
                }
                
                NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
                [indexSet addIndexesInRange:_range];
                NSArray *assets = [fetchResult objectsAtIndexes:indexSet];
                for (PHAsset *asset in assets){
                    [self getImageDataWithAlbumId:albumID asset:asset block:^(KKPhotoInfo *item) {
                        
                        if (item != nil){
                            [array safeAddObject:item];
                        }
                        
                        readCount ++;
                        if (readCount >= _range.length){
                            if(handler){
                                handler(array);
                            }
                            readCount = 0;
                        }
                    }];
                }
            }
        }else{
            if(handler){
                handler(nil);
            }
        }
    }];
}

#pragma mark -- 根据相册id、相片asset 获取图片的NSData

- (void)getImageDataWithAlbumId:(NSString *)albumId
                          asset:(PHAsset *)asset
                          block:(void(^)(KKPhotoInfo *item))handler
{
    if (asset == nil){
        if(handler){
            handler(nil);
        }
        return;
    }
    
    PHImageRequestOptions *requireOptions = [[PHImageRequestOptions alloc]init];
    requireOptions.networkAccessAllowed = YES ;
    
    [self requestImageDataWithAlbumId:albumId
                                asset:asset
                              options:requireOptions
                                block:^(KKPhotoInfo *item)
     {
         if(handler){
             handler(item);
         }
     }];
}

#pragma mark -- 根据相册id、相片标识(相片索引、相片id，相片的PHAsset对象)获取完整的图片

- (void)getImageDataWithAlbumID:(NSString *)albumID
                       searchID:(id)searchID
                           sort:(NSComparisonResult)comparison
                          block:(void(^)(KKPhotoInfo *item))handler
{
    NSString *theAlbumId = albumID;
    
    if (theAlbumId == nil){
        if (self.albumCollection && self.albumAssets){
            theAlbumId = self.albumCollection.localIdentifier;
            
            PHAsset *theAsset = nil;
            
            if ([searchID isKindOfClass:[NSNumber class]]){
                NSInteger index = [searchID integerValue];
                theAsset = self.albumAssets[index];
            }else if ([searchID isKindOfClass:[PHAsset class]]){
                theAsset = (PHAsset *)searchID;
            }else if ([searchID isKindOfClass:[NSString class]]){
                NSString *localId = (NSString *)searchID;
                theAsset = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:nil].firstObject;
            }
            
            if (theAsset){
                PHImageRequestOptions *requireOptions = [[PHImageRequestOptions alloc]init];
                requireOptions.networkAccessAllowed = YES ;
                
                [self requestImageDataWithAlbumId:theAlbumId
                                            asset:theAsset
                                          options:requireOptions
                                            block:^(KKPhotoInfo *item)
                 {
                     if(handler){
                         handler(item);
                     }
                 }];
                
            }else{
                if(handler){
                    handler(nil);
                }
            }
            
        }else{
            if(handler){
                handler(nil);
            }
        }
        
    }else{
        @weakify(self);
        [self getAlbumCollectionWithAlbumId:albumID block:^(PHAssetCollection *collection) {
            @strongify(self);
            if (collection != nil){
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                options.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:(comparison == NSOrderedAscending)?YES:NO]];
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
                PHFetchResult *assetsResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
                
                if (assetsResult){
                    PHAsset *theAsset = nil;
                    if ([searchID isKindOfClass:[NSNumber class]]){
                        NSInteger index = [searchID integerValue];
                        theAsset = assetsResult[index];
                    }else if ([searchID isKindOfClass:[PHAsset class]]){
                        theAsset = (PHAsset *)searchID;
                    }else if ([searchID isKindOfClass:[NSString class]]){
                        NSString *localId = (NSString *)searchID;
                        theAsset = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:nil].firstObject;
                    }
                    
                    if (theAsset){
                        PHImageRequestOptions *requireOptions = [[PHImageRequestOptions alloc]init];
                        requireOptions.networkAccessAllowed = YES ;
                        
                        [self requestImageDataWithAlbumId:theAlbumId
                                                        asset:theAsset
                                                      options:requireOptions
                                                        block:^(KKPhotoInfo *item)
                         {
                             if(handler){
                                 handler(item);
                             }
                         }];
                    }else{
                        if(handler){
                            handler(nil);
                        }
                    }
                }
            }else{
                if(handler){
                    handler(nil);
                }
            }
        }];
    }
}

#pragma mark -- 根据相册id，图片id，获取图片数据(NSData)

- (void)getImageDataWithAlbumID:(NSString *)albumID
           imageLocalIdentifier:(NSString *)localIdentifier
                           sort:(NSComparisonResult)comparison
                          block:(void(^)(KKPhotoInfo *item))handler
{
    PHAssetCollection *collection = [self getAlbumCollectionWithAlbumId:albumID];
    if (collection != nil){
        PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil].firstObject;
        if(!asset){
            if(handler){
                handler(nil);
            }
            return ;
        }
        
        PHImageRequestOptions *requireOptions = [[PHImageRequestOptions alloc]init];
        requireOptions.networkAccessAllowed = YES ;
        
        if (asset) {
            [self requestImageDataWithAlbumId:albumID
                                        asset:asset
                                      options:requireOptions
                                        block:^(KKPhotoInfo *item)
             {
                 if(handler){
                     handler(item);
                 }
             }];
        }else{
            if(handler){
                handler(nil);
            }
        }
    }else{
        if(handler){
            handler(nil);
        }
    }
}

- (void)getImageDataWithAlbumID:(NSString *)albumID
           imageLocalIdentifier:(NSString *)localIdentifier
                           sort:(NSComparisonResult)comparison
                           sync:(BOOL)sync
                          block:(void(^)(KKPhotoInfo *item))handler
{
    PHAssetCollection *collection = [self getAlbumCollectionWithAlbumId:albumID];
    if (collection != nil){
        PHImageRequestOptions *requestOptions = [[PHImageRequestOptions alloc]init];
        if(sync){
            requestOptions.synchronous = true ;
        }
        requestOptions.networkAccessAllowed = YES ;
        
        PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[localIdentifier] options:nil].firstObject;
        if(!asset){
            if(handler){
                handler(nil);
            }
            return ;
        }
        
        [self requestImageDataWithAlbumId:albumID
                                    asset:asset
                                  options:requestOptions
                                    block:^(KKPhotoInfo *item)
         {
             if(handler){
                 handler(item);
             }
         }];
    }else{
        if(handler){
            handler(nil);
        }
    }
}

#pragma mark -- 根据相册id，图片索引，获取图片数据(NSData)

- (void)getImageDataWithAlbumID:(NSString *)albumID
                          index:(NSInteger)index
                           sort:(NSComparisonResult)comparison
                          block:(void (^)(KKPhotoInfo *item))handler
{
    @weakify(self);
    [self getAlbumCollectionWithAlbumId:albumID block:^(PHAssetCollection *collection) {
        @strongify(self);
        if (collection != nil){
            PHFetchOptions *options = [[PHFetchOptions alloc] init];
            options.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:(comparison == NSOrderedAscending)?YES:NO]];
            options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
            PHFetchResult *assetsResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
            
            PHAsset *asset = assetsResult[index];
            if(!asset){
                if(handler){
                    handler(nil);
                }
                return ;
            }
            
            PHImageRequestOptions *requireOptions = [[PHImageRequestOptions alloc]init];
            requireOptions.networkAccessAllowed = YES ;
            
            [self requestImageDataWithAlbumId:albumID
                                            asset:asset
                                          options:requireOptions
                                            block:^(KKPhotoInfo *item)
             {
                 if(handler){
                     handler(item);
                 }
             }];
        }else{
            if(handler){
                handler(nil);
            }
        }
    }];
}

#pragma mark- 删除或移除照片

- (void)deleteImageWithAlbumId:(NSString*)albumId
             imageLocalIdArray:(NSArray *)localIdArray
                         block:(void(^)(BOOL suc))handler
{
    PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
    
    PHAssetCollection *collection = [self getAlbumCollectionWithAlbumId:albumId];
    
    NSMutableArray *willDeleteList = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSString *localId in localIdArray){
        PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[localId] options:nil].firstObject;
        if (asset){
            [willDeleteList addObject:asset];
        }
    }
    
    if([collection canPerformEditOperation:PHCollectionEditOperationDeleteContent]){
        //delete
        [photoLibrary performChanges:^{
            [PHAssetChangeRequest deleteAssets:willDeleteList];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if(handler){
                handler(success);
            }
        }];
    }else if ([collection canPerformEditOperation:PHCollectionEditOperationRemoveContent]){
        //remove
        [photoLibrary performChanges:^{
            PHAssetCollectionChangeRequest *changeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            [changeRequest removeAssets:willDeleteList];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if(handler){
                handler(success);
            }
        }];
    }
}

- (void)deleteImageWithAlbumId:(NSString*)albumId
                    indexArray:(NSArray*)indexArray
                          sort:(NSComparisonResult)comparison
                         block:(void(^)(bool suc))handler
{
    PHPhotoLibrary *photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
    
    [self getAlbumCollectionWithAlbumId:albumId block:^(PHAssetCollection *collection) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:(comparison == NSOrderedAscending)?YES:NO]];
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
        PHFetchResult *assetsResult = [PHAsset fetchAssetsInAssetCollection:collection options:options];
        
        NSMutableArray *willDeleteList = [[NSMutableArray alloc] initWithCapacity:0];
        
        for (NSNumber *indexNumber in indexArray){
            NSInteger index = [indexNumber integerValue];
            PHAsset *asset = assetsResult[index];
            [willDeleteList addObject:asset];
        }
        
        if([collection canPerformEditOperation:PHCollectionEditOperationDeleteContent]){
            //delete
            [photoLibrary performChanges:^{
                [PHAssetChangeRequest deleteAssets:willDeleteList];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if(handler){
                    handler(success);
                }
            }];
        }else if ([collection canPerformEditOperation:PHCollectionEditOperationRemoveContent]){
            //remove
            [photoLibrary performChanges:^{
                PHAssetCollectionChangeRequest *changeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
                [changeRequest removeAssets:willDeleteList];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if(handler){
                    handler(success);
                }
            }];
        }
    }];
}

#pragma mark -- 图片添加

- (void)addImageToAlbumWithImage:(UIImage *)image
                         albumId:(NSString *)albumId
                         options:(PHImageRequestOptions *)options
                           block:(void(^)(KKPhotoInfo *))block
{
    @autoreleasepool {
        @weakify(self);
        __block NSString *assetId = nil ;
        //异步添加相片
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            @strongify(self);
            PHAssetCollection *collection = [self getAlbumCollectionWithAlbumId:albumId];
            PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            
            PHAssetChangeRequest *changeAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            changeAssetRequest.creationDate = [NSDate date];
            
            PHObjectPlaceholder *assetPlaceholder = [changeAssetRequest placeholderForCreatedAsset];
            
            assetId = assetPlaceholder.localIdentifier ;
            
            if ([collection canPerformEditOperation:PHCollectionEditOperationAddContent]){
                [collectionChangeRequest addAssets:@[assetPlaceholder]];
            }
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (error) {
                NSLog(@"存储错误");
                if(block){
                    block(nil);
                }
                return;
            }
            
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
            if(!asset){
                block(nil);
                return ;
            }
            
            [self requestImageDataWithAlbumId:albumId
                                            asset:asset
                                          options:options
                                            block:^(KKPhotoInfo *item)
             {
                 if(block){
                     block(item);
                 }
             }];
            
        }];
        
    }
}

- (void)addImageFilesToAlbumWithImages:(NSArray *)imageFiles
                               albumId:(NSString *)albumId
                               options:(PHImageRequestOptions *)options
                                 block:(void(^)(NSArray *))block
{
    @autoreleasepool {
        @weakify(self);
        __block NSMutableArray *assetPlaceholderArray = [[NSMutableArray alloc]init];
        __block NSMutableArray *imageInfos = [[NSMutableArray alloc]init];
        
        //异步添加相片
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            @strongify(self);
            PHAssetCollection *collection = [self getAlbumCollectionWithAlbumId:albumId];
            PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            for (NSString *imageFilePath in imageFiles){
                UIImage *image = [UIImage imageWithContentsOfFile:imageFilePath];
                if (image){
                    PHAssetChangeRequest *changeAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
                    changeAssetRequest.creationDate = [NSDate date];
                    if (changeAssetRequest != nil){
                        [assetPlaceholderArray addObject:[changeAssetRequest placeholderForCreatedAsset]];
                    }
                    
                }
            }
            
            if ([collection canPerformEditOperation:PHCollectionEditOperationAddContent]){
                [collectionChangeRequest addAssets:@[assetPlaceholderArray]];
            }
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (error) {
                if(block){
                    block(nil);
                }
                return;
            }
            
            for(PHObjectPlaceholder *placeholder in assetPlaceholderArray){
                
                dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
                
                NSString *assetId = placeholder.localIdentifier ;
                
                PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
                if(!asset){
                    continue ;
                }
                
                [self requestImageDataWithAlbumId:albumId
                                                asset:asset
                                              options:options
                                                block:^(KKPhotoInfo *item)
                 {
                     if(item){
                         [imageInfos addObject:item];
                     }
                     dispatch_semaphore_signal(semaphore);
                 }];
                dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            }
            if(block){
                block(imageInfos);
            }
        }];
    }
}

//可用于保存gif图
- (void)addImageData:(NSData *)data
           toAlbumId:(NSString *)albumId
               block:(void(^)(BOOL suc))block
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 90000
    if ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f) {
        @weakify(self);
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            @strongify(self);
            PHAssetCollection *collection = [self getAlbumCollectionWithAlbumId:albumId];
            
            PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            
            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
            options.shouldMoveFile = YES;
            
            PHAssetCreationRequest *changeAssetRequest = [PHAssetCreationRequest creationRequestForAsset];
            changeAssetRequest.creationDate = [NSDate date];
            [changeAssetRequest addResourceWithType:PHAssetResourceTypePhoto data:data options:options];
            
            PHObjectPlaceholder *assetPlaceholder = [changeAssetRequest placeholderForCreatedAsset];
            
            if ([collection canPerformEditOperation:PHCollectionEditOperationAddContent]){
                [collectionChangeRequest addAssets:@[assetPlaceholder]];
            }
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (error) {
                if(block){
                    block(NO);
                }
            }else{
                if(block){
                    block(YES);
                }
            }
        }];
    }else {
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        @weakify(library);
        [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            @strongify(library);
            NSString* groupId = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
            if([groupId isEqualToString:albumId]){
                NSDictionary *metadata = @{@"UTI":(__bridge NSString *)kUTTypeGIF};
                // 开始写数据
                [library writeImageDataToSavedPhotosAlbum:data metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
                    if (error) {
                        if(block){
                            block(NO);
                        }
                    }else{
                        [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                            if ([group isEditable]) {
                                [group addAsset:asset];
                                if(block){
                                    block(YES);
                                }
                            }else{
                                if(block){
                                    block(NO);
                                }
                            }
                            
                        } failureBlock:^(NSError *error) {
                            if(block){
                                block(NO);
                            }
                        }];
                    }
                }];
            }
        } failureBlock:^(NSError *error) {
            if(block){
                block(NO);
            }
        }];
    }
#else
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    @weakify(library);
    [library enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        @strongify(library);
        NSString* groupId = [group valueForProperty:ALAssetsGroupPropertyPersistentID];
        if([groupId isEqualToString:albumId]){
            NSDictionary *metadata = @{@"UTI":(__bridge NSString *)kUTTypeGIF};
            // 开始写数据
            [library writeImageDataToSavedPhotosAlbum:data metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
                if (error) {
                    if(block){
                        block(NO);
                    }
                }else{
                    [library assetForURL:assetURL resultBlock:^(ALAsset *asset) {
                        if ([group isEditable]) {
                            [group addAsset:asset];
                            if(block){
                                block(YES);
                            }
                        }else{
                            if(block){
                                block(NO);
                            }
                        }
                        
                    } failureBlock:^(NSError *error) {
                        if(block){
                            block(NO);
                        }
                    }];
                }
            }];
        }
    } failureBlock:^(NSError *error) {
        if(block){
            block(NO);
        }
    }];
#endif
}



#pragma mark -- ////////////////////private//////////////////////



#pragma mark -- 从图片缓存中获取图片

- (void)requestImageFromCacheWithAsset:(PHAsset *)asset
                            targetSize:(CGSize)size
                           contentMode:(PHImageContentMode)contentMode
                               options:(PHImageRequestOptions *)options
                        isNeedDegraded:(BOOL)degraded
                                 block:(void(^)(KKPhotoInfo *item))handler
{
    if(!asset){
        if(handler){
            handler(nil);
        }
        return ;
    }
    
    KKPhotoInfo *item = [KKPhotoInfo new];
    
    [self.cachingImageManager requestImageForAsset:asset
                                        targetSize:size
                                       contentMode:contentMode
                                           options:options
                                     resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info)
     {
         if (degraded == YES){
             item.identifier = asset.localIdentifier;
             item.orientation = (UIImageOrientation)[[info objectForKey:@"PHImageFileOrientationKey"] intValue];
             item.imageName = [[info objectForKey:@"PHImageFileURLKey"]lastPathComponent];
             item.image = result;
             
             if(handler){
                 handler(item);
             }
         }else{
             //PHImageResultIsDegradedKey  的值为1时，表示为小尺寸的缩略图，此时还在下载原尺寸的图
             BOOL isDegraded = [[info objectForKey:PHImageResultIsDegradedKey] boolValue];
             
             if (isDegraded == NO){
                 item.identifier = asset.localIdentifier;
                 item.orientation = (UIImageOrientation)[[info objectForKey:@"PHImageFileOrientationKey"] intValue];
                 item.imageName = [[info objectForKey:@"PHImageFileURLKey"]lastPathComponent];
                 item.image = result;
                 
                 if(handler){
                     handler(item);
                 }
             }
         }
     }];
}

#pragma mark -- 从图片缓存中获取数据(NSData)

- (void)requestImageDataWithAlbumId:(NSString *)albumId
                              asset:(PHAsset *)asset
                            options:(PHImageRequestOptions *)options
                              block:(void(^)(KKPhotoInfo *item))handler
{
    KKPhotoInfo *item = [KKPhotoInfo new];
    
    if(!albumId.length || !asset){
        if(handler){
            handler(nil);
        }
        return ;
    }
    
    @autoreleasepool {
        [self.cachingImageManager requestImageDataForAsset:asset
                                                   options:options
                                             resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info)
         {
             if (info || imageData) {
                 
                 NSDate *createDate = asset.creationDate;
                 item.imageName = [[info objectForKey:@"PHImageFileURLKey"] lastPathComponent];
                 if (item.imageName == nil){
                     item.imageName = [createDate stringWithFormat:@"MMddyyyy"];
                 }
                 
                 item.albumId = albumId;
                 item.createDate = [createDate stringWithFormat:@"yyyy/MM/dd hh:mm:ss"];
                 item.modifyDate = [asset.modificationDate stringWithFormat:@"yyyy/MM/dd hh:mm:ss"];
                 item.imageWidth = asset.pixelWidth ;
                 item.imageHeight = asset.pixelHeight ;
                 item.dataSize = imageData.length;
                 item.orientation = orientation ;
                 item.identifier = asset.localIdentifier ;
                 item.imageData = imageData;
                 
                 if(handler){
                     handler(item);
                 }
                 
             }else{
                 if(handler){
                     handler(nil);
                 }
             }
         }];
    }
}

@end
