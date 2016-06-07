//
//  JYExemptPasswordViewController.m
//  JiYou
//
//  Created by 俊王 on 15/8/25.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYExemptPasswordViewController.h"
#import "JYExemptPasswordTableViewCell.h"
#import "JYBaseViewController+ExtraEvent.h"
#import "JYBuyTableViewCell.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "BKCustomProgressHUD.h"
#import "Shared.h"
#import "SSKeychain.h"
#import "JYUserModel.h"
#import "SCLAlertView.h"
#import "MD5.h"

#import "JYFingerPrintTableViewCell.h"


NSString * const kTouchIdKey = @"kTouchIdKey";
NSString * const kTouchIdCheckToShowName = @"kTouchIdCheckToShowName";

@interface JYExemptPasswordViewController ()<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contentTabelView;

@property (nonatomic, strong) NSArray *array;

@property (nonatomic, strong) JYExemptPasswordTableViewCell *cell;

@property (nonatomic, strong) JYFingerPrintTableViewCell *fingerCell;

@property (nonatomic, assign) BOOL isExempt;// 是否免密

@property (nonatomic, assign) BOOL isSuccessExempt;

@property (assign, nonatomic) BOOL shouldShowTouchID; // 开启指纹支付

@property (nonatomic, assign) BOOL shouldShowTouchIdCell;

@property (nonatomic, assign) BOOL showTouchID;

@property (nonatomic, assign) BOOL selectedSwitch;

@property (nonatomic, weak) SCLButton* confirmButton;

@property (nonatomic, weak) UITextField* popupTextField;

@property (nonatomic, strong) NSString *publicKey;

@end

@implementation JYExemptPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navTitle = @"支付设置";

    self.array = @[@"免密支付",@"指纹支付"];
    [self.contentTabelView registerNib:[UINib nibWithNibName:NSStringFromClass([JYExemptPasswordTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"JYExemptPasswordTableViewCell"];
    [self.contentTabelView registerNib:[UINib nibWithNibName:NSStringFromClass([JYFingerPrintTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"JYFingerPrintTableViewCell"];

    self.contentTabelView.rowHeight = 50;
    
    NSError * error;

    if ([[[LAContext alloc] init] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                                              error:&error]) {
        _shouldShowTouchIdCell = YES;
    } else if ([error.userInfo[@"NSLocalizedDescription"] isEqualToString:@"No fingers are enrolled with Touch ID."]) {
        
        _shouldShowTouchIdCell = YES;
    }
    
    NSString *publicKeyPath  = [[NSBundle mainBundle] pathForResource:@"public_key"  ofType:@"pem"];
    self.publicKey = [[Signer shareInstance] getPublickKeyStringWithPublickeyPath:publicKeyPath];
    
    NSLog(@"%@",self.publicKey);
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

#pragma mark - UITextFieldDelegate
- (void)textFieldTextDidChange:(NSNotification *)notification{
    //这里需要一个检测用户输入是否有效金额的逻辑

    if (notification.object == _popupTextField) {
        if (!NSString_ISNULL(_popupTextField.text)) {
            
            _confirmButton.enabled = YES;
            
        } else {
            
            _confirmButton.enabled = NO;
        }
        
    }
}

#pragma mark - UITableViewDataSource and Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.shouldShowTouchIdCell == YES? self.array.count:1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __block JYExemptPasswordViewController *weakself = self;

    if (indexPath.section == 0) {
        
        _cell = [tableView dequeueReusableCellWithIdentifier:@"JYExemptPasswordTableViewCell"];
        _cell.switchButton.onTintColor = [UIColor colorWithHexString:@"07B3E9"];
        _cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.isSuccessExempt = [JYUserModel shareInstance].isExermt;
        self.isExempt = self.isSuccessExempt;
        
        _cell.switchBlcok = ^(UISwitch *switchBtn){
            
            weakself.selectedSwitch = NO;

            if ([JYUserModel shareInstance].isExermt) {
                
                UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:nil
                                                                    message:@"关闭免密支付"
                                                                   delegate:weakself
                                                          cancelButtonTitle:@"取消"
                                                          otherButtonTitles:@"确定", nil];
                [alterView show];
            }
            else{
                
                [weakself exemptPasswordNetworkWithExtermPasswordType:ExemptPassword];
                
            }
        };
        
        return _cell;
 
    }
    else{
        
        _fingerCell = [tableView dequeueReusableCellWithIdentifier:@"JYFingerPrintTableViewCell"];
        _fingerCell.fingerPrintSwitch.onTintColor = [UIColor colorWithHexString:@"0x07B3E9"];
        _fingerCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.shouldShowTouchID = [JYUserModel shareInstance].isShowTouchID;
        self.showTouchID = self.shouldShowTouchID;

        _fingerCell.fingerBlcok = ^(UISwitch *switchBtn){

            weakself.selectedSwitch = YES;

            if ([JYUserModel shareInstance].isShowTouchID)
            {
                if ([[[LAContext alloc] init] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]){
                    
                    [weakself canShowTouchID:[JYUserModel shareInstance].isShowTouchID];
                }
                else{
                    
                    [weakself showTipsToHelpUserOpenTouchIdInSettings];
                }
            }
            else
            {
                [weakself canShowTouchID:[JYUserModel shareInstance].isShowTouchID];
            }
        };
        
        return self.fingerCell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}


-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        
        return 28;
    }
    return CGFLOAT_MIN;
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 20)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 8, kScreenWidth, 20)];
        label.text = @"使用手机支付，无需输入支付密码";
        label.font = [UIFont systemFontOfSize:12];
        label.textColor = [UIColor colorWithHexString:@"8a8a8a"];
        [view addSubview:label];
        return view;
    }
    
    return nil;
    
