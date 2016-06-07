//
//  JYMyExchangeTableViewCell.h
//  JiYou
//
//  Created by 俊王 on 15/8/21.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JYMyExchangeModel.h"
#import "BKLineView.h"
#import "NSNumber+BKAddition.h"
#import "NSString+Additions.h"

@interface JYMyExchangeTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;//产品名称

@property (weak, nonatomic) IBOutlet UILabel *priceLabel;//价格

@property (weak, nonatomic) IBOutlet UILabel *tradeDateLabel;//交易时间

@property (weak, nonatomic) IBOutlet UILabel *tradeStatusLabel;//交易状态

@property (nonatomic, strong) JYMyExchangeModel *productModel;

@property (nonatomic, strong) NSDictionary *modelDic;

@property (nonatomic, assign) BOOL isExchangeDetail;

@property (weak, nonatomic) IBOutlet BKHorizontalLineView *lineView;

@property (weak, nonatomic) IBOutlet BKHorizontalLineView *headerLineView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstant;

@end
