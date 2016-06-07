//
//  BKNetworkingModel.m
//  GITDemo
//
//  Created by XING XIAOYANG on 8/25/14.
//  Copyright (c) 2014 BEIKOO. All rights reserved.
//

#import "BKNetworkingModel.h"
#import "AFNetworking.h"
#import "YJ_OpenUDID.h"

NSString* const BKNetworkingResponseErrorDomain = @"com.beikoo.BKNetworking.Response";
NSInteger const BKNetworkingResponseErrorCodeNeedLogin = 12345;

#pragma mark - BKMultipartModel
@implementation BKMultipartModel

+ (instancetype)multipartWithName:(NSString *)name andURL:(NSURL *)pathURL
{
    return [[[self class] alloc] initWithName:name andURL:pathURL];
}

+ (instancetype)multipartWithName:(NSString *)name andPath:(NSString *)path
{
    return [[[self class] alloc] initWithName:name andPath:path];
}

- (instancetype)initWithName:(NSString *)name andURL:(NSURL *)pathURL
{
    self = [super init];
    if (self) {
        self.name = name;
        self.pathURL = pathURL;
    }
    return self;
}

- (instancetype)initWithName:(NSString *)name andPath:(NSString *)path
{
    self = [super init];
    if (self) {
        self.name = name;
        self.pathURL = [NSURL fileURLWithPath:path];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, name: %@, file: %@", NSStringFromClass([self class]), self,  self.name, self.pathURL];
}

@end


#pragma mark - BKRequestHead
@implementation BKRequestHead
+ (instancetype)standardRequestHead
{
    static BKRequestHead* head = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        head = [[self alloc] init];
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        head.appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        head.open_udid = [YJ_OpenUDID value];
    });
    
    return head;
}

- (NSString *)description
{
     return [NSString stringWithFormat:@"<%@: %p, appVersion: %@, token: %@", NSStringFromClass([self class]), self,  self.appVersion, self.token];
}


@end

#pragma mark - BKRequestModel
@implementation BKRequestModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.head          = [BKRequestHead standardRequestHead];
        self.type          = BKRequestTypePOST;
        self.multipartData = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithType:(BKRequestType)type urlString:(NSString *)urlString params:(id)params part:(NSArray *)part success:(BKRequestSuccessBlock)success failure:(BKRequestFailureBlock)failure
{
    self = [super init];
    if (self) {
        self.head = [BKRequestHead standardRequestHead];
        self.type = type;
        self.urlString = urlString;
        self.parameters = params;
        self.success = success;
        self.failure =failure;
        self.multipartData = part?[NSMutableArray arrayWithArray:part]:[NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    DLog(@"%@", self.urlString);
}

- (id)parameters
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObjects:@[JYMerID, self.head.appVersion,self.head.open_udid,@"inhouse"] forKeys:@[@"appMerId",@"appVersion",@"openUDID",@"distribution"]];
    if ([_parameters isKindOfClass:[NSDictionary class]]) {
        [dict addEntriesFromDictionary:_parameters];
    }
    return dict;
}


-(NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, type: %@, head: %@, multipart: %@", NSStringFromClass([self class]), self,  ((_type==BKRequestTypeGET) ? @"GET" : @"POST"), self.head, self.multipartData];
}


#pragma mark - Accessor
//- (void)setType:(BKRequestType)type
//{
//#ifdef NETWORK_ENVIRONMENT_RAW
//    _type = BKRequestTypeGET;
//#else
//    if (type!=_type) {
//        _type = type;
//    }
//#endif
//    
//}

- (void)cancel
{
    [self.afRequest cancel];
}

@end

#pragma mark - BKResponseHead
@implementation BKResponseHead

- (instancetype)initWithDictionary:(NSDictionary *)infoHeadDict
{
    self = [super init];
    if (self) {
        
//        NSAssert([infoHeadDict isKindOfClass:[NSDictionary class]], @"BKResponseHead must be init with dictionary");
        self.code = @"-1";
        self.msg = @"";
        if (infoHeadDict[@"code"] && (NSNull *)(infoHeadDict[@"code"])!=[NSNull null]) {
            self.code = infoHeadDict[@"code"];
        }
        if (infoHeadDict[@"msg"] && (NSNull *)(infoHeadDict[@"msg"])!=[NSNull null]) {
            self.msg = infoHeadDict[@"msg"];
        }
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, code: %@, msg: %@>", NSStringFromClass([self class]), self,  self.code, self.msg];
}

@end 

#pragma mark - BKResponseModel
@implementation BKResponseModel

- (instancetype)initWithDictionary:(id)infoDict
{
    self = [super init];
    if (self) {
#ifdef NETWORK_JSON_WITHOUT_HEAD
//        self.head = [BKResponseHead new];
//        self.head.status = (NSNull *)infoDict[@"headStatus"]==[NSNull null] ? @"0" : infoDict[@"headStatus"];
//        self.head.message = (NSNull *)infoDict[@"headMessage"]==[NSNull null] ? @"" : infoDict[@"headMessage"];
        self.responseObject = infoDict;
        self.needLogin = (self.responseObject && [self.responseObject isKindOfClass:[NSDictionary class]] && [self.responseObject[@"needLogin"] boolValue]);
#else
        if ([infoDict isKindOfClass:[NSDictionary class]]) {
            
            self.head = [[BKResponseHead alloc] initWithDictionary:infoDict[@"head"]];
            self.responseObject = infoDict[@"body"];
            
        }
      
#endif 
    }
    return self;
}

- (NSError *)error
{
    //TODO: classify status code
    NSError* e = nil;
#ifdef NETWORK_JSON_WITHOUT_HEAD
    if (self.needLogin) {
        e = [[NSError alloc] initWithDomain:BKNetworkingResponseErrorDomain code:BKNetworkingResponseErrorCodeNeedLogin userInfo:@{@"message": @"needlogin"}];
    }
#else
    if (![JYSuccessCode isEqualToString:self.head.code]) {
        e = [[NSError alloc] initWithDomain:BKNetworkingResponseErrorDomain code:[self.head.code intValue] userInfo:@{@"message": self.head.msg}];
    }
#endif
    
    
    return e;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p, head: %@, response: %@>", NSStringFromClass([self class]), self,  self.head, self.responseObject];
}
@end