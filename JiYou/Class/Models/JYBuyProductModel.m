//
//  JYBuyProductModel.m
//  JiYou
//
//  Created by 俊王 on 15/9/6.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYBuyProductModel.h"

@implementation JYBuyProductModel

- (NSMutableDictionary *)generateAttributeMapDictionary
{
    NSMutableDictionary* dict = [super generateAttributeMapDictionary];
    NSDictionary* map = @{@"ybProId": @"productID",
                          @"ybProName": @"productName",
                          @"num": @"surplusNum",
                          @"pointCount": @"surplusPoint",
                          @"pointPrice": @"pointPrice",
                          @"yjfApp": @"appId",
                          @"yjfAppUserId": @"appUser"
                          ,@"sellerAccount":@"sellerAccount"};
    
    [dict addEntriesFromDictionary:map];
    return dict;
}

@end
