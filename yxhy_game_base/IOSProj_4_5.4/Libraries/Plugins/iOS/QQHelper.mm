#include "QQHelper.h"
#import "IOSSdk.h"

@implementation QQHelper
+(QQHelper *)shareInstance {
    static QQHelper * g_instance = NULL;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [[QQHelper alloc] init];
    });
    
    return g_instance;
}

-(id) init
{
    NSDictionary * bundleDict = [[NSBundle mainBundle] infoDictionary];
    assert(bundleDict != NULL);
    
    //1106457563
    NSString *appId = [bundleDict objectForKey:@"com.yxhy.qq.appid"];
    assert(appId != NULL);
    
    _tencentOAuth = [[TencentOAuth alloc]initWithAppId:appId andDelegate:self];
    return self;
}

+(BOOL)handleOpenURL:(NSURL *)_url {
    [QQApiInterface handleOpenURL:_url delegate:[QQHelper shareInstance]];
    return [TencentOAuth HandleOpenURL:_url];
}

+(BOOL)CheckInstall{
    return [TencentOAuth iphoneQQInstalled];
}


-(void)onLogin{
    //1106457563
//    _tencentOAuth = [[TencentOAuth alloc]initWithAppId:@"1106457563" andDelegate:self];
    _permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_INFO, kOPEN_PERMISSION_GET_USER_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, nil];
    [_tencentOAuth authorize:_permissions];
}

-(void)tencentDidLogin{
    if(_tencentOAuth.accessToken and _tencentOAuth.openId){
        NSString *strRes = [NSString stringWithFormat:@"{\"access_token\":\"%@\",\"openId\":\"%@\",\"result\":%d}",
                            _tencentOAuth.accessToken, _tencentOAuth.openId,0];
        NSLog(@"strRes----%@",strRes);
        [IOSSdk QQLoginCallback:strRes];
       // [_tencentOAuth getUserInfo];//get user info
    }
    else{
        NSString *strRes = [NSString stringWithFormat:@"{\"result\":%d}",-1];
        [IOSSdk QQLoginCallback:strRes];
        NSLog(@"access Token get failed!");
    }
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
    //if(cancelled){
        NSString *strRes = [NSString stringWithFormat:@"{\"result\":%d}",-1];
        [IOSSdk QQLoginCallback:strRes];
    //}
}


- (void)tencentDidNotNetWork {
   
}

// 获取用户信息
- (void)getUserInfoResponse:(APIResponse *)response {
    
    if (response && response.retCode == URLREQUEST_SUCCEED) {
        
        //NSDictionary *userInfo = [response jsonResponse];
        // 后续操作...
        
    } else {
        NSLog(@"QQ auth fail ,getUserInfoResponse:%d", response.detailRetCode);
    }
}

//- (BOOL)tencentNeedPerformIncrAuth:(TencentOAuth *)tencentOAuth withPermissions:(NSArray *)permissions{
//    [tencentOAuth incrAuthWithPermissions:permissions];
//    return NO;
//}

+(NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    return dic;
}

///
-(void)QQShare:(const char*)_title summary:(const char*)_summary  targetUrl:(const char*)_targetUrl imgPath:(const char*) _imgPath{
    if (_imgPath == nil){
        _imgPath = "http://fjmj.dstars.cc/gamewap/youxianqipai/src/images/icon_108.png";
    }
    NSString *title = [NSString stringWithUTF8String:_title];
    NSString *summary = [NSString stringWithUTF8String:_summary];
    NSURL *targetUrl = [NSURL URLWithString:[NSString stringWithUTF8String:_targetUrl]];
    NSURL *imgPath = [NSURL URLWithString:[NSString stringWithUTF8String:_imgPath]];
    QQApiNewsObject* QQSend = [QQApiNewsObject objectWithURL:targetUrl title:title description:summary previewImageURL:imgPath];
    SendMessageToQQReq* QQReq = [SendMessageToQQReq reqWithContent:QQSend];
    QQApiSendResultCode QQSent = [QQApiInterface sendReq:QQReq];
    [self HandleSendResult:QQSent];
}

