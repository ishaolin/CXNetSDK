//
//  CXBaseURLRequest.m
//  Pods
//
//  Created by wshaolin on 2017/5/16.
//
//

#import "CXBaseURLRequest.h"
#import "CXHTTPResponseSerializer.h"
#import "CXNetworkReachabilityManager.h"
#import "CXSignUtils.h"
#import "CXBaseModel.h"

static AFHTTPSessionManager *_sessionManager;
static AFHTTPRequestSerializer *_sRequestSerializer;
static AFHTTPResponseSerializer *_sResponseSerializer;

@interface CXBaseURLRequest(){
    NSURLSessionDataTask *_sessionDataTask;
    NSMutableDictionary<NSString *, NSString *> *_headers;
    NSMutableDictionary<NSString *, id> *_params;
    NSString *_URLString;
    AFHTTPRequestSerializer *_requestSerializer;
    AFHTTPResponseSerializer *_responseSerializer;
}

@end

@implementation CXBaseURLRequest

- (instancetype)init{
    if(self = [super init]){
        [self.class setMaxConcurrentOperationCount:5];
        
        self.timeOutInterval = CXURLRequestTimeOutInterval;
        self.autoRetryTimes = 0;
        
        _headers = [NSMutableDictionary dictionary];
        _params = [NSMutableDictionary dictionary];
        _signKey = @"sig";
    }
    
    return self;
}

- (void)setTimeOutInterval:(NSTimeInterval)timeOutInterval{
    if(_timeOutInterval != timeOutInterval){
        _timeOutInterval = timeOutInterval;
        _sRequestSerializer.timeoutInterval = _timeOutInterval;
    }
}

- (NSDictionary<NSString *, id> *)commonParams{
    return nil;
}

- (NSString *)signWithParams:(NSDictionary<NSString *, id> *)params{
    return [self signWithParams:params ignoreKeys:@[_signKey]];
}

- (NSString *)signWithParams:(NSDictionary<NSString *, id> *)params
                  ignoreKeys:(nullable NSArray<NSString *> *)ignoreKeys{
    return [self signWithParams:params ignoreKeys:ignoreKeys privateKey:nil];
}

- (NSString *)signWithParams:(NSDictionary<NSString *, id> *)params
                  ignoreKeys:(nullable NSArray<NSString *> *)ignoreKeys
                  privateKey:(NSString *)privateKey{
    return [CXSignUtils signWithDictionary:params
                                ignoreKeys:ignoreKeys
                                privateKey:privateKey];
}

- (void)addParam:(id)param forKey:(NSString *)key{
    if([param isKindOfClass:[NSNumber class]] ||
       [param isKindOfClass:[NSString class]]){
        [_params cx_setObject:param forKey:key];
    }else{
        LOG_INFO(@"不支持的参数类型：%@=%@", key, param);
    }
}

- (void)addParams:(NSDictionary<NSString *, id> *)params{
    [params enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [self addParam:obj forKey:key];
    }];
}

