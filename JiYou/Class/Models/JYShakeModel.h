//
//  JYShakeModel.h
//  JiYou
//
//  Created by 俊王 on 16/3/30.
//  Copyright © 2016年 JY. All rights reserved.
//

#import "JYBaseModel.h"

@interface JYShakeModel : JYBaseModel

@property (nonatomic, copy) NSString *drawType;//选择的类型

@property (nonatomic, copy) NSString *account;

@property (nonatomic, strong) NSString *epointHadWin;

@property (nonatomic, assign) BOOL isEpoint;

@property (nonatomic, copy) NSString *isEpointTime;

@property (nonatomic, assign) NSInteger prizeEpoint;

@property (nonatomic, copy) NSString *epointLotteryNumber;

@property (nonatomic, copy) NSString *wjRange;

@property (nonatomic, copy) NSString *jjRange;


@property (nonatomic, copy) NSString *isMovieTime;
@property (nonatomic, assign) BOOL isLotteryDrawTime;

@property (nonatomic, copy) NSString *drawHadWin;
@property (nonatomic, copy) NSString *exchangeUrl;


@end
