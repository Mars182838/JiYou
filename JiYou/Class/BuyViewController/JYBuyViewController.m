//
//  JYBuyViewController.m
//  JiYou
//
//  Created by 俊王 on 15/8/21.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYBuyViewController.h"
#import "JYBuyTableViewCell.h"
#import "JYBuyAmountTableViewCell.h"
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

@interface JYBuyViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contentTableView;

@property (weak, nonatomic) IBOutlet UILabel *nameLable;

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

@property (strong, nonatomic) IBOutlet UIView *footerView;

@property (nonatomic, strong) JYBuyTableViewCell *buyCell;

@property (nonatomic, strong) JYBuyAmountTableViewCell *amountCell;

@property (strong, nonatomic) JYBuyProductModel *productDetailModel;

@property (nonatomic, strong) NSMutableArray *buyArray;

@property (nonatomic, strong) JYCommitModel *commitModel;

@property (weak, nonatomic) IBOutlet UILabel *tipsLabel;

@property (nonatomic) int num;

@property (nonatomic, strong) SCLButton* sclConfirmButton;

@property (nonatomic, weak) UITextField* popupTextField;

@property (nonatomic, strong) NSString *desc;
@property (nonatomic, strong) NSString *dateString;

@property (nonatomic, strong) UIAlertView *passwordAlterView;

@property (nonatomic, strong) UIAlertView *showURLAlterView;


- (IBAction)confirmButtonAction:(id)sender;

@end

@implementation JYBuyViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navTitle = @"兑换详情";
    self.leftImage = [UIImage imageNamed:@"close.png"];
    
    [self.contentTableView registerNib:[UINib nibWithNibName:NSStringFromClass([JYBuyTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"JYBuyTableViewCell"];
    [self.contentTableView registerNib:[UINib nibWithNibName:NSStringFromClass([JYBuyAmountTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"JYBuyAmountTableViewCell"];

    self.contentTableView.rowHeight = 50;
    
    self.contentTableView.tableFooterView = self.footerView;
    
    [self.confirmButton setBackgroundImage:[UIImage stretchableImageNamed:@"button" edgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateNormal];
    [self.confirmButton setBackgroundImage:[UIImage stretchableImageNamed:@"button_disable" edgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)] forState:UIControlStateDisabled];

    self.buyArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    self.contentTableView.hidden = YES;
    
    [self getNetworkDataSource];
    
    self.num = 1;
    
    [self addTextFieldTextDidChangeNotfication];
    
    __weak UIViewController* weakself = self;
    UITapGestureRecognizer* tap = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        
        [weakself.view endEditing:YES];
    }];
    [self.view addGestureRecognizer:tap];
}

#pragma textFieldDelegate Methods
-(void)textFieldTextDidChange:(NSNotification *)notification
{
    UITextField *text = notification.object;
    
    if (text == self.amountCell.numberTextField) {
        
        if ([text.text integerValue] > [self.productDetailModel.buyNumMax integerValue]) {
            
            [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:[NSString stringWithFormat:@"单次最多购买%@份",self.productDetailModel.buyNumMax]];
            self.num = 1;
            self.amountCell.numberTextField.text = [NSString stringWithFormat:@"%ld",(long)self.num];
            
            if (self.num == 1) {
                
                self.amountCell.leftBtn.enabled = NO;
                self.amountCell.rightBtn.enabled = YES;
            }
            
            self.confirmButton.enabled = YES;

        }
        else{
            
            self.num = [text.text intValue];

            if ([text.text integerValue] != 0) {
                
                if (self.num == [self.productDetailModel.buyNumMax integerValue]) {
                    
                    self.amountCell.rightBtn.enabled = YES;
                    self.amountCell.rightBtn.enabled = NO;
                }
                else{
                    
                   self.amountCell.leftBtn.enabled = self.amountCell.rightBtn.enabled = YES;
                }
                
                self.confirmButton.enabled = YES;

                [self upDataUI];
                
            }
            else{
                
                self.amountCell.leftBtn.enabled = self.amountCell.rightBtn.enabled = NO;
                self.confirmButton.enabled = NO;
            }
            
            self.amountCell.numberTextField.text = text.text;
        }
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField.text integerValue] == 0) {
        
        self.num = 1;
        
        self.amountCell.numberTextField.text = @"1";
        self.amountCell.rightBtn.enabled = YES;
        
    }
    [self upDataUI];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self removeTextFieldTextDidChangeNotfication];
}

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
                                                 else{
                                                     
                                                     UIAlertView *view = [[UIAlertView alloc] initWithTitle:nil
                                                                                                    message:_urlString
                                                                                                   delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"去看看", nil];
                                                     self.showURLAlterView = view;
                                                     [self.showURLAlterView show];

                                                 }
                                             }
                                             failure:^(BKRequestModel *request, NSError *error) {
                                                 
                                                 [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"网络状态不佳，请稍后再试试哦!"];
                                             }];
    
}

