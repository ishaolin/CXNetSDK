//
//  AFNetworkReachabilityManager+CXNetSDK.m
//  Pods
//
//  Created by wshaolin on 2017/5/16.
//
//

#import "AFNetworkReachabilityManager+CXNetSDK.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <objc/runtime.h>
#import <CoreTelephony/CTCarrier.h>

@implementation AFNetworkReachabilityManager (CXNetSDK)

- (CTTelephonyNetworkInfo *)cx_telephonyNetworkInfo{
    CTTelephonyNetworkInfo *telephonyNetworkInfo = objc_getAssociatedObject(self, _cmd);
    if(!telephonyNetworkInfo){
        telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
        objc_setAssociatedObject(self, _cmd, telephonyNetworkInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return telephonyNetworkInfo;
}

- (NSString *)networkReachabilityStatusText{
    switch (self.networkReachabilityStatus) {
        case AFNetworkReachabilityStatusReachableViaWiFi:
            return CXNetworkReachabilityStatusTextWiFi;
        case AFNetworkReachabilityStatusReachableViaWWAN:{
            CTTelephonyNetworkInfo *info = [self cx_telephonyNetworkInfo];
            if([info.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]){
                return CXNetworkReachabilityStatusText4G;
            }
            
            if([info.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS] ||
               [info.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge]){
                return CXNetworkReachabilityStatusText2G;
            }
            
            if([info.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA] ||
               [info.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA] ||
               [info.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA] ||
               [info.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x] ||
               [info.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
               [info.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||
               [info.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] ||
               [info.currentRadioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]){
                return CXNetworkReachabilityStatusText3G;
            }
            
            NSRange range = [info.currentRadioAccessTechnology rangeOfString:@"CTRadioAccessTechnology"];
            if(range.location == NSNotFound){
                return info.currentRadioAccessTechnology;
            }
            
            return [info.currentRadioAccessTechnology substringFromIndex:(range.location + range.length)];
        }
        case AFNetworkReachabilityStatusNotReachable:
            return CXNetworkReachabilityStatusTextNone;
        case AFNetworkReachabilityStatusUnknown:
        default:
            return CXNetworkReachabilityStatusTextUnknown;
    }
}

- (NSString *)carrier{
    return [self cx_telephonyNetworkInfo].subscriberCellularProvider.carrierName ?: @"unknown";
}

@end

NSString * const CXNetworkReachabilityStatusTextWiFi = @"WIFI";
NSString * const CXNetworkReachabilityStatusText2G = @"2G";
NSString * const CXNetworkReachabilityStatusText3G = @"3G";
NSString * const CXNetworkReachabilityStatusText4G = @"4G";
NSString * const CXNetworkReachabilityStatusTextNone = @"NO";
NSString * const CXNetworkReachabilityStatusTextUnknown = @"UNKNOWN";
