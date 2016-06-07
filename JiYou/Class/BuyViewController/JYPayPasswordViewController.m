//
//  JYPayPasswordViewController.m
//  JiYou
//
//  Created by 俊王 on 15/8/31.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYPayPasswordViewController.h"
#import "JYForgetPasswordViewController.h"
#import "UIGestureRecognizer+BlocksKit.h"
#import "JYBaseViewController+ExtraEvent.h"
#import "JYForgetPasswordViewController.h"
#import "BKCustomProgressHUD.h"
#import "JYTradeSuccessViewController.h"
#import "MD5.h"
#import "JYQRcodeViewController.h"

@interface JYPayPasswordViewController ()<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *verfiyBtn;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;

@property (nonatomic, strong) UIAlertView *passwordAlterView;

- (IBAction)verifyButtonClick:(id)sender;

- (IBAction)forgetButtonClick:(id)sender;

@end

@implementation JYPayPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navTitle = @"兑换详情";
    
    [self.verfiyBtn setBackgroundImage:[UIImage stretchableImageNamed:@"button" edgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
    [self.verfiyBtn setBackgroundImage:[UIImage stretchableImageNamed:@"button_disable" edgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateDisabled];
    
    self.verfiyBtn.enabled = NO;
    
    [self.contentImageView setImage:[UIImage stretchableImageNamed:@"text_tiny" edgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)]];
    
    __weak UIViewController* weakself = self;
    UITapGestureRecognizer* tap = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        
        [weakself.view endEditing:YES];
    }];
    [self.view addGestureRecognizer:tap];
    
    [self.passwordTextField becomeFirstResponder];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getNotification:) name:@"isTrade" object:nil];
    
}

-(void)getNotification:(NSNotification *)notification{

    self.passwordTextField.text = @"";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addTextFieldTextDidChangeNotfication];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self removeTextFieldTextDidChangeNotfication];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)textFieldTextDidChange:(NSNotification *)notification
{
    UITextField *textField = notification.object;
    if (textField == self.passwordTextField) {
    
        self.passwordTextField.text = textField.text;
    }
    
    self.verfiyBtn.enabled = [self isValid];
}

-(BOOL)isValid
{
    if (NSString_ISNULL(self.passwordTextField.text)) {
    
        return NO;
    }
    else{
        
        return YES;
    }
}


- (IBAction)verifyButtonClick:(id)sender {
    
    [self.view endEditing:YES];
    
    self.commitModel.password = [MD5 md5:self.passwordTextField.text];
    
    self.verfiyBtn.enabled = NO;
    
    [[BKCustomProgressHUD sharedCustomProgressHUD] showHUDWithView:self.view andString:@"支付确认中..."];
    
    NSDictionary *params = @{@"buyNum":self.commitModel.buyNum,
                             @"qrString":self.commitModel.urlString,
                             @"point":self.commitModel.point,
                             @"pwd":self.commitModel.password};
    
    [[BKRequestProxy sharedInstance] requestWithType:BKRequestTypePOST
                                           urlString:@"/ubox/order"
                                              params:params
                                                part:nil
                                             success:^(BKRequestModel *request, BKResponseModel *response) {
                                                 
                                                 NSLog(@"--------%@", response);
                                                 
                                                 /**
                                                  *  "2001":积分余额不足
                                                  *  "2002":积分扣减结果未知
                                                  *  "2003":积分扣减失败
                                                  */
                                                 
                                                 if ([JYSuccessCode isEqualToString:response.head.code]) {
                                                     
                                                     [[BKCustomProgressHUD sharedCustomProgressHUD] hiddenViewFast];

                                                     [[NSNotificationCenter defaultCenter] postNotificationName:JYOrderSuccess object:nil];
                                                     
                                                     JYTradeSuccessViewController *tradeSuccessVC = [[JYTradeSuccessViewController alloc] init];
                                                     tradeSuccessVC.commitModel = self.commitModel;
                                                     [self.navigationController pushViewController:tradeSuccessVC animated:YES];
                                                 }
                                                 else if ([@"2002" isEqualToString:response.head.code]){
                                                     
                                                     //jyConfirm
                                                     NSString* orderId = response.responseObject[@"orderId"];
                                                     dispatch_time_t delayInNanoSeconds = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
                                                     dispatch_after(delayInNanoSeconds, dispatch_get_main_queue(), ^(void){
                                                         [self checkOrderStatusWithOrderId:orderId times:1];
                                                     });
                                                 }
                                                 else if([@"2003" isEqualToString:response.head.code]){
                                                  
                                                     [[BKCustomProgressHUD sharedCustomProgressHUD] hiddenViewFast];
                                                     
                                                     UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:nil
                                                                                                         message:@"交易失败，请您稍后再试。"
                                                                                                        delegate:self
                                                                                               cancelButtonTitle:nil
                                                                                               otherButtonTitles:@"我知道了", nil];
                                                     [alterView show];

                                                 }
                                                 else if ([@"2004" isEqualToString:response.head.code]){
                                                 
                                                     [[BKCustomProgressHUD sharedCustomProgressHUD] hiddenViewFast];
                                                     
                                                     self.passwordAlterView = [[UIAlertView alloc] initWithTitle:nil message:response.head.msg
                                                                                                        delegate:self
                                                                                               cancelButtonTitle:@"重新输入"
                                                                                               otherButtonTitles:@"忘记密码", nil];
                                                     [self.passwordAlterView show];
                                                 }
                                                 else if ([@"2006" isEqualToString:response.head.code]){
                                                     
                                                     [[BKCustomProgressHUD sharedCustomProgressHUD] hiddenViewFast];

                                                     UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:nil message:response.head.msg
                                                                                                        delegate:self
                                                                                               cancelButtonTitle:nil
                                                                                               otherButtonTitles:@"我知道了", nil];
                                                     [alterView show];
                                                 }
                                                 else{
                                                     
                                                     self.verfiyBtn.enabled = YES;

                                                     [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:response.head.msg];
                                                 }
                                                 
                                             }
                                             failure:^(BKRequestModel *request, NSError *error) {
                                                 
                                                 UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                                                message:@"正在出货中，请稍候。。。如10秒之内仍未出货，请咨询HR。"
                                                                                               delegate:self
                                                                                      cancelButtonTitle:@"我知道了"
                                                                                      otherButtonTitles:nil, nil];
                                                 [view show];
                                             }];
    

}

