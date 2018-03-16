//
//  KKLocation.m
//  KKToydayNews
//
//  Created by finger on 2017/9/3.
//  Copyright © 2017年 finger. All rights reserved.
//

#import "KKLocation.h"
#import <CoreLocation/CoreLocation.h>

@interface KKLocation ()<CLLocationManagerDelegate>
@property (nonatomic) CLLocationManager* locationManager;
@property (nonatomic) CLGeocoder *geocoder;
@property (nonatomic) CLLocation *location;
@end

@implementation KKLocation

+ (instancetype)shareInstance{
    static KKLocation *localtion = nil ;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        localtion = [[self alloc] init];
    });
    return localtion;
}

+ (BOOL)locationStatus{
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)) {
        return YES;
    }else if ([CLLocationManager authorizationStatus] ==kCLAuthorizationStatusDenied) {
        return NO ;
    }
    return NO ;
}

+ (NSString *)locationStatusString{
    if([self locationStatus]){
        return @"authroize";
    }
    return @"deny";
}

#pragma mark -- 地理坐标

- (NSString *)latitude{
    CLLocationCoordinate2D coordinate = self.location.coordinate;
    return [NSString stringWithFormat:@"%f",coordinate.latitude];
}

- (NSString *)longitude{
    CLLocationCoordinate2D coordinate = self.location.coordinate;
    return [NSString stringWithFormat:@"%f",coordinate.longitude];
}

#pragma mark -- 初始化定位设置

- (void)startUpdateLocation{
    if ([[UIDevice currentDevice].systemVersion floatValue] > 8){
        [self.locationManager requestWhenInUseAuthorization];
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] > 9){
        [self.locationManager setAllowsBackgroundLocationUpdates:YES];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdateLocation{
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - 检查授权状态

- (void)checkLocationServicesAuthorizationStatus {
    [self reportLocationServicesAuthorizationStatus:[CLLocationManager authorizationStatus]];
}

- (void)reportLocationServicesAuthorizationStatus:(CLAuthorizationStatus)status{
    if(status == kCLAuthorizationStatusNotDetermined){
        [self startUpdateLocation];
    }else if(status == kCLAuthorizationStatusRestricted){
        [self alertViewWithMessage];
    }else if(status == kCLAuthorizationStatusDenied){
        [self alertViewWithMessage];
    }else if(status == kCLAuthorizationStatusAuthorizedWhenInUse){
        [self startUpdateLocation];
    }else if(status == kCLAuthorizationStatusAuthorizedAlways){
        [self startUpdateLocation];
    }
}

#pragma mark -- 根据坐标取得地名

-(void)getAddressByLocation:(CLLocation *)location{
    //反地理编码
    [self.geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks) {
            
            NSDictionary *address = [placemark addressDictionary];
            
            NSLog(@"%@", [address objectForKey:@"Country"]);
            
            NSLog(@"%@", [address objectForKey:@"State"]);
            
            self.curtCity = [address objectForKey:@"City"] ;
            if(self.curtCity.length){
                [self stopUpdateLocation];
            }
            NSLog(@"%@",self.curtCity);
        }
    }];
}

#pragma mark - CoreLocation 代理

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    self.location = [locations lastObject];
    [self getAddressByLocation:self.location];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    [self.locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    [self reportLocationServicesAuthorizationStatus:status];
}

#pragma mark -- 定位设置提示

- (void)alertViewWithMessage {
    UIAlertView *alter = [[UIAlertView alloc] initWithTitle:@"定位服务未开启" message:@"请在系统设置中开启服务" delegate:self cancelButtonTitle:@"暂不" otherButtonTitles:@"去设置", nil];
    [alter show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1){
        //进入系统设置页面，APP本身的权限管理页面
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

#pragma mark -- @property

- (CLLocationManager *)locationManager{
    if(!_locationManager){
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self ;
        _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
        //定位频率,每隔多少米定位一次
        CLLocationDistance distance= 10.0 ;
        _locationManager.distanceFilter=distance;
    }
    return _locationManager;
}

- (CLGeocoder *)geocoder{
    if(!_geocoder){
        _geocoder = [[CLGeocoder alloc]init];
    }
    return _geocoder;
}

@end
