//
//  NSNumber+Addition.h
//  BKUtilsDemo
//
//  Created by XING XIAOYANG on 8/27/14.
//  Copyright (c) 2014 BEIKOO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (BKAddition)
+ (NSNumberFormatter *)currencyFormatter;
+ (NSNumberFormatter *)decimalFormatter;
- (NSString *)toCurrency;
- (NSString *)toCurrencyWithoutSymbol;
- (NSString *)toDecimal;
- (NSString *)toPercent; //0~1.0
- (NSString *)toPercent100; // 0% ~100%
@end

/**
    num在小数点后digit位进行四舍五入
 */
extern double bkRoundAtDigit(double num, uint digit);
/**
 num在小数点后digit位取最接近的较大整数
 */
extern double bkCeilAtDigit(double num, uint digit);
/**
 num在小数点后digit位取最接近的较小整数
 */
extern double bkFloorAtDigit(double num, uint digit);