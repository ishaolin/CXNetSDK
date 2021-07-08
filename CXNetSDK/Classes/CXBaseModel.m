//
//  CXBaseModel.m
//  Pods
//
//  Created by wshaolin on 2017/5/16.
//
//

#import "CXBaseModel.h"

@implementation CXBaseModel

- (BOOL)isValid{
    return self.code == CXDataCodeSuccess;
}

@end

@implementation NSObject (CXModel)

+ (instancetype)cx_modelWithData:(id)data {
    return [self yy_modelWithJSON:data];
}

- (NSData *)cx_modelToJSONData{
    return [self yy_modelToJSONData];
}

- (NSString *)cx_modelToJSONString{
    return [self yy_modelToJSONString];
}

- (NSString *)cx_modelDescription{
    return [self yy_modelDescription];
}

@end

NSInteger const CXDataCodeSuccess = 0;
