//
//  ChessHTTPClient.m
//  IMSDK
//
//  Created by Xiangqi on 16/7/7.
//  Copyright © 2016年 Xiangqi. All rights reserved.
//

#import "ChessHTTPClient.h"
#import "ChessHTTPSessionManager.h"

/**
 * Seeing a return statements within an inner block
 * can sometimes be mistaken for a return point of the enclosing method.
 * This makes inline blocks a bit easier to read.
 **/
#define return_from_block  return

NSString * const kChessHTTPClientIssueFailureDomain = @"kChessHTTPClientIssueFailureDomain";
NSString * const kChessHTTPClientCustomDomain = @"kChessHTTPClientCustomDomain";

@interface ChessHTTPClient ()

@property (nonatomic, strong) ChessHTTPSessionManager    *httpSessionManager;
@property (nonatomic, strong) NSMutableDictionary *urlSessionTaskPool;

@end

@implementation ChessHTTPClient

- (id)init
{
    if (self = [super init]) {
        self.urlSessionTaskPool = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (ChessHTTPRequestSerializer *)requestSerializer
{
    return self.httpSessionManager.requestSerializer;
}

- (void)rebuildHTTPSessionManagerWithBaseURL:(NSString *)baseURLString configuration:(NSURLSessionConfiguration *)aConfiguration
{
    NSURL *baseURL = [NSURL URLWithString:baseURLString];
    NSURLSessionConfiguration *configuration = nil;
    if (aConfiguration) {
        configuration = aConfiguration;
    } else {
        configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.allowsCellularAccess = YES;
        configuration.timeoutIntervalForRequest = 30.0;
    }
    self.httpSessionManager = [[ChessHTTPSessionManager alloc] initWithBaseURL:baseURL sessionConfiguration:configuration];
}

//ChessHTTPResponseSerializer
- (void)setResponseSerializer:(id)responseSerializer
{
    [self.httpSessionManager setResponseSerializer:responseSerializer];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - HTTP Method
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)GETWithURLPath:(NSString *)URLPath
            parameters:(NSDictionary *)parameters
               success:(void (^)(id responseObject))success
               failure:(void (^)(NSError *error))failure
{
    [self GETWithURLPath:URLPath
              parameters:parameters
                progress:nil
                 success:success
                 failure:failure];
}

- (void)GETWithURLPath:(NSString *)URLPath
            parameters:(NSDictionary *)parameters
              progress:(void (^)(NSProgress *downloadProgress)) downloadProgress
               success:(void (^)(id responseObject))success
               failure:(void (^)(NSError *error))failure
{
    NSURLSessionDataTask *dataTask = [self ly_dataTaskWithHTTPMethod:@"GET"
                                                           URLString:URLPath
                                                          parameters:parameters
                                           constructingBodyWithBlock:nil
                                                      uploadProgress:nil
                                                    downloadProgress:downloadProgress
                                                             success:success
                                                             failure:failure];
    [dataTask resume];
}

- (void)HEADWithURLPath:(NSString *)URLPath
             parameters:(NSDictionary *)parameters
                success:(void (^)(id responseObject))success
                failure:(void (^)(NSError *error))failure
{
    NSURLSessionDataTask *dataTask = [self ly_dataTaskWithHTTPMethod:@"HEAD"
                                                           URLString:URLPath
                                                          parameters:parameters
                                           constructingBodyWithBlock:nil
                                                      uploadProgress:nil
                                                    downloadProgress:nil
                                                             success:success
                                                             failure:failure];
    [dataTask resume];
}

- (void)POSTWithURLPath:(NSString *)URLPath
             parameters:(NSDictionary *)parameters
                success:(void (^)(id responseObject))success
                failure:(void (^)(NSError *error))failure
{
    [self POSTWithURLPath:URLPath
               parameters:parameters
                 progress:nil
                  success:success
                  failure:failure];
}

- (void)POSTWithURLPath:(NSString *)URLPath
             parameters:(NSDictionary *)parameters
               progress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                success:(void (^)(id responseObject))success
                failure:(void (^)(NSError *error))failure
{
    NSURLSessionDataTask *dataTask = [self ly_dataTaskWithHTTPMethod:@"POST"
                                                           URLString:URLPath
                                                          parameters:parameters
                                           constructingBodyWithBlock:nil
                                                      uploadProgress:uploadProgress
                                                    downloadProgress:nil
                                                             success:success
                                                             failure:failure];
    [dataTask resume];
}

- (void)POSTWithURLPath:(NSString *)URLPath
             parameters:(NSDictionary *)parameters
constructingBodyWithBlock:(nullable void (^)(id <ChessMultipartFormData> formData))block
                success:(void (^)(id responseObject))success
                failure:(void (^)(NSError *error))failure
{

    [self POSTWithURLPath:URLPath
               parameters:parameters
constructingBodyWithBlock:block
                 progress:nil
                  success:success
                  failure:failure];
}

- (void)POSTWithURLPath:(NSString *)URLPath
             parameters:(NSDictionary *)parameters
constructingBodyWithBlock:(nullable void (^)(id <ChessMultipartFormData> formData))block
               progress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                success:(void (^)(id responseObject))success
                failure:(void (^)(NSError *error))failure
{
    NSURLSessionDataTask *dataTask = [self ly_dataTaskWithHTTPMethod:@"POST"
                                                           URLString:URLPath
                                                          parameters:parameters
                                           constructingBodyWithBlock:block
                                                      uploadProgress:uploadProgress
                                                    downloadProgress:nil
                                                             success:success
                                                             failure:failure];
    
    [dataTask resume];
}

- (void)httpRequestWithMethod:(NSString *)method
                      URLPath:(NSString *)URLPath
                   parameters:(NSDictionary *)parameters
                      success:(void (^)(id responseObject))success
                      failure:(void (^)(NSError *error))failure
{
    NSURLSessionDataTask *dataTask = [self ly_dataTaskWithHTTPMethod:method
                                                           URLString:URLPath
                                                          parameters:parameters
                                           constructingBodyWithBlock:nil
                                                      uploadProgress:nil
                                                    downloadProgress:nil
                                                             success:success
                                                             failure:failure];
    
    [dataTask resume];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Request Serializer
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSURLSessionDataTask *)ly_dataTaskWithHTTPMethod:(NSString *)method
                                          URLString:(NSString *)URLString
                                         parameters:(id)parameters
                          constructingBodyWithBlock:(nullable void (^)(id <ChessMultipartFormData> formData))constructBlock
                                     uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgress
                                   downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgress
                                            success:(void (^)(id))success
                                            failure:(void (^)(NSError *))failure
{
    NSError *serializationError = nil;
    NSString *absoluteString = [[NSURL URLWithString:URLString relativeToURL:self.httpSessionManager.baseURL] absoluteString];
    
    NSMutableDictionary *totalParameters = [NSMutableDictionary dictionary];
    [totalParameters addEntriesFromDictionary:parameters];
    
    if ([self appendAdditionBaseParameters]) {
        [totalParameters addEntriesFromDictionary:[self appendAdditionBaseParameters]];
    }
    
    NSMutableURLRequest *request = nil;
    if (constructBlock) {
        request = [[self requestSerializer] multipartFormRequestWithMethod:method
                                                                 URLString:absoluteString
                                                                parameters:totalParameters
                                                 constructingBodyWithBlock:constructBlock
                                                                     error:&serializationError];
    } else {
        request = [[self requestSerializer] requestWithMethod:method
                                                    URLString:absoluteString
                                                   parameters:totalParameters
                                                        error:&serializationError];
    }
    
    
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(dispatch_get_main_queue(), ^{
                failure(serializationError);
            });
#pragma clang diagnostic pop
        }
        
        return nil;
    }
    
    NSDictionary *headerFiledsDictionary = [self appendAdditionHTTPHeaderFields];
    if (headerFiledsDictionary) {
        for (NSString *key in [headerFiledsDictionary allKeys]) {
            [request addValue:headerFiledsDictionary[key] forHTTPHeaderField:key];
        }
    }
    
    [self expendFinalRulesForWillSendRequest:request withRelativeURL:URLString totalParameters:totalParameters];
    
    __block NSURLSessionDataTask *dataTask = nil;
    __weak typeof(self) weakSelf = self;
    
    if (constructBlock) {
        dataTask = [self.httpSessionManager uploadTaskWithStreamedRequest:request
                                                                 progress:uploadProgress
                                                        completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                                                            __strong ChessHTTPClient *strongSelf = weakSelf;
                                                            if (!strongSelf) return_from_block;
                                                            
                                                            if (error) {
                                                                if (failure) {
                                                                    [strongSelf analyseFailureWithTask:dataTask failureError:error failure:failure];
                                                                }
                                                            } else {
                                                                if (success) {
                                                                    [strongSelf analyseTaskResponseWithTask:dataTask reponseObject:responseObject success:success failure:failure];
                                                                }
                                                            }
                                                            
                                                            [strongSelf removeURLSessionTaskFromPool:dataTask];
                                                        }];
    } else {
        dataTask = [self.httpSessionManager dataTaskWithRequest:request
                                                 uploadProgress:uploadProgress
                                               downloadProgress:downloadProgress
                                              completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *error) {
                                                  __strong ChessHTTPClient *strongSelf = weakSelf;
                                                  if (!strongSelf) return_from_block;
                                                  
                                                  if (error) {
                                                      if (failure) {
                                                          [strongSelf analyseFailureWithTask:dataTask failureError:error failure:failure];
                                                      }
                                                  } else {
                                                      if (success) {
                                                          [strongSelf analyseTaskResponseWithTask:dataTask reponseObject:responseObject success:success failure:failure];
                                                      }
                                                  }
                                                  
                                                  [strongSelf removeURLSessionTaskFromPool:dataTask];
                                              }];
    }
    
    [self addURLSessionTaskInPool:dataTask];
    
    return dataTask;
}


