//
//  NSArray+Additions.h
//  YuanGongBao
//
//  Created by Mars on 15/4/23.
//  Copyright (c) 2015年 YiJie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Additions)

+(NSArray *)seperateArrayWithString:(NSString *)originalString byString:(NSString *)separateString;

-(BOOL)writeToPlistFile:(NSString*)filename;
+(NSArray*)readFromPlistFile:(NSString*)filename;

@end