//    使用手机支付，无需输入支付密码
}

#pragma -mark - About TouchID
- (void)showTouchIdUnlockIsOn:(BOOL)isOn
{
    if (isOn) {
        
        [self canCancelPasswordWithType:FingerprintPassword];
    
    }
    else{
     
        [self exemptPasswordNetworkWithExtermPasswordType:FingerprintPassword];
    }
}


-(void)canShowTouchID:(BOOL)isOn{
    
    LAContext * context = [[LAContext alloc] init];
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        
        if (isOn) {
            
            context.localizedFallbackTitle = @"确定";

        }
        else{
        
            context.localizedFallbackTitle = @"";

        }
        
        __block JYExemptPasswordViewController *weakself = self;

        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"通过Home键验证已有手机指纹" reply:
         ^(BOOL success, NSError *authenticationError) {
             
             if (success) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                 
                     if (isOn) {
                         
                         [weakself canCancelPasswordWithType:FingerprintPassword];
                         
                     }
                     else{
                     
                         [weakself showTouchIdUnlockIsOn:isOn];

                     }
                 });
             }
             else{
                 
                 NSLog(@"--%@",authenticationError.localizedDescription);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     switch (authenticationError.code) {
                         case LAErrorUserCancel: case LAErrorSystemCancel:
                         {
                             weakself.showTouchID = weakself.shouldShowTouchID;
                             
                             break;
                         }
                             
                         case LAErrorUserFallback:
                         {
                             NSLog(@"sssss");
                             break;
                         }
                             
                         default:
                             
                             weakself.showTouchID = weakself.shouldShowTouchID;
                             break;
                     }
                     
                 });
             }
         }];
    }

}

- (void)showTipsToHelpUserOpenTouchIdInSettings
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"使用提示"
                                                         message:@"请先在系统设置-Touch ID与密码中开启"
                                                        delegate:self
                                               cancelButtonTitle:@"我知道了"
                                               otherButtonTitles:nil];
    [alertView show];
}


#pragma mark -- getNetWorkMethods
-(void)exemptPasswordNetworkWithExtermPasswordType:(ExemptPasswordType)type{
    
    __block JYExemptPasswordViewController *weakself = self;

    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.buttonsHorizontal = YES;
    alert.showAnimationType = SlideInFromTop;
    alert.hideAnimationType = SlideOutToBottom;
    alert.shouldDismissOnTapOutside = NO;
    
    UITextField* textField = [alert addTextField:@"交易密码"];
    textField.secureTextEntry = YES;
    
    [alert showCustom:self.navigationController image:nil
                color:[UIColor yellowColor]
                title:@"请输入积友交易密码"
         subTitleDesc:nil
   confirmButtonTitle:@"确定"
         confirmBlock:^{
             
             NSDictionary *params = @{@"pwd":[MD5 md5:self.popupTextField.text],@"pubkey":self.publicKey,@"payType":[NSString stringWithFormat:@"%d",type]};
             
             NSLog(@"%@",params);

             [[BKCustomProgressHUD sharedCustomProgressHUD] showHUDLoadingView];
             [[BKRequestProxy sharedInstance] requestWithType:BKRequestTypePOST
                                                    urlString:@"/point/noPwdToPay"
                                                       params:params
                                                         part:nil
                                                      success:^(BKRequestModel *request, BKResponseModel *response) {
                                                          
                                                          [[BKCustomProgressHUD sharedCustomProgressHUD] hiddenViewFast];
                                                          
                                                          NSLog(@"saaaaaaa%@",response.responseObject);
                                                          
                                                          if ([JYSuccessCode isEqualToString:response.head.code]) {
                                                              
                                                              [JYUserModel shareInstance].isExermt = [response.responseObject[@"noPwdPayFlag"] boolValue];
                                                              [JYUserModel shareInstance].isShowTouchID = [response.responseObject[@"fingerPayFlag"] boolValue];
                                                              
                                                              weakself.isSuccessExempt = [JYUserModel shareInstance].isExermt;
                                                              weakself.shouldShowTouchID = [JYUserModel shareInstance].isShowTouchID;
                                                              
                                                              weakself.isExempt = weakself.isSuccessExempt;
                                                              weakself.showTouchID = weakself.shouldShowTouchID;
                                                              
                                                              if (weakself.selectedSwitch) {
                                                                  
                                                                  [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"已开启指纹支付"];

                                                              }
                                                              else{
                                                                  
                                                                  [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"已开启免密支付"];
                                                              }
                                                              
                                                          }
                                                          else{
                                                              
                                                              weakself.isExempt = weakself.isSuccessExempt;
                                                              weakself.showTouchID = weakself.shouldShowTouchID;
                                                              [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:response.head.msg];
                                                          }
                                                          
                                                      }
                                                      failure:^(BKRequestModel *request, NSError *error) {
                                                          
                                                          weakself.isExempt = weakself.isSuccessExempt;
                                                          weakself.showTouchID = weakself.shouldShowTouchID;
                                                          
                                                          [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"网络状态不佳，请稍后再试试哦!"];
                                                      }];
             
         } closeButtonTitle:@"取消"
           closeBlock:^{
               
               weakself.isExempt = weakself.isSuccessExempt;
               weakself.showTouchID = weakself.shouldShowTouchID;
           }
             duration:0.0
     ];
    
    [textField becomeFirstResponder];
    self.confirmButton = alert.confirmButton;
    self.popupTextField = textField;
}

