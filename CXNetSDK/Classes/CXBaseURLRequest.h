//
//  CXBaseURLRequest.h
//  Pods
//
//  Created by wshaolin on 2017/5/16.
//
//

#import <CXFoundation/CXFoundation.h>
#import "CXNetDefines.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CXHTTPMethod) {
    CXHTTPMethod_GET,   // GET
    CXHTTPMethod_HEAD,  // HEAD
    CXHTTPMethod_POST,  // POST
    CXHTTPMethod_PUT,   // PUT
    CXHTTPMethod_PATCH, // PATCH
    CXHTTPMethod_DELETE // DELETE
};

typedef void (^CXBaseURLRequestSuccessBlock)(NSURLSessionDataTask * _Nonnull dataTask, id _Nullable data);
typedef void (^CXBaseURLRequestFailureBlock)(NSURLSessionDataTask * _Nullable dataTask, NSError * _Nullable error);

@class AFHTTPRequestSerializer;
@class AFHTTPResponseSerializer;
@class CXUploadFileData;

@interface CXBaseURLRequest : NSObject

/*!
 *  @brief 单次的请求超时时间，总的请求超时时间为timeOutInterval * autoRetryTimes
 */
@property (nonatomic, assign) NSTimeInterval timeOutInterval;

/*!
 *  @brief 自动重试次数，默认0，既请求超时之后会自动重试，此值建议不要大于3
 */
@property (nonatomic, assign) NSUInteger autoRetryTimes;

/*!
 *  @brief 参数签名字符串传递给server的参数名
 */
@property (nonatomic, copy) NSString *signKey; /// Default is 'sig'

#pragma mark - 设置请求参数

/*!
 *  @brief param和params的value只能为NSString或NSNumber类型，其他的数据类型直接忽略
 *
 */
- (void)addParam:(id)param forKey:(NSString *)key;
- (void)addParams:(NSDictionary<NSString *, id> *)params;
- (void)removeParamForKey:(NSString *)key;

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field;

/*!
 *  @brief 发送网络请求
 *
 *  @param successBlock 请求成功的回调
 *  @param failureBlock 请求失败的回调
 */
- (void)loadRequestWithSuccess:(nullable CXBaseURLRequestSuccessBlock)successBlock
                       failure:(nullable CXBaseURLRequestFailureBlock)failureBlock;

/*!
 *  @brief 上传文件
 *
 *  @param fileDatas 文件数据
 *  @param successBlock 请求成功的回调
 *  @param failureBlock 请求失败的回调
 */
- (void)uploadFileData:(nullable NSArray<CXUploadFileData *> *)fileDatas
               success:(nullable CXBaseURLRequestSuccessBlock)successBlock
               failure:(nullable CXBaseURLRequestFailureBlock)failureBlock;

- (AFHTTPRequestSerializer *)requestSerializer;

- (AFHTTPResponseSerializer *)responseSerializer;

/*!
 *  @brief 转换数据，子类必须重写
 *
 *  @param data 数据
 *
 *  @return 转换之后的数据
 */
- (id)modelWithData:(id)data;

- (CXHTTPMethod)method;

- (NSString *)baseURL;

/*!
 *  @brief 请求的URL的后半部分，不能为nil，默认""
 *
 */
- (NSString *)path;

/*!
 *  @brief 公共参数
 *
 */
- (nullable NSDictionary<NSString *, id> *)commonParams;

/*!
 * @brief 参数签名，不使用默认签名方法时，子类需要重写此方法
 *
 */
- (NSString *)signWithParams:(NSDictionary<NSString *, id> *)params
                  ignoreKeys:(nullable NSArray<NSString *> *)ignoreKeys
                  privateKey:(NSString *)privateKey;

/*!
 *  @brief 取消请求
 */
- (void)cancel;
/*!
 *  @brief 暂停请求
 */
- (void)suspend;
/*!
 *  @brief 恢复请求
 */
- (void)resume;

/*!
 *  @brief 取消所有请求
 */
+ (void)cancelAll;

/*!
 *  @brief 设置最大并发数
 *
 *  @param maxConcurrentOperationCount 最大并发数
 */
+ (void)setMaxConcurrentOperationCount:(NSUInteger)maxConcurrentOperationCount;

@end

@interface NSError (CXHUDMsgSupported)

@property (nonatomic, copy, readonly) NSString *HUDMsg;

@end

@interface CXUploadFileData : NSObject

@property (nonatomic, strong) id file; // NSURL or NSData
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy, nullable) NSString *fileName;
@property (nonatomic, copy, nullable) NSString *mimeType;

@end

CX_NET_EXTERN NSTimeInterval const CXURLRequestTimeOutInterval;

NS_ASSUME_NONNULL_END
