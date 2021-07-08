//
//  CXSignUtil.h
//  Pods
//
//  Created by wshaolin on 2017/5/16.
//
//

#import <Foundation/Foundation.h>

@interface CXSignUtil : NSObject

+ (NSString *)signWithDictionary:(NSDictionary<NSString *, id> *)dictionary;
+ (NSString *)signWithDictionary:(NSDictionary<NSString *, id> *)dictionary
                      privateKey:(NSString *)privateKey;
+ (NSString *)signWithDictionary:(NSDictionary<NSString *, id> *)dictionary
                      ignoreKeys:(NSArray<NSString *> *)ignoreKeys;
+ (NSString *)signWithDictionary:(NSDictionary<NSString *, id> *)dictionary
                      ignoreKeys:(NSArray<NSString *> *)ignoreKeys
                      privateKey:(NSString *)privateKey;

+ (NSString *)signWithQueryItems:(NSArray<NSURLQueryItem *> *)queryItems;
+ (NSString *)signWithQueryItems:(NSArray<NSURLQueryItem *> *)queryItems
                      privateKey:(NSString *)privateKey;
+ (NSString *)signWithQueryItems:(NSArray<NSURLQueryItem *> *)queryItems
                      ignoreKeys:(NSArray<NSString *> *)ignoreKeys;
+ (NSString *)signWithQueryItems:(NSArray<NSURLQueryItem *> *)queryItems
                      ignoreKeys:(NSArray<NSString *> *)ignoreKeys
                      privateKey:(NSString *)privateKey;

@end
