//
//  JYBaseTabBarViewController.m
//  JiYou
//
//  Created by 俊王 on 15/8/17.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYBaseTabBarViewController.h"
#import "JYMyAccountViewController.h"
#import "JYQRcodeViewController.h"
#import "YJNavigationController.h"

@interface JYBaseTabBarViewController ()

@end

@implementation JYBaseTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSubControllers];
    
}

-(void)initSubControllers{

    JYQRcodeViewController *qrcodeVC = [[JYQRcodeViewController alloc] initWithNibName:@"JYQRcodeViewController" bundle:nil];
    [qrcodeVC setHidesBottomBarWhenPushed:NO];
    YJNavigationController *nav1 = [[YJNavigationController alloc] initWithRootViewController:qrcodeVC];
    nav1.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"首页"
                                                    image:[[UIImage imageNamed:@"root_home_normal.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                            selectedImage:[[UIImage imageNamed:@"root_home_highlighted.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    nav1.tabBarItem.tag = 0;
    
    JYMyAccountViewController *accountVC = [[JYMyAccountViewController alloc] initWithNibName:@"JYMyAccountViewController" bundle:nil];
    YJNavigationController *nav2 = [[YJNavigationController alloc] initWithRootViewController:accountVC];
    nav2.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的账户"
                                                    image:[[UIImage imageNamed:@"root_me_normal.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                            selectedImage:[[UIImage imageNamed:@"root_me_highlighted.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [accountVC setHidesBottomBarWhenPushed:NO];

    nav1.tabBarItem.tag = 1;

    [self setViewControllers:@[nav1,nav2]];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
