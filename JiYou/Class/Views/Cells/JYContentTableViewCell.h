//
//  JYContentTableViewCell.h
//  JiYou
//
//  Created by 俊王 on 15/12/22.
//  Copyright © 2015年 JY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JYMobileDetailModel.h"

@interface JYContentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, strong) JYMobileDetailModel *detailModel;

@property (nonatomic, assign) BOOL isSearched;

@property (nonatomic, strong) NSString *searchedString;

@end
