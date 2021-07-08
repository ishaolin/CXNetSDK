//
//  CXWiFiUtil.m
//  Pods
//
//  Created by wshaolin on 2019/1/30.
//

#import "CXWiFiUtil.h"
#import <SystemConfiguration/CaptiveNetwork.h>

@implementation CXWiFiUtil

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
