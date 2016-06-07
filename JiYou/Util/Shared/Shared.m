//
//  Shared.m
//  SignAndVerify
//
//  Created by Ricci Adams on 2014-07-20.
//
//

#import "Shared.h"
#import <CommonCrypto/CommonCrypto.h>
#import <Security/Security.h>


NSData *GetSHA1Hash(NSData *inData)
{
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];

    CC_SHA1_CTX ctx;

    CC_SHA1_Init(&ctx);
    CC_SHA1_Update(&ctx, [inData bytes], (CC_LONG)[inData length]);
    CC_SHA1_Final(digest, &ctx);
    
    return [[NSData alloc] initWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
}


NSData *GetSHA256Hash(NSData *inData)
{
    unsigned char digest[CC_SHA256_DIGEST_LENGTH];

    CC_SHA256_CTX ctx;

    CC_SHA256_Init(&ctx);
    CC_SHA256_Update(&ctx, [inData bytes], (CC_LONG)[inData length]);
    CC_SHA256_Final(digest, &ctx);
    
    return [[NSData alloc] initWithBytes:digest length:CC_SHA256_DIGEST_LENGTH];
}


NSString *GetHexStringWithData(NSData *data)
{
    NSUInteger inLength  = [data length];
    unichar *outCharacters = malloc(sizeof(unichar) * (inLength * 2));

    UInt8 *inBytes = (UInt8 *)[data bytes];
    static const char lookup[] = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };
 
    NSUInteger i, o = 0;
    for (i = 0; i < inLength; i++) {
        UInt8 inByte = inBytes[i];
        outCharacters[o++] = lookup[(inByte & 0xF0) >> 4];
        outCharacters[o++] = lookup[(inByte & 0x0F)];
    }

    return [[NSString alloc] initWithCharactersNoCopy:outCharacters length:o freeWhenDone:YES];
}


NSData *GetDataWithHexString(NSString *inputString)
{
    NSUInteger inLength = [inputString length];
    
    unichar *inCharacters = alloca(sizeof(unichar) * inLength);
    [inputString getCharacters:inCharacters range:NSMakeRange(0, inLength)];

    UInt8 *outBytes = malloc(sizeof(UInt8) * ((inLength / 2) + 1));

    NSInteger i, o = 0;
    UInt8 outByte = 0;
    for (i = 0; i < inLength; i++) {
        UInt8 c = inCharacters[i];
        SInt8 value = -1;
        
        if      (c >= '0' && c <= '9') value =      (c - '0');
        else if (c >= 'A' && c <= 'F') value = 10 + (c - 'A');
        else if (c >= 'a' && c <= 'f') value = 10 + (c - 'a');            
        
        if (value >= 0) {
            if (i % 2 == 1) {
                outBytes[o++] = (outByte << 4) | value;
                outByte = 0;
            } else {
                outByte = value;
            }

        } else {
            if (o != 0) break;
        }        
    }

    return [NSData dataWithBytesNoCopy:outBytes length:o freeWhenDone:YES];
}


//NSString *DoTest(NSString *privateKeyPath, NSString *publicKeyPath, NSString *textPath, NSString *resultsPath)
//{
//    NSMutableArray *sha1Hashes       = [NSMutableArray array];
//
//    NSMutableArray *sha1Signatures   = [NSMutableArray array];
//
//    [sha1Hashes addObject:GetSHA1Hash([@"hello world" dataUsingEncoding:NSUTF8StringEncoding])];
//
//    // Now sign each hash
//    Signer *signer = [[Signer alloc] initWithContentsOfFile:privateKeyPath tag:@"com.iccir.SignAndVerify.private-key"];
//
//    for (NSData *hash in sha1Hashes) {
//        [sha1Signatures addObject:[signer signSHA1Hash:hash]];
//    }
//    
//    // Verify the signatures with the Verifier and public key
//    {
//        Verifier *verifier = [[Verifier alloc] initWithContentsOfFile:publicKeyPath tag:@"com.iccir.SignAndVerify.public-key"];
//
//        for (NSInteger i = 0; i < [sha1Hashes count]; i++) {
//            if (![verifier verifySHA1Hash:sha1Hashes[i] withSignature:sha1Signatures[i]]) {
//                NSLog(@"OS X Verifier failed to verify line %ld", (long)i);
//            }
//        }
//    }
//
//    NSMutableString *results = [NSMutableString string];
//
//    
//    for (NSInteger i = 0; i < [sha1Hashes count]; i++) {
//        
////        NSLog(@"%@",GetHexStringWithData(sha1Hashes[i]));
//        
////        [results appendFormat:@"%@\t",GetHexStringWithData(sha1Signatures[i])];
//
//        [results appendFormat:@"%@\t",[sha1Signatures[i] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]];
//        
//    }
//    
//    NSLog(@"%@",results);
//    
//    return results;
//}

#pragma mark - iOS Implementations

