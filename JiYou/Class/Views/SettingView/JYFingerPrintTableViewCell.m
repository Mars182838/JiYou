//
//  JYFingerPrintTableViewCell.m
//  JiYou
//
//  Created by 俊王 on 15/9/18.
//  Copyright © 2015年 JY. All rights reserved.
//

#import "JYFingerPrintTableViewCell.h"

@implementation JYFingerPrintTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)fingerPrintSwitchAction:(UISwitch *)sender {
    
    if (self.fingerBlcok) {
        
        self.fingerBlcok(sender);
    }
}


@end
