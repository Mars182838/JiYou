//
//  JYSuccessAlterView.m
//  摇一摇
//
//  Created by 俊王 on 16/3/29.
//  Copyright © 2016年 nacker. All rights reserved.
//

#import "JYSuccessAlterView.h"

@interface JYSuccessAlterView()
{
    
    NSInteger count;
    CGFloat factorFloat;
    CGFloat jWindowWidth;
    CGFloat jWindowHeight;
    CGFloat jTextHeight;
    CGFloat jTitleHeight;
    CGFloat jCircleHeight;
}

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, copy) JYSuccessAlterViewBlock alterViewBlock;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UILabel *tipsLabel;

@property (nonatomic, strong) UILabel *messageLabel;

@property (nonatomic, strong) NSArray *buttonsArray;

@property (nonatomic, strong) UIButton *selectedBtn;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, assign) SuccessAlterViewType type;

@end

@implementation JYSuccessAlterView


-(JYSuccessAlterView *)init
{
    self = [super init];
    
    if (self) {
        
        self.frame = [UIScreen mainScreen].bounds;
        
        factorFloat = self.width/375.0;
        jWindowWidth = self.width - 60*factorFloat;
        
        NSLog(@"%f",jWindowWidth);
        
        jWindowHeight = 200.0f;
        jTitleHeight = 30;
        jTextHeight = 45.0f;
        jCircleHeight = 30.0f;
        
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0.6;
        [self addSubview:_backgroundView];
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, jWindowWidth, jWindowHeight)];
        [self addSubview:_imageView];
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:30];
        _titleLabel.textColor = [UIColor whiteColor];
        [_imageView addSubview:_titleLabel];
        
        
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.textAlignment = NSTextAlignmentCenter;
        _tipsLabel.font = [UIFont systemFontOfSize:16];
        _tipsLabel.textColor = [UIColor whiteColor];
        [_imageView addSubview:_tipsLabel];
        _tipsLabel.text = @"好可惜";
        _tipsLabel.hidden = YES;
        
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.font = [UIFont systemFontOfSize:11];
        _messageLabel.textColor = [UIColor whiteColor];
        [_imageView addSubview:_messageLabel];
    }
    
    return self;
}


