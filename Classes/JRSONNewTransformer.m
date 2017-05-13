//
//  JRSONNewTransformer.m
//  JRSON
//
//  Created by 王俊仁 on 2017/5/12.
//  Copyright © 2017年 J. All rights reserved.
//

#import "JRSONNewTransformer.h"
#import "JRSON.h"
#import <objc/runtime.h>
#import "JRSONDefaultImplementations.h"
#import "JRSONPropertyAnalyzing.h"
#import "JRSONTransformerManager.h"

@implementation JRSONNewTransformer

- (BOOL)jrsn_canHandleWithClass:(Class)aClass {
    return
    jrsn__checkSubInherit(aClass, [NSString class])
    ||jrsn__checkSubInherit(aClass, [NSNumber class])
//    ||jrsn__checkSubInherit(aClass, [NSArray class])
//    ||jrsn__checkSubInherit(aClass, [NSDictionary class])
    ||jrsn__checkSubInherit(aClass, [NSDate class])
    ||jrsn__checkSubInherit(aClass, [NSURL class])
    ||jrsn__checkSubInherit(aClass, [NSData class])
    ;
}

/////////////////////////////序列化////////////////////////////////////////////

- (NSString *)jrsn_serializeObj:(id)obj {
    id value = [self _jrsn_objToFoundationObj:obj];
    return value;
}

- (id)_jrsn_objToFoundationObj:(id)obj {

//    if ([obj isKindOfClass:[NSArray class]]) {
//
//        NSMutableArray *arr = [NSMutableArray array];
//        [((NSArray *)obj) enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            id newValue = [self _jrsn_objToFoundationObj:obj];
//            if (newValue) {
//                [arr addObject:newValue];
//            }
//        }];
//        return arr;
//
//    }
//    else if ([obj isKindOfClass:[NSDictionary class]]) {
//
//        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
//        [((NSDictionary *)obj) enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull value, BOOL * _Nonnull stop) {
//            dict[[self _jrsn_objToFoundationObj:key]] = [self _jrsn_objToFoundationObj:value];
//        }];
//        return dict;
//
//    }
//    else
    if ([obj isKindOfClass:[NSDate class]]) {
        return [@([((NSDate *)obj) timeIntervalSince1970] * 1000.0) description];
    }
    else if ([obj isKindOfClass:[NSURL class]]) {
        return ((NSURL *)obj).absoluteString;
    }
    else if ([obj isKindOfClass:[NSData class]]) {
        return [self _dataToString:obj];
    }
    else if ([obj isKindOfClass:[NSString class]]) {
        return obj;
    }
    else if ([obj isKindOfClass:[NSNumber class]]) {
        return obj;
    }

    return nil;
}

