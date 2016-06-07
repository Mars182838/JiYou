//
//  BKRequestProxy.m
//  BEIKOO
//
//  Created by leo on 14-9-10.
//  Copyright (c) 2014年 BEIKOO. All rights reserved.
//

#import "BKRequestProxy.h"
#import "AFNetworking.h"
#import "NSDictionary+BKJSONDictionary.h"
#import "JYUserModel.h"
#import "BKCustomProgressHUD.h"

#ifdef NETWORK_ENVIRONMENT_TEST_LOGIN
NSString* const BKBaseURLString = @"http://121.40.251.36:9080";
#endif

#ifdef NETWORK_ENVIRONMENT_TEST_REGISTER
NSString* const BKBaseURLString = @"http://10.10.10.125:8080";
#endif

#ifdef NETWORK_ENVIRONMENT_TEST_PRODUCT
NSString* const BKBaseURLString = @"http://120.26.127.54:8083";
#endif

#ifdef NETWORK_ENVIRONMENT_TEST_HUPENG
NSString* const BKBaseURLString = @"http://10.10.17.8:8080";
#endif

#ifdef NETWORK_ENVIRONMENT_TEST_JK
NSString* const BKBaseURLString = @"http://10.10.17.71:8099";
#endif
//
//#ifdef NETWORK_ENVIRONMENT_PROD
//NSString* const BKBaseURLString = @"https://viplending.com/";
////NSString* const BKBaseURLString = @"http://10.3.32.45:8091/";
//#endif

NSString * const JYSuccessCode = @"0000";
NSString * const JYNeedLoginCodeNotification = @"5001";
NSString * const JYLoginNotification = @"JYLoginNotification";

// To do
NSString * const JYMerID = @"100000000000003";///待定

@interface BKRequestProxy ()
@property (nonatomic, strong) NSArray* needGestureURLs;
@end

@implementation BKRequestProxy

+ (instancetype)sharedInstance
{
    static BKRequestProxy* defaultProxy = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        defaultProxy = [[[self class] alloc] init];
    });
    
    return defaultProxy;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)startRequestWithModel:(BKRequestModel *)requestModel
{
    AFHTTPRequestOperationManager* manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BKBaseURLString]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringCacheData;
    
    switch (requestModel.type) {
            
        case BKRequestTypeGET: {
            manager.requestSerializer.timeoutInterval = 4.0;
            requestModel.afRequest = [manager GET:requestModel.urlString parameters:requestModel.parameters
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {

                     NSDictionary* dict = [NSDictionary dictionaryWithJSONString:operation.responseString];
                     
                     BKResponseModel* response = [[BKResponseModel alloc] initWithDictionary:[dict isKindOfClass:[NSDictionary class]]?dict:operation.responseString];
                     if ([response.head.code isEqualToString:JYNeedLoginCodeNotification]) {
                         
                         [[JYUserModel shareInstance] loginWithFinishBlock:^{
                             
                         }];

                     } else {
                         requestModel.success(requestModel, response);
                     }
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     requestModel.failure(requestModel, error);
                     
                 }];
            
        }
        break;
            
        case BKRequestTypePOST: {
            manager.requestSerializer.timeoutInterval = 10.0;
            requestModel.afRequest = [manager POST:requestModel.urlString parameters:requestModel.parameters
              success:^(AFHTTPRequestOperation *operation, id responseObject) {

                  NSDictionary* dict = [NSDictionary dictionaryWithJSONString:operation.responseString];
                  
                  BKResponseModel* response = [[BKResponseModel alloc] initWithDictionary:[dict isKindOfClass:[NSDictionary class]]?dict:operation.responseString];
                  
                  if ([response.head.code isEqualToString:JYNeedLoginCodeNotification]) {
                    
                      [[JYUserModel shareInstance] loginWithFinishBlock:^{
                          
                      }];
                      
                  } else {
                      
                      requestModel.success(requestModel, response);
                  }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                requestModel.failure(requestModel, error);
                
            }];
        }
        break;
            
        default:
            NSAssert(NO, @"Request should be get or post");
        break;
    }
}

- (BKRequestModel *)requestWithType:(BKRequestType)type urlString:(NSString *)urlString params:(id)params part:(NSArray *)part success:(BKRequestSuccessBlock)success failure:(BKRequestFailureBlock)failure
{
    BKRequestModel* req = [[BKRequestModel alloc]
                           initWithType:type
                           urlString:urlString
                           params:params
                           part:part
                           success:success
                           failure:failure];
  
    [self startRequestWithModel:req];
    return req;
}

@end
