//
//  JYNewBuyViewController.m
//  JiYou
//
//  Created by 俊王 on 15/10/13.
//  Copyright © 2015年 JY. All rights reserved.
//

#import "JYNewBuyViewController.h"
#import "JYBuyTableViewCell.h"
#import "JYBuyNameTableViewCell.h"
#import "JYPayPasswordViewController.h"
#import "JYBuyProductModel.h"
#import "NSString+Additions.h"
#import "JYBaseViewController+ExtraEvent.h"
#import "JYCommitModel.h"
#import "JYUserModel.h"
#import "JYQRcodeViewController.h"
#import "UIGestureRecognizer+BlocksKit.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import "JYTradeSuccessViewController.h"
#import "BKCustomProgressHUD.h"
#import "SSKeychain.h"
#import "SCLAlertView.h"
#import "Shared.h"
#import "JYForgetPasswordViewController.h"
#import "MD5.h"

@interface JYNewBuyViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@property (strong, nonatomic) IBOutlet UIView *footerView;

@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@property (nonatomic, strong) IBOutlet UILabel *tipsLabel;

@property (strong, nonatomic) JYBuyProductModel *productDetailModel;

@property (nonatomic, strong) JYBuyTableViewCell *buyCell;

@property (nonatomic, strong) JYBuyNameTableViewCell *buyNameCell;

@property (nonatomic, strong) JYCommitModel *commitModel;

@property (nonatomic, strong) SCLButton* sclConfirmButton;

@property (nonatomic, strong) NSString *desc;

@property (nonatomic, strong) NSString *dateString;

@property (nonatomic, strong) UIAlertView *passwordAlterView;

@property (nonatomic, weak) UITextField* popupTextField;

- (IBAction)confirmButtonAction:(id)sender;

@end

