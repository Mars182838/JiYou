//
//  NSString+Additions.h
//  JY
//
//  Created by Mars on 14-9-16.
//  Copyright (c) 2014年 YiJie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSArray+Additions.h"

@interface NSString (Additions)

- (NSString *)capitalizedFirstLetter;
- (NSString *)omitSpace;

- (CGSize)boundingRectWithSize:(CGSize)size withFont:(UIFont *) font;
- (CGSize)stringSizeWithFont:(UIFont *)font width:(CGFloat)width;
- (CGSize)stringSizeWithFont:(UIFont *)font height:(CGFloat)height;
- (CGRect)stringDrawAtPoint:(CGPoint)point withFont:(UIFont *)font color:(UIColor *)color width:(CGFloat)width;

- (NSString *)formatPhone;
- (NSString *)formatFromPhone;

- (NSString *)formatTelePhone;

- (NSString *)formatBankCard;

- (NSString *)formatFromBankCard;

- (NSString *)formatStringWithOutDecimal;

-(NSString *)formatSymbolString:(NSString *)symbol;

- (NSString *)stringByReplacingOccurrencesOfCharactersInSet:(NSCharacterSet *)characterSet withString:(NSString *)string;

- (BOOL)has_yjFlag;
- (NSString *)remove_yjFlag; // 替换@@
- (NSArray *)yj_Attributes; // 返回的range 是没有@@时的位置
- (NSAttributedString *)attStringFromHTMLWithfont:(UIFont *)font;

+ (NSMutableAttributedString *)setSimilarAttributedStringWith:(NSString *)attributeString andTextColor:(UIColor *)color andBehindTextColor:(UIColor *)behindColor behindTextFont:(UIFont *)textFont;

+ (NSMutableAttributedString *)setRankingNameAttributedString:(NSString *)attributeString andRankOfString:(NSString *)rangeString rankTextColor:(UIColor *)color;

+(NSMutableAttributedString *)setAttributedStringWith:(NSString *)attributeString andTextFont:(UIFont *)font;

+(NSMutableAttributedString *)setAttributedStringWith:(NSString *)attributeString andTextFont:(UIFont *)font andTextColor:(UIColor *)color;


- (BOOL)isValidEmail;

- (BOOL)isValidPhone;

- (BOOL)isValidPassword;

- (BOOL)isValidAccount;

- (BOOL)isValidIdentificationNo;

- (BOOL)isValidVerifyNum;

- (BOOL)isValidateAlphabet;

- (NSDictionary *)formatURLParameterDictionary;

@end
