//
//  CXNetworkManager.h
//  Pods
//
//  Created by wshaolin on 2017/5/16.
//
//

#import <Foundation/Foundation.h>

#define CX_WIFI_SSID    @"SSID"
#define CX_WIFI_BSSID   @"BSSID"

@interface CXNetworkManager : NSObject

@property (nonatomic, copy) NSString *sigKey; // 请求参数签名的key
@property (nonatomic, copy, readonly) NSString *hardwareDescription;
@property (nonatomic, copy, readonly) NSString *hardwareString;

@property (nonatomic, copy, readonly) NSString *ipAddr;
@property (nonatomic, copy, readonly) NSString *gatewayAddr;
@property (nonatomic, copy, readonly) NSString *macAddr;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, NSString *> *WiFiInfo;

+ (instancetype)sharedManager;

- (void)networkChanged;

@end
