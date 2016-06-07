//
//  UIView+xibLoad.h
//  YuanGongBao
//
//  Created by 陆锋平 on 15-1-4.
//  Copyright (c) 2015年 YiJie. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SubViewEnumerator)(UIView* view);

@interface UIView (BKAddition)

+(UIView *) loadNib;

- (void)enumerateSubviewsWithBlock:(SubViewEnumerator)block;
- (void)resignAllFirstResponder;
- (void)removeAllSubviews;
- (UIView *)findSuperViewOfClass:(Class)aClass;

- (void)addHalfTransparentBg;
@end