@implementation JYNewBuyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navTitle = @"兑换详情";
    self.leftImage = [UIImage imageNamed:@"close.png"];
    
    [self.contentTableView registerNib:[UINib nibWithNibName:NSStringFromClass([JYBuyTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"JYBuyTableViewCell"];
    [self.contentTableView registerNib:[UINib nibWithNibName:NSStringFromClass([JYBuyNameTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"JYBuyNameTableViewCell"];
    self.contentTableView.rowHeight = 50;
    self.contentTableView.scrollEnabled = NO;
    
    self.contentTableView.tableFooterView = self.footerView;
    
    [self.confirmButton setBackgroundImage:[UIImage stretchableImageNamed:@"button" edgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
    [self.confirmButton setBackgroundImage:[UIImage stretchableImageNamed:@"button_disable" edgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateDisabled];
    
    self.contentTableView.hidden = YES;
    
    [self getNetworkDataSource];

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
    if (textField == self.popupTextField) {
        
        self.popupTextField.text = textField.text;
    }
    
    self.sclConfirmButton.enabled = [self isValid];
}

-(BOOL)isValid
{
    if (NSString_ISNULL(self.popupTextField.text)) {
        
        return NO;
    }
    else{
        
        return YES;
    }
}

#pragma mark - UITableViewDataSource And Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.buyCell = [tableView dequeueReusableCellWithIdentifier:@"JYBuyTableViewCell"];
    self.buyNameCell = [tableView dequeueReusableCellWithIdentifier:@"JYBuyNameTableViewCell"];
    
    if (indexPath.row == 0) {
        
        self.buyNameCell.nameLabel.text = self.productDetailModel.productName;
        self.buyCell.selectionStyle = UITableViewCellSelectionStyleNone;

        return self.buyNameCell;
    }
    else{
        
        self.buyCell.detailLabel.font = [UIFont fontWithName:@"Impact" size:20];
        self.buyCell.detailLabel.textColor = [UIColor colorWithHexString:@"0x18A7E6"];
        self.buyCell.detailLabel.text = [NSString stringWithFormat:@"%.0f 易积分",[self.productDetailModel.pointPrice floatValue]];
        self.buyCell.selectionStyle = UITableViewCellSelectionStyleNone;

        return self.buyCell;

    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}


#pragma mark 
#pragma mark Newtwork Methods

-(void)getNetworkDataSource
{
    [[BKCustomProgressHUD sharedCustomProgressHUD] showHUDLoadingView];
    
    NSDictionary *params = @{@"qr_string":_urlString};
    
    [[BKRequestProxy sharedInstance] requestWithType:BKRequestTypePOST
                                           urlString:@"/ubox/showProductInfo"
                                              params:params
                                                part:nil
                                             success:^(BKRequestModel *request, BKResponseModel *response) {
                                                 
                                                 NSLog(@"%@",response);
                                                 
                                                 [[BKCustomProgressHUD sharedCustomProgressHUD] hiddenViewFast];
                                                 
                                                 if ([response.responseObject isKindOfClass:[NSDictionary class]] && [JYSuccessCode isEqualToString:response.head.code]) {
                                                     
                                                     self.productDetailModel = [[JYBuyProductModel alloc] init];
                                                     [self.productDetailModel setAttributes:response.responseObject];
                                                     
                                                     [self upDataUI];
                                                     self.contentTableView.hidden = NO;
                                                     
                                                 }
                                                 else if ([@"4005" isEqualToString:response.head.code]){
                                                     
                                                   
                                                     UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                                                    message:@"请在易百货机购买！"
                                                                                                   delegate:self
                                                                                          cancelButtonTitle:@"我知道了"
                                                                                          otherButtonTitles:nil, nil];
                                                     [view show];
                                                 }
                                                 else{
                                                     
                                                     UIAlertView *view = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                                                    message:_urlString
                                                                                                   delegate:self
                                                                                          cancelButtonTitle:@"取消"
                                                                                          otherButtonTitles:@"去看看", nil];
                                                     [view show];
                                                 
                                                 }
                                             }
                                             failure:^(BKRequestModel *request, NSError *error) {
                                                
                                                 [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"网络状态不佳，请稍后再试试哦!"];
                                                 
                                                 [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                                                  target:self
                                                                                selector:@selector(navBack)
                                                                                userInfo:nil
                                                                                 repeats:YES];

                                             }];
    
}

-(void)upDataUI{
    
    if ([self.productDetailModel.pointPrice floatValue] > [JYUserModel shareInstance].pointCount) {
        
        self.confirmButton.enabled = NO;
        [self.confirmButton setTitle:@"您的易积分余额不足" forState:UIControlStateNormal];
        self.tipsLabel.text = [NSString stringWithFormat:@"当前易积分：%.0f",[JYUserModel shareInstance].pointCount];
    }
    else{
        
        self.confirmButton.enabled = YES;
        self.tipsLabel.text = @"";
        [self.confirmButton setTitle:@"兑换" forState:UIControlStateNormal];
        
    }

    [self.contentTableView reloadData];
}

-(void)setCommitModelData
{
    if (!self.commitModel) {
        
        self.commitModel = [[JYCommitModel alloc] init];
    }
    
    self.commitModel.buyNum = @"1";
    self.commitModel.urlString = self.urlString;
    self.commitModel.point = [NSString stringWithFormat:@"%.0f",[self.productDetailModel.pointPrice floatValue]];
    self.desc = [NSString stringWithFormat:@"%@",self.productDetailModel.productName];
}

- (IBAction)confirmButtonAction:(id)sender {
    
    if ([JYUserModel shareInstance].isExermt) {
        
        self.confirmButton.enabled = NO;

        [self exemptPasswordNetwork];
    }
    else if([JYUserModel shareInstance].isShowTouchID && [[[LAContext alloc] init] canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:nil]){
        
        self.confirmButton.enabled = NO;

        [self showTouchIdUnlock];
    }
    else{
        
        [self setCommitModelData];
        
        JYPayPasswordViewController *payVC = [[JYPayPasswordViewController alloc] initWithNibName:NSStringFromClass([JYPayPasswordViewController class]) bundle:nil];
        payVC.commitModel = self.commitModel;
        [self.navigationController pushViewController:payVC animated:YES];
        
    }
}

#pragma mark 
#pragma mark 指纹支付

- (void)showTouchIdUnlock
{
    __weak JYNewBuyViewController *weakself = self;

    LAContext * context = [[LAContext alloc] init];
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        
        context.localizedFallbackTitle = @"验证交易密码";
        
        // show the authentication UI with our reason string
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"通过Home键验证已有手机指纹" reply:
         ^(BOOL success, NSError *authenticationError) {
             
             if (success) {

                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     [weakself exemptPasswordNetwork];
                 });
             }
             else{
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     self.confirmButton.enabled = YES;

                     switch (authenticationError.code) {
                         case LAErrorUserCancel: case LAErrorSystemCancel:
                         {
                             break;
                         }
                             
                         case LAErrorUserFallback:
                         {
                             
                             [self showPasswordViewWith:weakself];
                             
                             break;
                         }
                         default:
                             break;
                     }
                     
                 });
             }
         }];
    }
    
}

