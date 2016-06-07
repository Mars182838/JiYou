//
//  UIView+frame.h
//  Carousel
//
//  Created by Calvin Sun on 11/12/12.
//
//

#import <UIKit/UIKit.h>

CGPoint CGRectGetCenter(CGRect rect);
CGRect  CGRectMoveToCenter(CGRect rect, CGPoint center);

@interface UIView (frame)

@property(nonatomic) CGFloat x,y;

- (CGFloat)originX;
- (CGFloat)originY;
- (CGFloat)rightX;
- (CGFloat)bottomY;

- (void)setOriginX:(CGFloat)x;
- (void)setOriginY:(CGFloat)y;
- (void)setCenterX:(CGFloat)x;
- (void)setCenterY:(CGFloat)y;
- (void)setRightX:(CGFloat)x;
- (void)setBottomY:(CGFloat)y;
- (void)setOrigin:(CGPoint)origin;

- (void)setOriginX:(CGFloat)x originY:(CGFloat)y width:(CGFloat)width height:(CGFloat)height;

@property CGPoint origin;
@property CGSize size;
@property CGFloat height;
@property CGFloat width;
@property CGFloat top;
@property CGFloat left;
@property CGFloat bottom;
@property CGFloat right;

@property (nonatomic, readonly) CGPoint bottomLeft;
@property (nonatomic, readonly) CGPoint bottomRight;
@property (nonatomic, readonly) CGPoint topRight;

- (void) moveBy: (CGPoint) delta;
- (void) scaleBy: (CGFloat) scaleFactor;
- (void) fitInSize: (CGSize) aSize;

@end

static inline CGFloat CGRectLeft(CGRect rect){
    return rect.origin.x;
}

static inline CGFloat CGRectRight(CGRect rect){
    return rect.origin.x+rect.size.width;
}

static inline CGFloat CGRectTop(CGRect rect){
    return rect.origin.y;
}

static inline CGFloat CGRectBottom(CGRect rect){
    return rect.origin.y+rect.size.height;
}

static inline CGPoint CGRectTopLeft(CGRect rect)
{
    return rect.origin;
}

static inline CGPoint CGRectTopRight(CGRect rect)
{
    CGFloat x = rect.origin.x+rect.size.width;
    return CGPointMake(x, rect.origin.y);
}

static inline CGPoint CGRectBottomLeft(CGRect rect)
{
    CGFloat y = rect.origin.y+rect.size.height;
    return CGPointMake(rect.origin.x, y);
}

static inline CGPoint CGRectBottomRight(CGRect rect)
{
    CGFloat x = rect.origin.x+rect.size.width;
    CGFloat y = rect.origin.y+rect.size.height;
    return CGPointMake(x, y);
}

static inline CGPoint CGPointAdd(CGPoint p1, CGPoint p2)
{
    return CGPointMake(p1.x+p2.x, p1.y+p2.y);
}
