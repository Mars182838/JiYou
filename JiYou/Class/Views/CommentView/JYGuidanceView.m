//
//  JYGuidanceView.m
//  JiYou
//
//  Created by 俊王 on 15/9/9.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYGuidanceView.h"

@implementation JYGuidanceView

static JYGuidanceView *customView;

+(instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        customView = [[JYGuidanceView alloc] init];
        
    });
    
    return customView;
}

-(JYGuidanceView *)initWithFrame:(CGRect)frame andWithString:(NSString *)name
{
    customView.frame = frame;
    
    UIView *bgView = [[UIView alloc] initWithFrame:self.frame];
    bgView.backgroundColor = [UIColor blackColor];
    bgView.alpha = 0.4;
    [customView addSubview:bgView];
    
    if (!self.imageView) {
    
        self.image = [UIImage imageNamed:@"card_tip.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((frame.size.width - _image.size.width)/2, -_image.size.height - 200, _image.size.width, _image.size.height)];
        imageView.image = _image;
        
        UIImage *btnImage = [UIImage imageNamed:@"close.png"];
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn addTarget:self action:@selector(dismissClick:) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn setImage:btnImage forState:UIControlStateNormal];
        rightBtn.frame = CGRectMake(imageView.width - 44, 5, 44, 44);
        [imageView addSubview:rightBtn];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, imageView.width-20, 50)];
        label.text = @"Hi";
        label.font = [UIFont fontWithName:@"Heiti SC" size:50];
        label.numberOfLines = 0;
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        [imageView addSubview:label];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, label.originY + label.height + 5, imageView.width-20, 30)];
        nameLabel.text = name;
        nameLabel.font = [UIFont fontWithName:@"Heiti SC" size:24];
        NSLog(@"%@",name);
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        [imageView addSubview:nameLabel];
        
        UILabel *tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, nameLabel.originY + nameLabel.height + 20, imageView.width-20, 0)];
        tipsLabel.text = @"欢迎您使用积友\n您的鼓励，我们前进的动力";
        tipsLabel.numberOfLines = 0;
        tipsLabel.textColor = [UIColor whiteColor];
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:tipsLabel.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyle setLineSpacing:5];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, tipsLabel.text.length)];
        
        tipsLabel.attributedText = attributedString;
        
        //调节高度
        CGSize size = CGSizeMake(tipsLabel.width, 5000);
        CGSize labelSize = [tipsLabel sizeThatFits:size];
        tipsLabel.textAlignment = NSTextAlignmentCenter;
        tipsLabel.height = labelSize.height;
        [imageView addSubview:tipsLabel];
        
        UIButton *clickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [clickBtn setTitle:@"立即体验" forState:UIControlStateNormal];
        [clickBtn addTarget:self action:@selector(dismissClick:) forControlEvents:UIControlEventTouchUpInside];
        [clickBtn setBackgroundImage:[UIImage stretchableImageNamed:@"btn_card" edgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
        clickBtn.frame = CGRectMake(35, imageView.height - 70, imageView.width - 70, 45);
        [imageView addSubview:clickBtn];
        
        self.imageView = imageView;
        self.imageView.userInteractionEnabled = YES;
    }

    [customView addSubview:self.imageView];
    [self startAnimation];

    return customView;
}

-(void)startAnimation{
    
    
    POPSpringAnimation *positionAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    positionAnimation.toValue = @(self.center.y);
    positionAnimation.springBounciness = 10;
    [positionAnimation setCompletionBlock:^(POPAnimation *anim, BOOL finished) {

    }];
    
    POPSpringAnimation *scaleAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleAnimation.springBounciness = 20;
    scaleAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake(1.2, 1.4)];
    
//    POPBasicAnimation *opacityAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
//    opacityAnimation.toValue = @(0.8);
    
    [self.imageView.layer pop_addAnimation:positionAnimation forKey:@"positionAnimation"];
    [self.imageView.layer pop_addAnimation:scaleAnimation forKey:@"scaleAnimation"];
//    [self.imageView.layer pop_addAnimation:opacityAnimation forKey:@"opacityAnimation"];

}

-(void)dismissClick:(id)sender
{
    if (_dismissBlock) {
        
        self.dismissBlock();
    }
}

@end
