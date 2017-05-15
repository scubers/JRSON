//
//  JRSONTransformerManager.m
//  JRSON
//
//  Created by 王俊仁 on 2017/5/13.
//  Copyright © 2017年 J. All rights reserved.
//

#import "JRSONTransformerManager.h"
#import "JRSONPropertyAnalyzing.h"
#import <objc/runtime.h>
#import "JRSONDefaultImplementations.h"
#import "JRSONStringTransformer.h"
#import "JRSONNumberTransformer.h"
#import "JRSONDateTransformer.h"
#import "JRSONURLTransformer.h"

@interface JRSONTransformerManager ()

@property (nonatomic, strong) NSMutableArray<id<JRSONTransformer>> *transformers;

@property (nonatomic, strong) NSMutableDictionary<NSString *, id<JRSONTransformer>> *cachedTransformers;

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
        _transformers = @[
                          [JRSONStringTransformer new],
                          [JRSONNumberTransformer new],
                          [JRSONDateTransformer new],
                          [JRSONURLTransformer new],
                          ].mutableCopy;
        _cachedTransformers = [[NSMutableDictionary<NSString *, id<JRSONTransformer>> alloc] init];
    }
    return self;
}

- (void)addTransformer:(id<JRSONTransformer>)transformer {
    [_transformers addObject:transformer];
}

- (void)removeTransformer:(Class<JRSONTransformer>)transformer {
    [_transformers enumerateObjectsUsingBlock:^(id<JRSONTransformer>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:transformer]) {
            [_transformers removeObject:obj];
        }
    }];

    [[_cachedTransformers allKeys] enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([_cachedTransformers[key] isKindOfClass:transformer]) {
            [_cachedTransformers removeObjectForKey:key];
        }
    }];

}

- (id<JRSONValuable>)jsonValueFromObj:(id<JRSON>)obj {

    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *array = [NSMutableArray array];
        [((NSArray *)obj) enumerateObjectsUsingBlock:^(id  _Nonnull element, NSUInteger idx, BOOL * _Nonnull stop) {
            id value = [self jsonValueFromObj:element];
            if (value) {
                [array addObject:value];
            }
        }];
        return array;
    } else {

        id<JRSONTransformer> transformer = [self _getTransformerForClass:[obj class]];
        if (transformer) {
            return [transformer jrsn_serializeObj:obj];
        }

        if (![obj conformsToProtocol:@protocol(JRSON)]) {
            return nil;
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

}

- (id<JRSON>)objFromJSONValue:(id<JRSONValuable>)jsonValue class:(Class<JRSON>)aClass {

    if ([jsonValue jrsn_valuableType] == JRSONValuableTypeArray) {

        NSMutableArray *array = [NSMutableArray array];
        [((NSArray *)jsonValue) enumerateObjectsUsingBlock:^(id  _Nonnull element, NSUInteger idx, BOOL * _Nonnull stop) {
            id value = [self objFromJSONValue:element class:aClass];
            if (value) {
                [array addObject:value];
            }
        }];
        return array;

    } else {

        id<JRSONTransformer> transformer = [self _getTransformerForClass:aClass];

        if (transformer) {
            return [transformer jrsn_deserializeJson:jsonValue withClass:aClass];
        }

        if (!class_conformsToProtocol(aClass, @protocol(JRSON))) {
            return nil;
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
                        [targetObj setValue:[self objFromJSONValue:subValue class:obj.arrayClass] forKey:obj.name];
                    }
                    else if (obj.type == JRSONPropertyTypeDictionary) {
                        NSAssert([subValue isKindOfClass:[NSDictionary class]], @"%@ is not a dictionry", subValue);
                        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];

                        [((NSDictionary *)subValue) enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull element, BOOL * _Nonnull stop) {
                            id value = [self objFromJSONValue:element class:obj.dictClass];
                            if (value) {
                                dictionary[key] = value;
                            }
                        }];
                        if (dictionary.count) {
                            [targetObj setValue:dictionary forKey:obj.name];
                        }
                    }
                    else {
                        [targetObj setValue:[self objFromJSONValue:subValue class:obj.targetClass] forKey:obj.name];
                    }
                }
                
            } @catch (NSException *exception) {
                NSLog(@"%@", exception);
            }
            
        }];
        
        return targetObj;
            
    }
}


#pragma mark private

- (id<JRSONTransformer>)_getTransformerForClass:(Class<JRSON>)aClass {
    NSString *key = NSStringFromClass(aClass);
    __block id<JRSONTransformer> transformer = [self cachedTransformers][key];
    if (!transformer) {
        [self.transformers enumerateObjectsUsingBlock:^(id<JRSONTransformer>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj jrsn_canHandleWithClass:aClass]) {
                transformer = obj;
                self.cachedTransformers[key] = obj;
                *stop = YES;
            }
        }];
    }
    return transformer;

}

- (BOOL)objShouldBeIgnore:(id)obj {
    BOOL flag1 = object_isClass(obj);
    return flag1 || obj == nil;
}

@end








