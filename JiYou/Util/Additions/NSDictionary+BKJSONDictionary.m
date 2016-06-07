//
//  NSDictionary+BKJSONDictionary.m
//  BEIKOO
//
//  Created by Mars on 14-10-17.
//  Copyright (c) 2014年 BEIKOO. All rights reserved.
//

#import "NSDictionary+BKJSONDictionary.h"

@implementation NSDictionary (BKJSONDictionary)

+(instancetype)jsonSerializationToDictionary:(NSData *)jsonData
{
    NSError *error = nil;
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                          options:NSJSONReadingAllowFragments
                                                            error:&error];
    
    if (jsonObject != nil && error == nil){
        
        return jsonObject;
        
    }else{
        
        // 解析错误
        return nil;
    }
}

+ (instancetype)dictionaryWithJSONString:(NSString *)jsonString
{
    NSError* error = nil;
    id jsonObj = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
    if (![jsonObj isKindOfClass:[NSDictionary class]] || error) {
        return nil;
    } else {
        return jsonObj;
    }
}

@end
