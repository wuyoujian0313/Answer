//
//  NetworkTask.m
//
//
//  Created by wuyj on 14-9-2.
//  Copyright (c) 2014年 wuyj. All rights reserved.
//

#import "NetworkTask.h"
#import "NetResultBase.h"
#import "AFNetworking.h"



@interface AFHTTPRequestOperationManager (PUTForm)

- (AFHTTPRequestOperation *)PUT:(NSString *)URLString
                     parameters:(id)parameters
      constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end

@implementation AFHTTPRequestOperationManager (PUTForm)

- (AFHTTPRequestOperation *)PUT:(NSString *)URLString
                     parameters:(id)parameters
      constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                        success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                        failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer multipartFormRequestWithMethod:@"PUT" URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters constructingBodyWithBlock:block error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
    
    [self.operationQueue addOperation:operation];
    
    return operation;
}

@end


@interface NetworkTask ()
@property (nonatomic,strong)AFHTTPRequestOperationManager *afManager;

@end


@implementation NetworkTask


+ (NetworkTask *)sharedNetworkTask {
    
    static NetworkTask *netTask = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        netTask = [[self alloc] init];
    });
    return netTask;
}


-(instancetype)init {
    
    if (self = [super init]) {
        self.taskTimeout = 20;
        self.afManager = [AFHTTPRequestOperationManager manager];
        
        [_afManager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
        [_afManager.requestSerializer setHTTPMethodsEncodingParametersInURI:[NSSet setWithObjects:@"GET",@"DELETE",nil]];
        [_afManager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
        
        NSMutableSet *acceptContentTypes = [NSMutableSet setWithSet:_afManager.responseSerializer.acceptableContentTypes];
        [acceptContentTypes addObject:@"text/plain"];
        [acceptContentTypes addObject:@"text/html"];
        [acceptContentTypes addObject:@"text/javascript"];
        [acceptContentTypes addObject:@"text/xml"];
        [acceptContentTypes addObject:@"application/json"];
        [acceptContentTypes addObject:@"application/json; charset=utf-8"];
        [_afManager.responseSerializer setAcceptableContentTypes:acceptContentTypes];

    }
    
    return self;
}

#pragma mark - 私有API

-(void)analyzeData:(NSData *)responseObject
          delegate:(id <NetworkTaskDelegate>)delegate
         resultObj:(NetResultBase*)resultObj
        customInfo:(id)customInfo {
    
    [resultObj autoParseJsonData:responseObject];
    
    if(resultObj.code != nil && [resultObj.code integerValue] == NetStatusCodeSuccess) {
        
        if (delegate != nil && [delegate respondsToSelector:@selector(netResultSuccessBack:forInfo:)]) {
            [delegate netResultSuccessBack:resultObj forInfo:customInfo];
        }
    } else if(resultObj.code != nil && [resultObj.code integerValue] != NetStatusCodeSuccess ) {
        
        if (delegate != nil && [delegate respondsToSelector:@selector(netResultFailBack:errorCode:forInfo:)]) {
            NSString *errorDesc = [NetworkTask errerDescription:[resultObj.code integerValue]];
            if (errorDesc != nil && [errorDesc length] > 0) {
                [delegate netResultFailBack:errorDesc errorCode:[resultObj.code integerValue]  forInfo:customInfo];
            } else {
                [delegate netResultFailBack:resultObj.message errorCode:[resultObj.code integerValue]  forInfo:customInfo];
            }
        }
        
    } else {
        
        NSString *errorDesc = [NetworkTask errerDescription:NetStatusCodeUnknown];
        if (delegate != nil && [delegate respondsToSelector:@selector(netResultFailBack:errorCode:forInfo:)]) {
            [delegate netResultFailBack:errorDesc errorCode:NetStatusCodeUnknown forInfo:customInfo];
        }
    }
}

-(void)handleError:(AFHTTPRequestOperation *)operation
             error:(NSError *)error
          delegate:(id <NetworkTaskDelegate>)delegate
  receiveResultObj:(NetResultBase*)resultObj
        customInfo:(id)customInfo {
    
    if (operation.responseData != nil ) {
        [self analyzeData:operation.responseData delegate:delegate resultObj:resultObj customInfo:customInfo];
    } else {
        if (delegate != nil && [delegate respondsToSelector:@selector(netResultFailBack:errorCode:forInfo:)]) {
            [delegate netResultFailBack:[error localizedDescription] errorCode:error.code forInfo:customInfo];
        }
    }
}

- (void)requestWithMethod:(NSString *)method
                      api:(NSString *)api
                    param:(NSDictionary *)param
                 delegate:(id <NetworkTaskDelegate>)delegate
                resultObj:(NetResultBase*)resultObj
               customInfo:(id)customInfo {
    
    [_afManager.requestSerializer setTimeoutInterval:_taskTimeout];
    [_afManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    __weak NetworkTask *weakSelf = self;
    NSString * urlString = [NSString stringWithFormat:@"%@/%@",kNetworkAPIServer,api];
    if ([method isEqualToString:@"GET"]) {
        
        [_afManager GET:urlString parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"response:%@",operation.responseString);
            
            [weakSelf analyzeData:responseObject delegate:delegate resultObj:resultObj customInfo:customInfo];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"response:%@",operation.responseString);
            
            if (delegate != nil && [delegate respondsToSelector:@selector(netResultFailBack:errorCode:forInfo:)]) {
                [delegate netResultFailBack:[error localizedDescription] errorCode:error.code forInfo:customInfo];
            }
        }];
        
    } else if([method isEqualToString:@"POST"]) {
        [_afManager POST:urlString parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //
            NSLog(@"response:%@",operation.responseString);
            //
            [weakSelf analyzeData:responseObject delegate:delegate resultObj:resultObj customInfo:customInfo];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //
            NSLog(@"response:%@",operation.responseString);
            [weakSelf handleError:operation error:error delegate:delegate receiveResultObj:resultObj customInfo:customInfo];
        }];
        
    } else if([method isEqualToString:@"PUT"]) {
        
        [_afManager PUT:urlString parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //
            NSLog(@"response:%@",operation.responseString);
            //
            [weakSelf analyzeData:responseObject delegate:delegate resultObj:resultObj customInfo:customInfo];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            //
            NSLog(@"response:%@",operation.responseString);
            [weakSelf handleError:operation error:error delegate:delegate receiveResultObj:resultObj customInfo:customInfo];
        }];
        
    } else if([method isEqualToString:@"DELETE"]) {
        [_afManager DELETE:urlString parameters:param success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"response:%@",operation.responseString);
            [weakSelf analyzeData:responseObject delegate:delegate resultObj:resultObj customInfo:customInfo];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"response:%@",operation.responseString);
            [weakSelf handleError:operation error:error delegate:delegate receiveResultObj:resultObj customInfo:customInfo];
        }];
    }
}

