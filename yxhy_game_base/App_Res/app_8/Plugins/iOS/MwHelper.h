#import <Foundation/Foundation.h>
#import "MWApi.h"

@interface MwHelper : NSObject {
    
}
@property(nonatomic, retain) id viewController;
@property(nonatomic, assign) int handlerID;
@property(nonatomic, retain) NSString *loginType;

+(MwHelper *)shareInstance;

// sdk
+(void)registerApp;
+(BOOL)handleOpenURL:(NSURL *)_url;

// toLua
//+(BOOL)wechatShare:(NSDictionary *)_dict;

@end
