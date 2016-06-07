//
//  JYShakeViewController.m
//  摇一摇
//
//  Created by 俊王 on 16/3/25.
//  Copyright © 2016年 nacker. All rights reserved.
//

#import "JYShakeViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "JYShakeAlterView.h"
#import "JYSuccessAlterView.h"
#import "JYExchangeDetailViewController.h"
#import "BKCustomProgressHUD.h"

@interface JYShakeViewController ()<UIAlertViewDelegate>
{
    NSInteger surplusTime;
}

@property (weak, nonatomic) IBOutlet UIView *upView;

@property (weak, nonatomic) IBOutlet UIView *downView;

@property (weak, nonatomic) IBOutlet UIView *backView;

@property (weak, nonatomic) IBOutlet UILabel *typeTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *typeAccountLabel;

@property (weak, nonatomic) IBOutlet UILabel *remainTimes;

@property (nonatomic, assign) BOOL shaked;

@property (nonatomic, strong) UIActivityIndicatorView *actView;

@end

@implementation JYShakeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shaked = YES;
    
    [[UIApplication sharedApplication] setApplicationSupportsShakeToEdit:YES];
    [self becomeFirstResponder];
    
    self.navigationBarHidden = YES;
    
    self.actView = [ [ UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0,30.0,30.0)];
    self.actView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    self.actView.hidesWhenStopped = NO;
    [self.view addSubview:self.actView];

    self.actView.hidden = YES;
}

//ViewController 加入以下两方法
-(BOOL)canBecomeFirstResponder
{
    //让当前controller可以成为firstResponder，这很重要
    return YES;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //停止加速仪更新（很重要！）
    [self resignFirstResponder];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self updateUI];
}

-(void)updateUI{
    
    NSArray *titleArray = @[@"稳定型",@"激进型"];
    self.actView.center = self.view.center;
    self.actView.originY = self.downView.y - 10;

    NSArray *accountArray = @[[NSString stringWithFormat:@"(%@)易积分",self.shakeModel.wjRange],[NSString stringWithFormat:@"(%@)易积分",self.shakeModel.jjRange]];
    self.remainTimes.text = [NSString stringWithFormat:@"剩余%@次机会",self.shakeModel.epointLotteryNumber];
    
    if (NSString_ISNULL(self.shakeModel.drawType)) {
        
        JYShakeAlterView *alterView = [[JYShakeAlterView alloc] initwithTypeArray:titleArray
                                                                     dismissBlock:^(NSInteger count) {
                                                                         
                                                                         NSLog(@"%ld",(long)count);
                                                                         
                                                                         if (count == 0) {
                                                                             
                                                                             self.typeTitleLabel.text = [NSString stringWithFormat:@"·%@·",titleArray[0]];
                                                                             self.typeAccountLabel.text = accountArray[0];
                                                                             self.shakeModel.drawType = @"0";
                                                                         }
                                                                         else{
                                                                             
                                                                             self.typeTitleLabel.text = [NSString stringWithFormat:@"·%@·",titleArray[1]];
                                                                             self.typeAccountLabel.text = accountArray[1];
                                                                             self.shakeModel.drawType = @"1";
                                                                         }
                                                                     }];
        
        alterView.messageLabel.text =[NSString stringWithFormat:@"抽奖次数：3次机会，以最后一次抽奖的奖励为准\n\n抽奖风格：参加抽奖前可以根据自己的风格选择\n(备注：稳定型选手的奖励是 %@易积分；激进型选手的奖励是 %@易积分）",self.shakeModel.wjRange,self.shakeModel.jjRange];
        [alterView show];
    }
    else{
        
        self.typeTitleLabel.text = [NSString stringWithFormat:@"·%@·",titleArray[[self.shakeModel.drawType integerValue]]];
        self.typeAccountLabel.text = accountArray[[self.shakeModel.drawType integerValue]];
    }
}

