#import "UnityAppController.h"
#import "UnityAppController+ViewHandling.h"
#import "UnityAppController+Rendering.h"
#import "iPhone_Sensors.h"

#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CADisplayLink.h>
#import <Availability.h>

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#include <mach/mach_time.h>

// MSAA_DEFAULT_SAMPLE_COUNT was moved to iPhone_GlesSupport.h
// ENABLE_INTERNAL_PROFILER and related defines were moved to iPhone_Profiler.h
// kFPS define for removed: you can use Application.targetFrameRate (30 fps by default)
// DisplayLink is the only run loop mode now - all others were removed

#include "CrashReporter.h"

#include "UI/OrientationSupport.h"
#include "UI/UnityView.h"
#include "UI/Keyboard.h"
#include "UI/SplashScreen.h"
#include "Unity/InternalProfiler.h"
#include "Unity/DisplayManager.h"
#include "Unity/EAGLContextHelper.h"
#include "Unity/GlesHelper.h"
#include "PluginBase/AppDelegateListener.h"
#import "WechatHelper.h"
#import "MwHelper.h"
#import "QQHelper.h"
#import "IOSSdk.h"

// jpushBegin
#import "JPUSHService.h"
#import <AdSupport/AdSupport.h>
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

//static NSString *appKey = @"455ff09856d61656c4602853";
//static NSString *channel = @"YouxianC01";
static BOOL isProduction = FALSE;

@interface UnityAppController ()<JPUSHRegisterDelegate>

@end
// jpushEnd

@implementation UnityViewControllerBase(HomeIndicator)
//TER0103-增加HOME指示器激活过程
- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures
{
    return UIRectEdgeAll;
}
@end

bool	_ios42orNewer			= false;
bool	_ios43orNewer			= false;
bool	_ios50orNewer			= false;
bool	_ios60orNewer			= false;
bool	_ios70orNewer			= false;
bool	_ios80orNewer			= false;
bool	_ios81orNewer			= false;
bool	_ios82orNewer			= false;
bool	_ios90orNewer			= false;
bool	_ios91orNewer			= false;
bool	_ios100orNewer			= false;

// was unity rendering already inited: we should not touch rendering while this is false
bool	_renderingInited		= false;
// was unity inited: we should not touch unity api while this is false
bool	_unityAppReady			= false;
// see if there's a need to do internal player pause/resume handling
//
// Typically the trampoline code should manage this internally, but
// there are use cases, videoplayer, plugin code, etc where the player
// is paused before the internal handling comes relevant. Avoid
// overriding externally managed player pause/resume handling by
// caching the state
bool	_wasPausedExternal		= false;
// should we skip present on next draw: used in corner cases (like rotation) to fill both draw-buffers with some content
bool	_skipPresent			= false;
// was app "resigned active": some operations do not make sense while app is in background
bool	_didResignActive		= false;

// was startUnity scheduled: used to make startup robust in case of locking device
static bool	_startUnityScheduled	= false;

bool	_supportsMSAA			= false;


@implementation UnityAppController

@synthesize unityView				= _unityView;
@synthesize unityDisplayLink		= _unityDisplayLink;

@synthesize rootView				= _rootView;
@synthesize rootViewController		= _rootController;
@synthesize mainDisplay				= _mainDisplay;
@synthesize renderDelegate			= _renderDelegate;
@synthesize quitHandler				= _quitHandler;

#if !UNITY_TVOS
@synthesize interfaceOrientation	= _curOrientation;
#endif

- (id)init
{
	if( (self = [super init]) )
	{
		// due to clang issues with generating warning for overriding deprecated methods
		// we will simply assert if deprecated methods are present
		// NB: methods table is initied at load (before this call), so it is ok to check for override
		NSAssert(![self respondsToSelector:@selector(createUnityViewImpl)],
			@"createUnityViewImpl is deprecated and will not be called. Override createUnityView"
		);
		NSAssert(![self respondsToSelector:@selector(createViewHierarchyImpl)],
			@"createViewHierarchyImpl is deprecated and will not be called. Override willStartWithViewController"
		);
		NSAssert(![self respondsToSelector:@selector(createViewHierarchy)],
			@"createViewHierarchy is deprecated and will not be implemented. Use createUI"
		);
	}
	return self;
}


- (void)setWindow:(id)object		{}
- (UIWindow*)window					{ return _window; }


- (void)shouldAttachRenderDelegate	{}
- (void)preStartUnity				{}


- (void)startUnity:(UIApplication*)application
{
	NSAssert(_unityAppReady == NO, @"[UnityAppController startUnity:] called after Unity has been initialized");

	UnityInitApplicationGraphics();

	// we make sure that first level gets correct display list and orientation
	[[DisplayManager Instance] updateDisplayListInUnity];

	UnityLoadApplication();
	Profiler_InitProfiler();

	[self showGameUI];
	[self createDisplayLink];

	UnitySetPlayerFocus(1);
}

