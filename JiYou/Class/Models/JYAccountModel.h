//
//  JYAccountModel.h
//  JiYou
//
//  Created by 俊王 on 15/9/1.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYBaseModel.h"

@interface JYAccountModel : JYBaseModel

@property (nonatomic, copy) NSString *picUrl;

@property (nonatomic, copy) NSString *exchangeSum;//兑换总数

@property (nonatomic, copy) NSString *pointCount;//总积分

@property (nonatomic, copy) NSString *userName;

@end
