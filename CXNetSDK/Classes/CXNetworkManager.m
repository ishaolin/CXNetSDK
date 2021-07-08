//
//  CXNetworkManager.m
//  Pods
//
//  Created by wshaolin on 2017/5/16.
//
//

#import "CXNetworkManager.h"

@implementation CXNetworkManager

+ (instancetype)sharedManager{
    static CXNetworkManager *networkManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkManager = [[self alloc] init];
    });
    
    return networkManager;
}

@end