- (void)removeParamForKey:(NSString *)key{
    if(key){
        [_params removeObjectForKey:key];
    }
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field{
    [_headers cx_setValue:value forKey:field];
}

- (void)preloadRequest{
    _URLString = [NSString stringWithFormat:@"%@%@", [self baseURL], [self path]];
    
    if(!_requestSerializer){
        _requestSerializer = [self requestSerializer];
        if(_timeOutInterval > 0){
            _requestSerializer.timeoutInterval = _timeOutInterval;
        }
        
        _sessionManager.requestSerializer = _requestSerializer;
    }
    
    if(!_responseSerializer){
        _responseSerializer = [self responseSerializer];
        _sessionManager.responseSerializer = _responseSerializer;
    }
}

- (void)loadRequestWithSuccess:(CXBaseURLRequestSuccessBlock)successBlock failure:(CXBaseURLRequestFailureBlock)failureBlock{
    NSError *error = [CXNetworkReachabilityManager networkReachabilityError];
    if(error){
        [self handleRequestFailure:failureBlock
                        retryBlock:nil
                          dataTask:nil
                             error:error];
        return;
    }
    
    [CXObjectManager addObject:self];
    [self addParams:[self commonParams]];
    
    NSString *sign = [self signWithParams:_params];
    [self addParam:sign forKey:_signKey];
    
    [self preloadRequest];
    
    switch ([self method]) {
        case CXHTTPMethod_GET:
            [self getRequestWithSuccess:successBlock failure:failureBlock];
            break;
        case CXHTTPMethod_HEAD:
            [self headRequestWithSuccess:successBlock failure:failureBlock];
            break;
        case CXHTTPMethod_POST:
            [self postRequestWithSuccess:successBlock failure:failureBlock];
            break;
        case CXHTTPMethod_PUT:
            [self putRequestWithSuccess:successBlock failure:failureBlock];
            break;
        case CXHTTPMethod_PATCH:
            [self patchRequestWithSuccess:successBlock failure:failureBlock];
            break;
        case CXHTTPMethod_DELETE:
            [self deleteRequestWithSuccess:successBlock failure:failureBlock];
            break;
        default:
            break;
    }
}

- (void)uploadFileData:(NSArray<CXUploadFileData *> *)fileDatas
              progress:(CXBaseURLRequestProgressBlock)progressBlock
               success:(CXBaseURLRequestSuccessBlock)successBlock
               failure:(CXBaseURLRequestFailureBlock)failureBlock{
    NSError *error = [CXNetworkReachabilityManager networkReachabilityError];
    if(error){
        [self handleRequestFailure:failureBlock
                        retryBlock:nil
                          dataTask:nil
                             error:error];
        return;
    }
    
    [CXObjectManager addObject:self];
    [self addParams:[self commonParams]];
    NSString *sign = [self signWithParams:_params];
    [self addParam:sign forKey:_signKey];
    
    [self preloadRequest];
    
    _sessionDataTask = [_sessionManager POST:_URLString
                                  parameters:_params
                                     headers:_headers
                   constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [fileDatas enumerateObjectsUsingBlock:^(CXUploadFileData * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj.file isKindOfClass:[NSData class]]){
                NSData *data = (NSData *)obj.file;
                if(obj.fileName){
                    [formData appendPartWithFileData:data
                                                name:obj.name
                                            fileName:obj.fileName
                                            mimeType:obj.mimeType];
                }else{
                    [formData appendPartWithFormData:data
                                                name:obj.name];
                }
            }else if([obj.file isKindOfClass:[NSURL class]]){
                NSURL *url = (NSURL *)obj.file;
                NSError *err = nil;
                if(obj.fileName){
                    [formData appendPartWithFileURL:url
                                               name:obj.name
                                           fileName:obj.fileName
                                           mimeType:obj.mimeType
                                              error:&err];
                }else{
                    [formData appendPartWithFileURL:url
                                               name:obj.name
                                              error:&err];
                }
                
                if(err){
                    LOG_INFO(@"文件读取失败：%@", err);
                }
            }else{
                LOG_FATEL(@"不支持的文件数据：%@", obj.file);
            }
        }];
    } progress:progressBlock success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self handleRequestSuccess:successBlock
                      responseData:responseObject
                          dataTask:task];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleRequestFailure:failureBlock retryBlock:^{
            [self loadRequestWithSuccess:successBlock failure:failureBlock];
        } dataTask:task error:error];
    }];
}

- (void)getRequestWithSuccess:(CXBaseURLRequestSuccessBlock)successBlock
                      failure:(CXBaseURLRequestFailureBlock)failureBlock{
    _sessionDataTask = [_sessionManager GET:_URLString
                                 parameters:_params
                                    headers:_headers
                                   progress:nil
                                    success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        [self handleRequestSuccess:successBlock
                      responseData:responseObject
                          dataTask:task];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        [self handleRequestFailure:failureBlock retryBlock:^{
            [self loadRequestWithSuccess:successBlock failure:failureBlock];
        } dataTask:task error:error];
    }];
}

- (void)headRequestWithSuccess:(CXBaseURLRequestSuccessBlock)successBlock
                       failure:(CXBaseURLRequestFailureBlock)failureBlock{
    _sessionDataTask = [_sessionManager HEAD:_URLString
                                  parameters:_params
                                     headers:_headers
                                     success:^(NSURLSessionDataTask * _Nonnull task) {
        [self handleRequestSuccess:successBlock
                      responseData:nil
                          dataTask:task];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleRequestFailure:failureBlock retryBlock:^{
            [self loadRequestWithSuccess:successBlock failure:failureBlock];
        } dataTask:task error:error];
    }];
}

- (void)postRequestWithSuccess:(CXBaseURLRequestSuccessBlock)successBlock
                       failure:(CXBaseURLRequestFailureBlock)failureBlock{
    _sessionDataTask = [_sessionManager POST:_URLString
                                  parameters:_params
                                     headers:_headers
                                    progress:nil
                                     success:^(NSURLSessionDataTask * _Nonnull task, id _Nullable responseObject) {
        [self handleRequestSuccess:successBlock
                      responseData:responseObject
                          dataTask:task];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        [self handleRequestFailure:failureBlock retryBlock:^{
            [self loadRequestWithSuccess:successBlock failure:failureBlock];
        } dataTask:task error:error];
    }];
}

- (void)putRequestWithSuccess:(CXBaseURLRequestSuccessBlock)successBlock
                      failure:(CXBaseURLRequestFailureBlock)failureBlock{
    _sessionDataTask = [_sessionManager PUT:_URLString parameters:_params headers:_headers success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self handleRequestSuccess:successBlock
                      responseData:responseObject
                          dataTask:task];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleRequestFailure:failureBlock retryBlock:^{
            [self loadRequestWithSuccess:successBlock failure:failureBlock];
        } dataTask:task error:error];
    }];
}

