//
//  NSNumber+Addition.m
//  BKUtilsDemo
//
//  Created by XING XIAOYANG on 8/27/14.
//  Copyright (c) 2014 BEIKOO. All rights reserved.
//

#import "NSNumber+BKAddition.h"

@implementation NSNumber (BKAddition)
+ (NSNumberFormatter *)currencyFormatter
{
    static id _currencyFormatter = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _currencyFormatter = [[NSNumberFormatter alloc] init];
        [_currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        [_currencyFormatter setCurrencySymbol:@"￥"];
    });
    
    return _currencyFormatter;
}

+ (NSNumberFormatter *)decimalFormatter
{
    static id _decimalFormatter = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _decimalFormatter = [[NSNumberFormatter alloc] init];
        [_decimalFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [_decimalFormatter setRoundingMode:NSNumberFormatterRoundFloor];
    });
    
    return _decimalFormatter;
}

- (NSString *)toCurrency
{
    NSNumberFormatter* fmt = [NSNumber currencyFormatter];
    fmt.currencySymbol = @"￥";
    return [fmt stringFromNumber:self];
}

- (NSString *)toCurrencyWithoutSymbol
{
    NSNumberFormatter* fmt = [NSNumber currencyFormatter];
    fmt.currencySymbol = @"";
    
    return [fmt stringFromNumber:self];
}

- (NSString *)toDecimal
{
    return [[NSNumber decimalFormatter] stringFromNumber:self];
}

- (NSString *)toPercent
{
    return [NSString stringWithFormat:@"%.1f%%", self.floatValue];
}

- (NSString *)toPercent100 {
    return [NSString stringWithFormat:@"%.2f%%", self.floatValue*100];
}

@end


double bkRoundAtDigit(double num, uint digit)
{
    uint tens = pow(10, digit);
    double n = round(num*tens);
    return n/tens;
}

double bkCeilAtDigit(double num, uint digit)
{
    uint tens = pow(10, digit);
    double n = ceil(num*tens);
    return n/tens;
}

double bkFloorAtDigit(double num, uint digit)
{
    uint tens = pow(10, digit);
    double n = floor(num*tens);
    return n/tens;
}