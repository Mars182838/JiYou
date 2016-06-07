//
//  BKRequestProxy.h
//  BEIKOO
//
//  Created by leo on 14-9-10.
//  Copyright (c) 2014年 BEIKOO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BKNetworking.h"

extern NSString* const BKBaseURLString;
extern NSString* const JYSuccessCode;
extern NSString* const JYNeedLoginCodeNotification;
extern NSString* const JYLoginNotification;
extern NSString *const JYMerID;
//extern NSString* const BKCancelLoginViewControllerNotification;
//extern NSString* const BKSuccseeLoginNotification;

@interface BKRequestProxy : NSObject

+ (instancetype)sharedInstance;
- (void)startRequestWithModel:(BKRequestModel *)requestModel;
- (BKRequestModel *)requestWithType:(BKRequestType)type
              urlString:(NSString *)urlString
                 params:(id)params
                   part:(NSArray *)part
                success:(BKRequestSuccessBlock)success
                failure:(BKRequestFailureBlock)failure;

@end
