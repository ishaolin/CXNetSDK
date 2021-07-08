//
//  CXNetworkUtil.h
//  Pods
//
//  Created by wshaolin on 2017/6/2.
//
//

#import <Foundation/Foundation.h>

#define CX_WiFi_SSID    @"SSID"
#define CX_WiFi_BSSID   @"BSSID"

@interface CXNetworkUtil : NSObject

+ (NSString *)MACAddr;
+ (NSString *)IPAddr;
+ (NSString *)gatewayAddr;

+ (NSDictionary<NSString *, NSString *> *)WiFiInfo;

@end