#pragma mark - 摇一摇动画效果
- (void)addAnimations
{
    [LZAudioTool playMusic:@"shakeMusic.mp3"];

    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.upView.y = self.upView.y - self.backView.height/2;

    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.35f delay:0.35 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.upView.y = self.upView.y + self.backView.height/2;
            
        } completion:nil];
    }];
    
    [UIView animateWithDuration:0.5f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.downView.y = self.downView.y + self.backView.height/2;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.35f delay:0.35f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.downView.y = self.downView.y - self.backView.height/2;

        } completion:^(BOOL finished){
        
            self.actView.hidden = NO;
            [self.actView startAnimating];
            
        }];
    }];
}

#pragma orgin
-(void)creatImformation{
    
    __weak JYShakeViewController *weakself = self;
    
    if (NSString_ISNULL(self.shakeModel.drawType)) {
        
        self.shakeModel.drawType = @"0";
    }
    
    NSDictionary *params = @{@"drawType":self.shakeModel.drawType};
    
    [[BKRequestProxy sharedInstance] requestWithType:BKRequestTypeGET
                                           urlString:@"/activity/epointDraw"
                                              params:params
                                                part:nil
                                             success:^(BKRequestModel *request, BKResponseModel *response) {
                                                 
                                                 if ([response.responseObject isKindOfClass:[NSDictionary class]] && [JYSuccessCode isEqualToString:response.head.code]) {
                                                     NSLog(@"%@",response.responseObject);
                                                     
                                                     weakself.shakeModel.prizeEpoint = [response.responseObject[@"prizeEpoint"] integerValue];
                                                     weakself.shakeModel.epointLotteryNumber = response.responseObject[@"lotteryNumber"];
                                                     
                                                     [weakself showWinner];
                                                 }
                                                 else{
                                                     
                                                     [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:response.head.msg];
                                                 }
                                                 
                                             }
                                             failure:^(BKRequestModel *request, NSError *error) {
                                                 
                                                 [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"网络状态不佳，请稍后再试试哦!"];
                                             }];
    
}

-(void)showWinner{
    
    [self.actView stopAnimating];
    self.actView.hidden = YES;
    
    __weak typeof(self) weakself = self;
    
    [LZAudioTool playMusic:@"shakeResult.mp3"];

    self.remainTimes.text = [NSString stringWithFormat:@"剩余%@次机会",self.shakeModel.epointLotteryNumber];

    if (self.shakeModel.prizeEpoint > 0 && [self.shakeModel.epointLotteryNumber integerValue] > 0) {
        
        JYSuccessAlterView *alterView = [[JYSuccessAlterView alloc] initwithTitle:[NSString stringWithFormat:@"%ld易积分",(long)self.shakeModel.prizeEpoint]
                                                                      buttonArray:@[@"继续抽奖",@"领取奖品"]
                                                                    alterViewType:kSuccessAlterType
                                                                     dismissBlock:^(NSInteger count) {
                                                                         NSLog(@"%ld",(long)count);
                                                                         if (count == 0) {

                                                                             weakself.shaked = YES;
                                                                         }
                                                                         else{
                                                                         
                                                                             [weakself getWinnerData];
                                                                         }
                                                                    }];
        
        [alterView show];
    }
    else if([self.shakeModel.epointLotteryNumber integerValue] == 0){
        
        NSString *title = @"就差一点";

        if (self.shakeModel.prizeEpoint > 0) {
            
            title = [NSString stringWithFormat:@"%ld易积分",(long)self.shakeModel.prizeEpoint];
            JYSuccessAlterView *alterView = [[JYSuccessAlterView alloc] initwithTitle:title
                                                                          buttonArray:@[@"领取奖品"]
                                                                        alterViewType:kLastSuccessAlterType
                                                                         dismissBlock:^(NSInteger count) {
                                                                             
                                                                             NSLog(@"%ld",(long)count);
                                                                             if (count == 0) {
                                                                                 
                                                                                 [weakself getWinnerData];
                                                                             }
                                                                             
                                                                         }];
            
            [alterView show];

        }
        else{
            
            JYSuccessAlterView *alterView = [[JYSuccessAlterView alloc] initwithTitle:title
                                                                          buttonArray:@[@"机会已用完"]
                                                                        alterViewType:kFailAlterType
                                                                         dismissBlock:^(NSInteger count) {
                                                                           
                                                                             
                                                                         }];
            
            [alterView show];
        }

    }
    else{
    
        JYSuccessAlterView *alterView = [[JYSuccessAlterView alloc] initwithTitle:@"就差一点"
                                                                      buttonArray:@[@"再来一次"]
                                                                    alterViewType:kFailAlterType
                                                                     dismissBlock:^(NSInteger count) {
                                                                         NSLog(@"%ld",(long)count);
                                                                         if (count == 0) {
                                                                             
                                                                             weakself.shaked = YES;
                                                                         }
                                                                     }];
        
        [alterView show];

    }
}

