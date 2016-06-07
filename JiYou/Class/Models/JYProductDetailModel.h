//
//  JYProductDetailModel.h
//  JiYou
//
//  Created by 俊王 on 15/9/1.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYBaseModel.h"

/*
"currentPage":当前页数,
"perPageNum":每页条数
"countPage":总页数
"countRows":总条数
"proId":友宝产品ID
"proName":产品名称
"buyNum":购买数量
"status":兑换状态
"priceAmt":消费现金
"epointAmt":消费积分
"createTime":兑换时间
*/

@interface JYProductDetailModel : JYBaseModel

@property (nonatomic, copy) NSString *countPage;

@property (nonatomic, copy) NSString *countRows;

@property (nonatomic, copy) NSString *currentPage;

@property (nonatomic, copy) NSString *prodcuctID;

@property (nonatomic, copy) NSString *prodcuctName;

@property (nonatomic, copy) NSString *proNum;

@property (nonatomic, copy) NSString *tran_id;

@property (nonatomic, copy) NSString *proPrice;

@property (nonatomic, copy) NSString *pointPrice;

@property (nonatomic, copy) NSString *orderTime;

@end



