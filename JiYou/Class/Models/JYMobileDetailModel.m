//
//  JYMobileDetailModel.m
//  JiYou
//
//  Created by 俊王 on 15/12/23.
//  Copyright © 2015年 JY. All rights reserved.
//

#import "JYMobileDetailModel.h"

@implementation JYMobileDetailModel

- (NSMutableDictionary *)generateAttributeMapDictionary
{
    NSMutableDictionary* dict = [super generateAttributeMapDictionary];
    NSDictionary* map = @{@"department_name": @"departmentName",
                          @"parent_department_name": @"parentDepartmentName",
                          @"email": @"preEmail",
                          @"name_spell": @"nameSpell",
                          @"head_url":@"headURL",
                          @"telephone_number":@"telePhone",
                          @"emp_position":@"title"};
    
    [dict addEntriesFromDictionary:map];
    return dict;
}

@end
