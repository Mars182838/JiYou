//
//  UIImage+Additions.m
//  YuanGongBao
//
//  Created by Mars on 14-9-16.
//  Copyright (c) 2014年 YiJie. All rights reserved.
//

#import "UIImage+Additions.h"

@implementation UIImage (Additions)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGSize size = CGSizeMake(1, 1);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    UIImage * desImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return desImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size{
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


- (UIImage *)resize
{
    return [self resizableImageWithCapInsets:UIEdgeInsetsMake(self.size.height / 2, self.size.width / 2, self.size.height / 2 - 1, self.size.width / 2 - 1)];
}


+ (UIImage *)stretchableImageNamed:(NSString *)name
{
    UIImage *image = [UIImage imageNamed:name];
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake((image.size.height-1)/2,
                                               (image.size.width-1)/2,
                                               (image.size.height-1)/2,
                                               (image.size.width-1)/2);
    return [UIImage stretchableImageNamed:name edgeInsets:edgeInsets];
}

+ (UIImage *)stretchableImageNamed:(NSString *)name edgeInsets:(UIEdgeInsets )edgeInsets
{
    UIImage *image = [UIImage imageNamed:name];
    image = [image resizableImageWithCapInsets:edgeInsets];
    return image;
}

@end