extern "C" void UnityRequestQuit()
{
	_didResignActive = true;
	if (GetAppController().quitHandler)
		GetAppController().quitHandler();
	else
		exit(0);
}

#if !UNITY_TVOS
- (NSUInteger)application:(UIApplication*)application supportedInterfaceOrientationsForWindow:(UIWindow*)window
{
    UIDeviceOrientation curOrient = [UIDevice currentDevice].orientation;
    if (curOrient == UIDeviceOrientationLandscapeLeft) {
        //TER1222#iphoneX适配(375x812)
        [self adjustScreenForIphoneX:window];
    } else if (curOrient == UIDeviceOrientationLandscapeRight) {
        //TER1222#iphoneX适配(375x812)
        [self adjustScreenForIphoneX:window];
    }
    
	// UIInterfaceOrientationMaskAll
	// it is the safest way of doing it:
	// - GameCenter and some other services might have portrait-only variant
	//     and will throw exception if portrait is not supported here
	// - When you change allowed orientations if you end up forbidding current one
	//     exception will be thrown
	// Anyway this is intersected with values provided from UIViewController, so we are good
	return   (1 << UIInterfaceOrientationPortrait) | (1 << UIInterfaceOrientationPortraitUpsideDown)
		   | (1 << UIInterfaceOrientationLandscapeRight) | (1 << UIInterfaceOrientationLandscapeLeft);
}
#endif

#if !UNITY_TVOS
- (void)application:(UIApplication*)application didReceiveLocalNotification:(UILocalNotification*)notification
{
	AppController_SendNotificationWithArg(kUnityDidReceiveLocalNotification, notification);
	UnitySendLocalNotification(notification);
}
#endif

#if UNITY_USES_REMOTE_NOTIFICATIONS
- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	AppController_SendNotificationWithArg(kUnityDidReceiveRemoteNotification, userInfo);
	UnitySendRemoteNotification(userInfo);
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	AppController_SendNotificationWithArg(kUnityDidRegisterForRemoteNotificationsWithDeviceToken, deviceToken);
	UnitySendDeviceToken(deviceToken);
    
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}

#if !UNITY_TVOS
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))handler
{
	AppController_SendNotificationWithArg(kUnityDidReceiveRemoteNotification, userInfo);
	UnitySendRemoteNotification(userInfo);
	if (handler)
	{
		handler(UIBackgroundFetchResultNoData);
	}
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    handler(UIBackgroundFetchResultNewData);
}
#endif

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	AppController_SendNotificationWithArg(kUnityDidFailToRegisterForRemoteNotificationsWithError, error);
	UnitySendRemoteNotificationError(error);
}
#endif

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    
    //wechat
    [WechatHelper handleOpenURL:url];
    //QQ
    [QQHelper handleOpenURL:url];
    //mw
    [MwHelper handleOpenURL:url];
    
    return YES;
}

- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation
{
    
    [WechatHelper handleOpenURL:url];
    [MwHelper handleOpenURL:url];
    [QQHelper handleOpenURL:url];
	NSMutableArray* keys	= [NSMutableArray arrayWithCapacity:3];
	NSMutableArray* values	= [NSMutableArray arrayWithCapacity:3];

	#define ADD_ITEM(item)	do{ if(item) {[keys addObject:@#item]; [values addObject:item];} }while(0)

	ADD_ITEM(url);
	ADD_ITEM(sourceApplication);
	ADD_ITEM(annotation);

	#undef ADD_ITEM

	NSDictionary* notifData = [NSDictionary dictionaryWithObjects:values forKeys:keys];
	AppController_SendNotificationWithArg(kUnityOnOpenURL, notifData);
	return YES;
}

-(BOOL)application:(UIApplication*)application willFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    // jpush  //Required
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    // Optional
    // 获取IDFA
    // 如需使用IDFA功能请添加此代码并在初始化方法的advertisingIdentifier参数中填写对应值
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    // Required
    // init Push
    // notice: 2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    NSDictionary * bundleDict = [[NSBundle mainBundle] infoDictionary];
    assert(bundleDict != NULL);
    
    NSString *appKey = [bundleDict objectForKey:@"com.yxhy.jpush.appkey"];
    assert(appKey != NULL);
    
    NSString *channel = [bundleDict objectForKey:@"com.yxhy.jpush.channel"];
    assert(channel != NULL);
    
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:channel
                 apsForProduction:isProduction
            advertisingIdentifier:advertisingId];
    
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            NSLog(@"registrationID获取成功：%@",registrationID);
            
        }
        else{
            NSLog(@"registrationID获取失败，code：%d",resCode);
        }
    }];
    
    [JPUSHService setBadge:0];//清空JPush服务器中存储的badge值
    [application setApplicationIconBadgeNumber:0];//小红点清0操作
    
	return YES;
}

