//
//  JYUserModel.h
//  JiYou
//
//  Created by 俊王 on 15/8/27.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYBaseModel.h"

typedef void(^AuthFinishBlock)(void);

@interface JYUserModel : JYBaseModel

@property (nonatomic, assign, readonly) BOOL isLogin;
@property (nonatomic, assign) BOOL logging;
@property (nonatomic, assign) BOOL forceLogin; // if NO 且登录失败或没有存储的账户，不显示登录页面，一般只用于app开启后的第一次自动登录

@property (nonatomic, copy) NSDate *lastLoginTime; //上次登录时间

@property (nonatomic, copy) NSString *mobile;//手机号

@property (nonatomic, copy) NSString *userID;

@property (nonatomic, copy) NSString *password;//动态验证码

@property (nonatomic, copy) NSString *imgString;//图片地址

@property (nonatomic, assign) BOOL firstUse;//第一次使用

@property (nonatomic, copy) NSString *token;//第一次使用

@property (nonatomic, assign) CGFloat exchangeSum;//兑换总数

@property (nonatomic, assign) CGFloat pointCount;//总积分

@property (nonatomic, assign) NSInteger timeout;//验证码超时

@property (nonatomic, copy) NSString *userName;

@property (nonatomic, copy) NSString *appVersion;//

@property (nonatomic, copy) NSString *appVersionMsg;//

@property (nonatomic, copy) NSString *workingStatus;

@property (nonatomic, copy) NSString *account;

@property (nonatomic, assign) BOOL isExermt;// 是否免密成功

@property (nonatomic, assign) BOOL isShowTouchID;// 是否开启指纹支付

+(instancetype) shareInstance;

- (void)logout;
- (void)loginWithFinishBlock:(AuthFinishBlock)finishBlock;
- (void)save;

@end

@interface JYInformationModel : NSObject

@end
