//
//  JYUploadProtraitImageNetworking.m
//  JiYou
//
//  Created by 俊王 on 15/9/2.
//  Copyright (c) 2015年 JY. All rights reserved.
//

#import "JYUploadProtraitImageNetworking.h"

@implementation JYUploadProtraitImageNetworking

+ (instancetype)sharedInstance
{
    static JYUploadProtraitImageNetworking* defaultProxy = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        //        NSURL* baseURL = [NSURL URLWithString:BKBaseURLString];
        defaultProxy = [[[self class] alloc] init];
    });
    
    return defaultProxy;
}


-(void)uploadImageWithProtrait:(UIImage *)image
{
    self.requestModel = [[BKRequestModel alloc] init];

    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    
    NSString *params = [NSString stringWithFormat:@"/user/uploadImg?appMerId=%@&appVersion=%@&openUDID=%@&distribution=%@",JYMerID,self.requestModel.head.appVersion,self.requestModel.head.open_udid,@"inhouse"];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",BKBaseURLString,params]]
                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:60];
    
    [request setHTTPMethod:@"POST"];
    
    // We need to add a header field named Content-Type with a value that tells that it's a form and also add a boundary.
    // I just picked a boundary by using one from a previous trace, you can just copy/paste from the traces.
    NSString *boundary = @"----WebKitFormBoundarycC4YiaUFwM44F6rT";
    
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    // the body of the post
    NSMutableData *body = [NSMutableData data];
    
    // Now we need to append the different data 'segments'. We first start by adding the boundary.
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//    [NSString stringWithFormat:@"appMerId = %@ appVersion = %@ openUDID = %@ distribution = %@"];

    // Now append the image
    // Note that the name of the form field is exactly the same as in the trace ('attachment[file]' in my case)!
    
    // You can choose whatever filename you want.
    [body appendData:[[NSString stringWithFormat:@"%@",@"Content-Disposition: form-data; name=\"imgFile\"; filename=\"headPortrait.png\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // We now need to tell the receiver what content type we have
    // In my case it's a png image. If you have a jpg, set it to 'image/jpg'
    [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Now we append the actual image data
    [body appendData:[NSData dataWithData:imageData]];
    
    // and again the delimiting boundary
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    // adding the body we've created to the request
    [request setHTTPBody:body];
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request
                                                                  delegate:self
                                                          startImmediately:NO];
    
    self.mdata = [[NSMutableData alloc] initWithLength:0];
    
    [connection start];

}


// 你可以在里面判断返回结果, 或者处理返回的http头中的信息

// 每收到一次数据, 会调用一次
- (void)connection:(NSURLConnection *)aConn didReceiveData:(NSData *)data
{
    [self.mdata appendData:data];
}


// 全部数据接收完毕时触发
- (void)connectionDidFinishLoading:(NSURLConnection *)aConn
{
    NSLog(@"%@",[[NSString alloc] initWithData:self.mdata encoding:NSUTF8StringEncoding]);
    NSDictionary *jsonDic = [NSJSONSerialization JSONObjectWithData:self.mdata options:NSJSONReadingMutableLeaves error:nil];
    [JYUserModel shareInstance].imgString = jsonDic[@"body"][@"url"];
    
    [[NSUserDefaults standardUserDefaults] setObject:[JYUserModel shareInstance].imgString forKey:@"imgString"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (self.successBlock) {
        
        self.successBlock();
    }
    
    NSLog(@"%@,%@",jsonDic,[jsonDic objectForKey:@"body"][@"url"]);
}



@end
