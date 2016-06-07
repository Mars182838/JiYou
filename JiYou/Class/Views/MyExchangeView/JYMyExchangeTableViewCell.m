//
//  JYMyExchangeTableViewCell.m
//  JiYou
//
//  Created by 俊王 on 15/8/21.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYMyExchangeTableViewCell.h"

@implementation JYMyExchangeTableViewCell

- (void)awakeFromNib {

    self.isExchangeDetail = NO;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

-(void)setProductModel:(JYMyExchangeModel *)productModel
{
    NSString *string = productModel.pointPrice;
    
    if ([string hasPrefix:@"+"]) {
        
        string = [string substringFromIndex:1];
        self.priceLabel.text = [NSString stringWithFormat:@"+%@",[[[NSNumber numberWithInteger:[string integerValue]] toCurrencyWithoutSymbol] formatStringWithOutDecimal]];

    }
    else if([string hasPrefix:@"-"]){
        
        string = [string substringFromIndex:1];
        self.priceLabel.text = [NSString stringWithFormat:@"-%@",[[[NSNumber numberWithInteger:[string integerValue]] toCurrencyWithoutSymbol] formatStringWithOutDecimal]];
    }
    else{
    
        self.priceLabel.text = [[[NSNumber numberWithInteger:[productModel.pointPrice integerValue]] toCurrencyWithoutSymbol] formatStringWithOutDecimal];
   
    }
    self.priceLabel.font = [UIFont fontWithName:@"Impact" size:18];
    
    if (self.isExchangeDetail) {
        
        self.tradeDateLabel.text = [NSString stringWithFormat:@"%@",productModel.createTime];
        self.nameLabel.text = [NSString stringWithFormat:@"%@",productModel.details];
        
        /**
         *  判断积分类型
         */
        if ([productModel.pointPrice hasPrefix:@"+"]) {
            
            self.priceLabel.textColor = [UIColor colorWithHexString:@"0x4E9C00"];
        }
        else{
            
            self.priceLabel.textColor = [UIColor colorWithHexString:@"0x3b3b3b"];
        }
    }
    else{
        
        self.tradeDateLabel.text = [NSString stringWithFormat:@"%@   数量 %@",productModel.createTime,productModel.buyNum];
        self.nameLabel.text = productModel.prodcuctName;
    
    }
    
    self.tradeStatusLabel.text = productModel.status;
}


-(void)setModelDic:(NSDictionary *)modelDic
{
    self.tradeDateLabel.text = [modelDic objectForKey:@"createTime"];
    self.nameLabel.text = [modelDic objectForKey:@"prizeName"];
    self.priceLabel.text = [modelDic objectForKey:@"prizeNum"];
    self.tradeStatusLabel.text = @"成功";
    
    self.widthConstant.constant = 220;
}

@end