#import <sys/utsname.h>
- (BOOL)isIphoneX
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceVersion = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    if ([deviceVersion isEqualToString:@"iPhone10,3"] || [deviceVersion isEqualToString:@"iPhone10,6"])
    {
        return YES;
    }
    return NO;
}
- (void)adjustScreenForIphoneX:(UIWindow *)_window
{
    //TER1222#iphoneX适配(375x812)
    if ([self isIphoneX])
    {
        id baseViewController = [[_window rootViewController] presentedViewController];
        if (baseViewController && [NSStringFromClass([baseViewController class]) isEqualToString:@"UniWebViewController"]) {
            //退出回调
            [baseViewController performSelector:@selector(exitBlock:) withObject:^{
                [self adjustScreenForIphoneX:_window];
            }];
            return;
        }
        
        CGPoint reduce = CGPointMake(32, 11);
        //CGRect bounds = CGRectMake(reduce.x, reduce.y, 812 -2*reduce.x, 375 -2*reduce.y);
        CGRect bounds = CGRectMake(reduce.x, 0, 812 -2*reduce.x, 375 -reduce.y);
        [_window setFrame:bounds];
    }
}

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
	::printf("-> applicationDidFinishLaunching()\n");

	// send notfications
#if !UNITY_TVOS
	if(UILocalNotification* notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey])
		UnitySendLocalNotification(notification);

	if(NSDictionary* notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey])
		UnitySendRemoteNotification(notification);

	if ([UIDevice currentDevice].generatesDeviceOrientationNotifications == NO)
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
#endif

	UnityInitApplicationNoGraphics([[[NSBundle mainBundle] bundlePath] UTF8String]);

	[self selectRenderingAPI];
	[UnityRenderingView InitializeForAPI:self.renderingAPI];
    
    CGRect bounds = [UIScreen mainScreen].bounds;
	_window			= [[UIWindow alloc] initWithFrame:bounds];
	_unityView		= [self createUnityView];
    
    //TER1222#iphoneX适配(375x812)
    [self adjustScreenForIphoneX:_window];

	[DisplayManager Initialize];
	_mainDisplay	= [DisplayManager Instance].mainDisplay;
	[_mainDisplay createWithWindow:_window andView:_unityView];

	[self createUI];
	[self preStartUnity];

	// if you wont use keyboard you may comment it out at save some memory
	[KeyboardDelegate Initialize];
    [WechatHelper registerApp];
    [QQHelper shareInstance];
    //MwSDK
    [MwHelper registerApp];
    
    //JPush
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];

	return YES;
}

- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    //NSString *content = [userInfo valueForKey:@"content"];
    NSDictionary *extras = [userInfo valueForKey:@"extras"];
    //NSString *customizeField1 = [extras valueForKey:@"customizeField1"]; //服务端传递的Extras附加字段，key是自己定义的
    
    //NSDictionary to json
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:extras options:NSJSONWritingPrettyPrinted error:&parseError];
    NSString *strExtras = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    [IOSSdk OnJPushEvent:strExtras];
}

- (void)applicationDidEnterBackground:(UIApplication*)application
{
	::printf("-> applicationDidEnterBackground()\n");
}

- (void)applicationWillEnterForeground:(UIApplication*)application
{
	::printf("-> applicationWillEnterForeground()\n");

	// applicationWillEnterForeground: might sometimes arrive *before* actually initing unity (e.g. locking on startup)
	if(_unityAppReady)
	{
		// if we were showing video before going to background - the view size may be changed while we are in background
		[GetAppController().unityView recreateGLESSurfaceIfNeeded];
	}
}

- (void)applicationDidBecomeActive:(UIApplication*)application
{
	::printf("-> applicationDidBecomeActive()\n");

	[self removeSnapshotView];

	if(_unityAppReady)
	{
		if(UnityIsPaused() && _wasPausedExternal == false)
		{
			UnityWillResume();
			UnityPause(0);
		}
		UnitySetPlayerFocus(1);
	}
	else if(!_startUnityScheduled)
	{
		_startUnityScheduled = true;
		[self performSelector:@selector(startUnity:) withObject:application afterDelay:0];
	}

	_didResignActive = false;
    
    [JPUSHService setBadge:0];//清空JPush服务器中存储的badge值
    [application setApplicationIconBadgeNumber:0];//小红点清0操作
}

