//
//  CXBaseModel.h
//  Pods
//
//  Created by wshaolin on 2017/5/16.
//
//

#import "CXNetDefines.h"
#import <YYModel/YYModel.h>

@interface CXBaseModel : NSObject

@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy) NSString *msg;

@property (nonatomic, assign, readonly) BOOL isValid;

@end

@interface NSObject (CXModel)

+ (instancetype)cx_modelWithData:(id)data;

- (NSData *)cx_modelToJSONData;

- (NSString *)cx_modelToJSONString;

- (NSString *)cx_modelDescription;

@end

CX_NET_EXTERN NSInteger const CXDataCodeSuccess;
