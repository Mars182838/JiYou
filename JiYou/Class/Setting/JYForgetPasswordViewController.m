//
//  JYForgetPasswordViewController.m
//  JiYou
//
//  Created by 俊王 on 15/8/25.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYForgetPasswordViewController.h"
#import "JYChangePasswordTableViewCell.h"
#import "JYVerifyPasswordTableViewCell.h"
#import "JYBaseViewController+ExtraEvent.h"
#import "JYUserModel.h"
#import "MD5.h"

@interface JYForgetPasswordViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *contentTabelView;

@property (nonatomic, strong) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UIButton *commiteButton;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (nonatomic, strong) JYForgetPassword *forgetModel;

- (IBAction)commiteButtonClick:(id)sender;

@end

@implementation JYForgetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navTitle = @"忘记交易密码";

    self.dataArray = @[@"手机号",@"验证码",@"新密码"];

    _forgetModel = [[JYForgetPassword alloc] init];

    [self.contentTabelView registerNib:[UINib nibWithNibName:NSStringFromClass([JYChangePasswordTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"JYChangePasswordTableViewCell"];
    [self.contentTabelView registerNib:[UINib nibWithNibName:NSStringFromClass([JYVerifyPasswordTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"JYVerifyPasswordTableViewCell"];

    self.contentTabelView.rowHeight = 50;
    self.contentTabelView.sectionFooterHeight = CGFLOAT_MIN;
    self.contentTabelView.tableFooterView = self.footerView;
    
    self.commiteButton.enabled = NO;
    [self.commiteButton setBackgroundImage:[UIImage stretchableImageNamed:@"button" edgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
    [self.commiteButton setBackgroundImage:[UIImage stretchableImageNamed:@"button_disable" edgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateDisabled];
    
    __weak UIViewController* weakself = self;
    UITapGestureRecognizer* tap = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        
        [weakself.view endEditing:YES];
    }];
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

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

#pragma mark -UITextFieldNotification

-(void)textFieldTextDidChange:(NSNotification *)notification
{
    UITextField *textfield = notification.object;
    if (textfield.tag ==1)
    {
        _forgetModel.verifyPassword = textfield.text;
    }
    else if (textfield.tag ==2)
    {
        _forgetModel.password = textfield.text;
    }
    
    [self isValidate];
}

-(void)isValidate
{
    if (!NSString_ISNULL(_forgetModel.iphone) && !NSString_ISNULL(_forgetModel.verifyPassword) && !NSString_ISNULL(_forgetModel.password)) {
        
        self.commiteButton.enabled = YES;
        
    }
    else{
        
        self.commiteButton.enabled = NO;
    }
}

#pragma mark - UITableViewDataSource and Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1) {
        
        JYVerifyPasswordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JYVerifyPasswordTableViewCell"];
        
        __weak JYVerifyPasswordTableViewCell *weakSelf = cell;
        cell.passwordBlock = ^(void){
        
            [[BKCustomProgressHUD sharedCustomProgressHUD] showHUDLoadingView];
            
            NSDictionary *params = @{@"mobile":_forgetModel.iphone};
            [[BKRequestProxy sharedInstance] requestWithType:BKRequestTypePOST
                                                   urlString:@"/user/getCheckCode"
                                                      params:params
                                                        part:nil
                                                     success:^(BKRequestModel *request, BKResponseModel *response) {
                                                         
                                                         if ([response.responseObject isKindOfClass:[NSDictionary class]] && [JYSuccessCode isEqualToString:response.head.code]) {
                                                             
                                                             [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"验证码发送成功"];
                                                             
                                                             [JYUserModel shareInstance].token = response.responseObject[@"token"];
                                                             [JYUserModel shareInstance].timeout = [response.responseObject[@"expiringSeconds"] integerValue];
                                                             
                                                             __block NSInteger timeout = [JYUserModel shareInstance].timeout; //倒计时时间
                                                             dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                                                             dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
                                                             dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //没秒执行
                                                             dispatch_source_set_event_handler(_timer, ^{
                                                                 if(timeout<=0){ //倒计时结束，关闭
                                                                     dispatch_source_cancel(_timer);
                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                         
                                                                         [weakSelf.verifyButton setTitle:@"获取验证码" forState:UIControlStateNormal];
                                                                         weakSelf.verifyButton.enabled = YES;
                                                                         [weakSelf.verifyButton setTitleColor:[UIColor colorWithHexString:@"0x0BB6EB"] forState:UIControlStateNormal];
                                                                         
                                                                         //设置界面的按钮显示 根据自己需求设置
                                                                     });
                                                                 }else{
                                                                     
                                                                     timeout--;
                                                                     
                                                                     NSString *strTime = [NSString stringWithFormat:@"%lds",(long)timeout];
                                                                     dispatch_async(dispatch_get_main_queue(), ^{
                                                                         //设置界面的按钮显示 根据自己需求设置
                                                                         [weakSelf.verifyButton setTitle:strTime forState:UIControlStateNormal];
                                                                         [weakSelf.verifyButton setTitleColor:[UIColor colorWithHexString:@"0x666666"] forState:UIControlStateDisabled];
                                                                         
                                                                         weakSelf.verifyButton.enabled = NO;
                                                                         
                                                                         
                                                                     });
                                                                     
                                                                 }  
                                                             });  
                                                             dispatch_resume(_timer);

                                                             NSLog(@"%@", response.responseObject);
                                                         }
                                                         else{
                                                         
                                                             [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:response.head.msg];
                                                         }
                                                         
                                                     }
                                                     failure:^(BKRequestModel *request, NSError *error) {
                                                         
                                                         [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"网络状态不佳，请稍后再试试哦!"];
                                                     }];

                  };
        
        cell.nameLabel.text = self.dataArray[indexPath.row];
        cell.verifyTextField.tag = indexPath.row;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        return cell;
        
    }
    else{
    
        JYChangePasswordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JYChangePasswordTableViewCell"];
        cell.nameLabel.text = self.dataArray[indexPath.row];
        cell.passwordTextField.tag = indexPath.row;
        
        if (indexPath.row == 0) {
            
            cell.passwordTextField.userInteractionEnabled = NO;
            cell.passwordTextField.text = [[JYUserModel shareInstance].mobile formatPhone];
            cell.passwordTextField.secureTextEntry = NO;
            _forgetModel.iphone = [JYUserModel shareInstance].mobile;
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}


- (IBAction)commiteButtonClick:(id)sender {
    
    [self.view endEditing:YES];

    [[BKCustomProgressHUD sharedCustomProgressHUD] showHUDLoadingView];
    if (NSString_ISNULL([JYUserModel shareInstance].token)) {
        
        [JYUserModel shareInstance].token = @"11";
    }
    
    NSDictionary *params = @{@"mobile":_forgetModel.iphone,@"identifyCode":_forgetModel.verifyPassword,@"newTransPwd":[MD5 md5:_forgetModel.password],@"token":[JYUserModel shareInstance].token};
    NSLog(@"%@",params);
    
    [[BKRequestProxy sharedInstance] requestWithType:BKRequestTypePOST
                                           urlString:@"/user/transPwdRecover"
                                              params:params
                                                part:nil
                                             success:^(BKRequestModel *request, BKResponseModel *response) {
                                                 
                                                 NSLog(@"%@ %@",request, response);
                                                 
                                                 if ([response.responseObject isKindOfClass:[NSDictionary class]] && [JYSuccessCode isEqualToString:response.head.code]) {
                                                     [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"交易密码设置成功"];
                                                     if (self.isTrade) {
                                                         
                                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"isTrade" object:nil];
                                                         
                                                     }
                                                     [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(goBack) userInfo:nil repeats:YES];
                                                     
                                                 }
                                                 else{
                                                     
                                                     [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:response.head.msg];
                                                 }
                                             }
                                             failure:^(BKRequestModel *request, NSError *error) {
                                                 
                                                 [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"网络状态不佳，请稍后再试试哦!"];
                                             }];
}

-(void)goBack{

    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc
{
    DLog(@"delate");
}

@end
