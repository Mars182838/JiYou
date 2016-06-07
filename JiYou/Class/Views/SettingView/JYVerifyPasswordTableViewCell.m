//
//  JYVerifyPasswordTableViewCell.m
//  JiYou
//
//  Created by 俊王 on 15/8/25.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYVerifyPasswordTableViewCell.h"

@implementation JYVerifyPasswordTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)verifyButtonClick:(id)sender {
    
    if (self.passwordBlock) {
        
        self.passwordBlock();
    }
}
@end
