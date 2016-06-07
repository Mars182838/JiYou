//
//  JYAccountModel.m
//  JiYou
//
//  Created by 俊王 on 15/9/1.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYAccountModel.h"

@implementation JYAccountModel

-(NSMutableDictionary *)generateAttributeMapDictionary
{
    NSMutableDictionary* dict = [super generateAttributeMapDictionary];
    NSDictionary* map = @{@"exchangeMemoCount": @"exchangeSum",
                          @"name": @"userName",
                          @"pointCount": @"pointCount",
                          @"picUrl": @"picUrl"};
    [dict addEntriesFromDictionary:map];
    return dict;
}

@end
