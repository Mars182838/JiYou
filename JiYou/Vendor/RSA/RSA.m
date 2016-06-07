/*
 @author: ideawu
 @link: https://github.com/ideawu/Objective-C-RSA
*/

#import "RSA.h"
#import <Security/Security.h>

@implementation RSA

static NSString *base64_encode_data(NSData *data){
	data = [data base64EncodedDataWithOptions:0];
	NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return ret;
}

static NSData *base64_decode(NSString *str){
	NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
	return data;
}

+ (NSData *)stripPublicKeyHeader:(NSData *)d_key{
	// Skip ASN.1 public key header
	if (d_key == nil) return(nil);
	
	unsigned long len = [d_key length];
	if (!len) return(nil);
	
	unsigned char *c_key = (unsigned char *)[d_key bytes];
	unsigned int  idx	= 0;
	
	if (c_key[idx++] != 0x30) return(nil);
	
	if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
	else idx++;
	
	// PKCS #1 rsaEncryption szOID_RSA_RSA
	static unsigned char seqiod[] =
	{ 0x30,   0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01,
		0x01, 0x05, 0x00 };
	if (memcmp(&c_key[idx], seqiod, 15)) return(nil);
	
	idx += 15;
	
	if (c_key[idx++] != 0x03) return(nil);
	
	if (c_key[idx] > 0x80) idx += c_key[idx] - 0x80 + 1;
	else idx++;
	
	if (c_key[idx++] != '\0') return(nil);
	
	// Now make a new NSData from this buffer
	return([NSData dataWithBytes:&c_key[idx] length:len - idx]);
}

