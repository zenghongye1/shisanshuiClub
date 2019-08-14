//
//  IAPShare.m
//

#import "IAPShare.h"
#import "NSString+Base64.h"
#import "IOSSdk.h"

#if ! __has_feature(objc_arc)
#error You need to either convert your project to ARC or add the -fobjc-arc compiler flag to IAPShare.m.
#endif

@implementation IAPShare
@synthesize iap= _iap;

+ (IAPShare *) sharedHelper {
    static IAPShare * _sharedHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedHelper = [[IAPShare alloc] init];
        _sharedHelper.iap = nil;
    });
    return _sharedHelper;
}

+(id)toJSON:(NSString *)json
{
    NSError* err = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData: [json dataUsingEncoding:NSUTF8StringEncoding]
                                    options: NSJSONReadingMutableContainers
                                      error: &err];
    
    if(err==nil) {
        return jsonObject;
    }
    else {
        NSLog(@"%@",[err localizedDescription]);
        return nil;
    }
    
}

+(BOOL)fetchIAPList:(NSDictionary *)_dict {
    
    if ([IAPShare sharedHelper].iap) {
        return YES;
    }
    
    NSString *iapList = [_dict valueForKey:@"param1"];
    NSArray *iapArray = [iapList componentsSeparatedByString:@","];
    
    NSSet* dataSet = [[NSSet alloc] initWithArray:iapArray];
//    NSSet* dataSet = [[NSSet alloc] initWithObjects:@"com.bshz.mjgame.pro1", nil];
    [IAPShare sharedHelper].iap = [[IAPHelper alloc] initWithProductIdentifiers:dataSet];
    
//    [IAPShare sharedHelper].iap.production = NO;
    
    // 请求商品信息
    [[IAPShare sharedHelper].iap requestProductsWithCompletion:^(SKProductsRequest* request,SKProductsResponse* response)
     {
         //回调列表
         NSString *tempIapList = @"";
         for (SKProduct *product in response.products) {
             NSString *strProId = [product productIdentifier];
//             NSLog(@"strPro:%@", strProId);
             if ([tempIapList length] <1) {
                 tempIapList = [tempIapList stringByAppendingFormat:@", %@", strProId];
             }
             else {
                 tempIapList = strProId;
             }
         }
//         tempIapList = [iapArray objectAtIndex:0];
         
         //回调
//         int handlerID = [[_dict valueForKey:@"callback"] intValue];
//         if (handlerID >0 && tempIapList) {
//             cocos2d::LuaBridge::pushLuaFunctionById(handlerID);
//             cocos2d::LuaStack *stack = cocos2d::LuaBridge::getStack();
//             stack->pushString([tempIapList UTF8String]);
//             stack->executeFunction(1);
//             cocos2d::LuaBridge::releaseLuaFunctionById(handlerID);
//         }
         
//         NSLog(@"tempIapList:%@", tempIapList);
         [IOSSdk IapListCallback:tempIapList];
     }];
    
    return YES;
}
+(BOOL)buyIAP:(NSDictionary *)_dict {
    
    if (![IAPShare sharedHelper].iap) {
        return NO;
    }
    
    NSString *productID = [_dict valueForKey:@"param1"];
    for (SKProduct* product in [IAPShare sharedHelper].iap.products) {
        
        if ([[product productIdentifier] isEqualToString:productID]) {
            
//            NSLog(@"Price: %@",[[IAPShare sharedHelper].iap getLocalePrice:product]);
//            NSLog(@"Title: %@",product.localizedTitle);
            
            [[IAPShare sharedHelper].iap buyProduct:product
                                       onCompletion:^(SKPaymentTransaction* trans){
                                           
                                           NSString *receiptBase64 = @"";
                                           
                                           if(trans.error)
                                           {
                                               NSLog(@"Fail %@",[trans.error localizedDescription]);
                                               
                                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[trans.error localizedDescription]
                                                                                              delegate:self cancelButtonTitle:@"确定"
                                                                                     otherButtonTitles:nil, nil];
                                               [alert show];
                                           }
                                           else if(trans.transactionState == SKPaymentTransactionStatePurchased) {
                                               
//                                               NSData* receiptData = [NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]];
//                                               [[IAPShare sharedHelper].iap checkReceipt:receiptData AndSharedSecret:@"your sharesecret"
//                                                                            onCompletion:^(NSString *response, NSError *error) {
//                                                                                
//                                                                                //Convert JSON String to NSDictionary
//                                                                                NSDictionary* rec = [IAPShare toJSON:response];
//                                                                                
//                                                                                if([rec[@"status"] integerValue]==0)
//                                                                                {
//                                                                                    [[IAPShare sharedHelper].iap provideContentWithTransaction:trans];
//                                                                                    NSLog(@"SUCCESS %@",response);
//                                                                                    NSLog(@"Pruchases %@",[IAPShare sharedHelper].iap.purchasedProducts);
//                                                                                }
//                                                                                else {
//                                                                                    NSLog(@"Fail");
//                                                                                }
//                                                                            }];
                                               
                                               //要求Base64编码
                                               NSString *transReceipt = [trans.transactionReceipt base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
//                                               receiptBase64 = [NSString stringWithFormat:@"{\"receipt-data\":\"%@\"}", transReceipt];
                                               receiptBase64 = transReceipt;

                                           }
                                           else if(trans.transactionState == SKPaymentTransactionStateFailed) {
                                               NSLog(@"Fail");
                                           }
                                           
//                                           //回调
//                                           int handlerID = [[_dict valueForKey:@"callback"] intValue];
//                                           if (handlerID >0) {
//                                               cocos2d::LuaBridge::pushLuaFunctionById(handlerID);
//                                               cocos2d::LuaStack *stack = cocos2d::LuaBridge::getStack();
//                                               stack->pushString([receiptBase64 UTF8String]);
//                                               stack->executeFunction(1);
//                                               cocos2d::LuaBridge::releaseLuaFunctionById(handlerID);
//                                           }
                                           
                                           [IOSSdk IapBuyCallback:receiptBase64];
                                           
                                       }];//end of buy product
        }
    }
    
    return YES;
}

@end
