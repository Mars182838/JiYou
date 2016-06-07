//
//  NSDictionary+BKJSONDictionary.h
//  BEIKOO
//
//  Created by Mars on 14-10-17.
//  Copyright (c) 2014年 BEIKOO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (BKJSONDictionary)

+(instancetype)jsonSerializationToDictionary:(NSData *)jsonData;
+(instancetype)dictionaryWithJSONString:(NSString *)jsonString;

@end