-(void)showPasswordViewWith:(JYNewBuyViewController *)weakself{

    [self setCommitModelData];
    
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.buttonsHorizontal = YES;
    alert.showAnimationType = SlideInFromTop;
    alert.hideAnimationType = SlideOutToBottom;
    alert.shouldDismissOnTapOutside = YES;
    
    UITextField* textField = [alert addTextField:@"交易密码"];
    textField.secureTextEntry = YES;
    
    [alert showCustom:self.navigationController image:nil
                color:[UIColor yellowColor]
                title:@"请输入交易密码,完成身份验证"
         subTitleDesc:nil
   confirmButtonTitle:@"确认"
         confirmBlock:^{
             
             weakself.commitModel.password = [MD5 md5:weakself.popupTextField.text];
             
             [[BKCustomProgressHUD sharedCustomProgressHUD] showHUDWithView:weakself.view andString:@"支付确认中..."];
             
             NSDictionary *params = @{@"buyNum":weakself.commitModel.buyNum,
                                      @"qrString":weakself.commitModel.urlString,
                                      @"point":weakself.commitModel.point,
                                      @"pwd":weakself.commitModel.password};
             
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
                                                              tradeSuccessVC.commitModel = weakself.commitModel;
                                                              [weakself.navigationController pushViewController:tradeSuccessVC animated:YES];
                                                          }
                                                          else if ([@"2002" isEqualToString:response.head.code]){
                                                              
                                                              //jyConfirm
                                                              NSString* orderId = response.responseObject[@"orderId"];
                                                              dispatch_time_t delayInNanoSeconds = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
                                                              dispatch_after(delayInNanoSeconds, dispatch_get_main_queue(), ^(void){
                                                                  [weakself checkOrderStatusWithOrderId:orderId times:1];
                                                              });
                                                          }
                                                          else if([@"2003" isEqualToString:response.head.code]){
                                                              
                                                              [[BKCustomProgressHUD sharedCustomProgressHUD] hiddenViewFast];
                                                              
                                                              UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:nil
                                                                                                                  message:@"交易失败，请您稍后再试。"
                                                                                                                 delegate:weakself
                                                                                                        cancelButtonTitle:nil
                                                                                                        otherButtonTitles:@"我知道了", nil];
                                                              [alterView show];
                                                              
                                                          }
                                                          else if ([@"2004" isEqualToString:response.head.code]){
                                                              
                                                              [[BKCustomProgressHUD sharedCustomProgressHUD] hiddenViewFast];
                                                              self.passwordAlterView = [[UIAlertView alloc] initWithTitle:nil
                                                                                                                  message:response.head.msg
                                                                                                                 delegate:weakself
                                                                                                        cancelButtonTitle:@"重新输入"
                                                                                                        otherButtonTitles:@"忘记密码", nil];
                                                              [self.passwordAlterView show];
                                                          }
                                                          else if ([@"2006" isEqualToString:response.head.code]){
                                                              
                                                              [[BKCustomProgressHUD sharedCustomProgressHUD] hiddenViewFast];
                                                              
                                                              UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:nil message:response.head.msg
                                                                                                                 delegate:weakself
                                                                                                        cancelButtonTitle:nil
                                                                                                        otherButtonTitles:@"我知道了", nil];
                                                              [alterView show];
                                                          }
                                                          else{
                                                              
                                                              self.confirmButton.enabled = YES;
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
             
             
         } closeButtonTitle:@"取消"
           closeBlock:^{
               
               self.confirmButton.enabled = YES;

           }
             duration:0.0
     ];
    
    [textField becomeFirstResponder];
    self.sclConfirmButton = alert.confirmButton;
    self.popupTextField = textField;

}

