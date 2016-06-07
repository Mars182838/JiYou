//
//  JYMobileDetailViewController.m
//  JiYou
//
//  Created by 俊王 on 15/12/22.
//  Copyright © 2015年 JY. All rights reserved.
//

#import "JYMobileDetailViewController.h"
#import "UIImageView+WebCache.h"
#import <MessageUI/MessageUI.h>
#import "NSString+Additions.h"
#import "JYMobileDetailCell.h"

@interface JYMobileDetailViewController ()<UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailPartmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) NSArray *contentArray;

@property (nonatomic, strong) NSArray *iconArray;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet UIView *headerView;

@end

@implementation JYMobileDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"0xEAEAEA"];

    self.navTitle = @"联系人详情";
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([JYMobileDetailCell class]) bundle:nil] forCellReuseIdentifier:@"JYMobileDetailCell"];
    self.tableView.rowHeight = 50.0f;
    self.tableView.scrollEnabled = NO;
    [self updateDetailModel:self.detailModel];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
}

-(void)updateDetailModel:(JYMobileDetailModel *)model
{
    self.nameLabel.text = model.name;
    self.departmentLabel.text = model.parentDepartmentName;
    if (NSString_ISNULL(model.departmentName)) {
        
        self.detailPartmentLabel.text = model.title;
    }
    else{
        self.detailPartmentLabel.text = model.departmentName;
        self.titleLabel.text = model.title;

    }
    
    if (NSString_ISNULL(model.extension)) {
        
        self.contentArray = @[model.mobile,model.preEmail];
        self.iconArray = @[@"iphone.png",@"mailIcon.png"];

    }
    else{
        self.iconArray = @[@"iphone.png",@"mobile.png",@"mailIcon.png"];
        NSString *telePhone = [NSString stringWithFormat:@"%@-%@",[model.telePhone formatTelePhone],model.extension];
        self.contentArray = @[model.mobile,telePhone,model.preEmail];
    }
    
    if (!NSString_ISNULL(model.headURL)) {
        
        [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:model.headURL]
                                placeholderImage:[UIImage imageNamed:@"portrait"]
                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                           
                                           NSLog(@"sssss");
                                           
                                       }];
    }
}

- (UIImageView *)headerImageView
{
    [_headerImageView.layer setCornerRadius:(_headerImageView.height/2)];
    [_headerImageView.layer setMasksToBounds:YES];
    [_headerImageView setContentMode:UIViewContentModeScaleAspectFill];
    [_headerImageView setClipsToBounds:YES];
    _headerImageView.layer.borderColor = [[UIColor whiteColor] CGColor];
    _headerImageView.layer.borderWidth = 2.0f;
    _headerImageView.userInteractionEnabled = YES;
    _headerImageView.backgroundColor = [UIColor clearColor];
    
    return _headerImageView;
}

#pragma mark
#pragma mark TableViewDelegate And TableViewDataSource Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contentArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    JYMobileDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JYMobileDetailCell"];
    cell.nameLabel.text = self.contentArray[indexPath.row];
    cell.headerImage.image = [UIImage imageNamed:self.iconArray[indexPath.row]];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * view = [[UIView alloc] init];
    view.backgroundColor = self.view.backgroundColor;
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 300, 25)];
    label.textColor = [UIColor colorWithHexString:@"0xADADAD"];
    label.font = [UIFont systemFontOfSize:15];
    label.text = @"公司信息";
    [view addSubview:label];
    return view;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@",self.contentArray[indexPath.row]]]];
        
    }
    else if (indexPath.row == 1){
        
        if (self.contentArray.count > 2) {
            
            NSString *telePhone = [NSString stringWithFormat:@"%@,%@",[self.detailModel.telePhone formatTelePhone],self.detailModel.extension];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt:%@",telePhone]]];
        }
        else{
            
            [self sendMailComposeVC:self.contentArray[indexPath.row]];
        }
    }
    else if (indexPath.row == 2)
    {
        [self sendMailComposeVC:self.contentArray[indexPath.row]];
    }
}

-(void)sendMailComposeVC:(NSString *)mailString{
    
    MFMailComposeViewController *mailVC = [[MFMailComposeViewController alloc] init];
    if ([MFMailComposeViewController canSendMail]) {

        mailVC.mailComposeDelegate = self;
        [mailVC setToRecipients:[NSArray arrayWithObject:mailString]];
        
        [self presentViewController:mailVC animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error {
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved...");
            break;
        case MFMailComposeResultSent:
            
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail send errored: %@...", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

@end