// @"video/quicktime"
//
#pragma mark - 公开API
- (void)startUploadTaskApi:(NSString*)api
                  forParam:(NSDictionary *)param
                  fileData:(NSData*)fileData
                   fileKey:(NSString*)fileKey
                  fileName:(NSString*)fileName
                  mimeType:(NSString*)mimeType
                  delegate:(id <NetworkTaskDelegate>)delegate
                 resultObj:(NetResultBase*)resultObj
                customInfo:(id)customInfo {
    
    
    
    [_afManager.requestSerializer setTimeoutInterval:_taskTimeout];
    [_afManager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    NSString * urlString = [NSString stringWithFormat:@"%@/%@",kNetworkAPIServer,api];

    __weak NetworkTask *weakSelf = self;

    [_afManager POST:urlString parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:fileData name:fileKey fileName:fileName mimeType:mimeType];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"response:%@",operation.responseString);
        [weakSelf analyzeData:responseObject delegate:delegate resultObj:resultObj customInfo:customInfo];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"response:%@",operation.responseString);
        
        [weakSelf handleError:operation error:error delegate:delegate receiveResultObj:resultObj customInfo:customInfo];
    }];
}


- (void)startUploadTaskApi:(NSString*)api
                  forParam:(NSDictionary *)param
                  filePath:(NSString*)filePath
                   fileKey:(NSString*)fileKey
                  fileName:(NSString*)fileName
                  mimeType:(NSString*)mimeType
                  delegate:(id <NetworkTaskDelegate>)delegate
                 resultObj:(NetResultBase*)resultObj
                customInfo:(id)customInfo {
    
    
    [_afManager.requestSerializer setTimeoutInterval:_taskTimeout];
    [_afManager.requestSerializer setValue:@"multipart/form-data" forHTTPHeaderField:@"Content-Type"];
    
    __weak NetworkTask *weakSelf = self;
    NSString * urlString = [NSString stringWithFormat:@"%@/%@",kNetworkAPIServer,api];
    [_afManager POST:urlString parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        NSURL *fileURL = [NSURL fileURLWithPath:filePath];
        [formData appendPartWithFileURL:fileURL name:fileKey fileName:fileName mimeType:mimeType error:nil];
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"response:%@",operation.responseString);
        [weakSelf analyzeData:responseObject delegate:delegate resultObj:resultObj customInfo:customInfo];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        NSLog(@"response:%@",operation.responseString);
        
        [weakSelf handleError:operation error:error delegate:delegate receiveResultObj:resultObj customInfo:customInfo];
    }];
}



