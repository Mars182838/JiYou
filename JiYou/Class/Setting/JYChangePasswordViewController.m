//
//  JYChangePasswordViewController.m
//  JiYou
//
//  Created by 俊王 on 15/8/25.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYChangePasswordViewController.h"
#import "JYChangePasswordTableViewCell.h"
#import "JYBaseViewController+ExtraEvent.h"
#import "JYPasswordModel.h"

@interface JYChangePasswordViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *contentTabelView;

@property (nonatomic, strong) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UIButton *commiteButton;
@property (strong, nonatomic) IBOutlet UIView *footerView;
@property (nonatomic, strong) JYPasswordModel *passwordModel;
@property (nonatomic, strong) JYChangePasswordTableViewCell *cell;

- (IBAction)commiteButtonClick:(id)sender;

@end

@implementation JYChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navTitle = @"修改交易密码";
    
    self.dataArray = @[@"旧密码",@"新密码"];

    _passwordModel = [[JYPasswordModel alloc] init];

    [self.contentTabelView registerNib:[UINib nibWithNibName:NSStringFromClass([JYChangePasswordTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"JYChangePasswordTableViewCell"];
    self.contentTabelView.rowHeight = 50;
    self.contentTabelView.sectionFooterHeight = CGFLOAT_MIN;
    self.contentTabelView.tableFooterView = self.footerView;
    
    [self.commiteButton setBackgroundImage:[UIImage stretchableImageNamed:@"button" edgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
    [self.commiteButton setBackgroundImage:[UIImage stretchableImageNamed:@"button_disable" edgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateDisabled];
    self.commiteButton.enabled = NO;
    
    __weak UIViewController* weakself = self;
    UITapGestureRecognizer* tap = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        
        [weakself.view endEditing:YES];
    }];
    [self.view addGestureRecognizer:tap];
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
    if (textfield.tag == 0) {
        
        _passwordModel.oldPassword = textfield.text;
    }
    else if (textfield.tag ==1)
    {
        _passwordModel.resetPassword = textfield.text;
    }
    
    [self isValidate];
}

-(void)isValidate
{
    if (!NSString_ISNULL(_passwordModel.oldPassword) && !NSString_ISNULL(_passwordModel.resetPassword)) {
        
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
    _cell = [tableView dequeueReusableCellWithIdentifier:@"JYChangePasswordTableViewCell"];
    _cell.nameLabel.text = self.dataArray[indexPath.row];
    _cell.passwordTextField.tag = indexPath.row;
    return _cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

- (IBAction)commiteButtonClick:(id)sender {

    [[BKCustomProgressHUD sharedCustomProgressHUD] showHUDLoadingView];
    
    NSDictionary *params = @{@"oldTransPwd":_passwordModel.oldPassword,@"newTransPwd":_passwordModel.resetPassword};
    
    [[BKRequestProxy sharedInstance] requestWithType:BKRequestTypePOST
                                           urlString:@"/user/transPwdModify"
                                              params:params
                                                part:nil
                                             success:^(BKRequestModel *request, BKResponseModel *response) {
                                                 
                                                 [[BKCustomProgressHUD sharedCustomProgressHUD] hiddenViewFast];
                                                 
                                                 NSLog(@"%@ %@",request, response);
                                                 
                                                 if ([response.responseObject isKindOfClass:[NSDictionary class]] && [JYSuccessCode isEqualToString:response.head.code]) {
                                                     
                                                     
                                                 }
                                                 
                                            }
                                             failure:^(BKRequestModel *request, NSError *error) {
                                                 
                                                 [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"网络状态不佳，请稍后再试试哦!"];
                                             }];

}

-(void)dealloc
{
    DLog(@"delate");
}


@end
