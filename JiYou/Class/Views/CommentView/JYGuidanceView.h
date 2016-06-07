//
//  JYGuidanceView.h
//  JiYou
//
//  Created by 俊王 on 15/9/9.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <pop/POP.h>

typedef void (^JYGuidanceViewDismissBlock)();

@interface JYGuidanceView : UIView

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, strong) JYGuidanceViewDismissBlock dismissBlock;

+(instancetype)shareInstance;

-(JYGuidanceView *)initWithFrame:(CGRect)frame andWithString:(NSString *)name;

@end
