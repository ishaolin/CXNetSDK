//
//  CXWiFiUtils.m
//  Pods
//
//  Created by wshaolin on 2019/1/30.
//

#import "CXWiFiUtils.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation CXWiFiUtils

+ (NSDictionary<NSString *, NSString *> *)WiFiInfo{
    NSDictionary<NSString *, NSString *> *info = nil;
    CFArrayRef arrayRef = CNCopySupportedInterfaces();
    if(arrayRef){
        CFDictionaryRef dictionaryRef = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(arrayRef, 0));
        if(dictionaryRef){
            info = (NSDictionary<NSString *, NSString *> *)CFBridgingRelease(dictionaryRef);
        }
        
        CFRelease(arrayRef);
    }
    
    return info;
}

@end
