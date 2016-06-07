//
//  JYBuyAmountTableViewCell.m
//  JiYou
//
//  Created by 俊王 on 15/8/31.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYBuyAmountTableViewCell.h"

@implementation JYBuyAmountTableViewCell

- (void)awakeFromNib {

    [self.leftBtn setBackgroundImage:[UIImage imageNamed:@"minus.png"] forState:UIControlStateNormal];
    [self.leftBtn setBackgroundImage:[UIImage imageNamed:@"minus_disable.png"] forState:UIControlStateDisabled];
    
    [self.rightBtn setBackgroundImage:[UIImage imageNamed:@"plus.png"] forState:UIControlStateNormal];
    [self.rightBtn setBackgroundImage:[UIImage imageNamed:@"plus_disable.png"] forState:UIControlStateDisabled];
    
    self.bgImage.image = [UIImage stretchableImageNamed:@"text_account" edgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)buttonClick:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    if (self.buttonBlock) {
        
        self.buttonBlock(button);
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{

}


@end
