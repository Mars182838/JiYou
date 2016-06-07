//
//  AppDelegate.m
//  JiYou
//
//  Created by 俊王 on 15/8/18.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "AppDelegate.h"
#import "JYQRcodeViewController.h"
#import "JYWebViewController.h"
#import "MobClick.h"
#import <CoreLocation/CoreLocation.h>
#import "YJ_OpenUDID.h"
#import "JYUserModel.h"

#import "APService.h"

#import "WXApi.h"

#define kWeiXinAppId @"wxe29d194860841ccb"
#define kWeiXinAppSecret  @"e38f95aabe0ef94232c3f4c059c7b1fc"

@interface AppDelegate ()<WXApiDelegate>

@property (nonatomic, strong) CLLocationManager* locationManager;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [[UITextField appearance] setTintColor:[UIColor colorWithHexString:@"0x04B3E8"]]; //sets textfield tint color
    
    /**
     *  未登录的用户
     */
    [self loadQRCodeViewController];

    [self setUpUmeng:nil];
    
    sleep(1.2f);
    
    [self.window makeKeyAndVisible];
    
    
    // Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
    
    // Required
    [APService setupWithOption:launchOptions];
    
    [WXApi registerApp:@"wxe29d194860841ccb"];


    return YES;
}

/**
 *  加载首页
 */
-(void)loadQRCodeViewController{
    
    JYQRcodeViewController *rootVC = [[JYQRcodeViewController alloc] init];
    YJNavigationController *nav = [[YJNavigationController alloc] initWithRootViewController:rootVC];
    //    JYBaseTabBarViewController *rootVC = [[JYBaseTabBarViewController alloc] init];
    self.window.rootViewController = nav;
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations{
    [manager stopUpdatingLocation];
    
    CLLocation* location = [locations lastObject];
    CLLocationCoordinate2D coordinate = location.coordinate;
    
    //保存当前选定的坐标值
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:coordinate.latitude] forKey:kLatitude];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:coordinate.longitude] forKey:kLongitude];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self setUpUmeng:location];
}


- (void)setUpUmeng:(CLLocation*)location{
    
    [MobClick startWithAppkey:@"55b837a267e58e5d840060a6" reportPolicy:SEND_INTERVAL channelId:nil];
    [MobClick setCrashReportEnabled:YES]; // 如果不需要捕捉异常，注释掉此行
    [MobClick setLocation:location];
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];

}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WXApi handleOpenURL:url delegate:self];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];
}

-(void)onResp:(BaseResp *)resp
{
    NSLog(@"%@",resp);
    
    [self getWeiXinCodeFinishedWithResp:resp];
}


- (void)getWeiXinCodeFinishedWithResp:(BaseResp *)resp
{
    if (resp.errCode == 0)
    {
        NSLog(@"用户同意");
        SendAuthResp *aresp = (SendAuthResp *)resp;
        [self getAccessTokenWithCode:aresp.code];
        
    }else if (resp.errCode == -4){
        NSLog(@"用户拒绝");
        
    }else if (resp.errCode == -2){
        NSLog(@"用户取消");
    }
}

- (void)getAccessTokenWithCode:(NSString *)code
{
    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",kWeiXinAppId,kWeiXinAppSecret,code];
    NSURL *url = [NSURL URLWithString:urlString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *dataStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (data)
            {
                
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                NSLog(@"------%@",dict);
                
                if ([dict objectForKey:@"errcode"])
                {
                    //获取token错误
                }else{
                    //存储AccessToken OpenId RefreshToken以便下次直接登陆
                    //AccessToken有效期两小时，RefreshToken有效期三十天
                    [self getUserInfoWithAccessToken:[dict objectForKey:@"access_token"] andOpenId:[dict objectForKey:@"openid"]];
                }
            }
        });
    });
    
    /*
     30      正确返回
     31      "access_token" = “Oez*****8Q";
     32      "expires_in" = 7200;
     33      openid = ooVLKjppt7****p5cI;
     34      "refresh_token" = “Oez*****smAM-g";
     35      scope = "snsapi_userinfo";
     36      */
    
    /*
     39      错误返回
     40      errcode = 40029;
     41      errmsg = "invalid code";
     42      */
}


-(void)getUserInfoWithAccessToken:(NSString *)accessToken andOpenId:(NSString *)openId
{
    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",accessToken,openId];
    NSURL *url = [NSURL URLWithString:urlString];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *dataStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (data)
            {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                
                NSLog(@"%@",dict);
                
                if ([dict objectForKey:@"errcode"])
                {
                    //AccessToken失效
                    //                                                 [self getAccessTokenWithRefreshToken:[[NSUserDefaults standardUserDefaults]objectForKey:kWeiXinRefreshToken]];
                }else{
                    //获取需要的数据
                }
            }
        });
    });
    
    /*
     29      city = ****;
     30      country = CN;
     31      headimgurl = "http://wx.qlogo.cn/mmopen/q9UTH59ty0K1PRvIQkyydYMia4xN3gib2m2FGh0tiaMZrPS9t4yPJFKedOt5gDFUvM6GusdNGWOJVEqGcSsZjdQGKYm9gr60hibd/0";
     32      language = "zh_CN";
     33      nickname = “****";
     34      openid = oo*********;
     35      privilege =     (
     36      );
     37      province = *****;
     38      sex = 1;
     39      unionid = “o7VbZjg***JrExs";
     40      */
    
    /*
     43      错误代码
     44      errcode = 42001;
     45      errmsg = "access_token expired";
     46      */
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [application setApplicationIconBadgeNumber:0];
    [application cancelAllLocalNotifications];

}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark
#pragma mark --APService Delegate

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    // Required
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required
    [APService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // IOS 7 Support Required
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}


@end
