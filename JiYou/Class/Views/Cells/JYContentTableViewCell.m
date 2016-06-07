//
//  JYContentTableViewCell.m
//  JiYou
//
//  Created by 俊王 on 15/12/22.
//  Copyright © 2015年 JY. All rights reserved.
//

#import "JYContentTableViewCell.h"

@implementation JYContentTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setDetailModel:(JYMobileDetailModel *)detailModel
{
    if (self.isSearched) {
        
//        self.nameLabel.text = detailModel.name;
//        self.phoneLabel.text = detailModel.mobile;
        
        self.nameLabel.attributedText = [NSString setRankingNameAttributedString:detailModel.name
                                                                 andRankOfString:self.searchedString
                                                                   rankTextColor:[UIColor colorWithHexString:@"0x18A7E6"]];
        self.phoneLabel.attributedText = [NSString setRankingNameAttributedString:detailModel.mobile
                                                        andRankOfString:self.searchedString
                                                          rankTextColor:[UIColor colorWithHexString:@"0x18A7E6"]];
        self.detailLabel.text = detailModel.parentDepartmentName;
        self.titleLabel.text = detailModel.title;
    }
    else{
        
        self.nameLabel.text = detailModel.name;
        self.detailLabel.text = detailModel.parentDepartmentName;
        self.phoneLabel.text = detailModel.mobile;
        self.titleLabel.text = detailModel.title;
    }
   
}

@end
