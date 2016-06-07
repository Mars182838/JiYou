//
//  JYDiscussViewController.m
//  JiYou
//
//  Created by 俊王 on 15/8/24.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYDiscussViewController.h"
#import "NSString+Additions.h"

@interface JYDiscussViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UIButton *commitButton;//提交Button
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (IBAction)commitButtonClick:(id)sender;

@end

@implementation JYDiscussViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navTitle = @"求吐槽";
    [self.commitButton setBackgroundImage:[UIImage stretchableImageNamed:@"button_disable" edgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateDisabled];
    [self.commitButton setBackgroundImage:[UIImage stretchableImageNamed:@"button" edgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)] forState:UIControlStateNormal];

    __weak UIViewController* weakself = self;
    UITapGestureRecognizer* tap = [UITapGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        
        [weakself.view endEditing:YES];
    }];
    [self.view addGestureRecognizer:tap];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)textViewDidChange:(UITextView *)textView
{
    NSInteger number = [textView.text length];
    if (number > 200) {
        
        textView.text = [textView.text substringToIndex:200];
        number = 200;
    }
    
    number = 200 - number;
    
    self.titleLabel.text = [NSString stringWithFormat:@"还可以输入%ld个字",(long)number];
    
    if (!NSString_ISNULL(self.textView.text)) {
        
        self.commitButton.enabled = YES;
    }
    else{
        
        self.commitButton.enabled = NO;

    }
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    textView.text = @"";
    self.textView.textColor = [UIColor colorWithHexString:@"0x3b3b3b"];
}


- (IBAction)commitButtonClick:(id)sender {

    [self.view endEditing:YES];

    [[BKCustomProgressHUD sharedCustomProgressHUD] showHUDLoadingView];
    
    NSDictionary *params = @{@"tweetMsg":self.textView.text};
    
    [[BKRequestProxy sharedInstance] requestWithType:BKRequestTypePOST
                                           urlString:@"/user/tweet"
                                              params:params
                                                part:nil
                                             success:^(BKRequestModel *request, BKResponseModel *response) {
                                                 
                                                 NSLog(@"%@ %@",request, response);
                                                 
                                                 if ([JYSuccessCode isEqualToString:response.head.code]) {
                                                     
                                                     [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"提交成功"];
                                                     
                                                     [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(goBack) userInfo:nil repeats:YES];
                                                 }
                                                 else{
                                                     
                                                     [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:response.head.msg];
                                                 }
                                                 
                                             }
                                             failure:^(BKRequestModel *request, NSError *error) {
                                                 
                                                 [[BKCustomProgressHUD sharedCustomProgressHUD] showHUdModeTextViewWithMessage:@"网络状态不佳，请稍后再试试哦!"];
                                             }];
    

}

-(void)goBack
{
    [self.navigationController popViewControllerAnimated:YES];

}

-(void)dealloc
{
    DLog(@"delate");
}

@end
