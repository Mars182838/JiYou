//
//  JYCustomView.m
//  JiYou
//
//  Created by 俊王 on 15/8/21.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYCustomView.h"

@implementation JYCustomView

static JYCustomView *customView;

+(instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        customView = [[JYCustomView alloc] init];
        
    });
    
    return customView;
}

-(JYCustomView *)showEmptyImageWithRect:(CGRect)rect andImageString:(NSString *)string andTitleString:(NSString *)titleString
{
    customView.frame = rect;
    UIImage *image  = [UIImage imageNamed:string];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((rect.size.width - image.size.width)/2, 0, image.size.width, image.size.height)];
    imageView.image = image;
    [customView addSubview:imageView];
    
    if (titleString != nil) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(rect.origin.x, imageView.originY + imageView.height + 10, rect.size.width, 20)];
        label.text = titleString;
        label.font = [UIFont systemFontOfSize:16];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor colorWithHexString:@"0xbbbbbb"];
        [customView addSubview:label];
    }
    
    return customView;
}

@end