-(void)checkOrderStatusWithOrderId:(NSString *)orderId times:(NSUInteger) times{
    
    if (times<=10) {

        NSDictionary *params = @{@"orderId":orderId};
        
        [[BKRequestProxy sharedInstance] requestWithType:BKRequestTypePOST
                                               urlString:@"/ubox/getOrderStatus"
                                                  params:params
                                                    part:nil
                                                 success:^(BKRequestModel *request, BKResponseModel *response) {
                                                     
                                                     if ([response.responseObject isKindOfClass:[NSDictionary class]]) {
                                                         
                                                         NSLog(@"%@",response.responseObject[@"result"]);
                                                         
                                                         NSString *desc = response.responseObject[@"result"];
                                                         
                                                         if ([JYSuccessCode isEqualToString:response.head.code]) {
                                                             
                                                             if ([@"00" isEqualToString:desc]) {
                                                                 
                                                                 //继续轮询
                                                                 NSUInteger t = times+1;
                                                                 dispatch_time_t delayInNanoSeconds = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
                                                                 dispatch_after(delayInNanoSeconds, dispatch_get_main_queue(), ^(void){
                                                                     [self checkOrderStatusWithOrderId:orderId times:t];
                                                                 });
                                                             }
                                                             else if([@"01" isEqualToString:desc]){
                                                                 
                                                                 [[BKCustomProgressHUD sharedCustomProgressHUD] hiddenViewFast];
                                                                 [[NSNotificationCenter defaultCenter] postNotificationName:JYOrderSuccess object:nil];

                                                                 JYTradeSuccessViewController *tradeSuccessVC = [[JYTradeSuccessViewController alloc] init];
                                                                 tradeSuccessVC.commitModel = self.commitModel;
                                                                 [self.navigationController pushViewController:tradeSuccessVC animated:YES];
                                                             }
                                                             else{
                                                                 
                                                                 [[BKCustomProgressHUD sharedCustomProgressHUD] hiddenViewFast];
                                                                 
                                                                 UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                                                                     message:@"交易确认中，请您联系客服，我们会尽快为您解决问题。"
                                                                                                                    delegate:self
                                                                                                           cancelButtonTitle:nil
                                                                                                           otherButtonTitles:@"我知道了", nil];
                                                                 [alterView show];
                                                             }
                                                         }
                                                         
                                                     }
                                                     else{
                                                         
                                                         self.verfiyBtn.enabled = YES;

                                                         [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:response.head.msg];
                                                     }
                                                     
                                                 }
                                                 failure:^(BKRequestModel *request, NSError *error) {
                                                     
                                                     //继续轮询
                                                     NSUInteger t = times+1;
                                                     dispatch_time_t delayInNanoSeconds = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
                                                     dispatch_after(delayInNanoSeconds, dispatch_get_main_queue(), ^(void){
                                                         [self checkOrderStatusWithOrderId:orderId times:t];
                                                     });
                                                     
                                                 }];
        
    }
    else {
        
        /**
         *  轮询十秒还是失败
         */
        [[BKCustomProgressHUD sharedCustomProgressHUD] hiddenViewFast];

        UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"交易"
                                                            message:@"交易失败，请您稍后再试。"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"我知道了", nil];
        [alterView show];
    }
}

- (IBAction)forgetButtonClick:(id)sender {
    
    [self.view endEditing:YES];
    
    JYForgetPasswordViewController *forgetPasswordVC = [[JYForgetPasswordViewController alloc] init];
    forgetPasswordVC.isTrade = YES;
    [self.navigationController pushViewController:forgetPasswordVC animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.passwordAlterView == alertView) {
        
        if (buttonIndex == 1) {
         
            JYForgetPasswordViewController *forgetPasswordVC = [[JYForgetPasswordViewController alloc] init];
            forgetPasswordVC.isTrade = YES;
            [self.navigationController pushViewController:forgetPasswordVC animated:YES];

        }
        else{
            
            self.passwordTextField.text = @"";

        }
    }
    else{
        
        if (buttonIndex == 0) {
            
            [self popToViewController:[JYQRcodeViewController class]];
        }
    }
}



-(void)dealloc
{
    DLog(@"delate");
}
@end
