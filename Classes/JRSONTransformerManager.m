//
//  JRSONTransformerManager.m
//  JRSON
//
//  Created by 王俊仁 on 2017/5/13.
//  Copyright © 2017年 J. All rights reserved.
//

#import "JRSONTransformerManager.h"
#import "JRSONNewTransformer.h"
#import "JRSONPropertyAnalyzing.h"
#import <objc/runtime.h>
#import "JRSONDefaultImplementations.h"

@interface JRSONTransformerManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, id<JRSONTransformer>> *transformers;

@end

@implementation JRSONTransformerManager

static id __INSTANCE;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __INSTANCE = [super allocWithZone:zone];
    });
    return __INSTANCE;
}

+ (instancetype)shared {
    if (__INSTANCE) return __INSTANCE;
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _transformers = [[NSMutableDictionary<NSString *, id<JRSONTransformer>> alloc] init];
        _defaultTransformer = [JRSONNewTransformer new];
    }
    return self;
}

- (void)setTransformer:(id<JRSONTransformer>)transformer forClass:(Class<JRSON>)aClass {
    if (!transformer) {
        [self removeTransformerForClass:aClass];
    } else {
        _transformers[NSStringFromClass(aClass)] = transformer;
    }
}

- (void)removeTransformerForClass:(Class<JRSON>)aClass {
    [_transformers removeObjectForKey:NSStringFromClass(aClass)];
}

- (id<JRSONValuable>)jsonValueFromObj:(id<JRSON>)obj {
    id<JRSONTransformer> transformer = self.transformers[NSStringFromClass([obj class])];
    if (transformer) {
        return [transformer jrsn_serializeObj:obj];
    }

    if ([_defaultTransformer jrsn_canHandleWithClass:[obj class]]) {
        return [_defaultTransformer jrsn_serializeObj:obj];
    }

    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray array];
        [((NSArray *)obj) enumerateObjectsUsingBlock:^(id  _Nonnull element, NSUInteger idx, BOOL * _Nonnull stop) {
            id value = [self jsonValueFromObj:element];
            if (value) {
                [array addObject:value];
            }
        }];
        return array;
    }
    else if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [((NSDictionary *)obj) enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull element, BOOL * _Nonnull stop) {
            id newKey = [self jsonValueFromObj:key];
            id value = [self jsonValueFromObj:element];
            if (value && newKey) {
                dict[newKey] = value;
            }
        }];
        return dict;
    }
    else {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        NSArray<JRSONPropertyInfo *> *infos = [[JRSONPropertyAnalyzing shared] analyzeClass:[obj class]];
        [infos enumerateObjectsUsingBlock:^(JRSONPropertyInfo * _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop) {

            @try {
                id value = [(NSObject *)obj valueForKey:info.name];
                if ([self objShouldBeIgnore:value]) return;

                id newValue = [self jsonValueFromObj:value];
                if (newValue) {
                    dict[info.name] = newValue;
                }
            } @catch (NSException *exception) {
                NSLog(@"%@", exception);
            }
            
        }];
        return dict;
    }
}

- (id<JRSON>)objFromJSONValue:(id<JRSONValuable>)jsonValue class:(Class<JRSON>)aClass {
    id<JRSONTransformer> transformer = self.transformers[NSStringFromClass(aClass)];
    if (transformer) {
        return [transformer jrsn_deserializeJson:jsonValue withClass:aClass];
    }

    NSDictionary *dict = (NSDictionary *)jsonValue;
    Class targetClass = aClass;

    // 创建一个对象
    id targetObj = [[targetClass alloc] init];

    NSArray<JRSONPropertyInfo *> *infos = [[JRSONPropertyAnalyzing shared] analyzeClass:targetClass];

    [infos enumerateObjectsUsingBlock:^(JRSONPropertyInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        // 在jsonvalue中获取对应的值
        id<JRSONValuable> subValue = dict[obj.name];

        @try {
            if (subValue) {
                if (obj.type == JRSONPropertyTypeArray) {
                    NSAssert([subValue isKindOfClass:[NSArray class]], @"%@ is not a array", subValue);
                    [_defaultTransformer jrsn_deserializeJson:subValue withClass:obj.arrayClass];
                }
                else if (obj.type == JRSONPropertyTypeDictionary) {
                    NSAssert([subValue isKindOfClass:[NSDictionary class]], @"%@ is not a dictionry", subValue);
                    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

                    [((NSDictionary *)subValue) enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull element, BOOL * _Nonnull stop) {
                        id value = [_defaultTransformer jrsn_deserializeJson:subValue withClass:obj.dictClass];
                        if (value) {
                            dictionary[key] = value;
                        }
                    }];

                    [targetObj setValue:dictionary forKey:obj.name];
                }
                else {
                    [targetObj setValue:[_defaultTransformer jrsn_deserializeJson:subValue withClass:obj.targetClass] forKey:obj.name];
                }
            }

        } @catch (NSException *exception) {
            NSLog(@"%@", exception);
        }

    }];

    return targetObj;

}

- (BOOL)objShouldBeIgnore:(id)obj {
    BOOL flag1 = object_isClass(obj);
    return flag1 || obj == nil;
}

@end
