//
//  JYMyExchangeModel.m
//  JiYou
//
//  Created by 俊王 on 15/9/2.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYMyExchangeModel.h"

@implementation JYMyExchangeModel

- (NSMutableDictionary *)generateAttributeMapDictionary
{
    NSMutableDictionary* dict = [super generateAttributeMapDictionary];
    NSDictionary* map = @{@"proId": @"prodcuctID",
                          @"proName": @"prodcuctName",
                          @"priceAmt": @"proPrice",
                          @"epointAmt": @"pointPrice"};
    [dict addEntriesFromDictionary:map];
    return dict;
}

@end
