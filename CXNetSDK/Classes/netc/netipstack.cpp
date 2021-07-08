//
//  netipstack.cpp
//  Pods
//
//  Created by wshaolin on 2017/6/5.
//
//

#include "netipstack.h"
#include <unistd.h>
#include <vector>
#include <resolv.h>
#include <arpa/inet.h>
#include <sys/errno.h>
#include <stdlib.h>
#include "netaddrget.h"

struct net_sockaddr_in{
    int family;
    const void *addr;
    socklen_t len;
};

union net_sockaddr{
    struct sockaddr     s;
    struct sockaddr_in  s_in;
    struct sockaddr_in6 s_in6;
};

static int net_test_connect(int inet, struct sockaddr *sa, socklen_t len){
    int s = socket(inet, SOCK_DGRAM, IPPROTO_UDP);
    if (s < 0){
        return 0;
    }
    
    int r = 0;
    do {
        r = connect(s, sa, len);
    } while (r < 0 && errno == EINTR);
    
    int success = (r == 0);
    do {
        r = close(s);
    } while (r < 0 && errno == EINTR);
    
    return success;
}

static int net_has_ip_v6(){
    static const struct sockaddr_in6 s_in6_t = {
        .sin6_len = sizeof(sockaddr_in6),
        .sin6_family = AF_INET6,
        .sin6_port = htons(0xFFFF),
        .sin6_addr.s6_addr = {0, 0x64, 0xFF, 0x9B, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    };
    
    net_sockaddr ns = {.s_in6 = s_in6_t};
    return net_test_connect(PF_INET6, &ns.s, sizeof(ns.s_in6));
}

static int net_has_ip_v4(){
    static const struct sockaddr_in s_in4_t = {
        .sin_len = sizeof(sockaddr_in),
        .sin_family = AF_INET,
        .sin_port = htons(0xFFFF),
        .sin_addr.s_addr = htonl(0x08080808L) // 8.8.8.8
    };
    
    net_sockaddr ns = {.s_in = s_in4_t};
    return net_test_connect(PF_INET, &ns.s, sizeof(ns.s_in));
}

class net_cs_sockaddr{
public:
    net_sockaddr ns;
    
    net_cs_sockaddr(sockaddr_in s_in) {
        ns.s_in = s_in;
    }
    
    net_cs_sockaddr(sockaddr_in6 s_in6) {
        ns.s_in6 = s_in6;
    }
    
    sockaddr s_addr() {
        return ns.s;
    }
};

void netgetdnssvraddrs(std::vector<net_cs_sockaddr> addrs){
    struct __res_state stat = {0};
    res_ninit(&stat);
    union res_sockaddr_union _addrs[MAXNS] = {0};
    int count = res_getservers(const_cast<res_state>(&stat), _addrs, MAXNS);
    for(int i = 0; i < count; ++ i){
        if(AF_INET == _addrs[i].sin.sin_family){
            addrs.push_back(net_cs_sockaddr(_addrs[i].sin));
        }else if(AF_INET6 == _addrs[i].sin.sin_family) {
            addrs.push_back(net_cs_sockaddr(_addrs[i].sin6));
        }
    }
    
    res_ndestroy(&stat);
}

int net_ipstack_get(){
    in6_addr v6 = {0};
    if(net_gateway_addr_v6_get(&v6) != CX_NET_OK || IN6_IS_ADDR_UNSPECIFIED(&v6)){
        return CX_NET_IPSTACK_IPV4;
    }
    
    in_addr v4 = {0};
    if(net_gateway_addr_v4_get(&v4) != CX_NET_OK || INADDR_NONE == v4.s_addr || INADDR_ANY == v4.s_addr){
        return CX_NET_IPSTACK_IPV6;
    }
    
    int type = 0;
    if(net_has_ip_v4()){
        type |= CX_NET_IPSTACK_IPV4;
    }
    
    if(net_has_ip_v6()){
        type |= CX_NET_IPSTACK_IPV6;
    }
    
    if(type != CX_NET_IPSTACK_DUAL){
        return type;
    }
    
    std::vector<net_cs_sockaddr> addrs;
    netgetdnssvraddrs(addrs);
    
    int dns_type = 0;
    for(int i = 0; i < addrs.size(); ++ i){
        if(AF_INET == addrs[i].s_addr().sa_family){
            dns_type |= CX_NET_IPSTACK_IPV4;
        }else if(AF_INET6 == addrs[i].s_addr().sa_family){
            dns_type |= CX_NET_IPSTACK_IPV6;
        }
    }
    
    return (dns_type != CX_NET_IPSTACK_NONE ? dns_type : type);
}

char *net_addr_get_t(int type){
    struct net_sockaddr_in ns_in = {0};
    if(type == CX_NET_IPSTACK_IPV6){
        struct in6_addr v6 = {0};
        if(net_ip_addr_v6_get(&v6) == CX_NET_OK && !IN6_IS_ADDR_UNSPECIFIED(&v6)){
            ns_in.family = AF_INET6;
            ns_in.addr = &v6;
            ns_in.len = INET6_ADDRSTRLEN;
        }
    }else{
        struct in_addr v4 = {0};
        if(net_ip_addr_v4_get(&v4) == CX_NET_OK){
            ns_in.family = AF_INET;
            ns_in.addr = &v4;
            ns_in.len = INET_ADDRSTRLEN;
        }
    }
    
    if(ns_in.addr){
        char *out_addr = (char *)malloc(ns_in.len);
        if(out_addr == NULL){
            return NULL;
        }
        
        if(inet_ntop(ns_in.family, ns_in.addr, out_addr, ns_in.len) != NULL){
            return out_addr;
        }
        
        free(out_addr);
    }
    
    return NULL;
}

char *net_gateway_addr_get_t(int type){
    struct net_sockaddr_in ns_in = {0};
    if(type == CX_NET_IPSTACK_IPV6){
        struct in6_addr v6 = {0};
        if(net_gateway_addr_v6_get(&v6) == CX_NET_OK && !IN6_IS_ADDR_UNSPECIFIED(&v6)){
            ns_in.family = AF_INET6;
            ns_in.addr = &v6;
            ns_in.len = INET6_ADDRSTRLEN;
        }
    }else{
        struct in_addr v4 = {0};
        if(net_gateway_addr_v4_get(&v4) == CX_NET_OK){
            ns_in.family = AF_INET;
            ns_in.addr = &v4;
            ns_in.len = INET_ADDRSTRLEN;
        }
    }
    
    if(ns_in.addr){
        char *out_addr = (char *)malloc(ns_in.len);
        if(out_addr == NULL){
            return NULL;
        }
        
        if(inet_ntop(ns_in.family, ns_in.addr, out_addr, ns_in.len) != NULL){
            return out_addr;
        }
        
        free(out_addr);
    }
    
    return NULL;
}

char *net_addr_get(){
    int type = net_ipstack_get();
    return net_addr_get_t(type);
}

char *net_gateway_addr(){
    int type = net_ipstack_get();
    return net_gateway_addr_get_t(type);
}
