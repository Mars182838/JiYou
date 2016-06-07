//
//  JYExemptPasswordViewController.h
//  JiYou
//
//  Created by 俊王 on 15/8/25.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYBaseViewController.h"

typedef enum
{
    //以下是枚举成员
    ExemptPassword = 0,//免密
    FingerprintPassword//指纹
    
}ExemptPasswordType;

@interface JYExemptPasswordViewController : JYBaseViewController

@end
