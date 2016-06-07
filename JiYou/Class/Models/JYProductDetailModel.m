//
//  JYProductDetailModel.m
//  JiYou
//
//  Created by 俊王 on 15/9/1.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYProductDetailModel.h"

@implementation JYProductDetailModel
/*
"ybProId":"22222222"
"ybProName":"加多宝"
"num":"20"
"tran_id":"12345678"
"price":"3.00"
"pointPrice":"300"
*/
- (NSMutableDictionary *)generateAttributeMapDictionary
{
    NSMutableDictionary* dict = [super generateAttributeMapDictionary];
    NSDictionary* map = @{@"ybProId": @"prodcuctID",
                          @"ybProName": @"prodcuctName",
                          @"num": @"proNum",
                          @"price": @"proPrice",
                          @"pointPrice": @"pointPrice"};
    [dict addEntriesFromDictionary:map];
    return dict;
}

@end