-(void)canCancelPasswordWithType:(ExemptPasswordType)type{

    __block JYExemptPasswordViewController *weakself = self;
    
    NSDictionary *params = @{@"payType":[NSString stringWithFormat:@"%d",type]};
    
    NSLog(@"%@",params);
    [[BKCustomProgressHUD sharedCustomProgressHUD] showHUDLoadingView];
    [[BKRequestProxy sharedInstance] requestWithType:BKRequestTypePOST
                                           urlString:@"/point/closeNoPwdToPay"
                                              params:params
                                                part:nil
                                             success:^(BKRequestModel *request, BKResponseModel *response) {
                                                 
                                                 [[BKCustomProgressHUD sharedCustomProgressHUD] hiddenViewFast];
                                                 
                                                 NSLog(@"%@",response.responseObject);
                                                 
                                                 if ([JYSuccessCode isEqualToString:response.head.code]) {
                                                     
                                                     [JYUserModel shareInstance].isExermt = [response.responseObject[@"noPwdPayFlag"] boolValue];
                                                     [JYUserModel shareInstance].isShowTouchID = [response.responseObject[@"fingerPayFlag"] boolValue];
                                                     
                                                     weakself.isSuccessExempt = [JYUserModel shareInstance].isExermt;
                                                     weakself.shouldShowTouchID = [JYUserModel shareInstance].isShowTouchID;
                                                     
                                                     weakself.isExempt = weakself.isSuccessExempt;
                                                     weakself.showTouchID = weakself.shouldShowTouchID;
                                                     
                                                     if (self.selectedSwitch) {
                                                         
                                                         [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"已关闭指纹支付"];
                                                         
                                                     }
                                                     else{
                                                         
                                                         [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"已关闭免密支付"];
                                                     }
                                                     
                                                 }
                                                 else{
                                                     
                                                     weakself.isExempt = weakself.isSuccessExempt;
                                                     weakself.showTouchID = weakself.shouldShowTouchID;
                                                     [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:response.head.msg];
                                                 }
                                                 
                                                 
                                             }
                                             failure:^(BKRequestModel *request, NSError *error) {
                                                 
                                                 weakself.isExempt = weakself.isSuccessExempt;
                                                 
                                                 weakself.showTouchID = weakself.shouldShowTouchID;
                                                 [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"网络状态不佳，请稍后再试试哦!"];
                                             }];

}

-(void)setIsExempt:(BOOL)isExempt
{
    self.cell.switchButton.on = isExempt;
}

-(void)setShowTouchID:(BOOL)showTouchID
{
    self.fingerCell.fingerPrintSwitch.on = showTouchID;
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:{
        
            if (self.selectedSwitch) {
                
                self.showTouchID = self.shouldShowTouchID;
            }
            else{
                
                self.isExempt = self.isSuccessExempt;
 
            }
        }
            break;
        case 1:{
        
            [self canCancelPasswordWithType:ExemptPassword];
        
            break;
        }

            default:
            break;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)dealloc
{
    DLog(@"delate");
}

@end
