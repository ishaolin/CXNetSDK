//
//  CXNetworkManager.h
//  Pods
//
//  Created by wshaolin on 2017/5/16.
//
//

#import <Foundation/Foundation.h>

@interface CXNetworkManager : NSObject

@property (nonatomic, copy) NSString *sigKey;

+ (instancetype)sharedManager;

@end
