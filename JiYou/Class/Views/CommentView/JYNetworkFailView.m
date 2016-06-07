//
//  BKNetworkFailView.m
//  BEIKOO
//
//  Created by Mars on 14/11/3.
//  Copyright (c) 2014年 BEIKOO. All rights reserved.
//

#import "JYNetworkFailView.h"
#import "UIGestureRecognizer+BlocksKit.h"

@interface JYNetworkFailView ()
@property (strong, nonatomic) UIView* bg;

@property (nonatomic, strong) UILabel * titleLable;
@property (nonatomic, assign) BOOL isBack;

@end

@implementation JYNetworkFailView

+(instancetype)shareInstance
{
    static id _bkNetworkFailView = nil;
    
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        
        _bkNetworkFailView = [[JYNetworkFailView alloc] init];

    });
    
    return _bkNetworkFailView;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, (kScreenHeight - 60)/2 - 64, kScreenWidth, 60)];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont boldSystemFontOfSize:16.0f];
        label.text = @"网络失败\n点击屏幕刷新";
        label.numberOfLines = 4;
        self.titleLable = label;
        [self addSubview:self.titleLable];
        
        __weak JYNetworkFailView* weakself = self;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] bk_initWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
            [weakself hiddenView];
            if (weakself.reload) {
                weakself.reload();
            }
        }];
        
        [self addGestureRecognizer:tap];
    }
    return self;
}

-(void)initWithView:(UIView *)view reload:(JYReloadNetwork )reload
{
    [self initWithView:view isNav:NO reload:reload];
}

-(void)initWithView:(UIView *)view isNav:(BOOL)isNav reload:(JYReloadNetwork )reload
{
    self.hidden = NO;
    if (isNav) {
        self.frame = CGRectMake(0, 64, kScreenWidth, kScreenHeight);
    } else {
        self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    }
    
    if (!self.isBack) {
        
        self.titleLable.textColor = [UIColor colorWithHexString:@"0x3b3b3b"];
    }
    else{
        
        self.titleLable.textColor = [UIColor whiteColor];
        
        self.isBack = NO;
    }
    

    self.reload = reload;
    [view addSubview:self];
}

-(void)initWithView:(UIView *)view isNav:(BOOL)isNav hasBackGround:(BOOL)isBack reload:(JYReloadNetwork)reload
{
    self.isBack = isBack;
    [self initWithView:view isNav:isNav reload:reload];
}

-(void)hiddenView
{
    if (self) {
        
        self.hidden = YES;
        [self removeFromSuperview];

    }
}



@end
