//
//  JYShakeAlterView.m
//  摇一摇
//
//  Created by 俊王 on 16/3/28.
//  Copyright © 2016年 nacker. All rights reserved.
//

#import "JYShakeAlterView.h"

@interface JYShakeAlterView()
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

@property (nonatomic, copy) JYShakeAlterViewBlock alterViewBlock;

@property (nonatomic, strong) UILabel *titleLabel;


@property (nonatomic, assign) CGSize size;

@property (nonatomic, strong) NSArray *buttonsArray;

@property (nonatomic, strong) UIView *btnBackgroundView;

@property (nonatomic, strong) NSMutableArray *imageArray;

@property (nonatomic, strong) UIButton *selectedBtn;

@end

@implementation JYShakeAlterView



-(JYShakeAlterView *)init
{
    self = [super init];
    
    if (self) {
        
        self.frame = [UIScreen mainScreen].bounds;
        
        factorFloat = self.width/320.0;
        
        jWindowWidth = self.width - (factorFloat * 50);
        
        NSLog(@"%f",jWindowWidth);
        
        jWindowHeight = 200.0f;
        jTitleHeight = 30;
        jTextHeight = 45.0f;
        jCircleHeight = 30.0f;
        
        _backgroundView = [[UIView alloc] initWithFrame:self.bounds];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0.6;
        [self addSubview:_backgroundView];
        
        _contentView = [[UIView alloc] init];
        _contentView.frame = CGRectMake(0.0f, 0, jWindowWidth, jWindowHeight);
        _contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_contentView];

        _btnBackgroundView = [[UIView alloc] init];
        _btnBackgroundView.frame = CGRectMake(0, 40, jWindowWidth, 150*factorFloat);
        _btnBackgroundView.backgroundColor = [UIColor colorWithHexString:@"#f5f5f9"];
        [_contentView addSubview:_btnBackgroundView];
        
        _contentView.layer.cornerRadius = 10.0f;
        _contentView.layer.masksToBounds = YES;
        
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithHexString:@"#919191"];
        [_contentView addSubview:_titleLabel];
        
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:11];
        _messageLabel.numberOfLines = 0;
        _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _messageLabel.textColor = [UIColor colorWithHexString:@"#919191"];
        [_contentView addSubview:_messageLabel];
        _contentView.center = _backgroundView.center;
        
        _selectedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *btnImage = [UIImage imageNamed:@"sureBtn"];
        [_selectedBtn setImage:btnImage forState:UIControlStateNormal];
        _selectedBtn.frame = CGRectMake((_contentView.width - btnImage.size.width)/2, 0, btnImage.size.width, btnImage.size.height);
        [_selectedBtn addTarget:self action:@selector(dismissBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:_selectedBtn];
        
        self.imageArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        self.selectedBtn.enabled = NO;
        
    }
    
    return self;
}

-(void)updateUI{
    
    _titleLabel.frame = CGRectMake(0, 5, _contentView.width, jTitleHeight);
    
    NSArray *imageArray = @[@"stability",@"accelerate"];
    NSArray *titleArray = @[@"稳定型\n^奖(200-500易积分)",@"激进型\n^奖(0-1200易积分)"];
    UIButton *button = nil;
    CGFloat imageWidth = 90*factorFloat;
    UILabel *label = nil;
    for (NSInteger i = 0; i< self.buttonsArray.count; i++) {
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(30 + i*(130*factorFloat), 15 * factorFloat,imageWidth, imageWidth)];
        imageView.image = [UIImage imageNamed:@"cornerBtn"];
        imageView.userInteractionEnabled = YES;
        [_btnBackgroundView addSubview:imageView];
        [self.imageArray addObject:imageView];
        
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, imageWidth, imageWidth);
        button.tag = i;
        [button setImage:[UIImage imageNamed:imageArray[i]] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [imageView addSubview:button];
        
        label = [[UILabel alloc] initWithFrame:CGRectMake(imageView.originX, imageView.originY + imageView.height, 95*factorFloat, 60)];
        label.font = [UIFont systemFontOfSize:16];
        label.attributedText = [NSString setAttributedStringWith:titleArray[i]
                                                     andTextFont:[UIFont systemFontOfSize:10]
                                                    andTextColor:[UIColor colorWithHexString:@"0x838383"]];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.textAlignment = NSTextAlignmentCenter;
        [_btnBackgroundView addSubview:label];
    }
    
    _btnBackgroundView.height = label.originY + label.height;

    _messageLabel.frame = CGRectMake(15, _titleLabel.originY + _btnBackgroundView.originY + _btnBackgroundView.height + 5, _titleLabel.width - 30, jTitleHeight);
    _size = [_messageLabel.text boundingRectWithSize:CGSizeMake(_messageLabel.width, 1000) withFont:_messageLabel.font];
    _messageLabel.height = _size.height;
    
    _selectedBtn.originY = _messageLabel.originY + 15 + _messageLabel.height;
    _contentView.height = _selectedBtn.originY + 15 + _selectedBtn.height;
    _contentView.center = self.center;
}


-(instancetype)initwithTypeArray:(NSArray *)array dismissBlock:(JYShakeAlterViewBlock)dismissBlock
{
    if ([self init]) {
        
        self.alterViewBlock = dismissBlock;
        self.titleLabel.text = @"请选择自己的类型";
        self.messageLabel.text = @"抽奖次数：3次机会，以最后一次抽奖的奖励为准\n\n抽奖风格：参加抽奖前可以根据自己的风格选择\n(备注：稳定型选手的奖励是 200-400易积分；激进型选手的奖励是 0-1200易积分）";
        self.buttonsArray = array;
        
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
    positionAnimation.springBounciness = 20;
    [positionAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        
    }];
    
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.springBounciness = 20;
    scaleAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(1.6, 1.8)];
    
    [self.contentView.layer pop_addAnimation:positionAnimation forKey:@"positionAnimation"];
    [self.contentView.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
    [self.contentView.layer pop_addAnimation:offscreenAnimation forKey:@"offscreenAnimation"];

    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
}

-(void)buttonClick:(UIButton *)sender
{
    self.selectedBtn.enabled = YES;
    for (UIImageView *imageView in self.imageArray) {
        imageView.image = [UIImage imageNamed:@"cornerBtn"];
    }
    
    UIImageView *imageView = (UIImageView *)self.imageArray[sender.tag];
    imageView.image = [UIImage imageNamed:@"yellowCornerBtn"];
    count = sender.tag;
}


-(void)dismissBtn:(UIButton *)sender{
    
    self.alterViewBlock(count);

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


