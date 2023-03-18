//
//  CXAddressUtils.h
//  Pods
//
//  Created by wshaolin on 2017/6/2.
//
//

#import <Foundation/Foundation.h>

@interface CXAddressUtils : NSObject

+ (NSString *)macAddress;
+ (NSString *)ipAddress;
+ (NSString *)gatewayAddress;

@end