- (void)patchRequestWithSuccess:(CXBaseURLRequestSuccessBlock)successBlock
                        failure:(CXBaseURLRequestFailureBlock)failureBlock{
    _sessionDataTask = [_sessionManager PATCH:_URLString parameters:_params headers:_headers success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self handleRequestSuccess:successBlock
                      responseData:responseObject
                          dataTask:task];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleRequestFailure:failureBlock retryBlock:^{
            [self loadRequestWithSuccess:successBlock failure:failureBlock];
        } dataTask:task error:error];
    }];
}

- (void)deleteRequestWithSuccess:(CXBaseURLRequestSuccessBlock)successBlock
                         failure:(CXBaseURLRequestFailureBlock)failureBlock{
    _sessionDataTask = [_sessionManager DELETE:_URLString
                                    parameters:_params
                                       headers:_headers
                                       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self handleRequestSuccess:successBlock
                      responseData:responseObject
                          dataTask:task];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self handleRequestFailure:failureBlock retryBlock:^{
            [self loadRequestWithSuccess:successBlock failure:failureBlock];
        } dataTask:task error:error];
    }];
}

- (void)handleRequestSuccess:(CXBaseURLRequestSuccessBlock)successBlock
                responseData:(id)responseData
                    dataTask:(NSURLSessionDataTask *)dataTask{
#if DEBUG
    LOG_INFO(@"\n请求：%@;\n参数：%@;", dataTask.currentRequest.URL, self->_params);
    LOG_INFO(@"\n结果：%@;", [NSJSONSerialization cx_stringWithJSONObject:responseData]);
#endif
    
    [CXDispatchHandler asyncOnMainQueue:^{
        if(successBlock){
            id data = nil;
            @try {
                data = [self modelWithData:responseData];
            } @catch (NSException *e) {
                LOG_FATEL(@"解析数据异常：%@", [e description]);
            }
            
            successBlock(dataTask, data);
        }
        
        [CXObjectManager removeObject:self];
    }];
}

- (void)handleRequestFailure:(CXBaseURLRequestFailureBlock)failureBlock
                  retryBlock:(dispatch_block_t)retryBlock
                    dataTask:(NSURLSessionDataTask *)dataTask
                       error:(NSError *)error{
    [CXDispatchHandler asyncOnMainQueue:^{
        /* 如果本次请求超时，且允许重试，则执行重试 */
        if(error.code == NSURLErrorTimedOut && self.autoRetryTimes > 0 && retryBlock){
            self.autoRetryTimes -= 1;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), retryBlock);
        }else{
#if DEBUG
            LOG_INFO(@"\n请求：%@;\n参数：%@;", dataTask.currentRequest.URL, self->_params);
            LOG_INFO(@"\n结果：%@;", error);
#endif
            if(failureBlock){
                failureBlock(dataTask, error);
            }
            
            [CXObjectManager removeObject:self];
        }
    }];
}

- (AFHTTPRequestSerializer *)requestSerializer{
    return _sRequestSerializer;
}

- (AFHTTPResponseSerializer *)responseSerializer{
    return _sResponseSerializer;
}

- (id)modelWithData:(id)data{
    return [CXBaseModel cx_modelWithData:data];
}

- (CXHTTPMethod)method{
    return CXHTTPMethod_GET;
}

- (NSString *)baseURL{
    return @"";
}

- (NSString *)path{
    return @"";
}

- (void)cancel{
    [_sessionDataTask cancel];
}

- (void)suspend{
    [_sessionDataTask suspend];
}

- (void)resume{
    [_sessionDataTask resume];
}

+ (void)cancelAll{
    [_sessionManager.operationQueue cancelAllOperations];
}

+ (void)setMaxConcurrentOperationCount:(NSUInteger)maxConcurrentOperationCount{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sessionManager = [AFHTTPSessionManager manager];
        _sRequestSerializer = [[AFHTTPRequestSerializer alloc] init];
        _sResponseSerializer = [[CXHTTPResponseSerializer alloc] init];
    });
    
    if(maxConcurrentOperationCount > 0){
        _sessionManager.operationQueue.maxConcurrentOperationCount = maxConcurrentOperationCount;
    }
}

- (void)dealloc{
    _sessionDataTask = nil;
}

@end

@implementation NSError (CXHUDMsgSupported)

- (NSString *)HUDMsg{
    switch(self.code){
        case NSURLErrorTimedOut:
            return @"网络超时，请稍后重试";
        case NSURLErrorNetworkConnectionLost:
        case NSURLErrorNotConnectedToInternet:
            return @"网络不可用，请检查网络设置";
        case NSURLErrorCannotConnectToHost:
            return @"无法连接服务器";
        case NSURLErrorBadURL:
            return @"404错误";
        default:
            return @"网络错误";
    }
}

@end

@implementation CXUploadFileData

@end

NSTimeInterval const CXURLRequestTimeOutInterval = 10.0;
