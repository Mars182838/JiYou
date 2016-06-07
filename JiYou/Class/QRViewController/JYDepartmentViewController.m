//
//  JYDepartmentViewController.m
//  JiYou
//
//  Created by 俊王 on 15/12/22.
//  Copyright © 2015年 JY. All rights reserved.
//

#import "JYDepartmentViewController.h"
#import "JYDepartmentDetailCell.h"
#import "JYDepartmentDetailViewController.h"
#import "JYMobileDetailModel.h"
#import "JYMobileDetailViewController.h"

@interface JYDepartmentViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, strong) NSMutableArray *numList;

@property (nonatomic, strong) NSMutableArray *detailArray;

@property (nonatomic, strong) NSMutableArray *departmentArray;

@property (nonatomic, strong) NSArray *keys;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UISearchController *searchController;

@end

@implementation JYDepartmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navTitle = @"部门列表";
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xEAEAEA"];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([JYDepartmentDetailCell class]) bundle:nil] forCellReuseIdentifier:@"JYDepartmentDetailCell"];
    self.tableView.rowHeight = 50.0f;
    
    [self setMobileData:self.mobileModel];
}

-(void)setMobileData:(JYMobileAddressModel *)mobileModel
{
    self.dataList = [[NSMutableArray alloc] initWithCapacity:0];
    self.numList = [[NSMutableArray alloc] initWithCapacity:0];
    self.detailArray = [[NSMutableArray alloc] init];
    self.departmentArray = [[NSMutableArray alloc] init];
    
    self.keys =  [NSArray array];
    
    /// 部门名称
    _keys = [[mobileModel.departDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString * obj2) {
        
        if ([obj1 localizedCompare:obj2] == NSOrderedDescending) {
            
            return NSOrderedDescending;
        }
        else{
            
            return NSOrderedSame;
        }
    }];
    
    for (NSString *key in _keys) {
        
        [self.dataList addObject:[mobileModel.departName objectForKey:key]];
    }
    
    ///部门人数
    NSArray *numKeys = [[mobileModel.departDic allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString * obj2) {
        
        if ([obj1 localizedCompare:obj2] == NSOrderedDescending) {
            
            return NSOrderedDescending;
        }
        else{
            
            return NSOrderedSame;
        }
    }];
    
    for (NSString *key in numKeys) {
        
        [self.numList addObject:[mobileModel.departEmpNum objectForKey:key]];
    }
}

#pragma mark
#pragma mark TableViewDelegate And TableViewDataSource Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JYDepartmentDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JYDepartmentDetailCell"];
    cell.nameLabel.text = self.dataList[indexPath.row];
    
    NSLog(@"%@",cell.nameLabel.text);
    cell.detaileNameLabel.text = [NSString stringWithFormat:@"%@ 人",self.numList[indexPath.row]];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self selectRowDataWith:indexPath.row];
    
    JYDepartmentDetailViewController *detailVC = [[JYDepartmentDetailViewController alloc] init];
    detailVC.dataList = self.detailArray;
    detailVC.headerArray = self.departmentArray;
    detailVC.navTitle = [self.mobileModel.departName objectForKey:[self.keys objectAtIndex:indexPath.row]];
    
    [self.navigationController pushViewController:detailVC animated:YES];
}

-(void)selectRowDataWith:(NSInteger)index
{
    [self.detailArray removeAllObjects];
    [self.departmentArray removeAllObjects];
    
    NSArray * array = [self.mobileModel.departDic objectForKey:[self.keys objectAtIndex:index]];
    for (NSInteger i = 0; i < array.count; i++) {
        
        [self.detailArray addObject:[self.mobileModel.departDetailDic objectForKey:array[i]]];
        
        [self.departmentArray addObject:[self.mobileModel.departName objectForKey:array[i]]];
    }
    
//    NSLog(@"---%@  ----%@",self.detailArray, self.departmentArray);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
