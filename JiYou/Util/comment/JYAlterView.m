//
//  JYAlterView.m
//  JiYou
//
//  Created by 俊王 on 15/9/30.
//  Copyright © 2015年 JY. All rights reserved.
//

#import "JYAlterView.h"
#import "NSString+Additions.h"
#import "BKLineView.h"
#import <pop/POP.h>

@interface JYAlterView()

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) NSString *message;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong) NSArray *buttonsArray;

@property (nonatomic, copy) JYAlterViewBlock alterViewBlock;

@property (nonatomic, assign) CGSize size;

@end

@implementation JYAlterView

CGFloat jWindowWidth;
CGFloat jWindowHeight;
CGFloat jTextHeight;
CGFloat jTitleHeight;
CGFloat jCircleHeight;

-(JYAlterView *)init
{
    self = [super init];

    if (self) {
        
        self.frame = [UIScreen mainScreen].bounds;
        
        jWindowWidth = 280.0f;
        jWindowHeight = 200.0f;
        jTitleHeight = 30;
        jTextHeight = 45.0f;
        jCircleHeight = 30.0f;

        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.backgroundColor = [UIColor clearColor];
        [self addSubview:_backgroundView];
        
        _contentView = [[UIView alloc] init];
        _contentView.frame = CGRectMake(0.0f, 0, jWindowWidth, jWindowHeight);
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.alpha = 0.98;
        [self addSubview:_contentView];

        _contentView.layer.cornerRadius = 10.0f;
        _contentView.layer.masksToBounds = YES;

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [_contentView addSubview:_titleLabel];
        
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:13];
        _messageLabel.numberOfLines = 0;
        _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_contentView addSubview:_messageLabel];
        _contentView.center = _backgroundView.center;
        
        self.buttonsArray = [[NSArray alloc] init];
    }
    
    return self;
}

-(void)setTitle:(NSString *)title
{
    _titleLabel.text = title;
}

-(void)setMessage:(NSString *)message
{
    _messageLabel.text = message;
    
}

-(void)updateUI{
    
    _titleLabel.frame = CGRectMake(0, 10, _contentView.width, jTitleHeight);
    
    _messageLabel.frame = CGRectMake(15, _titleLabel.originY + jTitleHeight, _titleLabel.width - 30, jTitleHeight);
    _size = [_messageLabel.text boundingRectWithSize:CGSizeMake(_messageLabel.width, 1000) withFont:_messageLabel.font];
    _messageLabel.height = _size.height;
    
    UIButton *button = nil;
    
    for (NSInteger i = 0; i< self.buttonsArray.count; i++) {
        
        BKHorizontalLineView *lineView = [[BKHorizontalLineView alloc] initWithFrame:CGRectMake(0, (_messageLabel.originY + _messageLabel.height + 15) + i*45, _contentView.width, 1)];
        lineView.backgroundColor = [UIColor colorWithHexString:@"0xE9E9E9"];
        [_contentView addSubview:lineView];
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, (_messageLabel.originY + _messageLabel.height + 15) + i*45, _contentView.width, jTextHeight);
        button.tag = i;
        button.titleLabel.font = [UIFont systemFontOfSize:15];

        if (i == 0) {
            
            button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        }
        
        [button setTitle:self.buttonsArray[i] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithHexString:@"0x106BFF"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [_contentView addSubview:button];
    }
    
    _contentView.height = button.originY + 5 + button.height;
}

-(instancetype)initWithTitle:(NSString *)title
                     message:(NSString *)message
                 buttonArray:(NSArray *)buttons
                dismissBlock:(JYAlterViewBlock)dismissBlock
{
    self = [self init];
    
    if (self) {
    
        self.alterViewBlock = dismissBlock;
        self.title = title;
        self.message = message;
        self.buttonsArray = buttons;
        
        [self updateUI];

    }
   
    return self;
}

-(void)show
{
    POPBasicAnimation *offscreenAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    offscreenAnimation.fromValue = @(-1.5*self.height);
    [offscreenAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        
    }];
    
    POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    positionAnimation.toValue = @(self.center.y);
    positionAnimation.springBounciness = 10;
    [positionAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        
    }];
    
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.springBounciness = 20;
    scaleAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(1.2, 1.4)];
    
    [self.contentView.layer pop_addAnimation:positionAnimation forKey:@"positionAnimation"];
    [self.contentView.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    [self.contentView.layer pop_addAnimation:offscreenAnimation forKey:@"offscreenAnimation"];

    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
}

-(void)buttonClick:(UIButton *)button{
    
    self.alterViewBlock(button);
    
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.springBounciness = 10;
    scaleAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.6, 0.8)];

    POPBasicAnimation *offscreenAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    offscreenAnimation.toValue = @(1.5*self.height);
    [offscreenAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        
        [self removeFromSuperview];

    }];
    
    [self.contentView.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    [self.contentView.layer pop_addAnimation:offscreenAnimation forKey:@"offscreenAnimation"];

}

@end
