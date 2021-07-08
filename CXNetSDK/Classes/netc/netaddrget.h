//
//  netaddrget.hpp
//  Pods
//
//  Created by wshaolin on 2017/6/5.
//
//

#ifndef netaddrget_h
#define netaddrget_h

#include <netinet/in.h>
#import "netipdefines.h"

int net_gateway_addr_v4_get(struct in_addr *addr_v4);
int net_gateway_addr_v6_get(struct in6_addr *addr_v6);

int net_ip_addr_v4_get(struct in_addr *addr_v4);
int net_ip_addr_v6_get(struct in6_addr *addr_v6);

#endif
