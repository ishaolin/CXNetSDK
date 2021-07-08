//
//  CXNetDefines.h
//  Pods
//
//  Created by wshaolin on 2019/2/12.
//

#ifndef CXNetDefines_h
#define CXNetDefines_h

#import <Foundation/Foundation.h>

#if defined(__cplusplus)
#define CX_NET_EXTERN   extern "C"
#else
#define CX_NET_EXTERN   extern
#endif

typedef NS_ENUM(NSInteger, CXNetEnvType) {
    CXNetEnvOL = 0, // 线上环境
    CXNetEnvQA = 1, // QA环境
    CXNetEnvRD = 2  // 开发环境
};

#endif /* CXNetDefines_h */
