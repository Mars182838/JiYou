//
//  JYAboutViewController.m
//  JiYou
//
//  Created by 俊王 on 15/8/24.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYAboutViewController.h"
#import "JYInformationTableViewCell.h"
#import "JYDiscussViewController.h"

@interface JYAboutViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *contentTabelView;

@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation JYAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navTitle = @"关于我们";
    
    self.dataArray = @[@"求吐槽",@"客服电话"];

    [self.contentTabelView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"accountTableViewCell"];
    
    [self.contentTabelView registerNib:[UINib nibWithNibName:NSStringFromClass([JYInformationTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"JYInformationTableViewCell"];
    self.contentTabelView.rowHeight = 50;
    self.contentTabelView.sectionFooterHeight = CGFLOAT_MIN;
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
    if (indexPath.row == 0) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accountTableViewCell"];
        
        cell.textLabel.text = self.dataArray[indexPath.row];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"0x333333"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        return cell;

    }
    else if (indexPath.row == 1) {
        
        JYInformationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JYInformationTableViewCell"];
        
        cell.nameLabel.text = @"客服电话";
        cell.nameLabel.textColor = [UIColor colorWithHexString:@"0x333333"];
        cell.detailLabel.text = @"400-8211-400";
        return cell;
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CGFLOAT_MIN;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        
        JYDiscussViewController *discussVC  = [[JYDiscussViewController alloc] init];
        [self.navigationController pushViewController:discussVC animated:YES];
    }
    else if (indexPath.row == 1) {
        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"telprompt://4008211400"]];

    }
    
}

-(void)dealloc
{
    DLog(@"delate");
}

@end
