//
//  JYShowPhotoViewController.m
//  JiYou
//
//  Created by 俊王 on 15/9/14.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYShowPhotoViewController.h"

@interface JYShowPhotoViewController ()

@property (weak, nonatomic) IBOutlet UILabel *showTitle;
- (IBAction)backAction:(id)sender;

@end

@implementation JYShowPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.leftImage = nil;
    self.navigationBarHidden = YES;

    self.showTitle.text = _titleString;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];

}

@end
