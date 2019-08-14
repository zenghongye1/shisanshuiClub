#import <Foundation/Foundation.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/QQApiInterface.h>


@interface QQHelper : NSObject<QQApiInterfaceDelegate, TencentSessionDelegate>{
    TencentOAuth *_tencentOAuth;
    NSArray *_permissions;
}

@property(nonatomic, retain) id viewController;
@property(nonatomic, assign) int handlerID;
//@property(nonatomic, strong) TencentOAuth *_tencentOAuth;
//@property(nonatomic, retain) NSString *loginType;

+(QQHelper *)shareInstance;

//sdk
-(void)onLogin;
+(BOOL)handleOpenURL:(NSURL *)_url;

+(BOOL)CheckInstall;
-(void)QQShare:(const char*)_title summary:(const char*)_summary  targetUrl:(const char*)_targetUrl imgPath:(const char*) _imgPath;
-(void)QQShareImg:(const char*)_imgPath title:(const char*)_title;
-(void)QQShareToQQZone:(const char*)_title summary:(const char*)_summary targetUrl:(const char*)_targetUrl imgPath:(const char*)_imgPath;
//+(BOOL)login;
// const int shareType,const int type ,const char* title,const char* filePath, const char* url,const char* description
//+(BOOL)share:(const int)shareType type:(const int) typeP title:(const char*) titleP filePath:(const char*) filePathP url:(const char*) urlP description:(const char*)descriptionP;

+(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

@end
