//
//  IOSSdk.m
//  Unity-iPhone
//
//  Created by app on 2017/7/24.
//
//

#import "IOSSdk.h"
#import "WechatHelper.h"
#import "QQHelper.h"
#import "MjFan.h"
#import "JPUSHService.h"

#import "IAPShare.h"
#import "BaiDuLocationHelper.h"
#define kDevice_Is_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

@implementation IOSSdk



const char* appId;

//**********************
//message tools
//+ (void)sendU3dMessage:(NSString *)messageName param:(NSDictionary *)dict
//{
//    NSString *param = @"";
//    if ( nil != dict ) {
//        for (NSString *key in dict)
//        {
//            if ([param length] == 0)
//            {
//                param = [param stringByAppendingFormat:@"%@=%@", key, [dict valueForKey:key]];
//            }
//            else
//            {
//                param = [param stringByAppendingFormat:@"&%@=%@", key, [dict valueForKey:key]];
//            }
//        }
//    }
//    UnitySendMessage(observer, [messageName UTF8String], [param UTF8String]);
//}

+ (void)WeiXinLoginCallback:(NSString*) rets
{
    UnitySendMessage("(singleton)YX_APIManage", [@"onWeiXinLoginCallBack" UTF8String], [rets UTF8String]);
//    [IOSSdk sendU3dMessage:@"onWeiXinLoginCallBack" param:[rets UTF8String]];
}

+ (void)WeiXinShareCallback:(NSString*) rets
{
    UnitySendMessage("(singleton)YX_APIManage", [@"onWeiXinShareCallBack" UTF8String], [rets UTF8String]);
    //    [IOSSdk sendU3dMessage:@"onWeiXinShareCallBack" param:[rets UTF8String]];
}

+ (void)IapListCallback:(NSString*) rets
{
    UnitySendMessage("(singleton)YX_APIManage", [@"onInitApplePayCallBack" UTF8String], [rets UTF8String]);
}
+ (void)IapBuyCallback:(NSString*) rets
{
    UnitySendMessage("(singleton)YX_APIManage", [@"onApplePayCallBack" UTF8String], [rets UTF8String]);
}

+ (void)QQLoginCallback:(NSString*) rets
{
    UnitySendMessage("(singleton)YX_APIManage", [@"onQQLoginCallBack" UTF8String], [rets UTF8String]);
    //    [IOSSdk sendU3dMessage:@"onQQLoginCallBack" param:[rets UTF8String]];
}

+ (void)QQShareCallback:(NSString*) rets
{
    UnitySendMessage("(singleton)YX_APIManage", [@"onQQShareCallBack" UTF8String], [rets UTF8String]);
    //    [IOSSdk sendU3dMessage:@"onQQLoginCallBack" param:[rets UTF8String]];
}

+ (void)LocationCallBack:(NSString*) rets
{
    UnitySendMessage("(singleton)YX_APIManage", [@"getLocationDataCallBack" UTF8String], [rets UTF8String]);
}

