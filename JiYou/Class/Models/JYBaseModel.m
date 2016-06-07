//
//  BKBaseModel.m
//  BEIKOO
//
//  Created by leo on 14-9-22.
//  Copyright (c) 2014年 BEIKOO. All rights reserved.
//

#import "JYBaseModel.h"

@interface JYBaseModel ()
- (NSString *)capitalizedFirstLetter:(NSString *)str;
/**
 @return return nil if non exists
 */
- (SEL)selectorWithPropertyName:(NSString *)propertyName;
/**
 @return first responsible selector in selectorNames, return nil if non responsible
 */
- (SEL)responsibleSelectorWithName:(NSArray *)selectorNames;
@end

@implementation JYBaseModel
@synthesize attributeMapDictionary = _attributeMapDictionary;

#pragma mark - BKBaseModel
- (instancetype)initWithDataDic:(NSDictionary*)data{
    if (self = [super init]) {
        
        [self setAttributes:data];
    }
    return self;
}

- (NSDictionary*)attributeMapDictionary{
    if (!_attributeMapDictionary) {
        _attributeMapDictionary = [self generateAttributeMapDictionary];
    }
    return _attributeMapDictionary;
}

- (NSMutableDictionary *)generateAttributeMapDictionary
{
    return [NSMutableDictionary dictionary];
}

- (NSString *)customDescription{
    return nil;
}

- (void)willSetAttributes:(NSDictionary *)data
{
    if (![data isKindOfClass:[NSDictionary class]]) {
        return;
    }
}

-(void)setAttributes:(NSDictionary*)dataDic{
    if ([self respondsToSelector:@selector(willSetAttributes:)]) {
        [self willSetAttributes:dataDic];
    }
    if ([dataDic isKindOfClass:[NSDictionary class]]) {
        [dataDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ((NSNull *)obj != [NSNull null]) {
                NSString* name = (NSString *)key;
                NSString* value = (NSString *)obj;
                
                SEL selector = [self selectorWithPropertyName:name];
                if ( value!=nil && (NSNull *)value!=[NSNull null] && selector) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                    [self performSelector:selector withObject:value];
#pragma clang diagnostic pop
                }
            }
        }];
    }
    if ([self respondsToSelector:@selector(didSetAttributes:)]) {
        [self didSetAttributes:dataDic];
    }
}

- (NSData*)archivedData{
    return [NSKeyedArchiver archivedDataWithRootObject:self];
}

- (void)didSetAttributes:(NSDictionary *)data
{
    if (![data isKindOfClass:[NSDictionary class]]) {
        return;
    }
}

#pragma mark - Override
- (NSString *)description{
    NSMutableString *attrsDesc = [NSMutableString stringWithCapacity:100];
    NSDictionary *attrMapDic = [self attributeMapDictionary];
    NSEnumerator *keyEnum = [attrMapDic keyEnumerator];
    id attributeName;
    
    while ((attributeName = [keyEnum nextObject])) {
        SEL getSel = NSSelectorFromString(attributeName);
        if ([self respondsToSelector:getSel]) {
            NSMethodSignature *signature = nil;
            signature = [self methodSignatureForSelector:getSel];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setTarget:self];
            [invocation setSelector:getSel];
            NSObject *valueObj = nil;
            [invocation invoke];
            [invocation getReturnValue:&valueObj];
            //            ITTDINFO(@"attributeName %@ value %@", attributeName, valueObj);
            if (valueObj) {
                [attrsDesc appendFormat:@" [%@=%@] ",attributeName, valueObj];
                //[valueObj release];
            }else {
                [attrsDesc appendFormat:@" [%@=nil] ",attributeName];
            }
            
        }
    }
    
    NSString *customDesc = [self customDescription];
    NSString *desc;
    
    if (customDesc && [customDesc length] > 0 ) {
        desc = [NSString stringWithFormat:@"%@:{%@,%@}",[self class],attrsDesc,customDesc];
    }else {
        desc = [NSString stringWithFormat:@"%@:{%@}",[self class],attrsDesc];
    }
    
    return desc;
}

#pragma mark - NSCoding
- (id)initWithCoder:(NSCoder *)decoder{
    if( self = [super init] ){
        NSDictionary *attrMapDic = [self attributeMapDictionary];
        if (attrMapDic == nil) {
            return self;
        }
        NSEnumerator *keyEnum = [attrMapDic keyEnumerator];
        id attributeName;
        while ((attributeName = [keyEnum nextObject])) {
            SEL sel = [self selectorWithPropertyName:attributeName];
            if ([self respondsToSelector:sel]) {
                id obj = [decoder decodeObjectForKey:attributeName];
                [self performSelectorOnMainThread:sel
                                       withObject:obj
                                    waitUntilDone:[NSThread isMainThread]];
            }
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder{
    NSDictionary *attrMapDic = [self attributeMapDictionary];
    if (attrMapDic == nil) {
        return;
    }
    NSEnumerator *keyEnum = [attrMapDic keyEnumerator];
    id attributeName;
    while ((attributeName = [keyEnum nextObject])) {
        SEL getSel = NSSelectorFromString(attributeName);
        if ([self respondsToSelector:getSel]) {
            NSMethodSignature *signature = nil;
            signature = [self methodSignatureForSelector:getSel];
            NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
            [invocation setTarget:self];
            [invocation setSelector:getSel];
            NSObject *valueObj = nil;
            [invocation invoke];
            [invocation getReturnValue:&valueObj];
            
            if (valueObj) {
                [encoder encodeObject:valueObj forKey:attributeName];
            }
        }
    }
}

#pragma mark - Helper
- (NSString *)capitalizedFirstLetter:(NSString *)str
{
    if (str.length>0) {
        NSString* first = [str substringToIndex:1];
        NSString* firstUp = [first uppercaseString];
        return [str stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstUp];
    } else {
        return [str copy];
    }
    
}

- (SEL)selectorWithPropertyName:(NSString *)propertyName
{
    NSString* mapName = self.attributeMapDictionary[propertyName];
    if (mapName==nil || (NSNull *)mapName==[NSNull null] || mapName.length==0) {
        mapName = propertyName;
    }
    NSString* capName = [self capitalizedFirstLetter:mapName];
    SEL selector = [self responsibleSelectorWithName:@[[NSString stringWithFormat:@"set%@Value:",capName], [NSString stringWithFormat:@"set%@:",capName]]];
    return selector;
}

- (SEL)responsibleSelectorWithName:(NSArray *)selectorNames
{
    SEL returnedSelector = nil;
    for (NSUInteger i=0; i<selectorNames.count; i++) {
        NSString* name = selectorNames[i];
        SEL selector = NSSelectorFromString(name);
        if ([self respondsToSelector:selector]) {
            returnedSelector = selector;
            break;
        }
    }
    return returnedSelector;
}


@end
