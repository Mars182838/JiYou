//
//  JYAccountViewController.m
//  JiYou
//
//  Created by 俊王 on 15/8/19.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYAccountViewController.h"
#import "JYChangePasswordViewController.h"
#import "JYForgetPasswordViewController.h"

@interface JYAccountViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *accountTableView;

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation JYAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navTitle = @"账户安全";
    
    self.leftImage = [UIImage imageNamed:@"back.png"];
    
    self.dataArray = @[@"忘记交易密码"];
    
    [self.accountTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"accountTableViewCell"];
    self.accountTableView.sectionFooterHeight = CGFLOAT_MIN;
    self.accountTableView.rowHeight = 50;
    self.accountTableView.scrollEnabled = NO;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource and Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accountTableViewCell"];
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    cell.textLabel.textColor = [UIColor colorWithHexString:@"0x333333"];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

//    if (indexPath.row == 0) {
//        
//        JYChangePasswordViewController *changePasswordVC = [[JYChangePasswordViewController alloc] init];
//        [self.navigationController pushViewController:changePasswordVC animated:YES];
//    }
    if(indexPath.row == 0)
    {
        JYForgetPasswordViewController *forgetPasswordVC = [[JYForgetPasswordViewController alloc] init];
        [self.navigationController pushViewController:forgetPasswordVC animated:YES];
    }
}

-(void)dealloc
{
    DLog(@"delate");
}


@end
