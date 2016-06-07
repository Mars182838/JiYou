//
//  JYSuccessAlterView.h
//  摇一摇
//
//  Created by 俊王 on 16/3/29.
//  Copyright © 2016年 nacker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <pop/POP.h>

typedef void (^JYSuccessAlterViewBlock)(NSInteger count);

typedef enum {
    kSuccessAlterType = 0,           // no button type
    kFailAlterType,
    kLastSuccessAlterType,
    kLotteryDrawAlterType,
} SuccessAlterViewType;

@interface JYSuccessAlterView : UIView

-(instancetype)initwithTitle:(NSString *)title
                 buttonArray:(NSArray *)btnArray
               alterViewType:(SuccessAlterViewType)type
                dismissBlock:(JYSuccessAlterViewBlock)dismissBlock;

-(void)show;

@end