- (void)startGETTaskURL:(NSString*)urlString
               delegate:(id <NetworkTaskDelegate>)delegate
              resultObj:( NetResultBase*)resultObj
             customInfo:(id)customInfo {
    
    [_afManager.requestSerializer setTimeoutInterval:_taskTimeout];
    [_afManager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    __weak NetworkTask *weakSelf = self;
    [_afManager GET:urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"response:%@",operation.responseString);
        [weakSelf analyzeData:responseObject delegate:delegate resultObj:resultObj customInfo:customInfo];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"response:%@",operation.responseString);
        
        [weakSelf handleError:operation error:error delegate:delegate receiveResultObj:resultObj customInfo:customInfo];
    }];
}


- (void)startGETTaskApi:(NSString*)api
               forParam:(NSDictionary *)param
               delegate:(id <NetworkTaskDelegate>)delegate
              resultObj:(NetResultBase*)resultObj
             customInfo:(id)customInfo {
    
    [self requestWithMethod:@"GET"
                        api:api
                      param:param
                   delegate:delegate
                  resultObj:resultObj
                 customInfo:customInfo];
}

- (void)startPOSTTaskApi:(NSString*)api
                forParam:(NSDictionary *)param
                delegate:(id <NetworkTaskDelegate>)delegate
               resultObj:(NetResultBase*)resultObj
              customInfo:(id)customInfo {
    
    [self requestWithMethod:@"POST"
                        api:api
                      param:param
                   delegate:delegate
                  resultObj:resultObj
                 customInfo:customInfo];
}


- (void)startPUTTaskApi:(NSString*)api
               forParam:(NSDictionary *)param
               delegate:(id <NetworkTaskDelegate>)delegate
              resultObj:(NetResultBase*)resultObj
             customInfo:(id)customInfo {
    
    [self requestWithMethod:@"PUT"
                        api:api
                      param:param
                   delegate:delegate
                  resultObj:resultObj
                 customInfo:customInfo];
}

- (void)startDELETETaskApi:(NSString*)api
                  forParam:(NSDictionary *)param
                  delegate:(id <NetworkTaskDelegate>)delegate
                 resultObj:(NetResultBase*)resultObj
                customInfo:(id)customInfo {
    
    [self requestWithMethod:@"DELETE"
                        api:api
                      param:param
                   delegate:delegate
                  resultObj:resultObj
                 customInfo:customInfo];
}



+(NSString *)errerDescription:(NSInteger)statusCode {
    NSMutableString *desc = [[NSMutableString alloc] initWithCapacity:0];
    
    switch (statusCode) {
        case NetStatusCodeSuccess: {
            [desc appendString:@"成功"];
            break;
        }
            
        case NetStatusCodeUnknown: {
            [desc appendString:@"未知错误，请重试"];
            break;
        }
            
            
        default:
            break;
    }
    
    return desc;
}

@end