-(void)QQShareImg:(const char*)_imgPath title:(const char*)_title {
    NSString *imgPath = [NSString stringWithUTF8String:_imgPath];
    NSData *imgData = [NSData dataWithContentsOfFile:imgPath];
    QQApiImageObject *imgObj = [QQApiImageObject objectWithData:imgData previewImageData:imgData title:@"" description:@""];
    SendMessageToQQReq* imgReq = [SendMessageToQQReq reqWithContent:imgObj];
    QQApiSendResultCode imgSent = [QQApiInterface sendReq:imgReq];
    [self HandleSendResult:imgSent];
}

-(void)QQShareToQQZone:(const char*)_title summary:(const char*)_summary targetUrl:(const char*)_targetUrl imgPath:(const char*)_imgPath{
    if (_imgPath == nil){
        _imgPath = "http://fjmj.dstars.cc/gamewap/youxianqipai/src/images/icon_108.png";
    }
    NSString *title = [NSString stringWithUTF8String:_title];
    NSString *summary = [NSString stringWithUTF8String:_summary];
    NSURL *targetUrl = [NSURL URLWithString:[NSString stringWithUTF8String:_targetUrl]];
    NSURL *imgPath = [NSURL URLWithString:[NSString stringWithUTF8String:_imgPath]];
    QQApiNewsObject* QZoneSend = [QQApiNewsObject objectWithURL:targetUrl title:title description:summary previewImageURL:imgPath];
    SendMessageToQQReq* QZoneReq = [SendMessageToQQReq reqWithContent:QZoneSend];
    QQApiSendResultCode QzoneSent = [QQApiInterface SendReqToQZone:QZoneReq];
    [self HandleSendResult:QzoneSent];
}
/*  QQApiSendResultCode 说明
 EQQAPISENDSUCESS = 0,                      操作成功
 EQQAPIQQNOTINSTALLED = 1,                   没有安装QQ
 EQQAPIQQNOTSUPPORTAPI = 2,
 EQQAPIMESSAGETYPEINVALID = 3,              参数错误
 EQQAPIMESSAGECONTENTNULL = 4,
 EQQAPIMESSAGECONTENTINVALID = 5,
 EQQAPIAPPNOTREGISTED = 6,                   应用未注册
 EQQAPIAPPSHAREASYNC = 7,
 EQQAPIQQNOTSUPPORTAPI_WITH_ERRORSHOW = 8,
 EQQAPISENDFAILD = -1,                       发送失败
 //qzone分享不支持text类型分享
 EQQAPIQZONENOTSUPPORTTEXT = 10000,
 //qzone分享不支持image类型分享
 EQQAPIQZONENOTSUPPORTIMAGE = 10001,
 //当前QQ版本太低，需要更新至新版本才可以支持
 EQQAPIVERSIONNEEDUPDATE = 10002,
 */
-(void)HandleSendResult:(QQApiSendResultCode)sendResult
{
    switch (sendResult) {
        case EQQAPISENDSUCESS:
        {
            NSString *strRes = [NSString stringWithFormat:@"{\"msg\":\"%@\",\"shareType\":\"%@\",\"result\":%d}",@"SUCESS",@"QQ",0];
            NSLog(@"strRes----%@",strRes);
           // [IOSSdk QQShareCallback:strRes];
            break;
        }
        default:
        {
            NSString *strRes = [NSString stringWithFormat:@"{\"msg\":\"%@\",\"shareType\":\"%@\",\"result\":%d,\"errCode\":%d}",@"Fail",@"QQ",-1,sendResult];
            NSLog(@"strRes----%@",strRes);
            //[IOSSdk QQShareCallback:strRes];
        }
            break;
    }
}

-(void) onReq:(QQBaseReq *)req{
    
}

-(void)onResp:(QQBaseResp *)resp
{
    NSLog(@"----------resp-----%@",resp);
    if ([resp isKindOfClass:[SendMessageToQQResp class]]) {
        SendMessageToQQResp *msg =(SendMessageToQQResp *)resp;
        NSLog(@"code:%@ errorCode:%@ infoType:%@",msg.result,msg.errorDescription,msg.extendInfo);
        NSString *strRes = [NSString stringWithFormat:@"{\"msg\":\"%@\",\"shareType\":\"%@\",\"result\":\"%@\"}",msg.errorDescription,@"QQ",msg.result];
        [IOSSdk QQShareCallback:strRes];
    }
}

@end
