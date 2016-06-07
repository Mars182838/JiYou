//
//  JYMovieWebViewController.m
//  JiYou
//
//  Created by 俊王 on 16/4/29.
//  Copyright © 2016年 JY. All rights reserved.
//

#import "JYMovieWebViewController.h"

@interface JYMovieWebViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation JYMovieWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"兑换电影票";

    NSLog(@"%@",self.urlString);
    
    NSURL *url = [NSURL URLWithString:self.urlString];
    [_webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
