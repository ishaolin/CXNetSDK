//
//  netaddrget.cpp
//  Pods
//
//  Created by wshaolin on 2017/6/5.
//
//

#include "netaddrget.h"
#include <stdio.h>
#include <stdlib.h>
#include <net/if.h>
#include <sys/sysctl.h>
#include <string.h>
#include <sys/param.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

#if TARGET_IPHONE_SIMULATOR
#include <net/route.h>
#define _NET_EN_TYPE "en1"
#else
#include "route.h"
#define _NET_EN_TYPE "en0"
#endif

#define NET_NUMBER_ROUND_UP(n) ((n) > 0 ? (1 + (((n) - 1) | (sizeof(long) - 1))) : sizeof(long))

int net_gateway_addr_v4_get(struct in_addr *addr_v4){
    int b_mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET, NET_RT_FLAGS, RTF_GATEWAY};
    size_t b_size_t;
    if(sysctl(b_mib, sizeof(b_mib) / sizeof(int), 0, &b_size_t, 0, 0) < 0){
        return CX_NET_ERR;
    }
    
    if(b_size_t == 0){
        return CX_NET_ERR;
    }
    
    char *b_buffer;
    char *b_p;
    struct rt_msghdr *b_rt_msghdr;
    struct sockaddr *b_sockaddr;
    struct sockaddr *b_sockaddr_t[RTAX_MAX];
    
    b_buffer = (char *)malloc(b_size_t);
    if(b_buffer == NULL){
        return CX_NET_ERR;
    }
    
    if(sysctl(b_mib, sizeof(b_mib) / sizeof(int), b_buffer, &b_size_t, 0, 0) < 0){
        free(b_buffer);
        return CX_NET_ERR;
    }
    
    int r = CX_NET_ERR;
    for(b_p = b_buffer; b_p < b_buffer + b_size_t; b_p += b_rt_msghdr->rtm_msglen){
        b_rt_msghdr = (struct rt_msghdr *)b_p;
        b_sockaddr = (struct sockaddr *)(b_rt_msghdr + 1);
        for(int i = 0; i < RTAX_MAX; i ++){
            if(b_rt_msghdr->rtm_addrs & (1 << i)){
                b_sockaddr_t[i] = b_sockaddr;
                b_sockaddr = (struct sockaddr *)((char *)b_sockaddr + NET_NUMBER_ROUND_UP(b_sockaddr->sa_len));
            }else{
                b_sockaddr_t[i] = NULL;
            }
        }
        
        if(((b_rt_msghdr->rtm_addrs & (RTA_DST | RTA_GATEWAY)) == (RTA_DST | RTA_GATEWAY)) &&
           b_sockaddr_t[RTAX_DST]->sa_family == AF_INET &&
           b_sockaddr_t[RTAX_GATEWAY]->sa_family == AF_INET){
            if(((struct sockaddr_in *)b_sockaddr_t[RTAX_DST])->sin_addr.s_addr == 0){
                char name[128];
                if_indextoname(b_rt_msghdr->rtm_index, name);
                if(strcmp(_NET_EN_TYPE, name) == 0){
                    *addr_v4 = ((struct sockaddr_in *)(b_sockaddr_t[RTAX_GATEWAY]))->sin_addr;
                    r = CX_NET_OK;
                    break;
                }
            }
        }
    }
    
    free(b_buffer);
    return r;
}

int net_gateway_addr_v6_get(struct in6_addr *addr_v6){
    int b_mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET6, NET_RT_FLAGS, RTF_GATEWAY};
    size_t b_size_t;
    
    if(sysctl(b_mib, sizeof(b_mib) / sizeof(int), 0, &b_size_t, 0, 0) < 0){
        return CX_NET_ERR;
    }
    
    if(b_size_t == 0){
        return CX_NET_ERR;
    }
    
    char *b_buffer;
    char *b_p;
    struct rt_msghdr *b_rt_msghdr;
    struct sockaddr *b_sockaddr;
    struct sockaddr *b_sockaddr_t[RTAX_MAX];
    
    b_buffer = (char *)malloc(b_size_t);
    if(b_buffer == NULL){
        return CX_NET_ERR;
    }
    
    if(sysctl(b_mib, sizeof(b_mib) / sizeof(int), b_buffer, &b_size_t, 0, 0) < 0){
        free(b_buffer);
        return CX_NET_ERR;
    }
    
    int r = CX_NET_ERR;
    for(b_p = b_buffer; b_p < b_buffer + b_size_t; b_p += b_rt_msghdr->rtm_msglen){
        b_rt_msghdr = (struct rt_msghdr *)b_p;
        b_sockaddr = (struct sockaddr *)(b_rt_msghdr + 1);
        for(int i = 0; i < RTAX_MAX; i ++){
            if(b_rt_msghdr->rtm_addrs & (1 << i)){
                b_sockaddr_t[i] = b_sockaddr;
                b_sockaddr = (struct sockaddr *)((char *)b_sockaddr + NET_NUMBER_ROUND_UP(b_sockaddr->sa_len));
            }else{
                b_sockaddr_t[i] = NULL;
            }
        }
        
        if(((b_rt_msghdr->rtm_addrs & (RTA_DST | RTA_GATEWAY)) == (RTA_DST | RTA_GATEWAY)) &&
           b_sockaddr_t[RTAX_DST]->sa_family == AF_INET6){
            if(IN6_IS_ADDR_UNSPECIFIED(&((struct sockaddr_in6 *)b_sockaddr_t[RTAX_DST])->sin6_addr)){
                *addr_v6 = ((struct sockaddr_in6 *)(b_sockaddr_t[RTAX_GATEWAY]))->sin6_addr;
                r = CX_NET_OK;
                break;
            }
        }
    }
    
    free(b_buffer);
    return r;
}

int net_ip_addr_v4_get(struct in_addr *addr_v4){
    int r = CX_NET_ERR;
    struct ifaddrs *_ifaddrs;
    
    if(getifaddrs(&_ifaddrs) == 0){
        struct ifaddrs *_ifaddrs_t = _ifaddrs;
        while(_ifaddrs_t != NULL){
            if(_ifaddrs_t->ifa_addr->sa_family == AF_INET &&
               strcmp(_NET_EN_TYPE, _ifaddrs_t->ifa_name) == 0){
                *addr_v4 = ((struct sockaddr_in *)_ifaddrs_t->ifa_addr)->sin_addr;
                r = CX_NET_OK;
                break;
            }
            
            _ifaddrs_t = _ifaddrs_t->ifa_next;
        }
    }
    
    freeifaddrs(_ifaddrs);
    return r;
}

int net_ip_addr_v6_get(struct in6_addr *addr_v6){
    int r = CX_NET_ERR;
    struct ifaddrs *_ifaddrs;
    
    if(getifaddrs(&_ifaddrs) == 0){
        struct ifaddrs *_ifaddrs_t = _ifaddrs;
        while(_ifaddrs_t != NULL){
            if(_ifaddrs_t->ifa_addr->sa_family == AF_INET6 &&
               strcmp(_NET_EN_TYPE, _ifaddrs_t->ifa_name) == 0){
                *addr_v6 = ((struct sockaddr_in6 *)_ifaddrs_t->ifa_addr)->sin6_addr;
                r = CX_NET_OK;
                break;
            }
            
            _ifaddrs_t = _ifaddrs_t->ifa_next;
        }
    }
    
    freeifaddrs(_ifaddrs);
    return r;
}