-(void)upDataUI{
        
    if ([self.productDetailModel.surplusNum integerValue] < [self.productDetailModel.buyNumMax integerValue]) {
        
        self.amountCell.nameLabel.attributedText = [NSString setAttributedStringWith:[NSString stringWithFormat:@"数量^ (剩余%@份)",_productDetailModel.surplusNum] andTextFont:[UIFont systemFontOfSize:12]
                                                                        andTextColor:[UIColor colorWithHexString:@"0xf5a623"]];
        
        self.productDetailModel.buyNumMax = self.productDetailModel.surplusNum;

    }
    else{
        
        self.amountCell.nameLabel.text = [NSString stringWithFormat:@"%@",@"数量"];
        
    }
    
    
//    self.amountCell.numberView.hidden = YES;

//    if ([self.productDetailModel.buyNumMax integerValue] != 1) {
//        
//        self.amountCell.numberView.hidden = YES;
//    }
//    else{
//        
//        self.amountCell.numberView.hidden = NO;
//    }
    
    self.amountCell.leftBtn.enabled = self.num == 1 ?NO:YES;
    
    self.detailLabel.text = [NSString stringWithFormat:@"%.0f 易积分",[self.productDetailModel.pointPrice floatValue] * self.num];
    self.detailLabel.font = [UIFont fontWithName:@"Impact" size:18];

    if ([self.productDetailModel.pointPrice floatValue] * self.num > [JYUserModel shareInstance].pointCount) {
        
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


#pragma mark - UITableViewDataSource And Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        
        JYBuyAmountTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JYBuyAmountTableViewCell"];
       
        cell.numberTextField.delegate = self;
        __weak JYBuyAmountTableViewCell *weakself = cell;
        
        cell.buttonBlock = ^(UIButton* button)
        {
            if (button.tag == 10) {
                
                weakself.numberTextField.text = [NSString stringWithFormat:@"%d", -- self.num];

                if (self.num == 1) {
                    
                    weakself.leftBtn.enabled = NO;

                }
                else{
                    
                    weakself.leftBtn.enabled = YES;
                    weakself.rightBtn.enabled = YES;

                }
            }
            else{
                
                weakself.numberTextField.text = [NSString stringWithFormat:@"%d",++self.num];

                if (self.num == [self.productDetailModel.buyNumMax integerValue]) {
                    
                    weakself.rightBtn.enabled = NO;
                }
                else{
                
                    weakself.rightBtn.enabled = YES;
                    weakself.leftBtn.enabled = YES;
                }
            }
            
            [self upDataUI];

        };
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.amountCell = cell;
        return self.amountCell;
    }
    else{
        
        self.buyCell = [tableView dequeueReusableCellWithIdentifier:@"JYBuyTableViewCell"];
        
        if (indexPath.row == 0) {
            
            self.buyCell.nameLabel.text = self.productDetailModel.productName;
            self.buyCell.nameLabel.textColor = [UIColor colorWithHexString:@"0x3b3b3b"];
            self.buyCell.nameLabel.font = [UIFont boldSystemFontOfSize:16];
            self.buyCell.detailLabel.text = [NSString stringWithFormat:@"%.2f元",[self.productDetailModel.price floatValue]];
        }
        else{
            
            CGFloat count = [self.productDetailModel.price floatValue] * self.num;
            self.buyCell.detailLabel.text = [NSString stringWithFormat:@"%.2f元",count];
         }
        
        self.buyCell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return self.buyCell;
    }

    return nil;
}



-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setCommitModelData
{
    if (!self.commitModel) {
        
        self.commitModel = [[JYCommitModel alloc] init];
    }
    
    self.commitModel.buyNum = [NSString stringWithFormat:@"%ld",(long)self.num];
    self.commitModel.urlString = self.urlString;
    self.commitModel.point = [NSString stringWithFormat:@"%.0f",[self.productDetailModel.pointPrice floatValue] * self.num];
    if (self.num > 1) {
        
        self.desc = [NSString stringWithFormat:@"%@ x %ld",self.productDetailModel.productName,(long)self.num];

    }
    else{
    
        self.desc = [NSString stringWithFormat:@"%@ ",self.productDetailModel.productName];
    }
}

