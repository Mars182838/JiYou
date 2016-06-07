//
//  JYExemptPasswordTableViewCell.h
//  JiYou
//
//  Created by 俊王 on 15/8/25.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^SwitchButtonBlock) (UISwitch *);

@interface JYExemptPasswordTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISwitch *switchButton;

@property (nonatomic, copy) SwitchButtonBlock switchBlcok;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

- (IBAction)switchClick:(UISwitch *)sender;

@end
