//
//  JYShakeAlterView.h
//  摇一摇
//
//  Created by 俊王 on 16/3/28.
//  Copyright © 2016年 nacker. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <pop/POP.h>

typedef void (^JYShakeAlterViewBlock)(NSInteger count);

@interface JYShakeAlterView : UIView

@property (nonatomic, strong) UILabel *messageLabel;

-(instancetype)initwithTypeArray:(NSArray *)array
                     dismissBlock:(JYShakeAlterViewBlock)dismissBlock;

-(void)show;

@end
