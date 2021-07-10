//
//  UIDevice+CXNetSDKExtensions.m
//  Pods
//
//  Created by wshaolin on 2017/6/2.
//
//

#import "UIDevice+CXNetSDKExtensions.h"
#import <objc/runtime.h>
#import "CXNetworkUtils.h"
#include <sys/utsname.h>
#import <CXFoundation/CXFoundation.h>

@implementation UIDevice (CXNetSDKExtensions)

- (NSString *)cx_hardwareString{
    NSString *hardwareString = objc_getAssociatedObject(self, _cmd);
    if(!hardwareString){
        struct utsname _ar_name;
        uname(&_ar_name);
        hardwareString = [NSString stringWithUTF8String:_ar_name.machine];
        objc_setAssociatedObject(self, _cmd, hardwareString, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    return hardwareString;
}

- (NSString *)cx_hardwareDescription{
    NSString *hardwareDescription = objc_getAssociatedObject(self, _cmd);
    if(hardwareDescription){
        return hardwareDescription;
    }
    
    if(!self.cx_hardwareString){
        return nil;
    }
    
    NSArray<NSString *> *bundles = @[@"CXNetSDK.bundle", @"Frameworks/CXNetSDK.framework/CXNetSDK.bundle"];
    for(NSString *bundle in bundles){
        // json数据来源参见：https://www.theiphonewiki.com/wiki/Models
        NSString *path = [[NSBundle mainBundle] pathForResource:[bundle stringByAppendingPathComponent:@"hardware_info"] ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSDictionary<NSString *, NSString *> *dictionary = [NSJSONSerialization cx_deserializeJSONToDictionary:data];
        hardwareDescription = dictionary[self.cx_hardwareString];
        objc_setAssociatedObject(self, _cmd, hardwareDescription, OBJC_ASSOCIATION_COPY_NONATOMIC);
        if(hardwareDescription){
            return hardwareDescription;
        }
    }
    
    return @"unknown";
}

- (NSString *)cx_IPAddr{
    return objc_getAssociatedObject(self, _cmd);
}

- (NSString *)cx_gatewayAddr{
    return objc_getAssociatedObject(self, _cmd);
}

- (NSString *)cx_MACAddr{
    NSString *addr = objc_getAssociatedObject(self, _cmd);
    if(!addr){
        addr = [CXNetworkUtils MACAddr];
        objc_setAssociatedObject(self, _cmd, addr, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    
    return addr;
}

- (NSDictionary<NSString *,NSString *> *)cx_WiFiInfo{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)cx_syncIPStack{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *IPAddr = [CXNetworkUtils IPAddr];
        NSString *gatewayAddr = [CXNetworkUtils gatewayAddr];
        dispatch_async(dispatch_get_main_queue(), ^{
            objc_setAssociatedObject(self,@selector(cx_IPAddr),
                                     IPAddr,
                                     OBJC_ASSOCIATION_COPY_NONATOMIC);
            objc_setAssociatedObject(self,@selector(cx_gatewayAddr),
                                     gatewayAddr,
                                     OBJC_ASSOCIATION_COPY_NONATOMIC);
            objc_setAssociatedObject(self,
                                     @selector(cx_WiFiInfo),
                                     [CXNetworkUtils WiFiInfo],
                                     OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        });
    });
}

@end
