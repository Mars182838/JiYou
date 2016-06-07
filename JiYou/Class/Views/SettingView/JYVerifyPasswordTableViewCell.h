//
//  JYVerifyPasswordTableViewCell.h
//  JiYou
//
//  Created by 俊王 on 15/8/25.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^VerifyPasswordBlock)();

@interface JYVerifyPasswordTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UITextField *verifyTextField;

@property (weak, nonatomic) IBOutlet UIButton *verifyButton;

@property(nonatomic, copy) VerifyPasswordBlock passwordBlock;

- (IBAction)verifyButtonClick:(id)sender;

@end
