//
//  JYLoginViewController.m
//  JiYou
//
//  Created by 俊王 on 15/8/21.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYLoginViewController.h"
#import "UIGestureRecognizer+BlocksKit.h"
#import "JYBaseViewController+ExtraEvent.h"
#import "JYQRcodeViewController.h"
#import "MD5.h"
#import "JYUserModel.h"

@interface JYLoginViewController ()
{
    NSInteger minSMSSendInverval;
    NSInteger timeCount;
    BOOL isTimeOut;
}

//@property (nonatomic, strong) NSTimer *timer;

@property (weak, nonatomic) IBOutlet UITextField *iphoneTextField;

@property (weak, nonatomic) IBOutlet UITextField *verifyTextField;

@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UIButton *verifyButton;

@property (weak, nonatomic) IBOutlet UIView *textView;

@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UIImageView *logoImage;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgViewConstraint;

- (IBAction)verfiyButtonClick:(id)sender;

- (IBAction)loginAction:(id)sender;

@end

@implementation JYLoginViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.navigationBarHidden = YES;
    isTimeOut = YES;
    self.leftImage = nil;
    minSMSSendInverval = 90;

    self.bgViewConstraint.constant = kScreenHeight;
    
    self.logoImage.alpha = 0;
    
    [self.loginButton setBackgroundImage:[UIImage stretchableImageNamed:@"login_button" edgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:[UIImage stretchableImageNamed:@"login_button" edgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateDisabled];

    [self.loginButton setTitleColor:[UIColor colorWithHexString:@"0x295B80"] forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor colorWithHexString:@"0xADCEDF"] forState:UIControlStateDisabled];
    
    [self.verifyButton setTitleColor:[UIColor colorWithHexString:@"0x295B80"] forState:UIControlStateNormal];
    [self.verifyButton setTitleColor:[UIColor colorWithHexString:@"0x5CB1DB"] forState:UIControlStateDisabled];
    
    __weak UIViewController* weakself = self;
    UITapGestureRecognizer* tap = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        
        [weakself.view endEditing:YES];
    }];
    [self.view addGestureRecognizer:tap];

    self.verifyButton.enabled = [self validatePhone];
    self.loginButton.enabled = [self validatePassword];
    
}

-(void)beginAnimation{
    
    [UIView animateWithDuration:0.2f animations:^{
        
        self.logoImage.alpha = 1.0f;
        self.bgView.alpha = 0;

    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.8f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            self.bgView.alpha = 1.0f;
            self.bgView.originY = 65;
            
        } completion:^(BOOL finished) {
            
            self.bgViewConstraint.constant = 65;
            [self.bgView needsUpdateConstraints];
            [self.bgView setNeedsLayout];
            
            [UIView animateWithDuration:0.25f delay:0.2f options:UIViewAnimationOptionCurveEaseIn animations:^{
                
                [self.iphoneTextField becomeFirstResponder];
                
            } completion:^(BOOL finished) {
                
            }];

        }];

    }];
}


#pragma maek TextField and Notification

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addTextFieldTextDidChangeNotfication];
   
    [self beginAnimation];

    if (IS_IPHONE4) {
        
        [self addKeyboardWillHideNotification];
        [self addKeyboardWillShowNotification];
    }
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeTextFieldTextDidChangeNotfication];
    
    if (IS_IPHONE4) {
        
        [self removeKeyboardWillHideNotification];
        [self removeKeyboardWillShowNotification];
    }
    
}

-(void)keyboardWillShow:(NSNotification *)notification
{
    [UIView animateWithDuration:0.25f animations:^{
        
        self.view.originY = -65;

    }];
}

-(void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.25f animations:^{
     
        self.view.originY = 0;

    }];
}

-(void)textFieldTextDidChange:(NSNotification *)notification
{
    UITextField *textField = notification.object;
    if (textField == self.iphoneTextField) {
        
        if ([textField.text formatFromPhone].length > 11 && textField.markedTextRange == nil) {
            
            if (textField.text.length > 13) {
                
                textField.text = [textField.text substringWithRange: NSMakeRange(0, 13)];
            }
        }
        
        self.iphoneTextField.text = [[textField.text formatFromPhone] formatPhone];
        
        if (isTimeOut) {
            
            self.verifyButton.enabled = [self validatePhone];

        }
        else{
        
            self.verifyButton.enabled = isTimeOut;
        }
    }
    
    self.loginButton.enabled = [self validatePassword];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];

}

-(BOOL)validatePhone
{
    BOOL isValidate = NO;
    
    if (!NSString_ISNULL(self.iphoneTextField.text) && [[self.iphoneTextField.text formatFromPhone] isValidPhone]) {
        
        isValidate = YES;
        
    }
    return isValidate;
}

-(BOOL)validatePassword{

    BOOL isValidate = NO;
    
    if (!NSString_ISNULL(self.verifyTextField.text) && [self validatePhone]) {
        
        isValidate = YES;
    }
    return isValidate;
}


#pragma mark ButtonClickMethods

