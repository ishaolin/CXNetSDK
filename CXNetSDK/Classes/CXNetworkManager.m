//
//  CXNetworkManager.m
//  Pods
//
//  Created by wshaolin on 2017/5/16.
//
//

#import "CXNetworkManager.h"
#include <sys/utsname.h>
#import <CXFoundation/CXFoundation.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "CXAddressUtils.h"

@interface CXNetworkManager () {
    NSString *_hardwareString;
    NSString *_hardwareDescription;
    NSString *_macAddress;
}

@end

@implementation CXNetworkManager

+ (instancetype)sharedManager{
    static CXNetworkManager *networkManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkManager = [[self alloc] init];
        [networkManager networkChanged];
    });
    
    return networkManager;
}

- (NSString *)hardwareString{
    if(!_hardwareString){
        struct utsname name;
        uname(&name);
        _hardwareString = [NSString stringWithUTF8String:name.machine];
    }
    
    return _hardwareString;
}

- (NSString *)hardwareDescription{
    if(_hardwareDescription){
        return _hardwareDescription;
    }
    
    if(!self.hardwareString){
        return nil;
    }
    
    NSArray<NSString *> *bundles = @[@"CXNetSDK.bundle", @"Frameworks/CXNetSDK.framework/CXNetSDK.bundle"];
    for(NSString *bundle in bundles){
        // json数据来源参见：https://www.theiphonewiki.com/wiki/Models
        NSString *path = [[NSBundle mainBundle] pathForResource:[bundle stringByAppendingPathComponent:@"hardware_info"] ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSDictionary<NSString *, NSString *> *dictionary = [NSJSONSerialization cx_deserializeJSONToDictionary:data];
        _hardwareDescription = dictionary[self.hardwareString];
        if(_hardwareDescription){
            return _hardwareDescription;
        }
    }
    
    _hardwareDescription = self.hardwareString;
    return _hardwareDescription;
}

- (NSString *)macAddress{
    if(!_macAddress){
        _macAddress = [CXAddressUtils macAddress];
    }
    
    return _macAddress;
}

- (void)networkChanged{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CFArrayRef arrayRef = CNCopySupportedInterfaces();
        if(arrayRef){
            CFDictionaryRef dictionaryRef = CNCopyCurrentNetworkInfo(CFArrayGetValueAtIndex(arrayRef, 0));
            if(dictionaryRef){
                _WiFiInfo = (NSDictionary<NSString *, NSString *> *)CFBridgingRelease(dictionaryRef);
            }
            
            CFRelease(arrayRef);
        }
        
        _ipAddress = [CXAddressUtils ipAddress];
        _gatewayAddress = [CXAddressUtils gatewayAddress];
    });
}

@end
