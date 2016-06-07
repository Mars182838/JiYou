//
//  JYSettingViewController.m
//  JiYou
//
//  Created by 俊王 on 15/8/19.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYSettingViewController.h"
#import "JYAccountViewController.h"
#import "JYInformationViewController.h"
#import "JYAboutViewController.h"
#import "JYExemptPasswordViewController.h"
#import "JYUserModel.h"
#import "JYForgetPasswordViewController.h"

@interface JYSettingViewController ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *settingArray;

@property (weak, nonatomic) IBOutlet UITableView *settingTableView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (strong, nonatomic) IBOutlet UIView *exitView;

@property (weak, nonatomic) IBOutlet UIButton *exitButton;

- (IBAction)exitCurrentAccountClick:(id)sender;

@end

@implementation JYSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navTitle = @"设置";
    
    self.leftImage = [UIImage imageNamed:@"back.png"];
    
    [self.exitButton setBackgroundImage:[UIImage stretchableImageNamed:@"button" edgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];
    
    self.settingArray = @[@[@"个人信息",@"忘记交易密码",@"支付设置"],@[@"关于我们"]];
    
    [self.settingTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"settingTableViewCell"];
    self.settingTableView.tableFooterView = self.exitView;
    self.settingTableView.rowHeight = 50;
}

#pragma mark - UITableViewDataSource and Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.settingArray[section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.settingArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingTableViewCell"];
//    if (indexPath.section ==0 && indexPath.row == 0) {
//        
//        if (self.nameLabel == nil) {
//            
//            self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 220, 0, 180, 48)];
//            self.nameLabel.textColor = [UIColor colorWithHexString:@"0x333333"];
//            self.nameLabel.font = [UIFont systemFontOfSize:16];
//            self.nameLabel.textAlignment = NSTextAlignmentRight;
//            
//            [cell.contentView addSubview:self.nameLabel];
//            
//        }
//        
//        self.nameLabel.text = [JYUserModel shareInstance].userName;
//    }
   
    cell.textLabel.text = self.settingArray[indexPath.section][indexPath.row];
    cell.textLabel.textColor = [UIColor colorWithHexString:@"0x333333"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 1) {
        
        return 20;
    }
    
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            
            JYInformationViewController *infoVC = [[JYInformationViewController alloc] initWithNibName:@"JYInformationViewController" bundle:nil];
            [self.navigationController pushViewController:infoVC animated:YES];
        }
        else if (indexPath.row == 1){
        
            JYForgetPasswordViewController *accountVC = [[JYForgetPasswordViewController alloc] initWithNibName:@"JYForgetPasswordViewController" bundle:nil];
            [self.navigationController pushViewController:accountVC animated:YES];
        }
        else if (indexPath.row == 2)
        {
            JYExemptPasswordViewController *accountVC = [[JYExemptPasswordViewController alloc] initWithNibName:@"JYExemptPasswordViewController" bundle:nil];
            [self.navigationController pushViewController:accountVC animated:YES];

        }
    }
    else if (indexPath.section == 1)
    {
        JYAboutViewController *aboutVC = [[JYAboutViewController alloc] init];
        [self.navigationController pushViewController:aboutVC animated:YES];
    }
    
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    
}

- (IBAction)exitCurrentAccountClick:(id)sender {
    
    UIAlertView *alterView = [[UIAlertView alloc] initWithTitle:@"确定退出吗?"
                                                        message:@""
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                              otherButtonTitles:@"确定", nil];
    [alterView show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        
        [[BKCustomProgressHUD sharedCustomProgressHUD] showHUDLoadingView];
        
        [[BKRequestProxy sharedInstance] requestWithType:BKRequestTypeGET
                                               urlString:@"/user/logout"
                                                  params:nil
                                                    part:nil
                                                 success:^(BKRequestModel *request, BKResponseModel *response) {
                                                     
                                                     [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"退出成功"];
                                                     
                                                     NSLog(@"%@ %@",request, response);
                                                     
                                                     if ([JYSuccessCode isEqualToString:response.head.code]) {
                                                         
                                                         [[JYUserModel shareInstance] logout];
                                                         
                                                     }
                                                 }
                                                 failure:^(BKRequestModel *request, NSError *error) {
                                                     
                                                     [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"网络状态不佳，请稍后再试试哦!"];
                                                 }];
    }
}

-(void)dealloc
{
    DLog(@"delate");
}

@end