#pragma mark
#pragma mark 领取奖品

-(void)getWinnerData{
    
    __weak typeof(self) weakself = self;

    [[BKRequestProxy sharedInstance] requestWithType:BKRequestTypeGET
                                           urlString:@"/activity/epointDrawResult"
                                              params:nil
                                                part:nil
                                             success:^(BKRequestModel *request, BKResponseModel *response) {
                                                 
                                                 if ([response.responseObject isKindOfClass:[NSDictionary class]] && [JYSuccessCode isEqualToString:response.head.code]) {
                                                     
                                                     [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:[NSString stringWithFormat:@"领取%ld易积分成功",(long)self.shakeModel.prizeEpoint]];
                                                     [weakself performSelector:@selector(goExchangDetailController) withObject:nil afterDelay:3.0];
                                                 }
                                             }
                                             failure:^(BKRequestModel *request, NSError *error) {
                                                 
                                                 [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"网络状态不佳，请稍后再试试哦!"];
                                             }];
}

-(void)goExchangDetailController{
    
    JYExchangeDetailViewController *exchangeVC = [[JYExchangeDetailViewController alloc] initWithNibName:@"JYExchangeDetailViewController" bundle:nil];
    [self.navigationController pushViewController:exchangeVC animated:YES];
}

#pragma mark - 实现相应的响应者方法
/** 开始摇一摇 */
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    NSLog(@"motionBegan");
    if (event.subtype == UIEventSubtypeMotionShake) {
        
        if (self.shaked) {
            
            [self addAnimations];
        }
    }
}

/** 摇一摇结束（需要在这里处理结束后的代码） */
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (event.subtype == UIEventSubtypeMotionShake) {
        
        if (self.shaked) {
            
            self.shaked = NO;
            if ([self.shakeModel.epointHadWin boolValue]) {
                
                [self performSelector:@selector(showHadWinAlterView) withObject:nil afterDelay:1.5f];

            }
            else{
                
                [self performSelector:@selector(creatImformation) withObject:nil afterDelay:1.5f];
            }
        }
        
        NSLog(@"ended");
    }
}

-(void)showHadWinAlterView{
    
    [self.actView stopAnimating];
    self.actView.hidden = YES;
    
    [LZAudioTool playMusic:@"shakeResult.mp3"];

    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"您已领取奖品，请到积分详情查看"
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"好的", nil];
    [alterView show];

}

/** 摇一摇取消（被中断，比如突然来电） */
- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    
    if (event.subtype == UIEventSubtypeMotionShake) {
        
        if (self.shaked) {
            
            self.shaked = NO;
            if ([self.shakeModel.epointHadWin boolValue]) {
                
                [self performSelector:@selector(showHadWinAlterView) withObject:nil afterDelay:1.5f];
                
            }
            else{
                
                [self performSelector:@selector(creatImformation) withObject:nil afterDelay:1.5f];
            }
        }
        
        NSLog(@"ended");
    }
    
    NSLog(@"motionCancelled");
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.shaked = YES;
}

@end
