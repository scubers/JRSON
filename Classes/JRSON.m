//
//  JRSON.m
//  JRSON
//
//  Created by 王俊仁 on 2017/3/23.
//  Copyright © 2017年 jrwong. All rights reserved.
//

#import "JRSON.h"
#import <objc/runtime.h>
#import "JRSONDefaultTransformer.h"
#import "JRSONDefaultImplementations.h"
@import MethodCopyer;

@interface JRSON ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, id<JRSONTransformer>> *transformers;

@property (nonatomic, strong) id<JRSONTransformer> defaultTransformer;

@end

@implementation JRSON

+ (void)load {
    [JRSON shared];
}

static id __instance;
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [super allocWithZone:zone];
    });
    return __instance;
}

+ (instancetype)shared {
    if (__instance) return __instance;
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    _defaultTransformer = [JRSONDefaultTransformer new];
    
    [MethodCopyer copyMethods:@[
                                NSStringFromSelector(@selector(jrsn_jsonString)),
                                NSStringFromSelector(@selector(jrsn_objectFromJSON:)),
                                NSStringFromSelector(@selector(jrsn_copy)),
                                ]
                 fromProtocol:@protocol(JRSON)
                    fromClass:[JRSNDefaultImp class]
                      toClass:[NSObject class]];
}

+ (NSString *)parseObjToJSON:(id)obj {
    return [[JRSON shared] parseObjToJSON:obj];
}

- (NSString *)parseObjToJSON:(id)obj {
    id<JRSONTransformer> transformer = self.transformers[NSStringFromClass([obj class])];
    if (transformer) {
        return [transformer jrsn_serializeObj:obj];
    }

    if ([_defaultTransformer jrsn_canHandleWithClass:[obj class]]
        || [obj conformsToProtocol:@protocol(JRSON)]
        ) {
        return [_defaultTransformer jrsn_serializeObj:obj];
    }
    return nil;
}

+ (id<JRSON>)formatJSON:(id<JRSONValuable>)json withClass:(Class<JRSON>)aClass {
    return [[JRSON shared] formatJSON:json withClass:aClass];
}

- (id<JRSON>)formatJSON:(id<JRSONValuable>)json withClass:(Class<JRSON>)aClass {
    id<JRSONTransformer> transformer = self.transformers[NSStringFromClass(aClass)];
    if (transformer) {
        return [transformer jrsn_deserializeJson:json withClass:aClass];
    }

    if ([_defaultTransformer jrsn_canHandleWithClass:aClass]
        || class_conformsToProtocol(aClass, @protocol(JRSON))
        ) {
        return [_defaultTransformer jrsn_deserializeJson:json withClass:aClass];
    }
    return nil;
}

+ (void)setTransformer:(id<JRSONTransformer>)transformer forClass:(Class)aClass {
    [[JRSON shared] setTransformer:transformer forClass:aClass];
}

- (void)setTransformer:(id<JRSONTransformer>)transformer forClass:(Class)aClass {
    if (!transformer) {
        [self.transformers removeObjectForKey:NSStringFromClass(aClass)];
    }
    self.transformers[NSStringFromClass(aClass)] = transformer;
}

#pragma mark getter setter

- (NSMutableDictionary<NSString *, id<JRSONTransformer>> *)transformers {
    if (!_transformers) {
        _transformers = [[NSMutableDictionary<NSString *, id<JRSONTransformer>> alloc] init];
    }
    return _transformers;
}

@end

//////////////////////////////////////////////////////////////////////////////////////////////////






