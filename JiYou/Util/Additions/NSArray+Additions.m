//
//  NSArray+Additions.m
//  YuanGongBao
//
//  Created by Mars on 15/4/23.
//  Copyright (c) 2015年 YiJie. All rights reserved.
//

#import "NSArray+Additions.h"

@implementation NSArray (Additions)

+(NSArray *)seperateArrayWithString:(NSString *)originalString byString:(NSString *)separateString
{
    NSRange originalRange = [originalString rangeOfString:@"#"];///判断是否包含
    
    if (originalRange.location != NSNotFound) {
        
        originalString = [originalString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    }
    
    NSRange range = [originalString rangeOfString:separateString];
    NSArray *seprateArray = nil;
    
    if (range.location != NSNotFound) {
        
        seprateArray = [originalString componentsSeparatedByString:separateString];
    }
    
    return seprateArray;
}

-(BOOL)writeToPlistFile:(NSString*)filename{
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:self];
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString * path = [documentsDirectory stringByAppendingPathComponent:filename];
    BOOL didWriteSuccessfull = [data writeToFile:path atomically:YES];
    return didWriteSuccessfull;
}

+(NSArray*)readFromPlistFile:(NSString*)filename{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString * path = [documentsDirectory stringByAppendingPathComponent:filename];
    NSData * data = [NSData dataWithContentsOfFile:path];
    return  [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

@end