+ (void)OnJPushEvent:(NSString*) rets
{
//    UnitySendMessage("(singleton)YX_APIManage", [@"OnJPushEvent" UTF8String], [rets UTF8String]);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    //NSLog(@"path:%@",documentsDirectory);
    NSString *writeStr = rets;
    if (writeStr != NULL){
        NSString *strPath = [documentsDirectory stringByAppendingPathComponent:@"tempPush.txt"];
        BOOL ret =  [writeStr writeToFile:strPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        if (ret == YES) {
            NSLog(@"OnJPushEvent ------------- writeStr  succ");
        }else {
            NSLog(@"OnJPushEvent ------------- writeStr  fail");
        }
    }
}

//**********************
//SDK fun

//初始化SDK
-(void)SDKInit
{

}

//获取用户ID
-(NSString*)SDKGetUserID
{
//    [[SDKPlatform defaultPlatform] SDKGetUserID];
}

// Converts C style string to NSString
NSString* CreateNSString (const char* string)
{
    if (string)
        return [NSString stringWithUTF8String: string];
    else
        return [NSString stringWithUTF8String: ""];
}

//**********************
//call back fun

//初始化更新回调
- (void)SNSInitResult:(NSNotification *)notify
{
//    [IOSSdk sendU3dMessage:@"onPluginsInitFinsh" param:nil];
    UnitySendMessage("(singleton)YX_APIManage", [@"onPluginsInitFinsh" UTF8String], "");
}



@end


//*****************************************************************************

#if defined(__cplusplus)
extern "C"{
#endif
    
    static IOSSdk *mySDK;
    
    
    // get battery
    void updateBattery()
    {
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
        float batteryLevel = [[UIDevice currentDevice] batteryLevel];
        NSString *strBattery = [NSString stringWithFormat:@"{\"percent\":%f}", batteryLevel *100];
        UnitySendMessage([@"(singleton)YX_APIManage" UTF8String], [@"onPhoneBattery" UTF8String], [strBattery UTF8String]);
        
        static dispatch_source_t _timer = nil;
        if (_timer == nil) {
            NSTimeInterval period = 3.0; //设置时间间隔
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
            dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period * NSEC_PER_SEC, 0); //每秒执行
            dispatch_source_set_event_handler(_timer, ^{
                // Level has changed
                float batteryLevel = [[UIDevice currentDevice] batteryLevel];
                if (batteryLevel >=0) {
                    NSString *strBattery = [NSString stringWithFormat:@"{\"percent\":%f}", batteryLevel *100];
                    UnitySendMessage([@"(singleton)YX_APIManage" UTF8String], [@"onPhoneBattery" UTF8String], [strBattery UTF8String]);
                }
            });
            dispatch_resume(_timer);
        }
    }
   
    //供u3d调用的c函数
    void Init(const char* appId,const BOOL * isTest,const char* observer)
    {
        appId = appId;
        observer = observer;
        
//        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:detailDic options:0 error:nil];
//        NSString * myString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"Init on enter pppppppp");
        NSLog(CreateNSString(observer));
//        IOSSdk.observer = observer;
//        [IOSSdk sendU3dMessage:CreateNSString(observer) param:nil];
        
        UnitySendMessage([@"(singleton)YX_APIManage" UTF8String], [@"onPluginsInitFinsh" UTF8String], "test");
        
        updateBattery();
    }
    
    void WeiXinLogin(){
        [WechatHelper login];
    }
    
    
    void WeiXinShare(const int shareType,const int type ,const char* title,const char* filePath, const char* url,const char* description){
        
        [WechatHelper share:shareType type:type title:title filePath:filePath url:url description:description];
    }
    
    void CopyToClipboard(const char* msg)
    {
        NSString *text = [NSString stringWithUTF8String: msg];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        pasteboard.string = text;
        //NSLog(@"CopyToClipboard-----%@",pasteboard.string);
//        [pasteboard setString:text];
        UnitySendMessage([@"(singleton)YX_APIManage" UTF8String], [@"onCopyCallBack" UTF8String], "test");
    }
    
    void GetCopyText()
    {
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        NSString *text = pasteboard.string;
        //NSLog(@"GetCopyText-----%@",text);
        if (pasteboard != nil && text != nil)
        {
            NSString *msg = [NSString stringWithFormat:@"{\"result\":%d,\"text\":\"%@\"}",0,pasteboard.string];
            //NSLog(@"--------%@",msg);
            UnitySendMessage([@"(singleton)YX_APIManage" UTF8String], [@"getCopyCallBack" UTF8String], [msg UTF8String]);
        }
    }
    
    void setPushUID(const char* msg)
    {
        NSString *uid = [NSString stringWithUTF8String: msg];
        [JPUSHService setAlias:uid completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
//            NSLog(@"setAlias:%ld, %@", (long)iResCode, iAlias);
//            UnitySendMessage([@"(singleton)YX_APIManage" UTF8String], [@"onPushUIDCallBack" UTF8String], [iAlias UTF8String]);
        } seq:NSInteger(0)];
    }
    
    void CheckWXInstall()
    {
        BOOL isInstall = [WechatHelper CheckInstall];
        if (isInstall == YES) {
             UnitySendMessage([@"(singleton)YX_APIManage" UTF8String], [@"onCheckWXInstallCallBack" UTF8String], "1");
        }else if (isInstall == NO) {
             UnitySendMessage([@"(singleton)YX_APIManage" UTF8String], [@"onCheckWXInstallCallBack" UTF8String], "0");
        }
    }
    
    //QQ SDK
    void TencentQQLogin()
    {
        [[QQHelper shareInstance] onLogin];
    }
    void TencentQQSharRiceText(const char* title, const char* summary, const char* targetUrl, const char* imgPath)
    {
        [[QQHelper shareInstance] QQShare:title summary:summary targetUrl:targetUrl imgPath:imgPath];
    }
    void TencentQQShareImg(const char* imgPath, const char* title)
    {
        [[QQHelper shareInstance] QQShareImg:imgPath title:title];
    }
    void TencentQQShareToQQZone(const char* title, const char* summary, const char* targetUrl, const char* imgPath)
    {
        [[QQHelper shareInstance] QQShareToQQZone:title summary:summary targetUrl:targetUrl imgPath:imgPath];
    }
    
    void CheckQQInstall()
    {
        BOOL isInstall = [QQHelper CheckInstall];
        if (isInstall == YES) {
            UnitySendMessage([@"(singleton)YX_APIManage" UTF8String], [@"onCheckQQInstallCallBack" UTF8String], "1");
        }else if (isInstall == NO) {
            UnitySendMessage([@"(singleton)YX_APIManage" UTF8String], [@"onCheckQQInstallCallBack" UTF8String], "0");
        }
    }
    
    //苹果支付
    void ApplePayInit(const char* _proList)
    {
        NSDictionary *proList = @{@"param1":[NSString stringWithUTF8String:_proList]};
        [IAPShare fetchIAPList:proList];
    }
    void ApplePay(const char* _proID)
    {
        NSDictionary *proList = @{@"param1":[NSString stringWithUTF8String:_proID]};
        [IAPShare buyIAP:proList];
    }
    
    BOOL isIphoneX()
    {
        return kDevice_Is_iPhoneX;
    }
    
    void locationStart()
    {
        [[BaiDuLocationHelper shareInstance] locationStar];
    }
    
    void locationStop()
    {
        [[BaiDuLocationHelper shareInstance] locationStop];
    }
    
    double getLocationDistance(double latitudeA, double longitudeA,double latitudeB,double longitudeB)
    {
        return [[BaiDuLocationHelper shareInstance] getLocationDistance:latitudeA longitudeA:longitudeA latitudeB:latitudeB longitudeB:longitudeB];
    }
    
#if defined(__cplusplus)
}
#endif
