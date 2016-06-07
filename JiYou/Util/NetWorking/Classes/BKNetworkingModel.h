//
//  BKNetworkingModel.h
//  GITDemo
//
//  Created by XING XIAOYANG on 8/25/14.
//  Copyright (c) 2014 BEIKOO. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AFHTTPRequestOperation;
@class AFHTTPRequestOperationManager;
@class BKRequestModel;
@class BKResponseModel;

typedef enum : NSUInteger {
    BKRequestTypeGET = 1,
    BKRequestTypePOST,
} BKRequestType;

typedef void(^BKRequestSuccessBlock)(BKRequestModel *request, BKResponseModel* response);
typedef void(^BKRequestFailureBlock)(BKRequestModel *request, NSError *error);

extern NSString* const BKNetworkingResponseErrorDomain;

#pragma mark - BKMultipartModel
@interface BKMultipartModel : NSObject

@property (nonatomic, copy) NSString* name;
@property (nonatomic, copy) NSURL* pathURL;

+ (instancetype)multipartWithName:(NSString *)name andURL:(NSURL *)pathURL;
+ (instancetype)multipartWithName:(NSString *)name andPath:(NSString *)path;
- (instancetype)initWithName:(NSString *)name andURL:(NSURL *)pathURL;
- (instancetype)initWithName:(NSString *)name andPath:(NSString *)path;

@end


#pragma mark - BKRequestHead
@interface BKRequestHead : NSObject

@property (nonatomic, copy) NSString* appVersion;
@property (nonatomic, copy) NSString* token;
@property (nonatomic, copy) NSString *open_udid;

+ (instancetype)standardRequestHead;

@end


#pragma mark - BKRequestModel
@interface BKRequestModel : NSObject
@property (nonatomic, assign) NSInteger retryTimes;
@property (nonatomic, assign) BKRequestType type;
@property (nonatomic, copy) NSString* urlString;
@property (nonatomic, strong) BKRequestHead* head;
@property (nonatomic, strong) id parameters; //array or dictionary
@property (nonatomic, strong) NSMutableArray* multipartData; //array of BKMultipartModel
@property (nonatomic, copy) BKRequestSuccessBlock success;
@property (nonatomic, copy) BKRequestFailureBlock failure;
@property (nonatomic, strong) AFHTTPRequestOperation* afRequest;

- (instancetype)initWithType:(BKRequestType)type
                   urlString:(NSString *)urlString
                      params:(id)params
                        part:(NSArray *)part
                     success:(BKRequestSuccessBlock)success
                     failure:(BKRequestFailureBlock)failure;
- (void)cancel;
@end


#pragma mark - BKResponseHead
@interface BKResponseHead : NSObject

@property (nonatomic, copy) NSString* code;
@property (nonatomic, copy) NSString* msg;

- (instancetype)initWithDictionary:(NSDictionary *)infoHeadDict;
@end


#pragma mark - BKResponseModel
@interface BKResponseModel : NSObject
@property (nonatomic, strong) BKResponseHead* head;
@property (nonatomic, strong) id responseObject; // array or dictionary

- (instancetype)initWithDictionary:(id)infoDict;
- (NSError *)error;

@end