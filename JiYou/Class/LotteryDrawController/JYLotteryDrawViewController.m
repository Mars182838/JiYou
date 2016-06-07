//
//  JYLotteryDrawViewController.m
//  JiYou
//
//  Created by 俊王 on 16/4/7.
//  Copyright © 2016年 JY. All rights reserved.
//

#import "JYLotteryDrawViewController.h"
#import "JYSuccessAlterView.h"
#import "BKCustomProgressHUD.h"
#import "JYAwardViewController.h"

@interface JYLotteryDrawViewController ()<UIAlertViewDelegate>
{
    NSString *strPrise;
    NSInteger angle;
}

@property (weak, nonatomic) IBOutlet UIImageView *lotteryHeaderImage;
@property (weak, nonatomic) IBOutlet UIImageView *lotteryDrawPoint;
@property (weak, nonatomic) IBOutlet UIButton *lotterBtn;
@property (weak, nonatomic) IBOutlet UIImageView *lotteryDrawFooter;
@property (weak, nonatomic) IBOutlet UIView *lotteryView;
@property (weak, nonatomic) IBOutlet UIButton *lotterBackBtn;

- (IBAction)lotteryBtnAction:(id)sender;

@end

@implementation JYLotteryDrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationBarHidden = YES;
    
    CGFloat factorFloat = kScreenWidth/320.0;
    CGFloat lotteryHeaderHeight = factorFloat * 86;
    CGFloat lotteryHeaderWidth = factorFloat * 300;
    
    self.lotteryHeaderImage.frame = CGRectMake((kScreenWidth - lotteryHeaderWidth)/2, self.lotteryHeaderImage.originY + 20, lotteryHeaderWidth, lotteryHeaderHeight);
    
    if (IS_IPHONE6) {
        
        self.lotteryDrawFooter.originY = self.lotteryView.originY + self.lotteryView.height - 38*factorFloat;
        
    }
    else if (IS_IPHONE6_PLUS){
        
        self.lotteryDrawFooter.originY = self.lotteryView.originY + self.lotteryView.height - 46*factorFloat;
    }
    
    
    if ([[self.model drawHadWin] boolValue]) {
        
        [_lotterBtn setTitle:@"已中奖" forState:UIControlStateNormal];
        _lotterBtn.enabled = NO;
        _lotterBackBtn.enabled = NO;
        
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark
#pragma mark start lotteryDraw

- (IBAction)lotteryBtnAction:(id)sender {
    
    [LZAudioTool playMusic:@"lotteryDraw.mp3"];

    [_lotterBtn setTitle:@"抽奖中" forState:UIControlStateNormal];
    _lotterBtn.enabled = NO;
    _lotterBackBtn.enabled = NO;

    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:12*M_PI];
    rotationAnimation.duration = 2.5f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.delegate = self;
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.removedOnCompletion = NO;
    [self.lotteryDrawPoint.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    [self performSelector:@selector(showWinner) withObject:self afterDelay:2.3f];
}

-(void)showWinner{
    
    __weak typeof(self) weakself = self;
    
    [[BKRequestProxy sharedInstance] requestWithType:BKRequestTypeGET
                                           urlString:@"/activity/luckyDraw"
                                              params:nil
                                                part:nil
                                             success:^(BKRequestModel *request, BKResponseModel *response) {

                                                 NSLog(@"%@",response.head.code);

                                                 if ([response.responseObject isKindOfClass:[NSDictionary class]] && [JYSuccessCode isEqualToString:response.head.code]) {
                                                     NSLog(@"%@",response.responseObject);
                                                     
                                                     if ([[response.responseObject objectForKey:@"hadWin"] boolValue]) {
                                                         
                                                         angle = 210;
                                                         weakself.model.drawHadWin = [response.responseObject objectForKey:@"hadWin"];
                                                         [weakself animationDidFinished];
                                                     }
                                                 }
                                                 else{
                                                     
                                                     angle = 270;
                                                     [weakself animationDidFinished];
                                                 }
                                             }
                                             failure:^(BKRequestModel *request, NSError *error) {
                                                 
                                                 angle = 270;
                                                 [weakself animationDidFinished];
                                             }];
    
}

-(void)animationDidFinished{
    
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat:angle*M_PI/180];
    rotationAnimation.duration = 2.5f;
    rotationAnimation.cumulative = YES;
    rotationAnimation.fillMode = kCAFillModeForwards;
    rotationAnimation.removedOnCompletion = NO;
    [_lotteryDrawPoint.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
    
    [_lotterBtn setTitle:@"已抽奖" forState:UIControlStateNormal];
    _lotterBtn.enabled = NO;

    if ([self.model.drawHadWin boolValue]) {
        [self performSelector:@selector(successView) withObject:self afterDelay:3.f];
    }
}


-(void)successView{

    [_lotterBtn setTitle:@"已中奖" forState:UIControlStateNormal];
    
    __weak typeof(self) weakSelf = self;
    NSString *title = @"电影票一张";
    JYSuccessAlterView *alterView = [[JYSuccessAlterView alloc] initwithTitle:title
                                                                  buttonArray:@[@"领取电影票"]
                                                                alterViewType:kLotteryDrawAlterType
                                                                 dismissBlock:^(NSInteger count) {
                                                                     
                                                                     [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"领取成功"];
                                                                     [weakSelf performSelector:@selector(getMovieDataSource) withObject:self afterDelay:2.5f];
                                                                     
                                                                 }];
    [alterView show];

}

-(void)getMovieDataSource{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:JYOrderSuccess object:nil];
    
    JYAwardViewController *awardController = [[JYAwardViewController alloc] init];
    awardController.urlStirng = self.model.exchangeUrl;
    [self.navigationController pushViewController:awardController animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        JYAwardViewController *awardController = [[JYAwardViewController alloc] init];
        awardController.urlStirng = self.model.exchangeUrl;
        [self.navigationController pushViewController:awardController animated:YES];
    }
}

@end
