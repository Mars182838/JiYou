//
//  JYChooseViewController.m
//  JiYou
//
//  Created by 俊王 on 16/4/11.
//  Copyright © 2016年 JY. All rights reserved.
//

#import "JYChooseViewController.h"
#import "JYLotteryDrawViewController.h"
#import "JYShakeViewController.h"
#import "JYUserModel.h"
#import "JYAwardViewController.h"

@interface JYChooseViewController ()

@property (weak, nonatomic) IBOutlet UIButton *lotteryDrawBtn;

@property (weak, nonatomic) IBOutlet UIButton *shakeDrawBtn;

@property (weak, nonatomic) IBOutlet UIView *defaultView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topShakeConstraint;


- (IBAction)lotteryDrawClick:(id)sender;

- (IBAction)shakeDrawClick:(id)sender;

- (IBAction)myAwardClick:(id)sender;

@end

@implementation JYChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navTitle = @"福利专区";

    self.lotteryDrawBtn.layer.masksToBounds = YES;
    self.lotteryDrawBtn.layer.cornerRadius = 8.0f;
    
    self.shakeDrawBtn.layer.masksToBounds = YES;
    self.shakeDrawBtn.layer.cornerRadius = 8.0f;
    
    self.defaultView.layer.masksToBounds = YES;
    self.defaultView.layer.cornerRadius = 8.0f;

    if (![[JYUserModel shareInstance].workingStatus isEqualToString:@"00"] && ![[JYUserModel shareInstance].workingStatus isEqualToString:@"99"]) {
    
        self.lotteryDrawBtn.hidden = self.shakeDrawBtn.hidden = YES;
        
    }
    else{
        
        self.lotteryDrawBtn.hidden = !self.shakeModel.isLotteryDrawTime;
        self.shakeDrawBtn.hidden = !self.shakeModel.isEpoint;
        self.defaultView.hidden = YES;
    }
}


-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.shakeModel.isEpoint && !self.shakeModel.isLotteryDrawTime) {
        
        self.topShakeConstraint.constant = 85;
        [self.shakeDrawBtn needsUpdateConstraints];
        [self.shakeDrawBtn setNeedsLayout];
        
        self.shakeDrawBtn.originY = 85;
    }
    else if (!self.shakeModel.isLotteryDrawTime && !self.shakeModel.isEpoint){
        
        self.defaultView.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)lotteryDrawClick:(id)sender {

    JYLotteryDrawViewController *lotteryDarw = [[JYLotteryDrawViewController alloc] init];
    lotteryDarw.model = self.shakeModel;
    [self.navigationController pushViewController:lotteryDarw animated:YES];

}

- (IBAction)shakeDrawClick:(id)sender {
    
    JYShakeViewController *shakeDarw = [[JYShakeViewController alloc] init];
    shakeDarw.shakeModel = self.shakeModel;
    [self.navigationController pushViewController:shakeDarw animated:YES];
}

- (IBAction)myAwardClick:(id)sender {
    
    JYAwardViewController *awardController = [[JYAwardViewController alloc] init];
    awardController.urlStirng = self.shakeModel.exchangeUrl;
    [self.navigationController pushViewController:awardController animated:YES];
}

@end
