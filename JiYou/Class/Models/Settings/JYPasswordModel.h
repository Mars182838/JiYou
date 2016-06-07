//
//  JYPasswordModel.h
//  JiYou
//
//  Created by 俊王 on 15/8/25.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JYBaseModel.h"

@interface JYPasswordModel : JYBaseModel

@property (nonatomic, copy) NSString *oldPassword;

@property (nonatomic, copy) NSString *resetPassword;

@end

@interface JYForgetPassword : JYBaseModel

@property (nonatomic, copy) NSString *iphone;

@property (nonatomic, copy) NSString *verifyPassword;

@property (nonatomic, copy) NSString *password;//新密码

@end