- (IBAction)confirmButtonAction:(id)sender {
    
    if ([JYUserModel shareInstance].isExermt || [JYUserModel shareInstance].isShowTouchID) {
        
        [self exemptPasswordNetwork];
    }
    else{
    
        [self setCommitModelData];
        
        JYPayPasswordViewController *payVC = [[JYPayPasswordViewController alloc] initWithNibName:NSStringFromClass([JYPayPasswordViewController class]) bundle:nil];
        payVC.commitModel = self.commitModel;
        [self.navigationController pushViewController:payVC animated:YES];

    }

}

- (void)checkToShowTouchIdisON:(BOOL)isOn
{
    if (!NSString_ISNULL([SSKeychain passwordForService:kTouchIdKey account:[JYUserModel shareInstance].mobile]))
    {
        [self showTouchIdUnlockIsOn:isOn];
    }
}

- (void)showTouchIdUnlockIsOn:(BOOL)isOn
{
    LAContext * context = [[LAContext alloc] init];
    NSError *error = nil;
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        
        context.localizedFallbackTitle = @"验证交易密码";
        
        // show the authentication UI with our reason string
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:@"通过Home键验证已有手机指纹" reply:
         ^(BOOL success, NSError *authenticationError) {
             
             if (success) {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     if (isOn) {
                         
                         [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"开启成功"];
                         
                         [SSKeychain setPassword:@"1"
                                      forService:kTouchIdKey
                                         account:[JYUserModel shareInstance].mobile];
                     }
                     else{
                         
                         [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"关闭成功"];
                         
                         //关闭指纹解锁
                         [SSKeychain setPassword:@"0"
                                      forService:kTouchIdKey
                                         account:[JYUserModel shareInstance].mobile];
                     }
                     
                 });
             }
             else{
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     
                     switch (authenticationError.code) {
                         case LAErrorUserCancel: case LAErrorSystemCancel:
                         {

                             
                             break;
                         }
                             
                         case LAErrorUserFallback:
                         {
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
                            confirmButtonTitle:nil
                                  confirmBlock:^{
                                      
                                      
                                      
                                  } closeButtonTitle:nil
                                    closeBlock:^{
                                        
                                        
                                    }
                                      duration:0.0
                              ];
                             
                             [textField becomeFirstResponder];
                             self.sclConfirmButton = alert.confirmButton;
                             self.popupTextField = textField;
                                                          
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

#pragma mark - DateString
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

#pragma mark sign

-(NSString *)clientSign{
    
    NSString *signString = [[NSString alloc] init];
    
//    &amount=1&app=elife&app_user_id=002&client_timestamp=1442485271658&out_order=test_20150917182111&to_account=1PfTTWMhEMPvsuaVPRveRvEN8adnWCaJVp&trans_desc=testSign
    
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
    
    NSLog(@"----%@",params);
    
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
                                                     
                                                     self.passwordAlterView = [[UIAlertView alloc] initWithTitle:nil message:response.head.msg
                                                                                                        delegate:self
                                                                                               cancelButtonTitle:@"重新输入"
                                                                                               otherButtonTitles:@"忘记密码", nil];
                                                     [self.passwordAlterView show];
                                                 }
                                                 else if ([@"2006" isEqualToString:response.head.code]){
                                                     
                                                     UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:nil message:response.head.msg
                                                                                                        delegate:self
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
        
        UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"交易" message:@"交易失败，请您稍后再试。" delegate:self cancelButtonTitle:nil otherButtonTitles:@"我知道了", nil];
        [alterView show];
    }
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (self.passwordAlterView == alertView) {
        
        if (buttonIndex == 1) {
            
            JYForgetPasswordViewController *forgetPasswordVC = [[JYForgetPasswordViewController alloc] init];
            forgetPasswordVC.isTrade = YES;
            [self.navigationController pushViewController:forgetPasswordVC animated:YES];
            
        }
    }
    else{
        
        if (buttonIndex == 0) {
            
            [self popToViewController:[JYQRcodeViewController class]];
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

-(void)dealloc
{
    DLog(@"delate");
}

@end