+ (SecKeyRef)addPublicKey:(NSString *)key{
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
	
	// This will be base64 encoded, decode it.
	NSData *data = base64_decode(key);
	data = [RSA stripPublicKeyHeader:data];
	if(!data){
		return nil;
	}
	
	NSString *tag = @"what_the_fuck_is_this";
	NSData *d_tag = [NSData dataWithBytes:[tag UTF8String] length:[tag length]];
	
	// Delete any old lingering key with the same tag
	NSMutableDictionary *publicKey = [[NSMutableDictionary alloc] init];
	[publicKey setObject:(__bridge id) kSecClassKey forKey:(__bridge id)kSecClass];
	[publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
	[publicKey setObject:d_tag forKey:(__bridge id)kSecAttrApplicationTag];
	SecItemDelete((__bridge CFDictionaryRef)publicKey);
	
	// Add persistent version of the key to system keychain
	[publicKey setObject:data forKey:(__bridge id)kSecValueData];
	[publicKey setObject:(__bridge id) kSecAttrKeyClassPublic forKey:(__bridge id)
	 kSecAttrKeyClass];
	[publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)
	 kSecReturnPersistentRef];
	
	CFTypeRef persistKey = nil;
	OSStatus status = SecItemAdd((__bridge CFDictionaryRef)publicKey, &persistKey);
	if (persistKey != nil){
		CFRelease(persistKey);
	}
	if ((status != noErr) && (status != errSecDuplicateItem)) {
		return nil;
	}

	[publicKey removeObjectForKey:(__bridge id)kSecValueData];
	[publicKey removeObjectForKey:(__bridge id)kSecReturnPersistentRef];
	[publicKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
	[publicKey setObject:(__bridge id) kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
	
	// Now fetch the SecKeyRef version of the key
	SecKeyRef keyRef = nil;
	status = SecItemCopyMatching((__bridge CFDictionaryRef)publicKey, (CFTypeRef *)&keyRef);
	if(status != noErr){
		return nil;
	}
	return keyRef;
}

+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey{
	NSData *data = [RSA encryptData:[str dataUsingEncoding:NSUTF8StringEncoding] publicKey:pubKey];
	NSString *ret = base64_encode_data(data);
	return ret;
}

+ (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey{
	if(!data || !pubKey){
		return nil;
	}
	SecKeyRef keyRef = [RSA addPublicKey:pubKey];
	if(!keyRef){
		return nil;
	}
	
	const uint8_t *srcbuf = (const uint8_t *)[data bytes];
	size_t srclen = (size_t)data.length;
	
    
	size_t outlen = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
	if(srclen > outlen - 11){
		CFRelease(keyRef);
		return nil;
	}
	void *outbuf = malloc(outlen);
	
	OSStatus status = noErr;
	status = SecKeyEncrypt(keyRef,
						   kSecPaddingPKCS1,
						   srcbuf,
						   srclen,
						   outbuf,
						   &outlen
						   );
	NSData *ret = nil;
	if (status != 0) {
		//NSLog(@"SecKeyEncrypt fail. Error Code: %ld", status);
	}else{
		ret = [NSData dataWithBytes:outbuf length:outlen];
	}
	free(outbuf);
	CFRelease(keyRef);
	return ret;
}

+ (NSString *)decryptString:(NSString *)str publicKey:(NSString *)pubKey{
	NSData *data = [[NSData alloc] initWithBase64EncodedString:str options:NSDataBase64DecodingIgnoreUnknownCharacters];
	data = [RSA decryptData:data publicKey:pubKey];
	NSString *ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	return ret;
}

+ (NSData *)decryptData:(NSData *)data publicKey:(NSString *)pubKey{
	if(!data || !pubKey){
		return nil;
	}
	SecKeyRef keyRef = [RSA addPublicKey:pubKey];
	if(!keyRef){
		return nil;
	}
	
	const uint8_t *srcbuf = (const uint8_t *)[data bytes];
	size_t srclen = (size_t)data.length;
	
	size_t outlen = SecKeyGetBlockSize(keyRef) * sizeof(uint8_t);
	if(srclen != outlen){
		//TODO currently we are able to decrypt only one block!
		CFRelease(keyRef);
		return nil;
	}
	UInt8 *outbuf = malloc(outlen);
	
	//use kSecPaddingNone in decryption mode
	OSStatus status = noErr;
	status = SecKeyDecrypt(keyRef,
						   kSecPaddingNone,
						   srcbuf,
						   srclen,
						   outbuf,
						   &outlen
						   );
	NSData *result = nil;
	if (status != 0) {
		//NSLog(@"SecKeyEncrypt fail. Error Code: %ld", status);
	}else{
		//the actual decrypted data is in the middle, locate it!
		int idxFirstZero = -1;
		int idxNextZero = (int)outlen;
		for ( int i = 0; i < outlen; i++ ) {
			if ( outbuf[i] == 0 ) {
				if ( idxFirstZero < 0 ) {
					idxFirstZero = i;
				} else {
					idxNextZero = i;
					break;
				}
			}
		}
		
		result = [NSData dataWithBytes:&outbuf[idxFirstZero+1] length:idxNextZero-idxFirstZero-1];
	}
	free(outbuf);
	CFRelease(keyRef);
	return result;
}

+(NSString *)signWithString:(NSData *)plainData privateKey:(NSString *)praKey
{
    SecKeyRef privateKey = NULL;
    privateKey = [RSA addPublicKey:praKey];

    size_t signedHashBytesSize = SecKeyGetBlockSize(privateKey);
    uint8_t* signedHashBytes = malloc(signedHashBytesSize);
    memset(signedHashBytes, 0x0, signedHashBytesSize);
    
    size_t hashBytesSize = CC_SHA1_DIGEST_LENGTH;
    uint8_t* hashBytes = malloc(hashBytesSize);
    if (!CC_SHA256([plainData bytes], (CC_LONG)[plainData length], hashBytes)) {
        return nil;
    }
    
    SecKeyRawSign(privateKey,
                  kSecPaddingPKCS1SHA256,
                  hashBytes,
                  hashBytesSize,
                  signedHashBytes,
                  &signedHashBytesSize);
    
    NSData* signedHash = [NSData dataWithBytes:signedHashBytes
                                        length:(NSUInteger)signedHashBytesSize];
    
//    if (hashBytes)
//        free(hashBytes);
//    if (signedHashBytes)
//        free(signedHashBytes);

    return [signedHash base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

+ (NSString *)getSignatureBytes:(NSData *)plainText andKeyString:(NSString *)key{
    
    OSStatus sanityCheck = noErr;
    NSData * signedHash = nil;
    
    uint8_t * signedHashBytes = NULL;
    size_t signedHashBytesSize = 0;
    
    SecKeyRef privateKey = NULL;
    
    privateKey = [RSA addPublicKey:key];
    NSLog(@"%@",privateKey);
    signedHashBytesSize = SecKeyGetBlockSize(privateKey);
    
    // Malloc a buffer to hold signature.
    signedHashBytes = malloc( signedHashBytesSize * sizeof(uint8_t) );
    memset((void *)signedHashBytes, 0x0, signedHashBytesSize);
    
    // Sign the SHA1 hash.
    sanityCheck = SecKeyRawSign(    privateKey,
                                kTypeOfSigPadding,
                                (const uint8_t *)[[self getHashBytes:plainText] bytes],
                                kChosenDigestLength,
                                (uint8_t *)signedHashBytes,
                                &signedHashBytesSize
                                );
    
    LOGGING_FACILITY1( sanityCheck == noErr, @"Problem signing the SHA1 hash, OSStatus == %d.", (int)sanityCheck );
    
    // Build up signed SHA1 blob.
    signedHash = [NSData dataWithBytes:(const void *)signedHashBytes length:(NSUInteger)signedHashBytesSize];
    
    NSString *signeString = [signedHash base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    if (signedHashBytes) free(signedHashBytes);
    
    return signeString;
}

+ (NSData *)getHashBytes:(NSData *)plainText {
    CC_SHA1_CTX ctx;
    uint8_t * hashBytes = NULL;
    NSData * hash = nil;
    
    // Malloc a buffer to hold hash.
    hashBytes = malloc( kChosenDigestLength * sizeof(uint8_t) );
    memset((void *)hashBytes, 0x0, kChosenDigestLength);
    
    // Initialize the context.
    CC_SHA1_Init(&ctx);
    // Perform the hash.
    CC_SHA1_Update(&ctx, (void *)[plainText bytes], [plainText length]);
    // Finalize the output.
    CC_SHA1_Final(hashBytes, &ctx);
    
    // Build up the SHA1 blob.
    hash = [NSData dataWithBytes:(const void *)hashBytes length:(NSUInteger)kChosenDigestLength];
    
    if (hashBytes) free(hashBytes);

    return hash;
}

@end
