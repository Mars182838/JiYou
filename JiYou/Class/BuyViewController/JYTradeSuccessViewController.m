//
//  JYTradeSuccessViewController.m
//  JiYou
//
//  Created by 俊王 on 15/8/21.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYTradeSuccessViewController.h"
#import "JYQRcodeViewController.h"

@interface JYTradeSuccessViewController ()

@property (weak, nonatomic) IBOutlet UILabel *integralLabel;//积分

@property (weak, nonatomic) IBOutlet UIButton *finishButton;

- (IBAction)finishButtonAction:(id)sender;

@end

@implementation JYTradeSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navTitle = @"兑换结果";
    self.leftImage = nil;
    
    [self.finishButton setBackgroundImage:[UIImage stretchableImageNamed:@"button" edgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
    
    self.integralLabel.text = [NSString stringWithFormat:@"花费易积分 %@",self.commitModel.point];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (IBAction)finishButtonAction:(id)sender {
    
    [self popToViewController:[JYQRcodeViewController class]];
}

-(void)dealloc
{
    DLog(@"delate");
}

@end
