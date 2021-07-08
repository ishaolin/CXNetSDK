//
//  CXNetworkReachabilityManager.m
//  Pods
//
//  Created by wshaolin on 2017/5/16.
//
//

#import "CXNetworkReachabilityManager.h"
#import "AFNetworkReachabilityManager+CXNetSDKExtensions.h"
#import "UIDevice+CXNetSDKExtensions.h"

@implementation CXNetworkReachabilityManager

+ (CXNetworkReachabilityStatus)networkReachabilityStatus{
    return (CXNetworkReachabilityStatus)[AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
}

+ (BOOL)isReachable{
    return [self networkReachabilityStatus] != CXNetworkReachabilityStatusNotReachable;
}

+ (NSString *)networkReachabilityStatusString{
    return [[AFNetworkReachabilityManager sharedManager] networkReachabilityStatusText];
}

+ (void)startMonitoring{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

+ (void)stopMonitoring{
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

+ (void)setReachabilityStatusChangeBlock:(void (^)(CXNetworkReachabilityStatus status))block{
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [[UIDevice currentDevice] cx_syncIPStack];
        !block ?: block((CXNetworkReachabilityStatus)status);
    }];
}

+ (NSError *)networkReachabilityError{
    if([self isReachable]){
        return nil;
    }
    
    return [NSError errorWithDomain:@"com.network.reachability"
                               code:NSURLErrorNetworkConnectionLost
                           userInfo:@{NSLocalizedDescriptionKey : @"当前网络不可用", NSLocalizedFailureReasonErrorKey : @"当前网络不可用"}];
}

@end

NSString * const CXNetworkingReachabilityDidChangeNotification = @"com.alamofire.networking.reachability.change";
