//
//  NCLCustomProgressHUD.h
//  NEWCHINALIFE
//
//  Created by Mars on 13-7-19.
//  Copyright (c) 2013年 com.oberon.osx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

extern CGFloat HUDHiddenTime;

@interface BKCustomProgressHUD : UIView<MBProgressHUDDelegate>

@property (nonatomic, retain) MBProgressHUD *progressHUD;

+ (id)sharedCustomProgressHUD;

#pragma  mark - showView In KeyWindow

-(void)showHUDLoadingView;
-(void)showHUdModeTextViewWithMessage:(NSString *)message;
-(void)showHUDCustomViewWithMessage:(NSString *)message;

#pragma mark - showView In CustomView

-(void)showHUDWithView:(UIView *)view andString:(NSString *)labelString;

-(void)showHUDModeTextWithView:(UIView *)view andString:(NSString *)labelString;

-(void)showHUDCustomViewWithView:(UIView *)view andString:(NSString *)labelString;

-(BOOL)hiddenView;

-(BOOL)hiddenViewFast;

@end
