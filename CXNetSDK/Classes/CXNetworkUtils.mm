//
//  CXNetworkUtils.m
//  Pods
//
//  Created by wshaolin on 2017/6/2.
//
//

#import "CXNetworkUtils.h"
#include <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
#import "netipstack.h"
#import "CXWiFiUtils.h"

@implementation CXNetworkUtils

+ (NSString *)MACAddr{
    int _mib[6];
    size_t _len;
    char *_buffer;
    unsigned char *_p;
    struct if_msghdr *_if_msghdr;
    struct sockaddr_dl *_sockaddr_dl;
    
    _mib[0] = CTL_NET;
    _mib[1] = AF_ROUTE;
    _mib[2] = 0;
    _mib[3] = AF_LINK;
    _mib[4] = NET_RT_IFLIST;
    
    if((_mib[5] = if_nametoindex("en0")) == 0) {
        return @"";
    }
    
    if(sysctl(_mib, 6, NULL, &_len, NULL, 0) < 0) {
        return @"";
    }
    
    if((_buffer = (char *)malloc(_len)) == NULL){
        return @"";
    }
    
    if(sysctl(_mib, 6, _buffer, &_len, NULL, 0) < 0){
        free(_buffer);
        return @"";
    }
    
    _if_msghdr = (struct if_msghdr *)_buffer;
    _sockaddr_dl = (struct sockaddr_dl *)(_if_msghdr + 1);
    _p = (unsigned char *)LLADDR(_sockaddr_dl);
    
    NSMutableString *_addr = [NSMutableString string];
    [_addr appendFormat:@"%02x", *_p];
    for(int i = 1; i < 6; i ++){
        [_addr appendFormat:@":%02x", *(_p + i)];
    }
    
    free(_buffer);
    
    return [_addr copy];
}

+ (NSString *)IPAddr{
    NSString *IPAddr = nil;
    char *addr = net_addr_get();
    if(addr != NULL){
        IPAddr = [NSString stringWithUTF8String:addr];
        free(addr);
    }
    
    return IPAddr;
}

+ (NSString *)gatewayAddr{
    NSString *gatewayAddr = nil;
    char *gateway = net_gateway_addr();
    if(gateway != NULL){
        gatewayAddr = [NSString stringWithUTF8String:gateway];
        free(gateway);
    }
    
    return gatewayAddr;
}

+ (NSDictionary<NSString *, NSString *> *)WiFiInfo{
    return [CXWiFiUtils WiFiInfo];
}

@end
