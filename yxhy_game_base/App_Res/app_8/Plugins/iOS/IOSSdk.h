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
@end

#endif /* IOSSdk_h */
