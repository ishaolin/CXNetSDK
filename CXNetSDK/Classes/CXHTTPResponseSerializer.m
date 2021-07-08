//
//  CXHTTPResponseSerializer.m
//  Pods
//
//  Created by wshaolin on 2019/8/4.
//

#import "CXHTTPResponseSerializer.h"

@interface CXHTTPResponseSerializer () {
    NSData *_emptyData;
}

@end

@implementation CXHTTPResponseSerializer

- (instancetype)init{
    if(self = [super init]){
        _emptyData = [NSData dataWithBytes:" " length:1];
        self.acceptableContentTypes = [NSSet setWithObjects:@"application/json",
                                       @"text/json",
                                       @"text/javascript",
                                       @"text/plain", nil];
    }
    
    return self;
}

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing  _Nullable *)error{
    if ([self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        return [self ignoreEmptyFromRawData:data];
    }
    
    if(!error || [self errorOrUnderlyingError:*error
                                      hasCode:NSURLErrorCannotDecodeContentData
                                     inDomain:AFURLResponseSerializationErrorDomain]){
        return nil;
    }
    
    return [self ignoreEmptyFromRawData:data];
}

- (BOOL)errorOrUnderlyingError:(NSError *)error hasCode:(NSInteger)code inDomain:(NSString *)domain{
    if(error.code == code && [error.domain isEqualToString:domain]){
        return YES;
    }else if(error.userInfo[NSUnderlyingErrorKey]){
        return [self errorOrUnderlyingError:error.userInfo[NSUnderlyingErrorKey]
                                    hasCode:code
                                   inDomain:domain];
    }
    
    return NO;
}

- (NSData *)ignoreEmptyFromRawData:(NSData *)rawData{
    if(!rawData || rawData.length == 0){
        return nil;
    }
    
    if(rawData.length == 1 && [rawData isEqualToData:_emptyData]){
        return nil;
    }
    
    return rawData;
}

@end
