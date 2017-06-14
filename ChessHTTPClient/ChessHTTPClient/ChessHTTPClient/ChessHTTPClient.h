//
//  ChessHTTPClient.h
//  IMSDK
//
//  Created by Xiangqi on 16/7/7.
//  Copyright © 2016年 Xiangqi. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol  ChessMultipartFormData;

@class ChessHTTPSessionManager;

@interface ChessHTTPClient : NSObject

//Read Only Property
@property (nonatomic, strong, readonly) ChessHTTPSessionManager    *httpSessionManager;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Setup
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 *  This method should be invoked only once  (at the setup period).
 *
 *  While initializing ChessHTTPClient, you can resetup it's baseURL and NSURLSessionConfiguration.
 *  Or you just think this method is a method which is typeof init.
 *
 *  @param aConfiguration : If aConfiguration is setted nil, a default configuration will be used.
 */
- (void)rebuildHTTPSessionManagerWithBaseURL:(NSString *)baseURLString configuration:(NSURLSessionConfiguration *)aConfiguration;

/**
 *  You can customize your ChessHTTPResponseSerializer.
 *  This method should be inovked once while you setup your ChessHTTPClient.
 *
 *  @param responseSerializer CustomChessHTTPResponseSerializer
 */
- (void)setResponseSerializer:(id)responseSerializer;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - HTTP Method
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)GETWithURLPath:(NSString *)URLPath
            parameters:(NSDictionary *)parameters
               success:(void (^)(id responseObject))success
               failure:(void (^)(NSError *error))failure;

- (void)POSTWithURLPath:(NSString *)URLPath
             parameters:(NSDictionary *)parameters
                success:(void (^)(id responseObject))success
                failure:(void (^)(NSError *error))failure;

- (void)HEADWithURLPath:(NSString *)URLPath
             parameters:(NSDictionary *)parameters
                success:(void (^)(id responseObject))success
                failure:(void (^)(NSError *error))failure;

- (void)POSTWithURLPath:(NSString *)URLPath
             parameters:(NSDictionary *)parameters
constructingBodyWithBlock:(void (^)(id <ChessMultipartFormData> formData))block
                success:(void (^)(id responseObject))success
                failure:(void (^)(NSError *error))failure;

- (void)httpRequestWithMethod:(NSString *)method
                      URLPath:(NSString *)URLPath
                   parameters:(NSDictionary *)parameters
                      success:(void (^)(id responseObject))success
                      failure:(void (^)(NSError *error))failure;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Override Response Serializer
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)analyseTaskResponseWithTask:(NSURLSessionDataTask *)task
                      reponseObject:(id)responseObject
                            success:(void (^)(id response))success
                            failure:(void (^)(NSError *error))failure;

- (void)analyseFailureWithTask:(NSURLSessionDataTask *)task
                  failureError:(NSError *)error
                       failure:(void (^)(NSError *))failure;

/**
 * Addition which need to be appended (Query string) in NSMutableURLRequest HTTPBody.
 */
- (NSDictionary *)appendAdditionBaseParameters;

/**
 *  Addition which need to be appended in NSMutableURLRequest HTTPHeadfields
 */
- (NSDictionary *)appendAdditionHTTPHeaderFields;

/**
 *  Will send the request, the custom rules for final assembly together
 */
- (void)expendFinalRulesForWillSendRequest:(NSMutableURLRequest *)willSendRequest
                      withRelativeURL:(NSString *)relativeURLString
                      totalParameters:(NSDictionary *)totalParameters;

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Task Control
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/**
 *  Cancel the ongoing URLSessionTask which path is like urlPath.
 *  Invoke on MainThread.
 */
- (void)cancelURLSessionTaskWithURLPath:(NSString *)urlPath;

/**
 *  Cancel all ongoing requests
 *  Invoke on MainThread.
 */
- (void)cancelAllHTTPClientRequest;

@end