#pragma mark
#pragma mark DateString

- (NSString *)stringFromDate{
    
    UInt64 minsec = [[self getNowDateFromatAnDate:[NSDate date]] timeIntervalSince1970]*1000;
    NSString *string = [NSString stringWithFormat:@"%llu",minsec];
    
    return string;
}

- (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone timeZoneForSecondsFromGMT:8];
    
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    
    //转为现在时间
    NSDate* destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    
    return destinationDateNow;
}

#pragma mark
#pragma mark sign

-(NSString *)clientSign{
    
    NSString *signString = [[NSString alloc] init];
    
    NSArray *keyArray = @[@"amount",@"app",@"app_user_id",@"client_timestamp",@"out_order",@"to_account",@"trans_desc"];
    
    NSArray *valueArray = @[self.commitModel.point,
                            self.productDetailModel.appId,
                            self.productDetailModel.appUser,
                            self.dateString,
                            self.productDetailModel.orderNo,
                            self.productDetailModel.sellerAccount,
                            self.desc];
    
    for (NSInteger i = 0; i< keyArray.count; i++) {
        
        signString = [signString stringByAppendingString:@"&"];
        signString = [signString stringByAppendingString:keyArray[i]];
        signString = [signString stringByAppendingString:@"="];
        signString = [self stringEnecodingURLFormat:[signString stringByAppendingString:valueArray[i]]];
    }
    
    NSString *privateKeyPath = [[NSBundle mainBundle] pathForResource:@"private_key" ofType:@"pem"];
    NSString *publicKeyPath  = [[NSBundle mainBundle] pathForResource:@"public_key"  ofType:@"pem"];
    NSLog(@"%@",signString);
    
    signString = [[Signer shareInstance] signSHA1StringWithprivateKey:privateKeyPath publicKey:publicKeyPath andinPutText:signString];
    
    return signString;
}

// encodingString
- (NSString *)stringEnecodingURLFormat:(NSString *)decodingString
{
    NSString *encodedValue = [decodingString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return encodedValue;
}

#pragma mark
#pragma mark 支付流程

-(void)exemptPasswordNetwork{
    
    [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"支付确认中..."];
    
    self.dateString = [self stringFromDate];
    
    [self setCommitModelData];
    
    NSDictionary *params = @{@"clientSign":[self clientSign],
                             @"amount":self.commitModel.point,
                             @"app_user_id":self.productDetailModel.appUser,
                             @"out_order":self.productDetailModel.orderNo,
                             @"buyNum":self.commitModel.buyNum,
                             @"qrString":self.commitModel.urlString,
                             @"client_timestamp":self.dateString,
                             @"trans_desc":self.desc};
    
    [[BKRequestProxy sharedInstance] requestWithType:BKRequestTypePOST
                                           urlString:@"/ubox/signOrder"
                                              params:params
                                                part:nil
                                             success:^(BKRequestModel *request, BKResponseModel *response) {
                                                 
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
                                                 else{
                                                     
                                                     self.confirmButton.enabled = YES;
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
                                                         
                                                         [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:response.head.msg];
                                                         
                                                         self.confirmButton.enabled = YES;

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

#pragma mark 
#pragma mark alterViewDelegate Methods

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    self.confirmButton.enabled = YES;

    if (self.passwordAlterView == alertView) {
        
        if (buttonIndex == 1) {
            
            JYForgetPasswordViewController *forgetPasswordVC = [[JYForgetPasswordViewController alloc] init];
            forgetPasswordVC.isTrade = YES;
            [self.navigationController pushViewController:forgetPasswordVC animated:YES];
            
        }
        else{
            
            __weak JYNewBuyViewController *weakself = self;

            [self showPasswordViewWith:weakself];
        }
    }
    else{
        
        if (buttonIndex == 0) {
            
            [self navBack];
        }
        else{
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_urlString]];

        }
    }
}

-(void)navBack
{
    [self popToViewController:[JYQRcodeViewController class]];
}

@end
