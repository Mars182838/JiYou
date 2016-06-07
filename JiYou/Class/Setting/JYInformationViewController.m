//
//  JYInformationViewController.m
//  JiYou
//
//  Created by 俊王 on 15/8/19.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYInformationViewController.h"
#import "JYInformationTableViewCell.h"
#import "JYUserModel.h"
#import "NSString+Additions.h"

@interface JYInformationViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *accountTableView;

@property (nonatomic, strong) NSArray *dataArray;

@property (nonatomic, strong) NSArray *detailArray;

@end

@implementation JYInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navTitle = @"个人信息";
    
    self.leftImage = [UIImage imageNamed:@"back.png"];
    
    self.dataArray = @[@"姓名",@"手机号"];
    
    if (NSString_ISNULL([JYUserModel shareInstance].userName)) {
        
        [JYUserModel shareInstance].userName = @"";
        
    }
    self.detailArray = @[[JYUserModel shareInstance].userName,[JYUserModel shareInstance].mobile];

    [self.accountTableView registerNib:[UINib nibWithNibName:NSStringFromClass([JYInformationTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"JYInformationTableViewCell"];
    self.accountTableView.scrollEnabled = NO;
    self.accountTableView.rowHeight = 50;
    
    self.accountTableView.sectionFooterHeight = CGFLOAT_MIN;
}

- (void)didReceiveMemoryWarning {

    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource and Delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    JYInformationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JYInformationTableViewCell"];
    
    cell.nameLabel.text = self.dataArray[indexPath.row];
    cell.detailLabel.text = self.detailArray[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

-(void)dealloc
{
    DLog(@"delate");
}

@end
