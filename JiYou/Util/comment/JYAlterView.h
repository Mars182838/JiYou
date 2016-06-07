//
//  JYAlterView.h
//  JiYou
//
//  Created by 俊王 on 15/9/30.
//  Copyright © 2015年 JY. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^JYAlterViewBlock)(UIButton *button);

@interface JYAlterView : UIView


- (instancetype)initWithTitle:(NSString *)title
                      message:(NSString *)message
                  buttonArray:(NSArray *)buttons
                 dismissBlock:(JYAlterViewBlock)dismissBlock;

-(void)show;

@end
