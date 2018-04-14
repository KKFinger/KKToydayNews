//
//  KKTabBarController.m
//  KKToydayNews
//
//  Created by finger on 2017/8/6.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKTabBarController.h"
#import "KKNavigationController.h"
#import "KKLocation.h"
#import "KKNewsBaseViewCtrl.h"
#import "KKTabBar.h"
#import "KKMoreView.h"
#import "KKTextImageShareCtrl.h"
#import "KKImageGalleryView.h"
#import "KKPhotoManager.h"
#import "KKVideoShareView.h"
#import "KKVideoCompressTool.h"
#import "KKRecordEngine.h"

static NSInteger maxImageCount = 9 ;

@interface KKTabBarController ()<UITabBarControllerDelegate,KKTabBarDelegate,KKMoreViewDelegate>
@property(nonatomic,weak)UIViewController *preSelCtrl;
@property(nonatomic,strong)KKMoreView *moreView ;
@property(nonatomic)NSMutableArray *imageArray;
@end

@implementation KKTabBarController

- (void)dealloc{
    [KKAppTools clearFileAtFolder:KKVideoCompressFileFolder];
    [KKAppTools clearFileAtFolder:KKVideoRecordFileFolder];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *vctrls = [[NSMutableArray alloc] init];
    NSArray *classes = @[@"KKHomeViewCtrl",@"KKXiGuaViewCtrl",@"KKXiaoShiPinViewCtrl",@"KKWeiTouTiaoViewCtrl"];
    NSArray *images = @[@"home_tabbar_32x32_",@"video_tabbar_32x32_",@"huoshan_tabbar",@"weitoutiao_tabbar_32x32_"];
    NSArray *selectedImages = @[@"home_tabbar_press_32x32_",@"video_tabbar_press_32x32_",@"huoshan_tabbar_press",@"weitoutiao_tabbar_press_32x32_"];
    NSArray *titles = @[@"首页",@"西瓜视频",@"小视频",@"微头条"];
    
    for (NSInteger i = 0; i < classes.count; i++){
        UIViewController *itemVc = [[NSClassFromString(classes[i]) alloc] init];
        itemVc.tabBarItem.title = titles[i];
        itemVc.tabBarItem.image = [[UIImage imageNamed:images[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        itemVc.tabBarItem.selectedImage = [[UIImage imageNamed:selectedImages[i]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
        KKNavigationController *nav = [[KKNavigationController alloc]initWithRootViewController:itemVc];
        
        [vctrls addObject:nav];
    }
    
    //创建自己的tabbar，然后用kvc将自己的tabbar和系统的tabBar替换下
    KKTabBar *tabbar = [[KKTabBar alloc] init];
    tabbar.kkTabDelegate = self;
    [self setValue:tabbar forKeyPath:@"tabBar"];
    
    self.delegate = self;
    self.viewControllers = vctrls;
    self.selectedIndex = 0 ;
    self.preSelCtrl = ((KKNavigationController *)self.viewControllers.firstObject).topViewController ;
    
    [self customTabBarStyle];
    [self initAppEnv];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    //设置tabbar的高度
    CGRect tabFrame = self.tabBar.frame;
    tabFrame.size.height = KKTabbarHeight;
    tabFrame.origin.y = self.view.frame.size.height - KKTabbarHeight;
    self.tabBar.frame = tabFrame;
}

#pragma mark -- 设置UI外观

-(void)customTabBarStyle{
    self.tabBar.backgroundImage = [UIImage imageWithColor:[UIColor whiteColor]];
    self.tabBar.borderType = KKBorderTypeTop;
    self.tabBar.borderColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
    self.tabBar.borderThickness = 0.3 ;
    [[UITabBar appearance] setShadowImage:[UIImage imageWithColor:[UIColor whiteColor]]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor redColor]} forState:UIControlStateSelected];
    [[UITabBarItem appearance]setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:10 weight:0.1],NSForegroundColorAttributeName:[UIColor blackColor]} forState:UIControlStateNormal];
}

#pragma mark -- tabbar点击

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    NSString *title = item.title;
    if([title isEqualToString:@"首页"]){
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];
    }else{
        [[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleDefault];
    }
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    UIViewController *ctrl = ((KKNavigationController *)viewController).topViewController;
    if([self.preSelCtrl isEqual:ctrl]){
        [(KKNewsBaseViewCtrl *)ctrl refreshData];
    }
    self.preSelCtrl = ctrl;
}

#pragma mark -- KKTabBarDelegate

- (void)tabBarMidBtnClick:(KKTabBar *)tabBar{
    self.moreView = [[KKMoreView alloc]init];
    self.moreView.delegate = self;
    [[UIApplication sharedApplication].keyWindow addSubview:self.moreView];
    [self.moreView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo([[UIScreen mainScreen]bounds].size);
    }];
    [self.moreView showView];
}

#pragma mark -- KKMoreViewDelegate

