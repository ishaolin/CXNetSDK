//
//  CXAddrUtils.m
//  Pods
//
//  Created by wshaolin on 2017/6/2.
//
//

#import "CXAddrUtils.h"
#include <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
#import "netipstack.h"

@implementation CXAddrUtils

+ (NSString *)macAddr{
    int mib[6];
    size_t len;
    char *buffer;
    unsigned char *addr_ptr;
    struct if_msghdr *msghdr;
    struct sockaddr_dl *sockaddr;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if((mib[5] = if_nametoindex("en0")) == 0) {
        return @"";
    }
    
    if(sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        return @"";
    }
    
    if((buffer = (char *)malloc(len)) == NULL){
        return @"";
    }
    
    if(sysctl(mib, 6, buffer, &len, NULL, 0) < 0){
        free(buffer);
        return @"";
    }
    
    msghdr = (struct if_msghdr *)buffer;
    sockaddr = (struct sockaddr_dl *)(msghdr + 1);
    addr_ptr = (unsigned char *)LLADDR(sockaddr);
    
    NSMutableString *addr = [NSMutableString string];
    [addr appendFormat:@"%02x", *addr_ptr];
    for(int i = 1; i < 6; i ++){
        [addr appendFormat:@":%02x", *(addr_ptr + i)];
    }
    
    free(buffer);
    
    return [addr copy];
}

+ (NSString *)ipAddr{
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

@end
