//
//  Shared.h
//  SignAndVerify
//
//  Created by Ricci Adams on 2014-07-20.
//
//

#import <Foundation/Foundation.h>

extern NSData *GetSHA1Hash(NSData *inData);
extern NSData *GetSHA256Hash(NSData *inData);

extern NSString *GetHexStringWithData(NSData *data);
extern NSData   *GetDataWithHexString(NSString *inputString);

//extern NSString *DoTest(NSString *privateKeyPath, NSString *publicKeyPath, NSString *inputTextPath, NSString *resultsPath);

@interface Signer : NSObject

+(instancetype) shareInstance;

- (NSString *)getPublickKeyStringWithPublickeyPath:(NSString *)publickeyPath;
- (NSData *) signSHA1Hash:(NSData *)hash;
- (NSData *) signSHA256Hash:(NSData *)hash;

- (NSString *)signSHA1StringWithprivateKey:(NSString *)privateKeyPath publicKey:(NSString *)publicKeyPath andinPutText:(NSString *)inputString;

- (NSString *)hexStringFromString:(NSString *)string;

@end


@interface Verifier : NSObject

@property (nonatomic, copy) NSString *publickKeyData;

- (id) initWithContentsOfFile:(NSString *)path tag:(NSString *)tag;

- (BOOL) verifySHA1Hash:(NSData *)hash   withSignature:(NSData *)signature;
- (BOOL) verifySHA256Hash:(NSData *)hash withSignature:(NSData *)signature;

@end
