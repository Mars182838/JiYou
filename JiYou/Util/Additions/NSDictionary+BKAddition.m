//
//  NSDictionary+BKAddition.m
//  BEIKOO
//
//  Created by XING XIAOYANG on 8/27/14.
//  Copyright (c) 2014 BEIKOO. All rights reserved.
//

#import "NSDictionary+BKAddition.h"

@implementation NSDictionary (BKAddition)
- (NSDictionary *)revertedDictionary
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity:self.count];
    Protocol* protocol = NSProtocolFromString(@"NSCopying");
    for (id<NSCopying> key in self.allKeys) {
        id value = [self objectForKey:key];
        if ([value conformsToProtocol:protocol]) {
            [dict setObject:key forKey:value];
        }
    }
    return dict;
}
@end
