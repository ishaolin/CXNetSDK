//
//  UIDevice+CXNetSDKExtensions.h
//  Pods
//
//  Created by wshaolin on 2017/6/2.
//
//

#import <UIKit/UIKit.h>

@interface UIDevice (CXNetSDKExtensions)

@property (nonatomic, copy, readonly) NSString *cx_hardwareDescription;
@property (nonatomic, copy, readonly) NSString *cx_hardwareString;

- (NSString *)cx_IPAddr;
- (NSString *)cx_gatewayAddr;
- (NSString *)cx_MACAddr;

- (NSDictionary<NSString *, NSString *> *)cx_WiFiInfo;

- (void)cx_syncIPStack;

@end