- (void)removeSnapshotView
{
	// do this on the main queue async so that if we try to create one 
	// and remove in the same frame, this always happens after in the same queue
	dispatch_async(dispatch_get_main_queue(), ^{
		if(_snapshotView)
		{
			[_snapshotView removeFromSuperview];
			_snapshotView = nil;
		}
	});
}

- (void)applicationWillResignActive:(UIApplication*)application
{
	::printf("-> applicationWillResignActive()\n");

	if(_unityAppReady)
	{
		UnitySetPlayerFocus(0);

		_wasPausedExternal = UnityIsPaused();
		if (_wasPausedExternal == false)
		{
			// do pause unity only if we dont need special background processing
			// otherwise batched player loop can be called to run user scripts
			int bgBehavior = UnityGetAppBackgroundBehavior();
			if(bgBehavior == appbgSuspend || bgBehavior == appbgExit)
			{
				// Force player to do one more frame, so scripts get a chance to render custom screen for minimized app in task manager.
				// NB: UnityWillPause will schedule OnApplicationPause message, which will be sent normally inside repaint (unity player loop)
				// NB: We will actually pause after the loop (when calling UnityPause).
				UnityWillPause();
				[self repaint];
				UnityPause(1);

				// this is done on the next frame so that
				// in the case where unity is paused while going 
				// into the background and an input is deactivated
				// we don't mess with the view hierarchy while taking
				// a view snapshot (case 760747).
				dispatch_async(dispatch_get_main_queue(), ^{
					// if we are active again, we don't need to do this anymore
					if (!_didResignActive) 
					{
						return;
					}
					_snapshotView = [self createSnapshotView];
					if(_snapshotView)
						[_rootView addSubview:_snapshotView];
				});
			}
		}
	}

	_didResignActive = true;
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication*)application
{
	::printf("WARNING -> applicationDidReceiveMemoryWarning()\n");
}

- (void)applicationWillTerminate:(UIApplication*)application
{
	::printf("-> applicationWillTerminate()\n");

	Profiler_UninitProfiler();
	UnityCleanup();

	extern void SensorsCleanup();
	SensorsCleanup();
}


#pragma mark- JPUSHRegisterDelegate

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}

@end


void AppController_SendNotification(NSString* name)
{
	[[NSNotificationCenter defaultCenter] postNotificationName:name object:GetAppController()];
}
void AppController_SendNotificationWithArg(NSString* name, id arg)
{
	[[NSNotificationCenter defaultCenter] postNotificationName:name object:GetAppController() userInfo:arg];
}
void AppController_SendUnityViewControllerNotification(NSString* name)
{
	[[NSNotificationCenter defaultCenter] postNotificationName:name object:UnityGetGLViewController()];
}

extern "C" UIWindow*			UnityGetMainWindow()		{ return GetAppController().mainDisplay.window; }
extern "C" UIViewController*	UnityGetGLViewController()	{ return GetAppController().rootViewController; }
extern "C" UIView*				UnityGetGLView()			{ return GetAppController().unityView; }
extern "C" ScreenOrientation	UnityCurrentOrientation()	{ return GetAppController().unityView.contentOrientation; }



bool LogToNSLogHandler(LogType logType, const char* log, va_list list)
{
	NSLogv([NSString stringWithUTF8String:log], list);
	return true;
}

void UnityInitTrampoline()
{
#if ENABLE_CRASH_REPORT_SUBMISSION
	SubmitCrashReportsAsync();
#endif
	InitCrashHandling();

	NSString* version = [[UIDevice currentDevice] systemVersion];

	// keep native plugin developers happy and keep old bools around
	_ios42orNewer = true;
	_ios43orNewer = true;
	_ios50orNewer = true;
	_ios60orNewer = true;
	_ios70orNewer = [version compare: @"7.0" options: NSNumericSearch] != NSOrderedAscending;
	_ios80orNewer = [version compare: @"8.0" options: NSNumericSearch] != NSOrderedAscending;
	_ios81orNewer = [version compare: @"8.1" options: NSNumericSearch] != NSOrderedAscending;
	_ios82orNewer = [version compare: @"8.2" options: NSNumericSearch] != NSOrderedAscending;
	_ios90orNewer = [version compare: @"9.0" options: NSNumericSearch] != NSOrderedAscending;
	_ios91orNewer = [version compare: @"9.1" options: NSNumericSearch] != NSOrderedAscending;
	_ios100orNewer = [version compare: @"10.0" options: NSNumericSearch] != NSOrderedAscending;

	// Try writing to console and if it fails switch to NSLog logging
	::fprintf(stdout, "\n");
	if(::ftell(stdout) < 0)
		UnitySetLogEntryHandler(LogToNSLogHandler);
}
