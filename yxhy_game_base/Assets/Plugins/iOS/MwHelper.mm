#include "MwHelper.h"
#include <string>

@implementation MwHelper

+(MwHelper *)shareInstance {
    static MwHelper * g_instance = NULL;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [[MwHelper alloc] init];
    });
    
    return g_instance;
}

+(void)registerApp{
    [MWApi registerApp:@"FOG8OIGXJB541UMJ8HR8OYWC0UV9S0OU"];
}

std::string findKeyString(std::string strUrl,std::string strKey,size_t sPos1) {
    std::string str = "";
    size_t sPos = sPos1;
    while (sPos != std::string::npos) {
        bool isMaching = true;
        for (int i=1; i<strKey.size(); i++) {
            std::string strTempKey = strKey.substr(i);
            size_t found = strUrl.find_first_of(strTempKey, sPos+i);
            if (found == std::string::npos) {
                isMaching = false;
                break;
            }
            else if (sPos+i != found) {
                isMaching = false;
                break;
            }
        }
        if (isMaching)
        {
            break;
        }
        else
        {
            sPos = strUrl.find_first_of(strKey, sPos+1);
        }
    }
    if (sPos == std::string::npos) {
        return str;
    }
    sPos = sPos +strKey.length();
    size_t ePos = strUrl.find_first_of("&", sPos);
    if (ePos == std::string::npos) {
        ePos = strUrl.size();
    }
    str = strUrl.substr(sPos, ePos-sPos);
    return str;
}

+(BOOL)handleOpenURL:(NSURL *)_url {
    if ([MWApi handleOpenURL:_url delegate:[MwHelper shareInstance]]) {
        NSLog(@"handleOpenURL enter -------------xxxxxxx1");
        // 获取键值
        std::string strUrl([[_url description] UTF8String]);
        std::string strKey("id=");
        std::string strKey1("uid=");
        size_t sPosRoomID = strUrl.find_first_of(strKey);
        size_t sPosUid = strUrl.find_first_of(strKey1);
        
        std::string strRoomID;
        std::string strUid;
        
        if (sPosRoomID != std::string::npos) {
            strRoomID =  findKeyString(strUrl,strKey,sPosRoomID);
        }
        if (sPosUid != std::string::npos) {
            strUid =  findKeyString(strUrl,strKey1,sPosUid);
        }
        NSLog(@"handleOpenURL enter -------------xxxxxxx12");
        if (strRoomID.length() >0 || strUid.length() > 0 ) {
            // 保存房间ID UID
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSLog(@"path:   %@",documentsDirectory);
            
            NSString *strRoomIDStr = [NSString stringWithCString:strRoomID.c_str()
                                                        encoding:[NSString defaultCStringEncoding]];
            NSLog(@"strRoomIDStr:   %@",strRoomIDStr);
            
            NSString *strUidStr = [NSString stringWithCString:strUid.c_str()
                                                     encoding:[NSString defaultCStringEncoding]];
            NSLog(@"strUidStr:   %@",strUidStr);
            NSString *writeStr;
            if(strUid.length() >0 && strRoomID.length() == 0 ) {
                writeStr = [NSString stringWithFormat:@"{\"uid\":\"%@\"}",
                            strUidStr];
                
                
            }else if(strRoomID.length() >0 && strUid.length() > 0 ) {
                writeStr = [NSString stringWithFormat:@"{\"uid\":\"%@\", \"roomId\":\"%@\"}",
                            strUidStr, strRoomIDStr];
            }
            
            // 重新提取key/value
            NSString *strUrl = [_url absoluteString];
            NSRange strRange = [strUrl rangeOfString:@"?"];
            strUrl = [strUrl substringFromIndex:(strRange.location +strRange.length)];
            if ([strUrl length] >0) {
                NSString *strKeyValue = @"{";
                NSArray *array = [strUrl componentsSeparatedByString:@"&"];
                for (int i=0; i<[array count]; i++) {
                    NSString *strValue = [array objectAtIndex:i];
                    //NSLog(@"strValue:%@", strValue);
                    NSArray *array2 = [strValue componentsSeparatedByString:@"="];
                    if ([array2 count] ==2) {
                        NSString *strValue2 = [array2 objectAtIndex:1];
                        if (strValue2 && [strValue2 length] >0) {
                            NSString *strKey = [array2 objectAtIndex:0];
                            if ([strKeyValue length] <2) {
                                strKeyValue = [strKeyValue stringByAppendingFormat:@"\"%@\":\"%@\"", strKey, strValue2];
                            } else {
                                strKeyValue = [strKeyValue stringByAppendingFormat:@",\"%@\":\"%@\"", strKey, strValue2];
                            }
                            //NSLog(@"strKey:\"%@\":\"%@\"", strKey, strValue2);
                        }
                    }
                }
                writeStr = [strKeyValue stringByAppendingString:@"}"];
            }
            //NSLog(@"writeStr:%@", writeStr);
            
            if (writeStr != NULL){
                NSString *strPath = [documentsDirectory stringByAppendingPathComponent:@"temp.txt"];
               BOOL ret =  [writeStr writeToFile:strPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
                if (ret == YES) {
                    NSLog(@"handleOpenURL enter ------------- writeStr  succ");
                }else {
                    NSLog(@"handleOpenURL enter ------------- writeStr  fail");
                }
                
                NSLog(@"handleOpenURL enter ------------- writeStr  %@  strPath  %@   ",writeStr , strPath);
                return YES;
            }else {
                NSLog(@"handleOpenURL enter ------------- writeStr  null");
                return NO;
            }
        }else {
             NSLog(@"handleOpenURL enter ------------- strRoomID strUid null");
            return NO;
        }
        
    }
    return NO;
}

@end
