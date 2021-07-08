//
//  CXSignUtil.m
//  Pods
//
//  Created by wshaolin on 2017/5/16.
//
//

#import "CXSignUtil.h"
#import "CXNetworkManager.h"
#import <CXFoundation/CXFoundation.h>

@implementation CXSignUtil

+ (NSString *)signWithDictionary:(NSDictionary<NSString *, id> *)dictionary{
    return [self signWithDictionary:dictionary
                         privateKey:[CXNetworkManager sharedManager].sigKey];
}

+ (NSString *)signWithDictionary:(NSDictionary<NSString *,id> *)dictionary
                      privateKey:(NSString *)privateKey{
    return [self signWithDictionary:dictionary
                         ignoreKeys:nil
                         privateKey:privateKey];
}

+ (NSString *)signWithDictionary:(NSDictionary<NSString *,id> *)dictionary ignoreKeys:(NSArray<NSString *> *)ignoreKeys{
    return [self signWithDictionary:dictionary
                         ignoreKeys:ignoreKeys
                         privateKey:[CXNetworkManager sharedManager].sigKey];
}

+ (NSString *)signWithDictionary:(NSDictionary<NSString *, id> *)dictionary
                      ignoreKeys:(NSArray<NSString *> *)ignoreKeys
                      privateKey:(NSString *)privateKey{
    NSArray<NSString *> *allKeys = [dictionary allKeys];
    // 排序
    allKeys = [allKeys sortedArrayUsingComparator:^NSComparisonResult(NSString *key1, NSString *key2){
        return [key1 compare:key2];
    }];
    
    NSMutableString *signString = [NSMutableString string];
    for(NSString *key in allKeys){
        if([ignoreKeys containsObject:key]){
            continue;
        }
        
        NSString *value = [NSString stringWithFormat:@"%@", dictionary[key]].stringByRemovingPercentEncoding;
        if(CXStringIsEmpty(value)){
            continue;
        }
        
        [signString appendFormat:@"%@=%@&", key, value];
    }
    
    return [self signWithString:signString privateKey:privateKey];
}

+ (NSString *)signWithQueryItems:(NSArray<NSURLQueryItem *> *)queryItems{
    return [self signWithQueryItems:queryItems
                         privateKey:[CXNetworkManager sharedManager].sigKey];
}


+ (NSString *)signWithQueryItems:(NSArray<NSURLQueryItem *> *)queryItems privateKey:(NSString *)privateKey{
    return [self signWithQueryItems:queryItems
                         ignoreKeys:nil
                         privateKey:privateKey];
}

+ (NSString *)signWithQueryItems:(NSArray<NSURLQueryItem *> *)queryItems
                      ignoreKeys:(NSArray<NSString *> *)ignoreKeys{
    return [self signWithQueryItems:queryItems
                         ignoreKeys:ignoreKeys
                         privateKey:[CXNetworkManager sharedManager].sigKey];
}

+ (NSString *)signWithQueryItems:(NSArray<NSURLQueryItem *> *)queryItems
                      ignoreKeys:(NSArray<NSString *> *)ignoreKeys
                      privateKey:(NSString *)privateKey{
    NSArray<NSURLQueryItem *> *items = [queryItems sortedArrayUsingComparator:^NSComparisonResult(NSURLQueryItem * _Nonnull obj1, NSURLQueryItem * _Nonnull obj2) {
        return [obj1.name compare:obj2.name];
    }];
    
    NSMutableString *signString = [NSMutableString string];
    [items enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if([ignoreKeys containsObject:obj.name]){
            return;
        }
        
        NSString *value = obj.value.stringByRemovingPercentEncoding;
        if(CXStringIsEmpty(value)){
            return;
        }
        
        [signString appendFormat:@"%@=%@&", obj.name, value];
    }];
    
    return [self signWithString:signString privateKey:privateKey];
}

+ (NSString *)signWithString:(NSString *)signString privateKey:(NSString *)privateKey{
    NSString *signText = signString;
    if(privateKey){
        NSString *key = [CXUCryptor SHA1:privateKey];
        signText = [signString stringByAppendingFormat:@"key=%@", key];
    }
    
    return [CXUCryptor SHA1:signText];
}

@end
