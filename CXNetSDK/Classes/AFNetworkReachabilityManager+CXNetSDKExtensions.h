//
//  AFNetworkReachabilityManager+CXNetSDKExtensions.h
//  Pods
//
//  Created by wshaolin on 2017/5/16.
//
//

#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "CXNetDefines.h"

@interface AFNetworkReachabilityManager (CXNetSDKExtensions)

- (NSString *)networkReachabilityStatusText;

- (NSString *)carrier;

@end

CX_NET_EXTERN NSString * const CXNetworkReachabilityStatusTextWiFi;
CX_NET_EXTERN NSString * const CXNetworkReachabilityStatusText2G;
CX_NET_EXTERN NSString * const CXNetworkReachabilityStatusText3G;
CX_NET_EXTERN NSString * const CXNetworkReachabilityStatusText4G;
CX_NET_EXTERN NSString * const CXNetworkReachabilityStatusTextNone;
CX_NET_EXTERN NSString * const CXNetworkReachabilityStatusTextUnknown;