-(void)updateUI{
    
    UIImage *image = nil;
    
    factorFloat = self.width/375.0;
    
    if (self.type == kSuccessAlterType || self.type == kLastSuccessAlterType) {
        
        image = [UIImage imageNamed:@"winnerAlter"];
    }
    else if(self.type == kFailAlterType){
        
        image = [UIImage imageNamed:@"alter"];
    }
    else{
        
        image = [UIImage imageNamed:@"lotteryAlter"];
    }
    
    _imageView.image = image;
    _imageView.width = image.size.width * factorFloat;
    _imageView.height = image.size.height * factorFloat;
    
    NSLog(@"%f ::::: %f",image.size.width, factorFloat);
    
    _titleLabel.frame = CGRectMake(0, 255 * factorFloat, _imageView.width, jTitleHeight);
    
    if (self.type == kFailAlterType) {
        
        _tipsLabel.frame = CGRectMake(0, 225 * factorFloat, _imageView.width, jTitleHeight);
        _titleLabel.frame = CGRectMake(0, 275 * factorFloat, _imageView.width, jTitleHeight);
        _tipsLabel.hidden = NO;
    }
    else if (self.type == kLotteryDrawAlterType){

        _messageLabel.hidden = YES;
        _tipsLabel.text = @"恭喜您获得";

        _tipsLabel.frame = CGRectMake(0, 235*factorFloat, _imageView.width, jTitleHeight);
        _titleLabel.frame = CGRectMake(0, 285 * factorFloat, _imageView.width, jTitleHeight);
        _tipsLabel.hidden = NO;
    }
    
    UIButton *button = nil;
    UIImage *imageBtn = nil;
    for (NSInteger i = 0; i < self.buttonsArray.count; i++) {
        
        imageBtn  = [UIImage imageNamed:@"shortBtn"];
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
         button.frame = CGRectMake(15 + i*(_imageView.width - imageBtn.size.width*factorFloat*5/6 - 35), _imageView.height - 50*factorFloat - 35, imageBtn.size.width*factorFloat*5/6, imageBtn.size.height*factorFloat*5/6);
        
        if (self.type == kFailAlterType) {
            
            imageBtn = [UIImage imageNamed:@"longBtn"];
             button.frame = CGRectMake((_imageView.width - imageBtn.size.width*factorFloat*5/6)/2, _imageView.height - 50*factorFloat - 30, imageBtn.size.width*factorFloat*5/6, imageBtn.size.height*factorFloat*5/6);
        }
        else if (self.type == kLastSuccessAlterType)
        {
            imageBtn = [UIImage imageNamed:@"longBtn"];
            button.frame = CGRectMake((_imageView.width - imageBtn.size.width*factorFloat*5/6)/2, _imageView.height - 50*factorFloat - 35, imageBtn.size.width*factorFloat*5/6, imageBtn.size.height*factorFloat*5/6);
        }
        else if (self.type == kLotteryDrawAlterType){
            
            imageBtn = [UIImage imageNamed:@"longBtn"];
            button.frame = CGRectMake((_imageView.width - imageBtn.size.width*factorFloat*5/7)/2, _titleLabel.originY + _titleLabel.height + 15, imageBtn.size.width*factorFloat*5/7, imageBtn.size.height*factorFloat*5/7);
        }
        
        button.tag = i;
        [button setTitle:self.buttonsArray[i] forState:UIControlStateNormal];
        [button setBackgroundImage:imageBtn forState:UIControlStateNormal];
        [button addTarget:self action:@selector(dismissBtn:) forControlEvents:UIControlEventTouchUpInside];
        [button setTitleColor:[UIColor colorWithHexString:@"#db5f07"] forState:UIControlStateNormal];
        [_imageView addSubview:button];
        _imageView.userInteractionEnabled = YES;
    }
    
    if (self.type == kLotteryDrawAlterType) {
        
        _imageView.height = button.originY + button.height + 15;

    }
    else {
        
        _messageLabel.frame = CGRectMake(0, button.originY + button.height + 10, _imageView.width, 20);
        _imageView.height = _messageLabel.originY + _messageLabel.height + 15;
    }
    
    _imageView.center = self.center;

}

-(instancetype)initwithTitle:(NSString *)title
                 buttonArray:(NSArray *)btnArray
               alterViewType:(SuccessAlterViewType)type
                dismissBlock:(JYSuccessAlterViewBlock)dismissBlock
{
    if ([self init]) {
        
        self.alterViewBlock = dismissBlock;
        self.titleLabel.text = title;
        _messageLabel.text = @"注意：奖品以最后一次抽奖结果为准！！！";
        self.buttonsArray = btnArray;
        self.type = type;
        [self updateUI];
    }
    
    return self;
}


-(void)show
{
    POPBasicAnimation *opacityAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    opacityAnimation.fromValue = @(0);

    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.springBounciness = 20;
    scaleAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.1, 0.1)];
    
    [self.imageView.layer pop_addAnimation:opacityAnimation forKey:@"opacityAnimation"];
    [self.imageView.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
}

-(void)dismissBtn:(UIButton *)sender{
    
    __weak typeof(self) weakSelf = self;
    
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.springBounciness = 10;
    scaleAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(0.6, 0.8)];
    
    POPBasicAnimation *offscreenAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    offscreenAnimation.toValue = @(1.5*self.height);
    [offscreenAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        
        [weakSelf removeFromSuperview];
        weakSelf.alterViewBlock(sender.tag);

    }];
    
    [self.imageView.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    [self.imageView.layer pop_addAnimation:offscreenAnimation forKey:@"offscreenAnimation"];
    
}

@end
