//
//  JYWebViewController.m
//  JiYou
//
//  Created by 俊王 on 16/3/17.
//  Copyright © 2016年 JY. All rights reserved.
//

#import "JYWebViewController.h"
#import "MD5.h"
#import "JYUserModel.h"

@interface JYWebViewController ()<UIWebViewDelegate,NSURLConnectionDataDelegate,NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (nonatomic, strong) NSString *params;

@property(nonatomic, strong) NSMutableData *mdata;

@end

@implementation JYWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.webView.delegate = self;
    
    self.webView.scalesPageToFit = YES;
    _webView.opaque = NO;
    _webView.backgroundColor = [UIColor clearColor];
    [self getMD5Port];
    
    self.rightImage = [UIImage imageNamed:@"webRefresh"];
}

#pragma mark --
#pragma mark --TODO

-(NSString *)acquireTimestampString{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYYMMddHHmmss"];
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    return [formatter stringFromDate:datenow];
}

-(NSString *)acquireDateString{
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    
    return timeSp;
}

-(void)getMD5Port
{
    NSString *acquireString = [self acquireDateString];
    NSMutableString *signString = [[NSMutableString alloc] initWithFormat:@"%@",@"iOS"];
    [signString appendString:[JYUserModel shareInstance].mobile];
    [signString appendString:[JYUserModel shareInstance].account];
    [signString appendString:acquireString];
    [signString appendString:Token];
    
    NSString *md5String = [MD5 md5:signString].uppercaseString;
    
    self.params = [NSString stringWithFormat:@"http://10.10.17.47:8080/ysh/app/third_index?mobile=%@&account=%@&appType=%@&timeStamp=%@&sign=%@",[JYUserModel shareInstance].mobile,[JYUserModel shareInstance].account,@"iOS",acquireString,md5String];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",self.params]]
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request
                                                                  delegate:self
                                                          startImmediately:NO];
    self.mdata = [[NSMutableData alloc] initWithLength:0];
    [connection start];
}

// 你可以在里面判断返回结果, 或者处理返回的http头中的信息
// 每收到一次数据, 会调用一次
- (void)connection:(NSURLConnection *)aConn didReceiveData:(NSData *)data
{
    [self.mdata appendData:data];
}

// 全部数据接收完毕时触发
- (void)connectionDidFinishLoading:(NSURLConnection *)aConn
{
//    self.navTitle = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self loadWebView];
}

-(void)loadWebView{
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.params]];
    [_webView loadRequest:request];
}

-(void)navNext
{
    [self reloadWebView];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.navTitle = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    [self creatButtonArray];
}

-(void)navBack
{
    if (NSString_ISNULL(self.navTitle)) {
     
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        
        if ([_webView canGoBack]) {
            [_webView goBack];
        }
    }
}

- (void)reloadWebView
{
    [self.webView reload];
}

- (void)webView:(UIWebView *)webview didFailLoadWithError:(NSError *)error
{
    [self webViewDidFinishLoad:webview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
