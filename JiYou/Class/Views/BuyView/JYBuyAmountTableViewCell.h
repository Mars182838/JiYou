//
//  JYBuyAmountTableViewCell.h
//  JiYou
//
//  Created by 俊王 on 15/8/31.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^BuyButtonBlock) (UIButton *);

@interface JYBuyAmountTableViewCell : UITableViewCell<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIButton *leftBtn;

@property (weak, nonatomic) IBOutlet UIButton *rightBtn;

@property (weak, nonatomic) IBOutlet UITextField *numberTextField;

@property (nonatomic, copy) BuyButtonBlock buttonBlock;

@property (weak, nonatomic) IBOutlet UIImageView *bgImage;

@property (weak, nonatomic) IBOutlet UIView *numberView;

- (IBAction)buttonClick:(id)sender;

@end
