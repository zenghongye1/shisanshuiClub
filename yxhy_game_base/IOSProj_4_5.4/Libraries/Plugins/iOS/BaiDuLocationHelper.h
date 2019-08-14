//
//  BaiDuLocationHelper.h
//  Unity-iPhone
//
//  Created by 耀星互娱 on 2017/12/25.
//

#import <Foundation/Foundation.h>
//#import <BaiduMapAPI_Base/BMKBaseComponent.h>
//#import <BMKLocationkit/BMKLocationComponent.h>
//#import <BMKLocationkit/BMKLocationAuth.h>
#import "IOSSdk.h"
@interface BaiDuLocationHelper : NSObject //<BMKGeneralDelegate, BMKLocationAuthDelegate,BMKLocationManagerDelegate>
{

}
//@property(nonatomic, strong) BMKLocationManager *locationManager;
//@property(nonatomic, strong) BMKMapManager* mapManager;
+(BaiDuLocationHelper *)shareInstance;
-(void)locationStar;
-(void)locationStop;
-(double) getLocationDistance:(double) latitudeA longitudeA:(double)longitudeA latitudeB:(double)latitudeB longitudeB:(double)longitudeB;
@end
