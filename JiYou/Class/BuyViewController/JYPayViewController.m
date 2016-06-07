//
//  JYPayViewController.m
//  NewProject
//
//  Created by 俊王 on 15/8/14.
//  Copyright (c) 2015年 Steven. All rights reserved.
//

#import "JYPayViewController.h"
#import "JYTradeSuccessViewController.h"

@interface JYPayViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *passWordImage;

@property (nonatomic, assign) NSInteger pointLength;

@property (nonatomic, strong) NSMutableArray *pointArray;

@end

@implementation JYPayViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"支付密码";
    
    [self.textField becomeFirstResponder];
        
    self.pointArray = [[NSMutableArray alloc] init];
}


-(void)updatePointImageView{
    
    for (UIImageView *image in self.passWordImage.subviews) {
        
        [image removeFromSuperview];
    }
    
    for (NSInteger i = 0; i < self.pointArray.count; i++) {
        
        UIImageView *pointImage = [[UIImageView alloc] initWithFrame:CGRectZero];

        UIImage *image = [UIImage imageNamed:@"yuan"];
        
        pointImage.image = image;

        pointImage.frame = CGRectMake(i*self.passWordImage.frame.size.width/6 + (self.passWordImage.frame.size.width/6 - image.size.width -1)/2, (self.passWordImage.frame.size.height - image.size.height -1)/2, image.size.width, image.size.height);
        
        [self.passWordImage addSubview:pointImage];
        
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (range.length != 1) {
        
        if (self.pointArray.count < 6) {
            
            [self.pointArray addObject:string];

            if (self.pointArray.count == 6) {
                
                JYTradeSuccessViewController *tradeVC = [[JYTradeSuccessViewController alloc] init];
                [self.navigationController pushViewController:tradeVC animated:YES];
            }
        }

    }
    else{
        
        [self.pointArray removeLastObject];
    }
    
    [self updatePointImageView];
    
    return YES;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];

}

@end
