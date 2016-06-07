//
//  JYQRViewController.h
//  YiYou
//
//  Created by Mars on 15/4/25.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JYBaseViewController.h"

typedef void(^QRUrlBlock)(NSString *url);

@interface JYQRViewController : JYBaseViewController

@property (nonatomic, copy) QRUrlBlock qrUrlBlock;

@end
