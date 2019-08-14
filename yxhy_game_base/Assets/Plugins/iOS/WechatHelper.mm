#include "WechatHelper.h"
#import "WXApiObject.h"
#import "IOSSdk.h"

@implementation WechatHelper

+(WechatHelper *)shareInstance {
    static WechatHelper * g_instance = NULL;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [[WechatHelper alloc] init];
    });
    
    return g_instance;
}

+(BOOL)registerApp {
//    [[WechatHelper shareInstance] setViewController:_viewController];
    
    //wxe3284e0c70a12c81
    return [WXApi registerApp:@"wxe898b9d2ec9db657" enableMTA:NO];
}
+(BOOL)handleOpenURL:(NSURL *)_url {
    
    return [WXApi handleOpenURL:_url delegate:[WechatHelper shareInstance]];
}

+(BOOL)CheckInstall{
    return [WXApi isWXAppInstalled];
}
+(BOOL)login{
    
    //获取OC的NSString
//    NSString *loginType = [_dict valueForKey:@"param1"];
//    [[WechatHelper shareInstance] setLoginType:loginType];
    
    //构造SendAuthReq结构体
    SendAuthReq* req =[[SendAuthReq alloc] init] ;
    req.scope = @"snsapi_userinfo";
    req.state = @"yx123";
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
//    [WXApi sendAuthReq:req viewController:[[WechatHelper shareInstance] viewController] delegate:[WechatHelper shareInstance]];
    
    //回调
//    int handlerID = [[_dict valueForKey:@"callback"] intValue];
//    [[WechatHelper shareInstance] setHandlerID:handlerID];
    
    return YES;
}

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
//    if(err)
//    {
//        NSLog(@"json解析失败：%@",err);
//        return nil;
//    }
    return dic;
}
/// <param name="shareType">0微信好友，1朋友圈，2微信收藏</param>
/// <param name="type">1文本，2图片，3声音，4视频，5网页</param>
+(BOOL)share:(const int)shareType type:(const int) typeP title:(const char*) titleP filePath:(const char*) filePathP url:(const char*) urlP description:(const char*)descriptionP {
    
    //获取OC的NSString
//    NSString *shareTemplate = [_dict valueForKey:@"param1"];
//    int contentType = [[_dict valueForKey:@"param2"] intValue];
//    NSString *shareContent = [_dict valueForKey:@"param3"];
//    int shareType = [[_dict valueForKey:@"param4"] intValue];
//    
//    NSDictionary *jsonDict = [WechatHelper dictionaryWithJsonString:shareContent];
//    
//    if (jsonDict ==nil) {
//        return NO;
//    }
    
    WXMediaMessage *message = [WXMediaMessage message];
//    message.title = [jsonDict valueForKey:@"title"];
//    message.description = [jsonDict valueForKey:@"description"];
//    [message setThumbImage:[UIImage imageNamed:@"icon.png"]];
    
    //构造SendMessageToWXReq结构体
    SendMessageToWXReq *req = [[SendMessageToWXReq alloc] init] ;
    if (shareType ==1) {
        req.scene = WXSceneTimeline;
    }
    else {
        req.scene = WXSceneSession;
    }
    
    switch (typeP) {
        case 1: //WX_SHARE_TYPE_OF_TEXT
        {
            req.text =   [NSString stringWithUTF8String:titleP] ;
            break;
        }
        case 2: //WX_SHARE_TYPE_OF_IMG
        {
            NSString *filePath = [NSString stringWithUTF8String:filePathP];
            
            // 创建一个bitmap的context
            UIImage *img = [UIImage imageNamed:filePath];
            CGSize size = CGSizeMake(CGImageGetWidth([img CGImage])/20, CGImageGetHeight([img CGImage])/20);
            // 并把它设置成为当前正在使用的context
            UIGraphicsBeginImageContext(size);
            // 绘制改变大小的图片
            [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
            // 从当前context中创建一个改变大小后的图片
            UIImage* scaleImage = UIGraphicsGetImageFromCurrentImageContext();
            // 使当前的context出堆栈    
            UIGraphicsEndImageContext();
            
            // 设置消息缩略图的方法
            [message setThumbImage:scaleImage];
            
            // 多媒体消息中包含的图片数据对象
            WXImageObject *imageObject = [WXImageObject object];
            // 图片真实数据内容
            imageObject.imageData = [NSData dataWithContentsOfFile:filePath];
            // 多媒体数据对象
            message.mediaObject = imageObject;
            
            req.bText = NO;
            req.message = message;
            
            break;
        }
        case 3: //WX_SHARE_TYPE_OF_AUDIO
        {
            message.title = [NSString stringWithUTF8String:titleP];
            message.description = [NSString stringWithUTF8String:descriptionP];
            // [message setThumbImage:[UIImage imageNamed:@"res2.png"]];
            
            // 多媒体消息中包含的音乐数据对象
            WXMusicObject *ext = [WXMusicObject object];
            // 音乐网页的url地址
            ext.musicUrl = [NSString stringWithUTF8String:urlP];
            // 音乐lowband数据url地址
            ext.musicLowBandDataUrl = ext.musicUrl;
            // 音乐数据url地址
            ext.musicDataUrl =[NSString stringWithUTF8String:urlP];
            // 音乐lowband数据url地址
            ext.musicLowBandDataUrl = ext.musicDataUrl;
            message.mediaObject = ext;
            
            req.bText = NO;
            req.message = message;
            
            break;
        }
        case 4: //WX_SHARE_TYPE_OF_VIDEO
        {
            message.title = [NSString stringWithUTF8String:titleP];
            message.description = [NSString stringWithUTF8String:descriptionP];
            // [message setThumbImage:[UIImage imageNamed:@"res2.png"]];
            
            // 多媒体消息中包含的视频数据对象
            WXVideoObject *videoObject = [WXVideoObject object];
            // 视频网页的url地址
            videoObject.videoUrl = [NSString stringWithUTF8String:urlP];
            // 视频lowband网页的url地址
            videoObject.videoLowBandUrl = videoObject.videoUrl;
            message.mediaObject = videoObject;
            
            req.bText = NO;
            req.message = message;
            
            break;
        }
        case 5: //WX_SHARE_TYPE_OF_WEBPAGE
        {
            message.title = [NSString stringWithUTF8String:titleP];
            message.description = [NSString stringWithUTF8String:descriptionP];
            NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
            NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
            [message setThumbImage:[UIImage imageNamed:icon]];
            
            // 多媒体消息中包含的网页数据对象
            WXWebpageObject *webpageObject = [WXWebpageObject object];
            // 网页的url地址
            webpageObject.webpageUrl = [NSString stringWithUTF8String:urlP];
            message.mediaObject = webpageObject;
            
            req.bText = NO;
            req.message = message;
            
            break;
        }
        default:
            break;
    }
    [WXApi sendReq:req];
    
    //回调
//    int handlerID = [[_dict valueForKey:@"callback"] intValue];
//    [[WechatHelper shareInstance] setHandlerID:handlerID];
    
    return YES;
}

// WXApiDelegate
-(void) onReq:(BaseReq*)req {
    
}
-(void) onResp:(BaseResp*)resp {
    
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        // 登陆回调
        int errCode = [resp errCode];
        switch ([resp errCode]) {
            case WXSuccess: //成功
                errCode = 0;
                break;
            case WXErrCodeAuthDeny: //拒绝
                errCode = 1;
                break;
            case WXErrCodeUserCancel: //取消
                errCode = 2;
                break;
        }
        NSString *errStr = [resp errStr];
        NSString *strCode = [(SendAuthResp *)resp code];
//        NSString *loginType = [[WechatHelper shareInstance] loginType];
        
        //    {
        //        "resultCode":"结果码  1.succ  2.failure 3.calcel",
        //        "code":"微信code"
        //        "msg":"登陆结果提示消息"，
        //        "loginType"："登录方式"
        //        
        //    }
        
        NSString *strRes = [NSString stringWithFormat:@"{\"result\":%d, \"access_token\":\"%@\", \"msg\":\"%@\"}",
                            errCode, strCode, errStr];
        NSLog(@"strRes----%@",strRes);
//        //回调
//        int handlerID = [[WechatHelper shareInstance] handlerID];
//        cocos2d::LuaBridge::pushLuaFunctionById(handlerID); //压入需要调用的方法id（假设方法为XG）
//        cocos2d::LuaStack *stack = cocos2d::LuaBridge::getStack();  //获取lua栈
//        stack->pushString([strRes UTF8String]);  //将需要通过方法XG传递给lua的参数压入lua栈
//        stack->executeFunction(1);  //根据压入的方法id调用方法XG，并把XG方法参数传递给lua代码
//        cocos2d::LuaBridge::releaseLuaFunctionById(handlerID); //最后记得释放一下function
        
        [IOSSdk WeiXinLoginCallback:strRes];
        
    } else if ([resp isKindOfClass:[SendMessageToWXResp class]]) {
        // 分享回调
        int errCode = [resp errCode];
        switch ([resp errCode]) {
            case WXSuccess: //成功
                errCode = 0;
                break;
            case WXErrCodeAuthDeny: //拒绝
                errCode = 1;
                break;
            case WXErrCodeUserCancel: //取消
                errCode = 2;
                break;
        }
        NSString *errStr = [resp errStr];
        NSString *strRes = [NSString stringWithFormat:@"{\"result\":%d,  \"msg\":\"%@\"}",
                            errCode, errStr];
        NSLog(@"strRes----%@",strRes);
        [IOSSdk WeiXinShareCallback:strRes];
        
//    } else if ([resp isKindOfClass:[PayResp class]]) {
//        // 支付回调
    }
}

@end
