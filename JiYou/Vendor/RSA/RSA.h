/*
 @author: ideawu
 @link: https://github.com/ideawu/Objective-C-RSA
*/

#import <Foundation/Foundation.h>

#define PUBLICKEY @"-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAvF07oIfxIQMTCCHiJLSE\nd/aJaSxeNj3aloXi9RG2BnS03MWwhOiS2zE5vjg6F8jTlVSwY0P06I0KDpYHmoDI\nVfBRF4Lzc39t/4iej7V/j2R8G/xz09Zzhj0wPlwUuRS3dkOGaAOznTxnR7nbEnTE\nKd3+1+FjsFNr4KprKPT+vK1zNCK9hDKTN/Vc+MhTWIV9Uy+zd2MB+s4ogtUnbejd\nJxENzrTMIiYlNZxaj54Hk50rpKov8JTXnbeySz7Bb6Zt3G2GRvqArGQJa0RlCYKk\njwOZ/Tto9bz4rkrWBoRWRlj+GvZjkx+lkUJNcrG1l+EBoyqTzSF4qFeiKqYppjHC\niQIDAQAB\n-----END PUBLIC KEY-----"

#define PRIVATEKEY @"-----BEGIN RSA PRIVATE KEY-----\nMIIEogIBAAKCAQEAqJKppmlTx/peJwGnBzLfgOB5WR7VAGwY9NyH68FDKwsdMi+t\nE956pDXgz1PIGMxWhDEoV1Fy4+o64wNY5edz5gKks497MBtxUPCK9ZasK+Cjlw3v\nUbu5arBc8dTGbl1AA9llZHjSguLeZjbN2JoBf5XTMA9dANVWtlzfw6IAnDROGKm4\nzF8zfsslm425UW3LIHC0lU+cLg/SiHnNKW8U4NWN9Bdo+TR2dRvVwCM9ITL2PZ6k\nlQABjIVL3Zhni5tw1IrF0Vc73z+lLuna1VC/Rk2jED1EzL/XTvRnmh2LGKs0ZrkY\nC7nzRjmQJOlpztgqZnEXafPG9u1gvcanZ1Ll0wIDAQABAoIBAHTqc7u1ZaRXY6HO\nJZh6kkWCaueC2NyYHJ8HrUW4Huvlo3RBWNtk/M6Th76EL03zuzWoGoClPvgQZpM4\nqRmbc+jdgHoBU8FD503p55b5z6QHA68qvQeFGc6DT5NyrcWx60pAJ3CN1ANvciyW\naiKGfe+NbJHyteB0FtYYiCHZZG7xP8qPUJossAHbuT4LI1JQi4HFDVqELHkzD/DD\nfeHPOnFgBMzl4sv3ARDOPiD0JL6nawNnmjU8DQqvdV3Y3TGfE0SkzC2Lx2ee/pvF\nuouFxc+2wXoA53tZC3dgL1HcLuqzUc31UlqvN2VARdczt9oktMMwOlmHQ+iPCNFp\nTynKqEECgYEA1apOap84L9G1NRQMcU87+TcmCTvmwydrINT61HphJJxTwuL4k20T\nq+PNTCj0Qwp86OxWBMvxEiLGYc7NkCLpnNeeaAfuB36xkYs9KkzVN2/srx/rzzmD\niIrKAKU9Gq1/DlvPj/W3Ch4SCWaP3FwkY8oYZ+KbNVUoKjvOrrOJOYMCgYEAyfkl\nqLWIAkD2eP7hUqgA4NiEJ7gQk5BFamlTKVwtjjie6PfOWohYLrfVgqUmRXyBFCOS\nAx577OiFUgp6FT8PlfJbb/cTdObJlXcoJIkRBUzc61Qjic3Z5kzhYlaHPs5xI3p9\nCJ75cs1MvKU41eZWMxW+5iZdKvXXLscp22utAXECgYA//DJjh67h0yE69fgL7rh9\nF2DSnxeqFaHlQSKkgsmYlyAWWrYqIB4l+aA/UHxlnzxs3GmeIhzdW4ChRbcVlP70\nszWC3e0QXYZ7mYEFq+CmK2RrxVluw0B6oWWA7/ruhEpqWGA+Mk1QQFUSb55hVU6o\ne5r3cUsdm5TdoO9yLd3IVQKBgHMMI6J1PTMjdAI6FXlyz4VEcAr78x1LOe9CbaeK\npTx1DjfgKEAzmB+Mged4UVOVdyVUmbCDJc4uKPsxkpcVo7gjJGij0gZuC/fCtzAQ\nj4x4WwMFm3S8uFlSA7RzW3iwOYwfEqfdfnQhc4ulhbl6CjHxOht5UOrOvLMdqb8e\nF59RAoGAIu4onNMzTn3++gNpdwV+ZaSNWFsnW9TE9K515x7SBgKOpG6EdbBq8g1O\nDZYh8zIU5RYZQndQy/X8Sr2eO/OlBdNWNj/H/GrOaODy6D8hzZ1z8idZLWJOYm70\nI8q5ACsRgdUvPWX3FQFqefpAQ4Nc3wswg0roleS7x8AwcGyp3mo=\n-----END RSA PRIVATE KEY-----"


#import <Security/Security.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

// The chosen symmetric key and digest algorithm chosen for this sample is AES and SHA1.
// The reasoning behind this was due to the fact that the iPhone and iPod touch have
// hardware accelerators for those particular algorithms and therefore are energy efficient.

#define kChosenCipherBlockSize  kCCBlockSizeAES128
#define kChosenCipherKeySize    kCCKeySizeAES128
#define kChosenDigestLength     CC_SHA1_DIGEST_LENGTH

// Global constants for padding schemes.
#define kPKCS1                  11
#define kTypeOfWrapPadding      kSecPaddingPKCS1
#define kTypeOfSigPadding       kSecPaddingPKCS1SHA1

#define LOGGING_FACILITY(X, Y)  \
if (!(X)) {         \
NSLog(Y);       \
}

#define LOGGING_FACILITY1(X, Y, Z)  \
if (!(X)) {             \
NSLog(Y, Z);        \
}

@interface RSA : NSObject

// return base64 encoded string
+ (NSString *)encryptString:(NSString *)str publicKey:(NSString *)pubKey;
// return raw data
+ (NSData *)encryptData:(NSData *)data publicKey:(NSString *)pubKey;
// TODO:
//+ (NSString *)encryptString:(NSString *)str privateKey:(NSString *)privKey;
//+ (NSData *)encryptData:(NSData *)data privateKey:(NSString *)privKey;

// decrypt base64 encoded string, convert result to string(not base64 encoded)
+ (NSString *)decryptString:(NSString *)str publicKey:(NSString *)pubKey;
+ (NSData *)decryptData:(NSData *)data publicKey:(NSString *)pubKey;
// TODO:
//+ (NSString *)decryptString:(NSString *)str privateKey:(NSString *)privKey;
//+ (NSData *)decryptData:(NSData *)data privateKey:(NSString *)privKey;

+(NSString *)signWithString:(NSData *)plainData privateKey:(NSString *)praKey;

+ (NSString *)getSignatureBytes:(NSData *)plainText andKeyString:(NSString *)key;

+ (NSData *)getHashBytes:(NSData *)plainText;
@end
