//
//  IOSSdk.h
//  Unity-iPhone
//
//  Created by app on 2017/7/24.
//
//

#ifndef IOSSdk_h
#define IOSSdk_h

#import <Foundation/Foundation.h>

@interface IOSSdk : NSObject

+(const char*) observer;

+ (void)WeiXinLoginCallback:(NSString*) rets;
+ (void)WeiXinShareCallback:(NSString*) rets;

+ (void)IapListCallback:(NSString*) rets;
+ (void)IapBuyCallback:(NSString*) rets;

+ (void)QQLoginCallback:(NSString*) rets;
+ (void)QQShareCallback:(NSString*) rets;
+ (void)LocationCallBack:(NSString*) rets;

+ (void)OnJPushEvent:(NSString*) rets;

@end

#endif /* IOSSdk_h */
