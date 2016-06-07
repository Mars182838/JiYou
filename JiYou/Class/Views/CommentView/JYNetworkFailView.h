//
//  BKNetworkFailView.h
//  BEIKOO
//
//  Created by Mars on 14/11/3.
//  Copyright (c) 2014年 BEIKOO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JYNetworkFailView : UIView

typedef void(^JYReloadNetwork)();


@property (nonatomic, copy) JYReloadNetwork reload;

+(instancetype)shareInstance;

-(void)initWithView:(UIView *)view reload:(JYReloadNetwork )reload;

-(void)initWithView:(UIView *)view  isNav:(BOOL )isNav reload:(JYReloadNetwork)reload;

-(void)initWithView:(UIView *)view isNav:(BOOL)isNav hasBackGround:(BOOL)isBack reload:(JYReloadNetwork)reload;

-(void)hiddenView;

@end
