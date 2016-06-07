//
//  JYCustomView.h
//  JiYou
//
//  Created by 俊王 on 15/8/21.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JYCustomView : UIView

+(instancetype)shareInstance;

-(JYCustomView *)showEmptyImageWithRect:(CGRect)rect andImageString:(NSString *)string andTitleString:(NSString *)titleString;

@end
