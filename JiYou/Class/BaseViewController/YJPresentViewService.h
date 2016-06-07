//
//  YJPresentViewService.h
//  YuanGongBao
//
//  Created by wangyaqing on 15/5/12.
//  Copyright (c) 2015年 YiJie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YJPresentViewService : NSObject

+ (void)presentViewController:(UIViewController *)controller completion:(void (^)(void))completion dismiss:(void (^)(void))dismiss;
+ (void)dismissOncompletion:(void (^)(void))completion;

@end