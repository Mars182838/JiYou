//
//  BKLineView.h
//  BEIKOO
//
//  Created by leo on 14-9-30.
//  Copyright (c) 2014年 BEIKOO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BKLineView : UIView
@end

@interface BKHorizontalLineView : UIView  //横线

@property (nonatomic, assign) CGFloat lineWidth; //线的粗细
@property (nonatomic, strong) UIColor* lineColor; //线的颜色, 默认白色

@end


@interface BKVerticalLineView : UIView  //竖线

@property (nonatomic, assign) CGFloat lineWidth; //线的粗细
@property (nonatomic, strong) UIColor* lineColor; //线的颜色, 默认白色

@end


@interface BKHorizontalDashLineView : UIView
@property (nonatomic, strong) UIColor* strokeColor;
@end
