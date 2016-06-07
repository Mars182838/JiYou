//
//  JYMobileDetailCell.h
//  JiYou
//
//  Created by 俊王 on 15/12/28.
//  Copyright © 2015年 JY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTCopyableLabel.h"

@interface JYMobileDetailCell : UITableViewCell

@property (weak, nonatomic) IBOutlet HTCopyableLabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *headerImage;

@end
