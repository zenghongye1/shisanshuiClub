//
//  BaiDuLocationHelper.m
//  Unity-iPhone
//
//  Created by 耀星互娱 on 2017/12/25.
//

#import "BaiDuLocationHelper.h"
//#import <BMKLocationkit/BMKLocationComponent.h>

@implementation BaiDuLocationHelper

+(BaiDuLocationHelper *)shareInstance {
    static BaiDuLocationHelper * g_instance = NULL;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [[BaiDuLocationHelper alloc] init];
    });
    
    return g_instance;
}

-(id) init
{
//    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:@"aSwYzesSfl17sI3lfxSH5nrgYf3Z6XTr" authDelegate:self];
    [self initLocation];
    
    return self;
}

-(void)initLocation
{
//    _locationManager = [[BMKLocationManager alloc] init];
//    _locationManager.delegate = self;
//    _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
//    _locationManager.distanceFilter = kCLDistanceFilterNone;
//    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
//    _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
//    _locationManager.pausesLocationUpdatesAutomatically = NO;
//    _locationManager.allowsBackgroundLocationUpdates = NO;// YES的话是可以进行后台定位的，但需要项目配置，否则会报错，具体参考开发文档
//    _locationManager.locationTimeout = 10;
//    _locationManager.reGeocodeTimeout = 10;
   
   
    
 //   NSLog(@"距离%@",)
}

-(void)locationStar
{
//    [_locationManager startUpdatingLocation];
}

-(void)locationStop
{
//    [_locationManager stopUpdatingLocation];
}

-(double) getLocationDistance:(double) latitudeA longitudeA:(double)longitudeA latitudeB:(double)latitudeB longitudeB:(double)longitudeB
{
    
  //  BMKMapPoint point1 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(39.915,116.404));
  //  BMKMapPoint point2 = BMKMapPointForCoordinate(CLLocationCoordinate2DMake(38.915,115.404));
    
  //  CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
  //  NSLog(@"++++++++++++++++++++++%f",(double)distance);
  //  return (double)distance;
    
//
// //   CLLocation *location1 = [[CLLocation alloc] initWithLatitude:39.915 longitude:116.404];
////    CLLocation *location2 = [[CLLocation alloc] initWithLatitude:38.915 longitude:115.404] ;
//    CLLocation *location1 = [[CLLocation alloc] initWithLatitude:latitudeA longitude:longitudeA];
//    CLLocation *location2 = [[CLLocation alloc] initWithLatitude:latitudeB longitude:longitudeB];
//    CLLocationDistance distance = [location1 distanceFromLocation:location2];
//    NSLog(@"++++++++++++++++++++++%f",(double)distance);
//    //++++++++++++++++++++++140508.091712
//    return (double)distance;
    
    return 0;
}

- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}
//
//- (void)onCheckPermissionState:(BMKLocationAuthErrorCode)iError
//{
//    NSLog(@"location auth onGetPermissionState %ld",(long)iError);
//
//}
//
//
///**
// *  @brief 当定位发生错误时，会调用代理的此方法。
// *  @param manager 定位 BMKLocationManager 类。
// *  @param error 返回的错误，参考 CLError 。
// */
//- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didFailWithError:(NSError * _Nullable)error
//{
//
//    NSLog(@"serial loc error = %@", error);
//
//}
//
//- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didUpdateLocation:(BMKLocation * _Nullable)location orError:(NSError * _Nullable)error
//{
//    if (error)
//    {
//        NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
//    }
//    if (location) {//得到定位信息，添加annotation
//        if (location.location) {
//            NSLog(@"LOC = %@",location.location);
//            NSLog([NSString stringWithFormat:@"lat=%.5f|lon=%.5f",location.location.coordinate.latitude, location.location.coordinate.longitude]);
//            double latitude = location.location.coordinate.latitude;
//            double longitude = location.location.coordinate.longitude;
//            NSString *strRes = [NSString stringWithFormat:@"{\"latitude\":\"%.5f\",\"longitude\":\"%.5f\",\"result\":%d}",
//                                latitude, longitude,0];
//             [IOSSdk LocationCallBack:strRes];
//     //       [self getLocationDistance:0 longitudeA:0 latitudeB:0 longitudeB:0];
//            [self locationStop];
//        }
//    }
//}
//
///**
// *  @brief 定位权限状态改变时回调函数
// *  @param manager 定位 BMKLocationManager 类。
// *  @param status 定位权限状态。
// */
//- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
//{
//    NSLog(@"serial loc CLAuthorizationStatus = %d", status);
//}
//
///**
// * BMKLocationManagerShouldDisplayHeadingCalibration:
// *    该方法为BMKLocationManager提示需要设备校正回调方法。
// * @param manager 提供该定位结果的BMKLocationManager类的实例
// */
//- (BOOL)BMKLocationManagerShouldDisplayHeadingCalibration:(BMKLocationManager * _Nonnull)manager
//{
//    NSLog(@"serial loc need calibration heading! ");
//    return YES;
//}
//
///**
// * BMKLocationManager:didUpdateHeading:
// *    该方法为BMKLocationManager提供设备朝向的回调方法。
// * @param manager 提供该定位结果的BMKLocationManager类的实例
// * @param heading 设备的朝向结果
// */
//- (void)BMKLocationManager:(BMKLocationManager * _Nonnull)manager
//          didUpdateHeading:(CLHeading * _Nullable)heading
//{
//    NSLog(@"serial loc heading = %@", heading.description);
//}

@end
