//
//  JYFingerPrintTableViewCell.h
//  JiYou
//
//  Created by 俊王 on 15/9/18.
//  Copyright © 2015年 JY. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FingerSwitchBlock) (UISwitch *);

@interface JYFingerPrintTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UISwitch *fingerPrintSwitch;

@property (nonatomic, copy) FingerSwitchBlock fingerBlcok;

- (IBAction)fingerPrintSwitchAction:(UISwitch *)sender;

@end
