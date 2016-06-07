//
//  NCLCustomProgressHUD.m
//  NEWCHINALIFE
//
//  Created by Mars on 13-7-19.
//  Copyright (c) 2013年 com.oberon.osx. All rights reserved.
//

#import "BKCustomProgressHUD.h"

CGFloat HUDHiddenTime = 2;

@implementation BKCustomProgressHUD

+ (id)sharedCustomProgressHUD
{
    static BKCustomProgressHUD *progress;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        progress = [[BKCustomProgressHUD alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    });
    return progress;
}

#pragma  mark - ShowInKetyWindow

-(void)showHUDLoadingView
{
    [self removeSubViews];
    UIView *view = [UIApplication sharedApplication].keyWindow;
    _progressHUD = [[MBProgressHUD alloc] initWithView:self];
    _progressHUD.mode = MBProgressHUDModeIndeterminate;
    [self addSubview:_progressHUD];
    [view addSubview:self];
    [_progressHUD show:YES];
}

-(void)showHUdModeTextViewWithMessage:(NSString *)message
{
    [self hiddenViewFast];
    [self removeSubViews];
    UIView *view = [UIApplication sharedApplication].keyWindow;
    NSTimeInterval duration = 0.5f;
    
    if (_progressHUD == nil) {
        
        _progressHUD = [[MBProgressHUD alloc]initWithView:self];
        
    }
    _progressHUD.detailsLabelText = message;
    _progressHUD.detailsLabelFont = [UIFont systemFontOfSize:15.0f];
    if ([message isValidateAlphabet]) {
        
        _progressHUD.detailsLabelFont = [UIFont systemFontOfSize:30.0f];
        duration = 0.35f;
        HUDHiddenTime = 1.0f;
    }
    else{
        
        HUDHiddenTime = 2.0f;
    }
    _progressHUD.mode = MBProgressHUDModeText;
    [self addSubview:_progressHUD];
    [view addSubview:self];
    
    [_progressHUD show:YES];
    [UIView animateWithDuration:duration delay:HUDHiddenTime options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _progressHUD.alpha = 0;
    } completion:^(BOOL finished) {
        _progressHUD.alpha = 1;
        [_progressHUD removeFromSuperview];
        _progressHUD = nil;
        [self removeFromSuperview];
    }];
}

-(void)showHUDCustomViewWithMessage:(NSString *)message
{
    [self hiddenViewFast];
    [self removeSubViews];
    UIView *view = [UIApplication sharedApplication].keyWindow;
    
    if (_progressHUD == nil) {
        
        _progressHUD = [[MBProgressHUD alloc] initWithView:self];
        [self addSubview:_progressHUD];
    }
    [view addSubview:self];
    _progressHUD.labelText = message;
    _progressHUD.labelFont = [UIFont systemFontOfSize:15.0f];
    _progressHUD.mode = MBProgressHUDModeCustomView;
    _progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ark_icon_checkMark"]];
    
    [_progressHUD showAnimated:YES whileExecutingBlock:^{
        sleep(HUDHiddenTime);
    } completionBlock:^{
        [_progressHUD removeFromSuperview];
        _progressHUD = nil;
        [self removeFromSuperview];
    }];
}

#pragma mark - ShowInCustomView
-(void)showHUDWithView:(UIView *)view andString:(NSString *)labelString
{
    [self removeSubViews];
    if (view == nil) {
        
        view = [UIApplication sharedApplication].keyWindow;
    }
    _progressHUD = [[MBProgressHUD alloc] initWithView:self];
    _progressHUD.labelText = labelString;
    _progressHUD.mode = MBProgressHUDModeIndeterminate;
    [self addSubview:_progressHUD];
    [view addSubview:self];
    [_progressHUD show:YES];
}


-(void)showHUDModeTextWithView:(UIView *)view andString:(NSString *)labelString
{
    [self removeSubViews];
    if (_progressHUD == nil) {
        
        _progressHUD = [[MBProgressHUD alloc]initWithView:self];
        
        [self addSubview:_progressHUD];

    }
    _progressHUD.detailsLabelText = labelString;
    _progressHUD.mode = MBProgressHUDModeText;
    [view addSubview:self];
    
    [_progressHUD show:YES];
    [UIView animateWithDuration:0.5 delay:HUDHiddenTime options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _progressHUD.alpha = 0; 
    } completion:^(BOOL finished) {
        _progressHUD.alpha = 1;
        [_progressHUD removeFromSuperview];
        _progressHUD = nil;
        [self removeFromSuperview];
    }];
    
}

-(void)showHUDCustomViewWithView:(UIView *)view andString:(NSString *)labelString
{
    [self removeSubViews];
    if (_progressHUD == nil) {
        
        _progressHUD = [[MBProgressHUD alloc] initWithView:self];
        [self addSubview:_progressHUD];
    }
    [view addSubview:self];
    _progressHUD.labelText = labelString;
    _progressHUD.mode = MBProgressHUDModeCustomView;
    _progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ark_icon_checkMark"]];
    [_progressHUD showAnimated:YES whileExecutingBlock:^{
        sleep(HUDHiddenTime);
    } completionBlock:^{
        [_progressHUD removeFromSuperview];
        _progressHUD = nil;
        [self removeFromSuperview];
    }];
}

- (void)removeSubViews
{
    NSInteger count = self.subviews.count;

    for (int i = 0; i<count; i++) {
        
        UIView *view = [self.subviews objectAtIndex:i];
        [view removeFromSuperview];
    }
}

-(BOOL)hiddenView
{
    [_progressHUD hide:YES afterDelay:HUDHiddenTime];
    [self removeFromSuperview];
    return YES;
}

-(BOOL)hiddenViewFast
{
    [_progressHUD removeFromSuperview];
    _progressHUD = nil;
    [self removeFromSuperview];
    return YES;
}
#pragma mark - Hud Delegate Methods
- (void)hudWasHidden:(MBProgressHUD *)hud
{
    if (hud != nil) {
        [hud removeFromSuperview];
        [self removeFromSuperview];
        hud = nil;
    }
}

@end