- (IBAction)verfiyButtonClick:(id)sender {
    
    [[BKCustomProgressHUD sharedCustomProgressHUD] showHUDLoadingView];
    
    __weak JYLoginViewController *weakSelf = self;
    
    NSDictionary *params = @{@"mobile":[self.iphoneTextField.text formatFromPhone]};
    [[BKRequestProxy sharedInstance] requestWithType:BKRequestTypePOST
                                           urlString:@"/user/getCheckCode"
                                              params:params
                                                part:nil
                                             success:^(BKRequestModel *request, BKResponseModel *response) {
                                                 
                                                 [[BKCustomProgressHUD sharedCustomProgressHUD] hiddenViewFast];
                                                 
                                                 if ([response.responseObject isKindOfClass:[NSDictionary class]] && [JYSuccessCode isEqualToString:response.head.code]) {

                                                     [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"验证码发送成功"];

                                                     self.verifyButton.enabled = NO;
                                                     [JYUserModel shareInstance].token = response.responseObject[@"token"];
                                                     [JYUserModel shareInstance].timeout = [response.responseObject[@"expiringSeconds"] integerValue];
                                                     NSLog(@"%@",response.responseObject);
                                                     
                                                     __block NSInteger timeout = [JYUserModel shareInstance].timeout; //倒计时时间
                                                     dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                                                     dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
                                                     dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //没秒执行
                                                     dispatch_source_set_event_handler(_timer, ^{
                                                         if(timeout<=0){
                                                             
                                                             isTimeOut = YES;
                                                             
                                                             //倒计时结束，关闭
                                                             dispatch_source_cancel(_timer);
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 
                                                                 [weakSelf.verifyButton setTitle:@"获取验证码" forState:UIControlStateNormal];
                                                                 weakSelf.verifyButton.enabled = [self validatePhone];
                                                                 
                                                                 //设置界面的按钮显示 根据自己需求设置
                                                             });
                                                         }else{
                                                             
                                                             timeout--;
                                                             isTimeOut = NO;
                                                             
                                                             NSString *strTime = [NSString stringWithFormat:@"%lds",(long)timeout];
                                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                                 
                                                                 weakSelf.verifyButton.enabled = NO;
                                                                 //设置界面的按钮显示 根据自己需求设置
                                                                 [weakSelf.verifyButton setTitle:strTime forState:UIControlStateNormal];
                                                                 
                                                             });
                                                             
                                                         }
                                                     });
                                                     dispatch_resume(_timer);
                                                     
                                                 }
                                                 else if ([@"0002" isEqualToString:response.head.code]){
                                                     
                                                     UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                                                         message:@"您的手机号暂时没有登记，请速速联系易百HR的漂亮mm吧。"
                                                                                                        delegate:nil
                                                                                               cancelButtonTitle:nil
                                                                                               otherButtonTitles:@"我知道了", nil];
                                                     [alterView show];
                                                 }
                                                 else{
                                                     
                                                     [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:response.head.msg];

                                                 }
                                                 
                                             }
                                             failure:^(BKRequestModel *request, NSError *error) {
                                                 
                                                 [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"网络状态不佳，请稍后再试试哦!"];
                                             }];
    
}

- (IBAction)loginAction:(id)sender {
    
    [self.view endEditing:YES];
    
    [JYUserModel shareInstance].mobile = [self.iphoneTextField.text formatFromPhone];

    [JYUserModel shareInstance].password = self.verifyTextField.text;
    
    if ([JYUserModel shareInstance].password.length != 6 ) {
        
        [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"请输入6位验证码"];
        
        return;
    }
    
    if (NSString_ISNULL([JYUserModel shareInstance].token)) {
        
        [JYUserModel shareInstance].token = @"111";
 
    }
    
    NSDictionary *params = @{@"mobile":[JYUserModel shareInstance].mobile,@"password":[JYUserModel shareInstance].password,@"token":[JYUserModel shareInstance].token};
    
    NSLog(@"---%@",params);

    [[BKCustomProgressHUD sharedCustomProgressHUD] showHUDLoadingView];

    [[BKRequestProxy sharedInstance] requestWithType:BKRequestTypePOST
                                           urlString:@"/user/login"
                                              params:params
                                                part:nil
                                             success:^(BKRequestModel *request, BKResponseModel *response) {
                                                 
                                                 [[BKCustomProgressHUD sharedCustomProgressHUD] hiddenViewFast];
                                                 
                                                 NSLog(@"%@",response.responseObject);

                                                 if ([response.responseObject isKindOfClass:[NSDictionary class]] && [JYSuccessCode isEqualToString:response.head.code]) {
                                                     
                                                     [JYUserModel shareInstance].lastLoginTime = [NSDate date];
                                                     
                                                     [JYUserModel shareInstance].firstUse = [response.responseObject[@"firstUse"] boolValue];
                                                     [JYUserModel shareInstance].userID = response.responseObject[@"userId"];
                                                     [JYUserModel shareInstance].account = response.responseObject[@"yjfAccount"];
                                                     [[JYUserModel shareInstance] save];

                                                     JYQRcodeViewController *qrcodeVC  = [[JYQRcodeViewController alloc] init];
                                                     [self.navigationController pushViewController:qrcodeVC animated:YES];
                                                     
                                                 }
                                                 else if ([@"0002" isEqualToString:response.head.code]){
                                                     
                                                     UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                                                         message:@"您的手机号暂时没有登记，请速速联系易百HR的漂亮mm吧。"
                                                                                                        delegate:nil
                                                                                               cancelButtonTitle:nil
                                                                                               otherButtonTitles:@"我知道了", nil];
                                                     [alterView show];
                                                 }
                                                 else{
                                                     
                                                     [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:response.head.msg];
                                                 }
                                             }
                                             failure:^(BKRequestModel *request, NSError *error) {
                                                 
                                                 [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"网络状态不佳，请稍后再试试哦!"];
                                             }];
}

-(void)showTime:(NSTimer *)timer
{
    timeCount ++;
    
    if (timeCount < minSMSSendInverval) {
        
        [self.verifyButton setTitle:[NSString stringWithFormat:@"%lds",(long)(minSMSSendInverval - timeCount)] forState:UIControlStateDisabled];
    }
    else{
        
        self.verifyButton.enabled = YES;
        [self.verifyButton setTitle:@"获取验证码" forState:UIControlStateNormal];
//        [self.timer invalidate];

    }
}

-(void)dealloc
{
    DLog(@"delate");
}

@end
