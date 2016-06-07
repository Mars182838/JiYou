//
//  JYAwardViewController.m
//  JiYou
//
//  Created by 俊王 on 16/4/12.
//  Copyright © 2016年 JY. All rights reserved.
//

#import "JYAwardViewController.h"
#import "JYMyExchangeTableViewCell.h"
#import "JYQRcodeViewController.h"
#import "JYMovieWebViewController.h"

@interface JYAwardViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation JYAwardViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navTitle = @"我的奖品";
    
    [_myTableView registerNib:[UINib nibWithNibName:NSStringFromClass([JYMyExchangeTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([JYMyExchangeTableViewCell class])];
    _myTableView.rowHeight = 75;
    
    _dataSource = [NSMutableArray new];
    
    [self creatInformation];
}


-(void)creatInformation{
    
    [[BKRequestProxy sharedInstance] requestWithType:BKRequestTypeGET
                                           urlString:@"/activity/prizeList"
                                              params:nil
                                                part:nil
                                             success:^(BKRequestModel *request, BKResponseModel *response) {
                                                 
                                                 if ([response.responseObject isKindOfClass:[NSDictionary class]] && [JYSuccessCode isEqualToString:response.head.code]) {
                                                     
                                                     NSLog(@"%@",response.responseObject);
                                                     
                                                     _dataSource = [[response responseObject] objectForKey:@"resultList"];
                                                     [_myTableView reloadData];
                                                 }
                                             }
                                             failure:^(BKRequestModel *request, NSError *error) {
                                                 
                                                 [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"网络状态不佳，请稍后再试试哦!"];
                                             }];

}

#pragma mark
#pragma mark tableViewDelegate and DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JYMyExchangeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([JYMyExchangeTableViewCell class])];

    cell.modelDic = _dataSource[indexPath.row];
    
    cell.headerLineView.hidden = YES;
    
    if (indexPath.row == 0) {
        
        cell.headerLineView.hidden = NO;
    }
    
    if ((self.dataSource.count -1) == indexPath.row) {
        
        cell.lineView.hidden = NO;
        
    }
    else{
        
        cell.lineView.hidden = YES;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([[_dataSource[indexPath.row] objectForKey:@"activityId"] isEqualToString:@"1"]) {
        
        JYMovieWebViewController *movieVC = [[JYMovieWebViewController alloc] init];
        movieVC.urlString = self.urlStirng;
        [self.navigationController pushViewController:movieVC animated:YES];
    }
}

-(void)navBack
{
    [self popToViewController:[JYQRcodeViewController class]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
