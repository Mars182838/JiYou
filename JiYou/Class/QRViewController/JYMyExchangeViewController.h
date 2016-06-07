//
//  JYMyExchangeViewController.h
//  JiYou
//
//  Created by 俊王 on 15/8/20.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYBaseViewController.h"
#import "JYMyExchangeModel.h"

@interface JYMyExchangeViewController : JYBaseViewController

//当前页
@property (nonatomic) NSInteger currentPage;

//上一次分页，刷新失败时，需要用到
@property (nonatomic) int prePage;

//列表数据
@property (strong, nonatomic) NSMutableArray *dataListArray;

@property (nonatomic, strong) JYMyExchangeModel *exchangeModel;

@end
