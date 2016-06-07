//
//  JYDepartmentDetailViewController.m
//  JiYou
//
//  Created by 俊王 on 15/12/23.
//  Copyright © 2015年 JY. All rights reserved.
//

#import "JYDepartmentDetailViewController.h"
#import "JYMobileDetailViewController.h"
#import "JYDepartmentCell.h"

@interface JYDepartmentDetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation JYDepartmentDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xEAEAEA"];
    
    NSLog(@"---%@",self.dataList);
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([JYDepartmentCell class]) bundle:nil] forCellReuseIdentifier:@"JYDepartmentCell"];
    self.tableView.rowHeight = 50.0f;
}

#pragma mark
#pragma mark TableViewDelegate And TableViewDataSource Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataList[section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        
        return CGFLOAT_MIN;
        
    }
    else{
        
        return 45.0f;
    }
    
    return CGFLOAT_MIN;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
        
    } else {
        
        UIView * view = [[UIView alloc] init];
        view.backgroundColor = self.view.backgroundColor;
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 300, 25)];
        label.textColor = [UIColor colorWithHexString:@"0xADADAD"];
        label.font = [UIFont systemFontOfSize:15];
        label.text = [self.headerArray objectAtIndex:section];
        [view addSubview:label];
        return view;
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JYDepartmentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JYDepartmentCell"];
    
    if (self.dataList.count > 0) {
        
        cell.nameLabel.text = [self.dataList[indexPath.section][indexPath.row] objectForKey:@"name"];
        cell.titleLabel.text = [self.dataList[indexPath.section][indexPath.row] objectForKey:@"emp_position"];
    }
    else{
        
        cell.nameLabel.text = @"";
        cell.titleLabel.text = @"";

    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JYMobileDetailModel *detailModel = nil;
    if (self.dataList.count > 0) {
        detailModel = [[JYMobileDetailModel alloc] initWithDataDic:self.dataList[indexPath.section][indexPath.row]];
    }
    
    JYMobileDetailViewController *mobileVC = [[JYMobileDetailViewController alloc] init];
    mobileVC.detailModel = detailModel;
    [self.navigationController pushViewController:mobileVC animated:YES];
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
    
}


@end
