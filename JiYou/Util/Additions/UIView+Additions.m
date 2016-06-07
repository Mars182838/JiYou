//
//  UIView+xibLoad.m
//  YuanGongBao
//
//  Created by 陆锋平 on 15-1-4.
//  Copyright (c) 2015年 YiJie. All rights reserved.
//

#import "UIView+Addtions.h"

@implementation UIView (Additions)

+(UIView *) loadNib
{
    NSArray *array=[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
    UIView * view=[array lastObject];
    return view;
}

- (void)enumerateSubviewsWithBlock:(SubViewEnumerator)block
{
    for (UIView* view in self.subviews) {
        block(view);
        [view enumerateSubviewsWithBlock:block];
    }
}

- (void)resignAllFirstResponder
{
    [self enumerateSubviewsWithBlock:^(UIView *view) {
        if (view.isFirstResponder) {
            [view resignFirstResponder];
        }
    }];
}

- (void)removeAllSubviews
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

- (UIView *)findSuperViewOfClass:(Class)aClass
{
    UIView* view = self.superview;
    while (view != nil) {
        if ([view isKindOfClass:aClass]) {
            break;
        } else {
            view = view.superview;
        }
    }
    return view;
}

- (void)addHalfTransparentBg
{
    UIView* bg = [[UIView alloc] initWithFrame:self.bounds];
    bg.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    bg.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self insertSubview:bg atIndex:0];
}

@end