// From http://blog.flirble.org/2011/01/05/rsa-public-key-openssl-ios/
static NSData *sGetDataByStrippingHeader(NSData *data)
{
    NSUInteger length = [data length];
    if (!length) return nil;

    const void *bytes = [data bytes];
    NSUInteger index = 0;

    UInt8 (^getByte)(NSUInteger) = ^(NSUInteger i) {
        UInt8 result = 0;

        if (i < length) {
            result = ((UInt8 *)bytes)[i];
        }
        
        return result;
    };
    
    if (getByte(index++) != 0x30) {
        return nil;
    }

    if (getByte(index) > 0x80) {
        index += getByte(index) - 0x80 + 1;
    } else {
        index++;
    }

    // PKCS #1 rsaEncryption szOID_RSA_RSA
    static unsigned char seqiod[] = { 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00 };
    if ((index + 15) >= length) {
        return nil;
    }

    if (memcmp(&bytes[index], seqiod, 15)) return nil;

    index += 15;

    if (getByte(index++) != 0x03) return nil;

    if (getByte(index) > 0x80) {
        index += getByte(index) - 0x80 + 1;
    } else {
        index++;
    }

    if (getByte(index++) != '\0') return nil;

    // Now make a new NSData from this buffer
    return (index < length) ? [NSData dataWithBytes:&bytes[index] length:(length - index)] : nil;
}


static NSData *sExtractKey(NSString *inString)
{
    NSArray        *inLines   = [inString componentsSeparatedByString:@"\n"];
    NSMutableArray *outLines  = [NSMutableArray array];
    BOOL            insideKey = NO;

    for (NSString *line in inLines) {
        if ([line rangeOfString:@"KEY-----"].location != NSNotFound) {
            if ([line hasPrefix:@"-----BEGIN"]) {
                insideKey = YES;
            } else if ([line hasPrefix:@"-----END"]) {
                insideKey = NO;
            }

        } else if (insideKey) {
            [outLines addObject:line];
        }
    }

    NSString *outString = [outLines componentsJoinedByString:@"\n"];
    
    return [[NSData alloc] initWithBase64EncodedString:outString options:NSDataBase64DecodingIgnoreUnknownCharacters];
}

@implementation Signer {
    
    SecKeyRef _privateKey;
}


static Signer *customView;

+(instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        customView = [[Signer alloc] init];
    });
    return customView;
}

-(NSString *)formatPublickeySrting:(NSString *)key{
    
    NSRange spos = [key rangeOfString:@"-----BEGIN PUBLIC KEY-----"];
    NSRange epos = [key rangeOfString:@"-----END PUBLIC KEY-----"];
    if(spos.location != NSNotFound && epos.location != NSNotFound){
        NSUInteger s = spos.location + spos.length;
        NSUInteger e = epos.location;
        NSRange range = NSMakeRange(s, e-s);
        key = [key substringWithRange:range];
    }
    key = [key stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    key = [key stringByReplacingOccurrencesOfString:@" "  withString:@""];
    
    return key;
}

-(NSString *)getPublickKeyStringWithPublickeyPath:(NSString *)publickeyPath
{
    NSString *publickKey = nil;
    
    Verifier *verifier = [[Verifier alloc] initWithContentsOfFile:publickeyPath tag:@"com.iccir.SignAndVerify.public-key"];

    publickKey = [self formatPublickeySrting:verifier.publickKeyData];
    
//    NSLog(@"%@ \n %@",verifier.publickKeyData,publickKey);
    
    return publickKey;
}


- (NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
        
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        
        if([newHexStr length]==1)
            
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        
        else
            
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr]; 
    } 
    return hexStr; 
}

-(NSString *)signSHA1StringWithprivateKey:(NSString *)privateKeyPath publicKey:(NSString *)publicKeyPath andinPutText:(NSString *)inputString
{
    NSMutableArray *sha1Hashes       = [NSMutableArray array];
    
    NSMutableArray *sha1Signatures   = [NSMutableArray array];
    
    [sha1Hashes addObject:GetSHA1Hash([inputString dataUsingEncoding:NSUTF8StringEncoding])];
    
    _privateKey = [self _importPrivateKeyAtPath:privateKeyPath tag:@"com.iccir.SignAndVerify.private-key"];
    
    for (NSData *hash in sha1Hashes) {
        
        [sha1Signatures addObject:[self signSHA1Hash:hash]];
    }
    
    // Verify the signatures with the Verifier and public key
    {
        Verifier *verifier = [[Verifier alloc] initWithContentsOfFile:publicKeyPath tag:@"com.iccir.SignAndVerify.public-key"];
        
        for (NSInteger i = 0; i < [sha1Hashes count]; i++) {
            if (![verifier verifySHA1Hash:sha1Hashes[i] withSignature:sha1Signatures[i]]) {
                NSLog(@"OS X Verifier failed to verify line %ld", (long)i);
            }
        }
    }
    
    NSMutableString *results = [NSMutableString string];
    
    for (NSInteger i = 0; i < [sha1Hashes count]; i++) {
        
        [results appendFormat:@"%@\t",[sha1Signatures[i] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed]];
        
    }
    
    NSLog(@"%@",results);
    
    return results;
}

