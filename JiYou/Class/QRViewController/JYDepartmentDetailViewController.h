//
//  JYDepartmentDetailViewController.h
//  JiYou
//
//  Created by 俊王 on 15/12/23.
//  Copyright © 2015年 JY. All rights reserved.
//

#import "JYBaseViewController.h"
#import "JYMobileDetailModel.h"

@interface JYDepartmentDetailViewController : JYBaseViewController

@property (nonatomic, strong) NSArray *dataList;

@property (nonatomic, strong) NSArray *headerArray;

@property (nonatomic, strong) JYMobileDetailModel *detailModel;

@end
