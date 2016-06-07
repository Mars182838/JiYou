//
//  Header.h
//  JiYou
//
//  Created by 俊王 on 15/8/18.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#ifndef JiYou_Header_h
#define JiYou_Header_h

#define OBJECT_ISNULL(object) (object==nil || (NSNull *)object==[NSNull null])

#define OBJECT_VALUE(object) (object==nil)?[NSNull null]:object

#define NSString_ISNULL(string) (OBJECT_ISNULL(string) || string.length==0)

//友盟appKey
#define kUMAppkey @"55d2fc9ee0f55a9e83002405"

#define Token @"Token=970EC680705D7506DA998867F837A8EB"

//定义屏幕宽度
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
//定义屏幕高度
#define kScreenHeight ([UIScreen mainScreen].bounds.size.height)

#ifndef __OPTIMIZE__
#define NSLog(...) NSLog(__VA_ARGS__)
#else
#define NSLog(...) {}
#endif

//定义打印
#ifdef DEBUG
#	define DLog(fmt, ...) NSLog((@"[%@  %@  %d]:  " fmt), NSStringFromClass([self class]), NSStringFromSelector(_cmd), __LINE__, ##__VA_ARGS__);
#else
#	define DLog(...)
#endif

#define IS_IOS7 (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1 && floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1)
#define IS_IOS8  ([[[UIDevice currentDevice] systemVersion] compare:@"8" options:NSNumericSearch] != NSOrderedAscending)

#define IS_IPHONE4 (([UIScreen mainScreen].bounds.size.height == 480)? (YES):(NO))
#define IS_IPHONE5 (([UIScreen mainScreen].bounds.size.height == 568)? (YES):(NO))
#define IS_IPHONE6 (([UIScreen mainScreen].bounds.size.height == 667)? (YES):(NO))
#define IS_IPHONE6_PLUS (([UIScreen mainScreen].bounds.size.height > 667)? (YES):(NO))
#define MULTIPLE ([UIScreen mainScreen].bounds.size.width / 320)

#define kLatitude @"VIPlendingLatitude"  //用户经纬度
#define kLongitude @"VIPlendingLongitude" //用户经纬度

#define kDefaultRowHeight 44   //默认tableView cell的高度
#define kDefaultToolbarHeight 49  //默认底部工具条的高度
#define kDefaultKeyboardHeight 216 //默认键盘高度

//#define NETWORK_ENVIRONMENT_TEST_LOGIN

//#define NETWORK_ENVIRONMENT_TEST_PRODUCT

//#define NETWORK_ENVIRONMENT_TEST_REGISTER //设置网络环境

#define NETWORK_ENVIRONMENT_TEST_HUPENG

//#define NETWORK_ENVIRONMENT_TEST_JK

//定义屏幕高度-状态栏-导航栏的高度
#define kBarHeight ([UIApplication sharedApplication].statusBarFrame.size.height + self.navigationController.navigationBar.frame.size.height)
#define kValidScreenHeight (kScreenHeight - kBarHeight)
#define kShrinkFrame(rect) CGRectMake(rect.origin.x, rect.origin.y+kBarHeight, rect.size.width, rect.size.height-kBarHeight)

#define kUserDefaultsIgnoreVersion @"IgnoreVersionKey"


//Model
#define BK_PROPERTY_MODEL(model_property, presentation_property, mutator, element_type) \
BK_PROPERTY_MODEL_GET(model_property, presentation_property) \
BK_PROPERTY_MODEL_SET(model_property, mutator, element_type)

#define BK_PROPERTY_MODEL_GET(model_property, presentation_property) \
- (NSDictionary *)presentation_property { \
return [self.model_property toDictionaryWithParser:[BKObjectParser defaultParser]]; \
}

#define BK_PROPERTY_MODEL_SET(model_property, mutator, element_type) \
- (void)mutator: (NSDictionary *)value { \
if (!self.model_property) { \
self.model_property = [[element_type alloc] init]; \
} \
[self.model_property setAttributes:value]; \
}


static CGFloat const kStatusBarHeight = 20;
static CGFloat const kNavigationBarHeight = 64;
static CGFloat const kToolBarHeight = 50;

extern NSString* const JYLoginUserName; // == kBKLoginViewControllerUserPhone
extern NSString* const JYLoginUserID; // == kBKLoginViewControllerUserPhone
extern NSString* const JYOrderSuccess;
extern NSString* const JYLoginAccount;

extern NSString * const kTouchIdKey;
extern NSString * const kTouchIdCheckToShowName;

#endif
