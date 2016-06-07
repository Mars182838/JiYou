//
//  YJNavigationController.m
//  YuanGongBao
//
//  Created by Mars on 14-9-17.
//  Copyright (c) 2014年 YiJie. All rights reserved.
//

#import "YJNavigationController.h"
#import "JYQRcodeViewController.h"
#import "JYNewBuyViewController.h"
#import "JYMobileAddressController.h"

@interface YJNavigationController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@end

@implementation YJNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    if (self = [super initWithRootViewController:rootViewController])
    {
        _enablePopGesture = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __weak YJNavigationController *weakSelf = self;
    
    [self.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor]] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    [self.navigationBar.layer setMasksToBounds:YES];
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.delegate = weakSelf;
        self.delegate = weakSelf;
    }
}


- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.interactivePopGestureRecognizer.enabled = NO;
    }
    [super pushViewController:viewController animated:animated];
}

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate
{
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        if (self.viewControllers.count > 1 && [JYQRcodeViewController class] != [viewController class] && [viewController class] != [JYNewBuyViewController class] && [JYMobileAddressController class] != [viewController class])
        {
            self.interactivePopGestureRecognizer.enabled = _enablePopGesture;
        }
        else
        {
            self.interactivePopGestureRecognizer.enabled = NO;
        }
    }
}

@end
