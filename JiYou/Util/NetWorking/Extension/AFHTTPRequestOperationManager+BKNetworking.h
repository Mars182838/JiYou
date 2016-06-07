//
//  AFHTTPRequestOperationManager+BKNetworking.h
//  GITDemo
//
//  Created by XING XIAOYANG on 8/25/14.
//  Copyright (c) 2014 BEIKOO. All rights reserved.
//

#import "AFHTTPRequestOperationManager.h"
#import "BKNetworkingModel.h"

extern NSString* const BKBaseURLString;

@interface AFHTTPRequestOperationManager (BKNetworking)
+ (instancetype)sharedInstance;
- (void)startRequestWithModel:(BKRequestModel *)requestModel;
- (void)requestWithType:(BKRequestType)type
              urlString:(NSString *)urlString
                 params:(id)params
                   part:(NSArray *)part
                success:(BKRequestSuccessBlock)success
                failure:(BKRequestFailureBlock)failure;
@end
