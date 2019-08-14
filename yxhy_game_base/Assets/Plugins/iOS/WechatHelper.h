#import <Foundation/Foundation.h>
#import "WXApi.h"

@interface WechatHelper : NSObject<WXApiDelegate> {
    
}
@property(nonatomic, retain) id viewController;
@property(nonatomic, assign) int handlerID;
//@property(nonatomic, retain) NSString *loginType;

+(WechatHelper *)shareInstance;

// sdk
+(BOOL)registerApp;
+(BOOL)handleOpenURL:(NSURL *)_url;

+(BOOL)CheckInstall;
+(BOOL)login;
// const int shareType,const int type ,const char* title,const char* filePath, const char* url,const char* description
+(BOOL)share:(const int)shareType type:(const int) typeP title:(const char*) titleP filePath:(const char*) filePathP url:(const char*) urlP description:(const char*)descriptionP;

+(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

@end