- (SecKeyRef) _importPrivateKeyAtPath:(NSString *)keyPath tag:(NSString *)tag CF_RETURNS_RETAINED
{
    NSError  *error     = nil;
    NSString *contents  = [NSString stringWithContentsOfFile:keyPath encoding:NSUTF8StringEncoding error:&error];
    
    NSLog(@"%@",contents);
    
    SecKeyRef keyRef = nil;
    
    NSData   *keyData   = sExtractKey(contents);

    NSData   *tagAsData = [tag dataUsingEncoding:NSUTF8StringEncoding];
    OSStatus  err       = 0;

    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    [dictionary setObject:(__bridge id)kSecClassKey       forKey:(__bridge id)kSecClass];
    [dictionary setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [dictionary setObject:tagAsData                       forKey:(__bridge id)kSecAttrApplicationTag];

    SecItemDelete((__bridge CFDictionaryRef)dictionary);

    [dictionary setObject:keyData                              forKey:(__bridge id)kSecValueData];
    [dictionary setObject:(__bridge id)kSecAttrKeyClassPrivate forKey:(__bridge id)kSecAttrKeyClass];

    err = SecItemAdd((__bridge CFDictionaryRef)dictionary, NULL);

    if ((err != noErr) && (err != errSecDuplicateItem)) {
        return NULL;
    }

    // Now fetch the SecKeyRef version of the key
    [dictionary removeObjectForKey:(__bridge id)kSecValueData];
    [dictionary setObject:@YES forKey:(__bridge id)kSecReturnRef];

    SecItemCopyMatching((__bridge CFDictionaryRef)dictionary, (CFTypeRef *)&keyRef);

    return keyRef;
}


- (NSData *) _signHash:(NSData *)hash withPadding:(SecPadding)padding
{
    size_t   signatureLength = SecKeyGetBlockSize(_privateKey);
    uint8_t *signatureBytes  = malloc(signatureLength);

    OSStatus err = SecKeyRawSign(_privateKey, padding, [hash bytes], [hash length], signatureBytes, &signatureLength);
    NSData *result = nil;
    
    if (err == errSecSuccess) {
        result = [NSData dataWithBytes:signatureBytes length:signatureLength];
    }
    
    free(signatureBytes);
    
    return result;

}

- (NSData *) signSHA1Hash:(NSData *)hash
{
    return [self _signHash:hash withPadding:kSecPaddingPKCS1SHA1];
}


- (NSData *) signSHA256Hash:(NSData *)hash
{
    return [self _signHash:hash withPadding:kSecPaddingPKCS1SHA256];
}


@end


@implementation Verifier {
    SecKeyRef _publicKey;
}


- (id) initWithContentsOfFile:(NSString *)path tag:(NSString *)tag
{
    if ((self = [super init])) {
        
        _publicKey = [self _importPublicKeyAtPath:path tag:tag];

        if (!_publicKey) {
            
            self = nil;
            return self;
        }
    }

    return self;
}


- (SecKeyRef) _importPublicKeyAtPath:(NSString *)keyPath tag:(NSString *)tag CF_RETURNS_RETAINED
{
    NSError  *error     = nil;
    NSString *contents  = [NSString stringWithContentsOfFile:keyPath encoding:NSUTF8StringEncoding error:&error];
    
    self.publickKeyData = contents;

    NSData   *keyData   = sGetDataByStrippingHeader(sExtractKey(contents));
    
    NSData   *tagAsData = [tag dataUsingEncoding:NSUTF8StringEncoding];

    OSStatus  err       = 0;

    NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
    [publicKey setObject:(__bridge id)kSecClassKey       forKey:(__bridge id)kSecClass];
    [publicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [publicKey setObject:tagAsData                       forKey:(__bridge id)kSecAttrApplicationTag];
    SecItemDelete((__bridge CFDictionaryRef)publicKey);

    [publicKey setObject:keyData                             forKey:(__bridge id)kSecValueData];
    [publicKey setObject:(__bridge id)kSecAttrKeyClassPublic forKey:(__bridge id)kSecAttrKeyClass];

    err = SecItemAdd((__bridge CFDictionaryRef)publicKey, NULL);

    if ((err != noErr) && (err != errSecDuplicateItem)) {
        return NULL;
    }

    // Now fetch the SecKeyRef version of the key
    SecKeyRef keyRef = nil;

    [publicKey removeObjectForKey:(__bridge id)kSecValueData];
    [publicKey setObject:@YES forKey:(__bridge id)kSecReturnRef];

    SecItemCopyMatching((__bridge CFDictionaryRef)publicKey, (CFTypeRef *)&keyRef);

    return keyRef;
}


- (BOOL) verifySHA1Hash:(NSData *)hash withSignature:(NSData *)signature
{
    OSStatus err = SecKeyRawVerify(_publicKey, kSecPaddingPKCS1SHA1, [hash bytes], [hash length], [signature bytes], [signature length]);
    return err == errSecSuccess;
}


- (BOOL) verifySHA256Hash:(NSData *)hash withSignature:(NSData *)signature
{
    OSStatus err = SecKeyRawVerify(_publicKey, kSecPaddingPKCS1SHA256, [hash bytes], [hash length], [signature bytes], [signature length]);
    return err == errSecSuccess;
}

@end
