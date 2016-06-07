//
//  JYExemptPasswordTableViewCell.m
//  JiYou
//
//  Created by 俊王 on 15/8/25.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYExemptPasswordTableViewCell.h"

@implementation JYExemptPasswordTableViewCell

- (void)awakeFromNib {
        
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)switchClick:(UISwitch *)sender {

    if (self.switchBlcok) {
        
        self.switchBlcok(sender);
    }
}

@end
