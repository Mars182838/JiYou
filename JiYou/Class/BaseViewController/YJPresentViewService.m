//
//  YJPresentViewService.m
//  YuanGongBao
//
//  Created by wangyaqing on 15/5/12.
//  Copyright (c) 2015年 YiJie. All rights reserved.
//

#import "YJPresentViewService.h"
#import "JYBaseViewController.h"

static id kYJPResentViewController_show;
static id kYJPResentViewController_dismiss;

@interface YJPresentViewService()

@property (strong, nonatomic) UIWindow * rootWindow;
@property (strong, nonatomic) NSMutableArray * viewControllers;

@end

@implementation YJPresentViewService

+ (void)presentViewController:(UIViewController *)controller completion:(void (^)(void))completion dismiss:(void (^)(void))dismiss
{
    [[YJPresentViewService sharedInstance] presentViewController:controller completion:completion dismiss:dismiss];
}

+ (void)dismissOncompletion:(void (^)(void))completion
{
    [[YJPresentViewService sharedInstance] dismissOncompletion:completion];
}

- (instancetype)init
{
    if (self = [super init])
    {
        UIWindow *window = [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
        window.windowLevel = UIWindowLevelNormal + 1;
        window.backgroundColor = [UIColor clearColor];
        window.hidden = YES;
        _rootWindow = window;
        
        _viewControllers = [NSMutableArray array];
    }
    return self;
}

- (void)presentViewController:(UIViewController *)controller completion:(void (^)(void))completion dismiss:(void (^)(void))dismiss
{
    objc_setAssociatedObject(controller, &kYJPResentViewController_show, completion, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(controller, &kYJPResentViewController_dismiss, dismiss, OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    _rootWindow.hidden = NO;
    
    UINavigationBar * backgroundView = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight)];
    backgroundView.barStyle = UIBarStyleBlack;
    [_rootWindow addSubview:backgroundView];
    
    controller.view.frame = backgroundView.bounds;
    [backgroundView addSubview:controller.view];
    [_viewControllers addObject:controller];

    [UIView animateWithDuration:0.3 animations:^
    {
        backgroundView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    } completion:^(BOOL finished)
     {
        [_rootWindow makeKeyAndVisible];
         
         if (completion != nil)
         {
             completion();
         }
    }];
}

- (void)dismissOncompletion:(void (^)(void))completion
{
    if (_viewControllers.count > 0)
    {
        UIViewController * viewController = [_viewControllers lastObject];
        void (^dismiss)(void);
        dismiss = objc_getAssociatedObject(viewController, &kYJPResentViewController_dismiss);
        
        [UIView animateWithDuration:0.3 animations:^
        {
            viewController.view.superview.frame = CGRectMake(0, kScreenHeight, kScreenWidth, kScreenHeight);
        } completion:^(BOOL finished)
        {
            if (completion) completion();
            if (dismiss) dismiss();
            
            [viewController.view.superview removeFromSuperview];
            [_viewControllers removeObject:viewController];
            
            if (_viewControllers.count == 0)
            {
                _rootWindow.hidden = YES;
                [_rootWindow resignKeyWindow];
            }
        }];
    }
}

@end