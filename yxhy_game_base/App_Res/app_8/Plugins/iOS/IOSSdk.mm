//
//  IOSSdk.m
//  Unity-iPhone
//
//  Created by app on 2017/7/24.
//
//

#import "IOSSdk.h"
#import "WechatHelper.h"
#import "MjFan.h"

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
        UnitySendMessage([@"(singleton)YX_APIManage" UTF8String], [@"onCopyCallBack" UTF8String], "test");
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
    
    
    
    
#if defined(__cplusplus)
}
#endif
