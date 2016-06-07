//
//  BKLineView.m
//  BEIKOO
//
//  Created by leo on 14-9-30.
//  Copyright (c) 2014年 BEIKOO. All rights reserved.
//

#import "BKLineView.h"

@implementation BKLineView
@end

@implementation BKHorizontalLineView

- (void)awakeFromNib{
    [super awakeFromNib];
    self.lineWidth = 0.8f;
    self.lineColor = self.backgroundColor;
    self.backgroundColor = [UIColor clearColor];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.lineWidth = frame.size.height;
        self.lineColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, self.frame.size.width, 0);
    CGContextStrokePath(context);
    
}

@end


@implementation BKVerticalLineView

- (void)awakeFromNib{
    [super awakeFromNib];
    self.lineWidth = 0.8f;
    self.lineColor = self.backgroundColor;
    self.backgroundColor = [UIColor clearColor];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.lineWidth = frame.size.height;
        self.lineColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextSetStrokeColorWithColor(context, self.lineColor.CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 0, self.frame.size.height);
    CGContextStrokePath(context);
    
}

@end

@implementation BKHorizontalDashLineView

- (void)awakeFromNib{
    [super awakeFromNib];
    self.strokeColor = self.backgroundColor;
    self.backgroundColor = [UIColor clearColor];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.strokeColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat y = rect.size.height/2;
    CGFloat xStart = rect.origin.x;
    CGFloat xEnd = rect.origin.x + rect.size.width;
    
    [self.strokeColor setStroke];
    UIBezierPath* path = [UIBezierPath bezierPath];
    path.lineWidth = 0.8f;
    CGFloat lengths[] = {2,2};
    [path setLineDash:lengths count:2 phase:0];
    [path moveToPoint:CGPointMake(xStart, y)];
    [path addLineToPoint:CGPointMake(xEnd, y)];
    [path stroke];
}

@end