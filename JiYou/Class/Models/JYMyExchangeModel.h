//
//  JYMyExchangeModel.h
//  JiYou
//
//  Created by 俊王 on 15/9/2.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYBaseModel.h"

@interface JYMyExchangeModel : JYBaseModel

@property (nonatomic, copy) NSString *countPage;//总页数

@property (nonatomic, copy) NSString *countRows;//总条数

@property (nonatomic, copy) NSString *currentPage;//当前页数

@property (nonatomic, copy) NSString *prodcuctID;//友宝产品ID

@property (nonatomic, copy) NSString *prodcuctName;//产品名称

@property (nonatomic, copy) NSString *buyNum;//购买数量

@property (nonatomic, copy) NSString *proPrice;//消费现金

@property (nonatomic, copy) NSString *pointPrice;//消费积分

@property (nonatomic, copy) NSString *createTime;//下单时间

@property (nonatomic, copy) NSString *status;//兑换状态

@property (nonatomic, copy) NSString *details;//产品详情

@end