- (void)showViewWithType:(KKMoreViewType)type{
    [self.moreView hideView];
    if(type == KKMoreViewTypeText){
        KKTextImageShareCtrl *ctrl = [KKTextImageShareCtrl new];
        KKNavigationController *navCtrl = [[KKNavigationController alloc]initWithRootViewController:ctrl];
        [self presentViewController:navCtrl animated:YES completion:nil];
    }else if(type == KKMoreViewTypeImage){
        [self showImageGallery];
    }else if(type == KKMoreViewTypeVideo){
        [self showVideoRecordView];
    }else if(type == KKMoreViewTypeQuestion){
        
    }
}

#pragma mark -- 初始化app必要环境

- (void)initAppEnv{
    [[KKLocation shareInstance]checkLocationServicesAuthorizationStatus];
    [[SDWebImageManager sharedManager].imageCache setMaxMemoryCost:30 * 1024 * 1024];//30M
    [[[SDWebImageManager sharedManager]imageCache]clearMemory];
    [[[SDWebImageManager sharedManager]imageCache]clearDiskOnCompletion:^{
        NSLog(@"clear disk image cache complete!");
    }];
}

#pragma mark -- 视频播放器，屏幕旋转相关

- (BOOL)shouldAutorotate {
    return [self.selectedViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.selectedViewController supportedInterfaceOrientations];
}

#pragma mark -- 显示图片选择视图

- (void)showImageGallery{
    KKImageGalleryView *view = [KKImageGalleryView new];
    view.topSpace = KKStatusBarHeight ;
    view.navContentOffsetY = 0 ;
    view.navTitleHeight = 50 ;
    view.contentViewCornerRadius = 10 ;
    view.cornerEdge = UIRectCornerTopRight|UIRectCornerTopLeft;
    view.navView.selCount = @"0";
    view.curtSelCount = 0 ;
    view.limitSelCount = maxImageCount ;
    
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(UIDeviceScreenWidth, UIDeviceScreenHeight));
    }];
    [view setSelectImageCallback:^(KKPhotoInfo *item,BOOL isSelect,void(^canSelect)(BOOL canSelect,NSInteger selCount)){
        if(isSelect){
            NSInteger count = self.imageArray.count;
            if(count < maxImageCount + 1){
                if(item.identifier.length && item.albumId.length){
                    [[KKPhotoManager sharedInstance]getImageWithAlbumID:item.albumId imageLocalIdentifier:item.identifier needImageSize:UIDeviceScreenSize isNeedDegraded:NO sort:NSOrderedDescending block:^(KKPhotoInfo *item) {
                        [self.imageArray safeInsertObj:item atIndex:count - 1];
                        if(canSelect){
                            canSelect(YES,self.imageArray.count-1);
                        }
                    }];
                }else{
                    [self.imageArray safeInsertObj:item atIndex:count - 1];
                    if(canSelect){
                        canSelect(YES,self.imageArray.count-1);
                    }
                }
            }else{
                [[UIApplication sharedApplication].keyWindow promptMessage:@"最多只能添加9张图片"];
                if(canSelect){
                    canSelect(NO,self.imageArray.count-1);
                }
            }
        }else{
            for(NSInteger i = 0 ; i < self.imageArray.count ; i++){
                KKPhotoInfo *_item = [self.imageArray safeObjectAtIndex:i];
                if([item.identifier isEqualToString:_item.identifier]){
                    [self.imageArray safeRemoveObjectAtIndex:i];
                    break ;
                }
            }
            if(canSelect){
                canSelect(YES,self.imageArray.count-1);
            }
        }
    }];
    
    [view setGetCurtSelArray:^NSArray *(){
        return self.imageArray;
    }];
    
    [view setShowShareCtrlWhenDismiss:^{
        KKTextImageShareCtrl *ctrl = [KKTextImageShareCtrl new];
        ctrl.imageArray = self.imageArray;
        KKNavigationController *navCtrl = [[KKNavigationController alloc]initWithRootViewController:ctrl];
        
        @weakify(self);
        [self presentViewController:navCtrl animated:YES completion:^{
            @strongify(self);
            [self.imageArray removeAllObjects];
            self.imageArray = nil ;
        }];
    }];
    
    [view startShow];
}

#pragma mark -- 显示视频选择视图

- (void)showVideoRecordView{
    KKVideoShareView *view = [KKVideoShareView new];
    view.topSpace = 0 ;
    view.contentViewCornerRadius = 0 ;
    
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    [view mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(UIDeviceScreenWidth, UIDeviceScreenHeight));
    }];
    
    [view startShow];
}

#pragma mark -- @property

- (NSMutableArray *)imageArray{
    if(!_imageArray){
        _imageArray = [NSMutableArray arrayWithCapacity:0];
        
        KKPhotoInfo *item = [KKPhotoInfo new];
        item.image = [UIImage imageNamed:@"introduct_add_picture"];
        item.isPlaceholderImage = YES ;
        [_imageArray safeAddObject:item];
    }
    return _imageArray;
}

@end
