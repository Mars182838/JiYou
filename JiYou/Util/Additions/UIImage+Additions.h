//
//  UIImage+Additions.h
//  YuanGongBao
//
//  Created by Mars on 14-9-16.
//  Copyright (c) 2014年 YiJie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Additions)
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;
+ (UIImage *)imageWithColor:(UIColor *)color;
- (UIImage *)resize;
+ (UIImage *)stretchableImageNamed:(NSString *)name;
+ (UIImage *)stretchableImageNamed:(NSString *)name edgeInsets:(UIEdgeInsets )edgeInsets;

@end