- (NSString *)_dataToString:(NSData *)data {
    NSAssert([data isKindOfClass:[NSData class]], @"本处理器只处理【NSData】");
    if ([data length] > 1024 * 1024) {
        NSLog(@"序列化Data已经超过 1M；建议减少体积，或者忽略该字段 @see +[jrsn_ignoreProperties]");
    }
    return [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

/////////////////////////////反序列化//////////////////////////////////////////

- (id<JRSON>)jrsn_deserializeJson:(id<JRSONValuable>)json withClass:(Class<JRSON>)aClass {

//    NSError *error;
//    id jsonObj = [NSJSONSerialization JSONObjectWithData:[((NSString *)json) dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:&error];
//
//    if (error) {
//        NSLog(@"%@", error);
//        return nil;
//    }

    return [self _jrsn_deserialize:json class:aClass];
}



- (id<JRSON>)_jrsn_deserialize:(id)obj class:(Class<JRSON>)aClass {

    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *arr = [NSMutableArray array];
        [((NSArray *)obj) enumerateObjectsUsingBlock:^(id  _Nonnull element, NSUInteger idx, BOOL * _Nonnull stop) {
            id value = [self _jrsn_deserialize:element class:aClass];
            if (value) {
                [arr addObject:value];
            }
        }];
        return arr;
    }
    else if (
             [obj isKindOfClass:[NSString class]]
             ||
             [obj isKindOfClass:[NSNumber class]]
             ) {
        if (jrsn__checkSubInherit(aClass, [NSString class])) {
            return [obj description];
        }
        else if (jrsn__checkSubInherit(aClass, [NSNumber class])) {
            NSAssert([obj isKindOfClass:[NSNumber class]], @"%@ is not a number", obj);
            return obj;
        }
        else if (jrsn__checkSubInherit(aClass, [NSURL class])) {
            NSAssert([obj isKindOfClass:[NSString class]], @"%@ is not a string", obj);
            NSURL *url = [NSURL URLWithString:obj];
            return url;
        }
        else if (jrsn__checkSubInherit(aClass, [NSDate class])) {
            if ([obj isKindOfClass:[NSString class]]) {
                return [NSDate dateWithTimeIntervalSince1970:[((NSString *)obj) doubleValue] / 1000.0];
            } else if ([obj isKindOfClass:[NSNumber class]]) {
                return [NSDate dateWithTimeIntervalSince1970:[((NSNumber *)obj) doubleValue] / 1000.0];
            } else {
                return nil;
            }
        }
        else if (jrsn__checkSubInherit(aClass, [NSData class])) {
            NSAssert([obj isKindOfClass:[NSString class]], @"%@ is not a string", obj);
            return [[NSData alloc] initWithBase64EncodedString:obj
                                                       options:NSDataBase64DecodingIgnoreUnknownCharacters];
        }
    }
    else {
        return [[JRSONTransformerManager shared] objFromJSONValue:obj class:aClass];

//        // 可以自定义反序列化
//        if ([JRSON _canCustomFormatClass:aClass]) {
//            return [JRSON formatJSON:obj class:aClass];
//        }
//
//        else {
//            NSDictionary *dict = (NSDictionary *)obj;
//            Class targetClass = aClass;
//
//            // 创建一个对象
//            id targetObj = [[targetClass alloc] init];
//
//            NSArray<JRSONPropertyInfo *> *infos = [[JRSONPropertyAnalyzing shared] analyzeClass:targetClass];
//
//            [infos enumerateObjectsUsingBlock:^(JRSONPropertyInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                // 在jsonvalue中获取对应的值
//                id<JRSONValuable> subValue = dict[obj.name];
//
//                @try {
//                    if (subValue) {
//                        if (obj.type == JRSONPropertyTypeArray) {
//                            NSAssert([subValue isKindOfClass:[NSArray class]], @"%@ is not a array", subValue);
////                            NSMutableArray *array = [NSMutableArray array];
////
////                            [((NSArray *)subValue) enumerateObjectsUsingBlock:^(id  _Nonnull element, NSUInteger idx, BOOL * _Nonnull stop) {
////                                id value = [self _jrsn_deserialize:element class:obj.arrayClass];
////                                if (value) {
////                                    [array addObject:value];
////                                }
////                            }];
//
//                            [targetObj setValue:[self _jrsn_deserialize:subValue class:obj.arrayClass] forKey:obj.name];
//                        }
//                        else if (obj.type == JRSONPropertyTypeDictionary) {
//                            NSAssert([subValue isKindOfClass:[NSDictionary class]], @"%@ is not a dictionry", subValue);
//                            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
//
//                            [((NSDictionary *)subValue) enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull element, BOOL * _Nonnull stop) {
//                                id value = [self _jrsn_deserialize:element class:obj.dictClass];
//                                if (value) {
//                                    dictionary[key] = value;
//                                }
//                            }];
//
//                            [targetObj setValue:dictionary forKey:obj.name];
//                        }
//                        else {
//                            [targetObj setValue:[self _jrsn_deserialize:subValue class:obj.targetClass] forKey:obj.name];
//                        }
//                    }
//
//                } @catch (NSException *exception) {
//                    NSLog(@"%@", exception);
//                }
//
//            }];
//            
//            return targetObj;
//        }

    }

    return nil;
}

//////////////////////////////私有////////////////////////////////////////////

- (BOOL)objShouldBeIgnore:(id)obj {
    BOOL flag1 = object_isClass(obj);
    return flag1 || obj == nil;
}

@end