- (NSDictionary *)appendAdditionBaseParameters
{
    return nil;
}

- (NSDictionary *)appendAdditionHTTPHeaderFields
{
    return nil;
}

- (void)expendFinalRulesForWillSendRequest:(NSMutableURLRequest *)willSendRequest
                      withRelativeURL:(NSString *)relativeURLString
                      totalParameters:(NSDictionary *)totalParameters {}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Override Response Serializer
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)analyseTaskResponseWithTask:(NSURLSessionDataTask *)task
                      reponseObject:(id)responseObject
                            success:(void (^)(id response))success
                            failure:(void (^)(NSError *error))failure
{
    NSError *error = nil;
    if ([self validateBaseResponse:responseObject error:&error]) {
        if (success) {
            success(responseObject);
        }
    } else {
        [self analyseFailureWithTask:task failureError:error failure:failure];
    }
}

- (BOOL)validateBaseResponse:(id)response  error:(NSError **)error
{
    return YES;
}

- (void)analyseFailureWithTask:(NSURLSessionDataTask *)task
                  failureError:(NSError *)error
                       failure:(void (^)(NSError *))failure
{
    //DEBUG的时候，可以查看error的NSLocalizedDescriptionKey
    if ([error.domain isEqualToString:kChessHTTPClientIssueFailureDomain]) {
        if (failure) {
            failure(error);
        }
    } else {
        //错误类型含有： 1.网络异常 2.服务器异常 3.request参数拼接 出错 4. response（JSON格式）解析出错
        //这里初步将不是业务的错误code 统一处理为 "网络异常"
        NSError *e = [self customErrorWithCode:1001];
        if (failure) {
            failure(e);
        }
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Error Code
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSError *)customErrorWithCode:(NSInteger)errorCode
{
    NSString *description = [[self customErrorMappingDictionary] objectForKey:[@(errorCode) stringValue]];
    NSError *error = [NSError errorWithDomain:kChessHTTPClientCustomDomain
                                         code:errorCode
                                     userInfo:@{NSLocalizedDescriptionKey: description}];
    
    return error;
}

- (NSDictionary *)customErrorMappingDictionary
{
    //后期补充类型，抓取error产生的原因
    //错误类型含有： 1.网络异常 2.服务器异常 3.request参数拼接 出错 4. response（JSON格式）解析出错
    return @{@"1001" : @"网络不给力"};
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Task Control
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)addURLSessionTaskInPool:(NSURLSessionTask *)task
{
    dispatch_block_t block = ^{@autoreleasepool{
        if (!task) return;
        
        NSString *path = task.currentRequest.URL.path;
        if (!path || ![path length]) return;
        
        NSArray *scheduleTaskArray = [self.urlSessionTaskPool objectForKey:path];
        if (!scheduleTaskArray || ![scheduleTaskArray count]) {
            [self.urlSessionTaskPool setValue:@[task] forKey:path];
        } else {
            NSMutableArray *mut = [NSMutableArray arrayWithArray:scheduleTaskArray];
            [mut addObject:task];
            [self.urlSessionTaskPool setValue:mut forKey:path];
        }
    }};
    
    if (![NSThread isMainThread]) {
        
        dispatch_async(dispatch_get_main_queue(), block);
        return;
    } else {
        block();
    }
}

- (void)removeURLSessionTaskFromPool:(NSURLSessionTask *)task
{
    dispatch_block_t block = ^{@autoreleasepool{
        if (!task) return;
        
        NSString *path = task.currentRequest.URL.path;
        if (!path || ![path length]) return;
        
        NSArray *scheduleTaskArray = [self.urlSessionTaskPool objectForKey:path];
        if (scheduleTaskArray && [scheduleTaskArray count]) {
            //存在同类型Path的任务,删除 task 的内存引用
            NSMutableArray *mut = [NSMutableArray arrayWithArray:scheduleTaskArray];
            [mut removeObject:task];
            
            if (![mut count]) {
                [self.urlSessionTaskPool removeObjectForKey:path];
            } else {
                [self.urlSessionTaskPool setValue:mut forKey:path];
            }
            
        }
    }};
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), block);
        return;
    } else {
        block();
    }
}

- (void)cancelURLSessionTaskWithURLPath:(NSString *)urlPath
{
    dispatch_block_t block = ^{@autoreleasepool{
        if (!urlPath || ![urlPath length]) return;
        
        NSMutableArray *containsArray = [NSMutableArray array];
        for (NSString *path in [self.urlSessionTaskPool allKeys]) {
            if ([path rangeOfString:urlPath].length > 0) {
                [containsArray addObject:path];
            }
        }
        
        for (NSString *path in containsArray) {
            NSArray *scheduleTaskArray = [self.urlSessionTaskPool objectForKey:path];
            for (NSURLSessionTask *task in scheduleTaskArray) {
                if (task && task.state <= NSURLSessionTaskStateSuspended) {
                    [task cancel];
                }
            }
        }
    }};
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), block);
        return;
    } else {
        block();
    }
}

- (void)cancelAllHTTPClientRequest
{
    [self cancelURLSessionTaskWithURLPath:@"/"];
}

@end
