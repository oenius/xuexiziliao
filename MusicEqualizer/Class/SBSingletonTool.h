//
//  SBSingletonTool.h
//
//  Created by 何少博 on 16/12/23.
//  Copyright © 2016年 shaobo.He. All rights reserved.
//

#ifndef SBSingletonTool_h
#define SBSingletonTool_h

/*
 在.h文件中调用
 */

#define SBSingle_h(singletonMethodName) + (instancetype)default##singletonMethodName;

/*
 在.m文件中调用
 */
#if __has_feature(objc_arc) // 是ARC
#define SBSingle_m(singletonMethodName) \
static id _instace = nil; \
+ (id)allocWithZone:(struct _NSZone *)zone \
{ \
    if (_instace == nil) { \
        static dispatch_once_t onceToken; \
        dispatch_once(&onceToken, ^{ \
            _instace = [super allocWithZone:zone]; \
        }); \
    } \
    return _instace; \
} \
\
- (id)init \
{ \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        _instace = [super init]; \
    }); \
    return _instace; \
} \
\
+ (instancetype)default##singletonMethodName \
{ \
    return [[self alloc] init]; \
} \
+ (id)copyWithZone:(struct _NSZone *)zone \
{ \
    return _instace; \
} \
\
+ (id)mutableCopyWithZone:(struct _NSZone *)zone \
{ \
    return _instace; \
}

#else // 不是ARC

#define SBSingle_m(singletonMethodName) \
static id _instace = nil; \
+ (id)allocWithZone:(struct _NSZone *)zone \
{ \
    if (_instace == nil) { \
        static dispatch_once_t onceToken; \
        dispatch_once(&onceToken, ^{ \
            _instace = [super allocWithZone:zone]; \
        }); \
    } \
    return _instace; \
} \
\
- (id)init \
{ \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        _instace = [super init]; \
    }); \
    return _instace; \
} \
\
+ (instancetype)default##singletonMethodName \
{ \
    return [[self alloc] init]; \
} \
\
- (oneway void)release \
{ \
\
} \
\
- (id)retain \
{ \
    return self; \
} \
\
- (NSUInteger)retainCount \
{ \
    return 1; \
} \
+ (id)copyWithZone:(struct _NSZone *)zone \
{ \
    return _instace; \
} \
\
+ (id)mutableCopyWithZone:(struct _NSZone *)zone \
{ \
    return _instace; \
}
#endif

#endif /* SBSingletonTool_h */
