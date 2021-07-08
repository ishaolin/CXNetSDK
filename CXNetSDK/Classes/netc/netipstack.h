//
//  netipstack.hpp
//  Pods
//
//  Created by wshaolin on 2017/6/5.
//
//

#ifndef netipstack_h
#define netipstack_h

#include "netipdefines.h"

int net_ipstack_get();

/// Needs free the return value if not NULL. Param type source is `net_ipstack_get()`. Value defined in `netipdefines.h`
char *net_addr_get_t(int type);
char *net_gateway_addr_get_t(int type);

/// Needs free the return value if not NULL.
char *net_addr_get();
char *net_gateway_addr();

#endif
