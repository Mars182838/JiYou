//
//  JYUploadProtraitImageNetworking.h
//  JiYou
//
//  Created by 俊王 on 15/9/2.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JYUserModel.h"
#import "BKNetworkingModel.h"

typedef void(^ProtraitImageSuccessBlock)();

@interface JYUploadProtraitImageNetworking : NSObject<NSURLConnectionDelegate,NSURLConnectionDataDelegate>

@property(nonatomic, strong) BKRequestModel *requestModel;

@property(nonatomic, strong) NSMutableData *mdata;

+(instancetype) sharedInstance;

-(void)uploadImageWithProtrait:(UIImage *)image;

@property (nonatomic, copy) ProtraitImageSuccessBlock successBlock;

@end
