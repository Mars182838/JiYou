//
//  AFHTTPRequestOperationManager+BKNetworking.m
//  GITDemo
//
//  Created by XING XIAOYANG on 8/25/14.
//  Copyright (c) 2014 BEIKOO. All rights reserved.
//

#import "AFHTTPRequestOperationManager+BKNetworking.h"
#import "BKNetworking.h"
#import "BKNetworkingModel.h"

@implementation AFHTTPRequestOperationManager (BKNetworking)

+ (instancetype)sharedInstance
{
    static id _bkRequestManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSURL* baseURL = [NSURL URLWithString:BKBaseURLString];
        _bkRequestManager = [[[self class] alloc] initWithBaseURL: baseURL];
    });
    
    return _bkRequestManager;
}

- (void)startRequestWithModel:(BKRequestModel *)requestModel
{
    AFHTTPRequestOperationManager* manager = self;
    switch (requestModel.type) {
        case BKRequestTypeGET: {
            
            NSLog(@"%@",requestModel.parameters);

            [manager GET:requestModel.urlString parameters:requestModel.parameters
                 success:^(AFHTTPRequestOperation *operation, id responseObject) {
                     NSAssert([responseObject isKindOfClass:[NSDictionary class]], @"Response must be dictionary. Request: %@",operation);
                     requestModel.afRequest = operation;
                     BKResponseModel* response = [[BKResponseModel alloc] initWithDictionary:responseObject];
                     //TODO: classify status code
                     if ([JYSuccessCode isEqualToString:response.head.code]) {
                         requestModel.success(requestModel, response);
                     } else {
                         requestModel.failure(requestModel, response.error);
                     }
                 } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                     requestModel.afRequest = operation;
                     requestModel.failure(requestModel, error);
                 }];
        }
            break;
        case BKRequestTypePOST: {
            NSLog(@"%@",requestModel.parameters);
            [manager POST:requestModel.urlString parameters:requestModel.parameters
                constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                    for (int i=0; i<requestModel.multipartData.count; i++) {
                        BKMultipartModel* part = requestModel.multipartData[i];
                        [formData appendPartWithFileURL:part.pathURL name:part.name error:nil];
                    }
                } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSAssert([responseObject isKindOfClass:[NSDictionary class]], @"Response must be dictionary. Request: %@",operation);
                    requestModel.afRequest = operation;
                    BKResponseModel* response = [[BKResponseModel alloc] initWithDictionary:responseObject];
                    //TODO: classify status code
                    if ([JYSuccessCode isEqualToString:response.head.code]) {
                        requestModel.success(requestModel, response);
                    } else {
                        requestModel.failure(requestModel, response.error);
                    }
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    requestModel.afRequest = operation;
                    requestModel.failure(requestModel, error);
                }];
        }
            break;
            
        default:
            NSAssert(NO, @"Request should be get or post");
            break;
    }
}

- (void)requestWithType:(BKRequestType)type urlString:(NSString *)urlString params:(id)params part:(NSArray *)part success:(BKRequestSuccessBlock)success failure:(BKRequestFailureBlock)failure
{
    BKRequestModel* req = [[BKRequestModel alloc]
                           initWithType:type
                           urlString:urlString
                           params:params
                           part:part
                           success:success
                           failure:failure];
    [self startRequestWithModel:req];
}
@end
