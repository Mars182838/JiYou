//
//  JYBuyProductModel.h
//  JiYou
//
//  Created by 俊王 on 15/9/6.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYBaseModel.h"

@interface JYBuyProductModel : JYBaseModel

/*
yjfApp :""
yjfAppUserId :""
sellerAccount :""
orderNo  :""
noPwdPayFlag:
"ybProId":"22222222"
"ybProName":"加多宝"
"num":"20"
"tranId":"12345678"
"price":"3.00"
"pointPrice":"300"
"buyNumMax":3
"pointCount":10000
 */

@property (nonatomic, copy) NSString *appId;//易积分app
@property (nonatomic, copy) NSString *appUser;//易积分用户ID
@property (nonatomic, copy) NSString *sellerAccount;//易积分配置
@property (nonatomic, copy) NSString *orderNo;//订单号

@property (nonatomic, copy) NSString *buyNumMax;
@property (nonatomic, copy) NSString *surplusNum;//可售数量
@property (nonatomic, copy) NSString *productName;//友宝产品名称
@property (nonatomic, copy) NSString *productID;//友宝产品ID
@property (nonatomic, copy) NSString *tranID;//交易编号
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSString *pointPrice;//积分价格
@property (nonatomic, assign) CGFloat surplusPoint;//剩余积分

@end
