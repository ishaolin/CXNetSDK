//
//  CXNetworkReachabilityManager.h
//  Pods
//
//  Created by wshaolin on 2017/5/16.
//
//

#import <Foundation/Foundation.h>
#import "CXNetDefines.h"

typedef NS_ENUM(NSInteger, CXNetworkReachabilityStatus) {
    CXNetworkReachabilityStatusUnknown          = -1,
    CXNetworkReachabilityStatusNotReachable     = 0,
    CXNetworkReachabilityStatusReachableViaWWAN = 1,
    CXNetworkReachabilityStatusReachableViaWiFi = 2,
};

@interface CXNetworkReachabilityManager : NSObject

+ (CXNetworkReachabilityStatus)networkReachabilityStatus;

+ (BOOL)isReachable;

+ (NSString *)networkReachabilityStatusString;

+ (void)startMonitoring;

+ (void)stopMonitoring;

+ (void)setReachabilityStatusChangeBlock:(void (^)(CXNetworkReachabilityStatus status))block;

+ (NSError *)networkReachabilityError;

@end

CX_NET_EXTERN NSString * const CXNetworkingReachabilityDidChangeNotification;
