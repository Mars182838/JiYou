//
//  JYUserModel.m
//  JiYou
//
//  Created by 俊王 on 15/8/27.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYUserModel.h"
#import "JYLoginViewController.h"
#import "BKRequestProxy.h"
#import "YJNavigationController.h"
#import "YJPresentViewService.h"

NSTimeInterval const BKSessionTimeout = 29*60;

@implementation JYUserModel

NSString* const JYLoginUserName = @"JYLoginUserName";
NSString* const JYLoginUserID = @"JYLoginUserID";
NSString* const JYOrderSuccess = @"JYOrderSuccess";
NSString *const JYLoginAccount = @"JYLoginAccount";
+(instancetype) shareInstance
{
    static JYUserModel *_userModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _userModel = [[[self class] alloc] init];
        
    });
    
    return _userModel;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.mobile = [[NSUserDefaults standardUserDefaults] objectForKey:JYLoginUserName];
        self.userID = [[NSUserDefaults standardUserDefaults] objectForKey:JYLoginUserID];
        self.account = [[NSUserDefaults standardUserDefaults] objectForKey:JYLoginAccount];
        if (!NSString_ISNULL(self.mobile)) {
            
            self.mobile = [self.mobile formatFromPhone];
            
        }
    }
    return self;
}

- (BOOL)isLogin
{
    return (self.lastLoginTime!=nil);
}

-(void)setImgString:(NSString *)imgString
{
    if ([@"<null>" isEqualToString:imgString] || NSString_ISNULL(imgString)) {
        
        _imgString = nil;
    }
    else{
        
        _imgString = imgString;
    }
}

-(void)setMobile:(NSString *)mobile
{
    if (![mobile isEqualToString:_mobile]) {
        if ([@"(null)" isEqualToString:mobile] || NSString_ISNULL(mobile)) {
            _mobile = nil;
        } else {
            _mobile = mobile;
        }
    }
}

-(void)setToken:(NSString *)token
{
    if (NSString_ISNULL(token)) {
        
        _token = @"12";
    }
    else{
        
        _token = token;
    }
}

-(void)save
{
    [[NSUserDefaults standardUserDefaults] setObject:self.mobile forKey:JYLoginUserName];
    [[NSUserDefaults standardUserDefaults] setObject:self.userID forKey:JYLoginUserID];
    [[NSUserDefaults standardUserDefaults] setObject:self.account forKey:JYLoginAccount];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)logout
{
    self.password = @"";
    self.lastLoginTime = nil;
    NSArray* cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    for (NSHTTPCookie* cookie  in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    
    JYLoginViewController * viewController = [[JYLoginViewController alloc] init];
    YJNavigationController * rootViewController = [[YJNavigationController alloc] initWithRootViewController:viewController];
    [YJPresentViewService presentViewController:rootViewController completion:^{
    
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:JYLoginUserName];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:JYLoginUserID];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:JYLoginAccount];

        [[NSUserDefaults standardUserDefaults] synchronize];

    }dismiss:nil];
}


- (void)loginWithFinishBlock:(AuthFinishBlock)finishBlock
{
    __weak JYUserModel* weakself = self;
    if (NSString_ISNULL(self.mobile)) {
        [self showLoginViewController];
    } else {
        
        NSDictionary *params = @{@"mobile":self.mobile,@"userId":self.userID};
        self.logging = YES;
        
        [[BKRequestProxy sharedInstance] requestWithType:BKRequestTypePOST
                                               urlString:@"/user/auto_login"
                                                  params:params
                                                    part:nil
                                                 success:^(BKRequestModel *request, BKResponseModel *response) {
                                                     
                                                     if ([response.responseObject isKindOfClass:[NSDictionary class]] && [JYSuccessCode isEqualToString:response.head.code]) {
                                                         
                                                         weakself.lastLoginTime = [NSDate date];
                                                         
                                                         if (finishBlock) {
                                                             
                                                             finishBlock();
                                                         }
                                                        
                                                     } else {
                                                         //密码错误
                                                         [self showLoginViewController];
                                                     }
                                                 }
                                                 failure:^(BKRequestModel *request, NSError *error) {

                                                 }];
    }
}

- (void)showLoginViewController
{
    JYLoginViewController * viewController = [[JYLoginViewController alloc] init];
    YJNavigationController * rootViewController = [[YJNavigationController alloc] initWithRootViewController:viewController];
    [YJPresentViewService presentViewController:rootViewController completion:nil dismiss:nil];
    
}

@end
